@echo off
title Academix v13.2 ^| ERP Academie DSS ^| El Bayadh
:: Portable — uses %~dp0 relative paths
set "SCRIPT_ROOT=%~dp0"
set "PS1_PATH=%SCRIPT_ROOT%scripts\academix-launcher.ps1"
echo.
echo  ===========================================
echo    Academix v13.2 — Decision Support System
echo    Direction de l'Education, El Bayadh
echo    Mahi Kamel Abdelghani
echo  ===========================================
echo.
:: CrossFlow handoff check
if exist "%SCRIPT_ROOT%\.crossflow\HANDOFF.md" (
    echo [CrossFlow]
    findstr /b "|" "%SCRIPT_ROOT%\.crossflow\HANDOFF.md" | findstr "Last action Current phase Next step" >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%a in ('findstr "Last action" "%SCRIPT_ROOT%\.crossflow\HANDOFF.md"') do echo   %%a
        for /f "delims=" %%b in ('findstr "Current phase" "%SCRIPT_ROOT%\.crossflow\HANDOFF.md"') do echo   %%b
    )
    echo.
)
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
