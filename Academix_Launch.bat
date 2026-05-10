@echo off
title Academix v13.2 ^| ERP Academie DSS ^| El Bayadh
:: Portable — uses %~dp0 relative paths
set "SCRIPT_ROOT=%~dp0"
set "PS1_PATH=%SCRIPT_ROOT%academix-launcher.ps1"
echo.
echo  ===========================================
echo    Academix v13.2 — Decision Support System
echo    Direction de l'Education, El Bayadh
echo    Mahi Kamel Abdelghani
echo  ===========================================
echo.
if not exist "%PS1_PATH%" (
    echo ERROR: academix-launcher.ps1 not found
    echo Expected: %PS1_PATH%
    pause
    exit /b 1
)
cd /d "%SCRIPT_ROOT%"
pwsh -NoExit -ExecutionPolicy Bypass -File "%PS1_PATH%"
echo.
echo  Session ended.
pause
