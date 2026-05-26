@echo off
title Sari v1 - Micro-ERP Launcher
:: ==============================================================
:: Sari v1 - Micro-ERP Launcher
:: Mahi Kamel Abdelghani | Direction de l'Education El Bayadh
:: Updated: 2026-05-24
:: ==============================================================
:: Uses %~dp0 relative paths - copy project folder anywhere.
:: ==============================================================
:: Usage:
::   Sari_Launch         Interactive dashboard
::   Sari_Launch build   Build only
::   Sari_Launch scan    Scan for compile errors
:: ==============================================================

setlocal enabledelayedexpansion

set "SCRIPT_ROOT=%~dp0"
if "%SCRIPT_ROOT:~-1%"=="\" set "SCRIPT_ROOT=%SCRIPT_ROOT:~0,-1%"

set "SARI_ROOT=%SCRIPT_ROOT%\sari"
set "LAUNCHER_SCRIPT=%SARI_ROOT%\scripts\sari-launcher.ps1"

if not exist "%LAUNCHER_SCRIPT%" (
    echo [ERROR] sari-launcher.ps1 not found at:
    echo %LAUNCHER_SCRIPT%
    pause
    exit /b 1
)

set "MODE=%~1"

if /i "%MODE%"=="build" (
    echo [Sari] Building workbook...
    pwsh -NoProfile -Command "^& { Get-Process -Name excel -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep 2 }"
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SARI_ROOT%\build.ps1"
    if errorlevel 1 (
        echo [Sari] BUILD FAILED
    ) else (
        echo [Sari] BUILD OK
    )
    pause
    exit /b
)

if /i "%MODE%"=="scan" (
    echo [Sari] Scanning for VBA compile errors...
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SARI_ROOT%\tools\scan-vba.ps1"
    echo.
    pause
    exit /b
)

if /i "%MODE%"=="build-scan" (
    echo [Sari] Build + scan...
    pwsh -NoProfile -Command "^& { Get-Process -Name excel -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep 2 }"
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SARI_ROOT%\build.ps1"
    if errorlevel 1 (
        echo [Sari] BUILD FAILED
        pause
        exit /b
    )
    echo.
    echo [Sari] BUILD OK - scanning...
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SARI_ROOT%\tools\scan-vba.ps1"
    echo.
    pause
    exit /b
)

:: Default: interactive dashboard
title Sari v1 - Micro-ERP Dashboard
pwsh -NoExit -ExecutionPolicy Bypass -File "%LAUNCHER_SCRIPT%"
pause
