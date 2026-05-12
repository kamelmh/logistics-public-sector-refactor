@echo off
title Academix v13.2 ^| Groq Cloud AI ^| El Bayadh
:: Legacy launcher — delegates to modern OpenCode.bat
echo.
echo ============================================
echo   ACADEMIX v13.2 — ERP Academie
echo   Direction de l'Education El Bayadh
echo ============================================
echo.
set "BAT=%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor\OpenCode.bat"
if exist "%BAT%" (
    call "%BAT%" groq
) else (
    echo [ERROR] OpenCode.bat not found at:
    echo %BAT%
    echo.
    echo Falling back to direct launch...
    D:\software\opencode\opencode.exe --model groq/llama-3.3-70b-versatile "%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor"
)
echo.
echo Session ended.
pause
