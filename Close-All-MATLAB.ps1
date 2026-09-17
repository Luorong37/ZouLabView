<#
.SYNOPSIS
    Close all MATLAB.exe processes on this workstation.

.DESCRIPTION
    Lists the exact MATLAB processes, asks for explicit confirmation, tries a
    normal window-close first, then force-stops only the previously identified
    MATLAB PIDs that remain. The action and final verification are written to
    Zoulabview\logs.

    This script does not call imaqreset and does not stop or reconfigure NI,
    Hamamatsu, or other hardware services.

.PARAMETER Yes
    Skip the interactive CLOSE confirmation. Intended for an already reviewed
    command-line invocation, not for routine double-click use.

.PARAMETER GraceSeconds
    Seconds allowed for a normal MATLAB window-close before remaining target
    PIDs are force-stopped. Default: 3.

.EXAMPLE
    .\Close-All-MATLAB.ps1

.EXAMPLE
    .\Close-All-MATLAB.ps1 -Yes -GraceSeconds 0
#>

[CmdletBinding()]
param(
    [switch]$Yes,
    [ValidateRange(0, 30)]
    [int]$GraceSeconds = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
} catch {
    # Output encoding is cosmetic; cleanup must still be usable.
}

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFolder = Join-Path $scriptFolder 'logs'
if (-not (Test-Path -LiteralPath $logFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
}
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$logPath = Join-Path $logFolder ("matlab_process_cleanup_{0}.log" -f $stamp)

function Write-CleanupEvent {
    param(
        [Parameter(Mandatory = $true)][string]$Level,
        [Parameter(Mandatory = $true)][string]$Event,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $oneLine = $Message -replace '[\r\n]+', ' '
    $line = '{0} | {1,-7} | {2,-32} | {3}' -f `
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), `
        $Level.ToUpperInvariant(), $Event, $oneLine
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    Write-Host $line
}

function Get-MatlabProcessInfo {
    try {
        $items = @(Get-CimInstance Win32_Process -ErrorAction Stop |
            Where-Object { $_.Name -ieq 'MATLAB.exe' })
        return @($items | ForEach-Object {
            [pscustomobject]@{
                ProcessId       = [int]$_.ProcessId
                ParentProcessId = [int]$_.ParentProcessId
                Created         = $_.CreationDate
                CommandLine     = [string]$_.CommandLine
                Discovery       = 'Win32_Process'
            }
        })
    } catch {
        Write-CleanupEvent -Level 'WARNING' `
            -Event 'PROCESS_COMMAND_LINE_UNAVAILABLE' `
            -Message ("CIM query failed; using Get-Process fallback. Error={0}" -f $_.Exception.Message)
        $items = @(Get-Process -Name MATLAB -ErrorAction SilentlyContinue)
        return @($items | ForEach-Object {
            [pscustomobject]@{
                ProcessId       = [int]$_.Id
                ParentProcessId = -1
                Created         = $_.StartTime
                CommandLine     = '<unavailable without Win32_Process access>'
                Discovery       = 'Get-Process fallback'
            }
        })
    }
}

Write-CleanupEvent -Level 'INFO' -Event 'MATLAB_CLEANUP_STARTED' `
    -Message ("RequestedBy={0}\{1} | GraceSeconds={2} | SkipConfirmation={3} | imaqreset=0 | NIServiceChanged=0" -f `
        $env:USERDOMAIN, $env:USERNAME, $GraceSeconds, [int]$Yes.IsPresent)

$targets = @(Get-MatlabProcessInfo)
if ($targets.Count -eq 0) {
    Write-CleanupEvent -Level 'SUCCESS' -Event 'NO_MATLAB_PROCESS_FOUND' `
        -Message 'No MATLAB.exe process is running. Nothing was changed.'
    Write-Host "Log: $logPath"
    exit 0
}

Write-Host ''
Write-Host 'The following MATLAB processes will be closed:' -ForegroundColor Yellow
$targets |
    Select-Object ProcessId, ParentProcessId, Created, CommandLine |
    Format-Table -AutoSize -Wrap
$targetSummary = ($targets | ForEach-Object {
    'PID={0},Parent={1},Created={2},Command={3}' -f `
        $_.ProcessId, $_.ParentProcessId, $_.Created, $_.CommandLine
}) -join ' || '
Write-CleanupEvent -Level 'INFO' -Event 'MATLAB_PROCESSES_IDENTIFIED' `
    -Message ("Count={0} | {1}" -f $targets.Count, $targetSummary)

if (-not $Yes.IsPresent) {
    Write-Host ''
    Write-Host 'WARNING: Unsaved work in every listed MATLAB process will be lost.' `
        -ForegroundColor Red
    Write-Host '警告：上面所有 MATLAB 进程中未保存的内容都可能丢失。' `
        -ForegroundColor Red
    $confirmation = Read-Host 'Type CLOSE to continue (输入 CLOSE 继续)'
    if ($confirmation -cne 'CLOSE') {
        Write-CleanupEvent -Level 'INFO' -Event 'MATLAB_CLEANUP_CANCELLED' `
            -Message ("Confirmation={0} | No process was stopped" -f $confirmation)
        Write-Host "Cancelled. Log: $logPath"
        exit 1
    }
}

