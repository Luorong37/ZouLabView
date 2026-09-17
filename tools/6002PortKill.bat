@echo off
setlocal enabledelayedexpansion

REM 查找占用端口6002的程序PID
for /f "tokens=4" %%a in ('netstat -ano ^| findstr "6002"') do (
    set "PID=%%a"
    goto :found
)

:found
if defined PID (
    echo find 6002 PID: %PID%
    
    REM 使用taskkill命令关闭程序
    taskkill /F /PID !PID!
    echo Succeed Close 6002 Port pid
) else (
    echo Not Find 6002 port pid
)

pause >nul
endlocal