@echo off
title Academix v13.2 ^| Project Portal
:: ==============================================================
:: Academix v13.2 — Quick Launch Portal
:: Delegates to the Master Launcher for consistency.
:: ==============================================================
echo.
echo  ===========================================
echo    Academix v13.2 — Project Portal
echo  ===========================================
echo.
echo  Launching Interactive Dashboard...
echo.

set "MASTER_BAT=%~dp0OpenCode.bat"
if exist "%MASTER_BAT%" (
    call "%MASTER_BAT%" academix
) else (
    echo [ERROR] Master launcher OpenCode.bat not found in:
    echo %MASTER_BAT%
    pause
    exit /b 1
)

echo.
echo Session ended.
pause