$targetIds = @($targets.ProcessId | Sort-Object -Unique)
$normalCloseRequested = @()
foreach ($processId in $targetIds) {
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($null -eq $process -or $process.ProcessName -ine 'MATLAB') {
        continue
    }
    try {
        if ($process.MainWindowHandle -ne 0 -and $process.CloseMainWindow()) {
            $normalCloseRequested += $processId
            Write-CleanupEvent -Level 'INFO' -Event 'MATLAB_NORMAL_CLOSE_REQUESTED' `
                -Message ("PID={0}" -f $processId)
        }
    } catch {
        Write-CleanupEvent -Level 'WARNING' -Event 'MATLAB_NORMAL_CLOSE_FAILED' `
            -Message ("PID={0} | Error={1}" -f $processId, $_.Exception.Message)
    }
}

if ($normalCloseRequested.Count -gt 0 -and $GraceSeconds -gt 0) {
    $deadline = (Get-Date).AddSeconds($GraceSeconds)
    while ((Get-Date) -lt $deadline) {
        $stillRunning = @($targetIds | Where-Object {
            $candidate = Get-Process -Id $_ -ErrorAction SilentlyContinue
            $null -ne $candidate -and $candidate.ProcessName -ieq 'MATLAB'
        })
        if ($stillRunning.Count -eq 0) {
            break
        }
        Start-Sleep -Milliseconds 200
    }
}

$forceTargets = @()
foreach ($processId in $targetIds) {
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($null -ne $process -and $process.ProcessName -ieq 'MATLAB') {
        $forceTargets += $process
    }
}

if ($forceTargets.Count -gt 0) {
    # Child MATLAB processes are stopped before their listed parents.
    $knownParentIds = @($targets.ParentProcessId)
    $forceTargets = @($forceTargets | Sort-Object `
        @{ Expression = { [int]($knownParentIds -contains $_.Id) }; Descending = $false }, `
        Id -Descending)
    foreach ($process in $forceTargets) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            Write-CleanupEvent -Level 'SUCCESS' -Event 'MATLAB_PROCESS_FORCE_STOPPED' `
                -Message ("PID={0}" -f $process.Id)
        } catch {
            Write-CleanupEvent -Level 'ERROR' -Event 'MATLAB_PROCESS_STOP_FAILED' `
                -Message ("PID={0} | Error={1}" -f $process.Id, $_.Exception.Message)
        }
    }
}

Start-Sleep -Milliseconds 800
$remaining = @(Get-MatlabProcessInfo)
if ($remaining.Count -gt 0) {
    $remainingIds = ($remaining.ProcessId | Sort-Object -Unique) -join ','
    Write-CleanupEvent -Level 'ERROR' -Event 'MATLAB_CLEANUP_INCOMPLETE' `
        -Message ("RemainingCount={0} | RemainingPIDs={1} | Try Run as administrator" -f `
            $remaining.Count, $remainingIds)
    Write-Host "Cleanup incomplete. Log: $logPath" -ForegroundColor Red
    exit 2
}

Write-CleanupEvent -Level 'SUCCESS' -Event 'MATLAB_CLEANUP_COMPLETE' `
    -Message ("StoppedTargetCount={0} | RemainingMATLAB=0 | imaqreset=0 | NIServiceChanged=0" -f `
        $targets.Count)
Write-Host "All MATLAB processes are closed. Log: $logPath" -ForegroundColor Green
exit 0

