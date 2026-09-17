@echo off
setlocal
title Close all MATLAB processes

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Close-All-MATLAB.ps1"
set "cleanup_exit=%ERRORLEVEL%"

echo.
if "%cleanup_exit%"=="0" (
    echo MATLAB cleanup completed successfully.
) else if "%cleanup_exit%"=="1" (
    echo MATLAB cleanup was cancelled.
) else (
    echo MATLAB cleanup was incomplete. Review the log shown above.
)
echo.
pause
exit /b %cleanup_exit%
