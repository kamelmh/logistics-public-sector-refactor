@echo off
title Academix v13.2 ^| Qwen Coder 1.5B Local (Offline)
:: Legacy launcher — delegates to modern OpenCode.bat
echo.
echo ============================================
echo   ACADEMIX v13.2 — ERP Academie
echo   Direction de l'Education El Bayadh
echo ============================================
echo.
set "BAT=%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor\OpenCode.bat"
if exist "%BAT%" (
    call "%BAT%" qwen3
) else (
    echo [ERROR] OpenCode.bat not found.
    echo Falling back to direct launch...
    D:\software\opencode\opencode.exe --model ollama/qwen3:1.7b "%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor"
)
echo.
echo Session ended.
pause
