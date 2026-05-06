@echo off
title Academix v13.2 — Qwen Coder 1.5B Local (Offline)
echo.
echo ============================================
echo   ACADEMIX v13.2 — ERP Academie
echo   Direction de l'Education El Bayadh
echo   AI: Qwen2.5-Coder 1.5B (LOCAL, Ollama)
echo ============================================
echo.
echo [1/4] Checking Ollama service...
tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I /N "ollama.exe">NUL
if "%ERRORLEVEL%"=="1" (
    echo   Starting Ollama service...
    start "" /B ollama serve
    timeout /t 3 /nobreak >NUL
) else (
    echo   Ollama already running
)
echo.
echo [2/4] Verifying qwen2.5-coder:1.5b model...
for /f "delims=" %%a in ('ollama list 2^>NUL ^| find "qwen2.5-coder:1.5b"') do set MODEL_FOUND=1
if defined MODEL_FOUND (
    echo   Model found locally
) else (
    echo   Model NOT found — pulling now...
    ollama pull qwen2.5-coder:1.5b
)
echo.
echo [3/4] Checking project context files...
set "CTX=%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor\.opencode\context.md"
if exist "%CTX%" (
    echo   context.md found
) else (
    echo   WARNING: context.md missing
)
echo.
echo [4/4] Launching OpenCode with local model...
echo.
echo   NOTE: Local model loads from HDD (~60-108s first load)
echo   TIP: Type this at session start:
echo   ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
echo.
echo ============================================

REM Override OpenCode config for local model
set "LOCAL_CONFIG=%USERPROFILE%\AppData\Local\Temp\opencode_local_config.json"
echo {> "%LOCAL_CONFIG%"
echo   "$schema": "https://opencode.ai/config.schema.json",>> "%LOCAL_CONFIG%"
echo   "model": "ollama/qwen2.5-coder:1.5b",>> "%LOCAL_CONFIG%"
echo   "autoshare": false,>> "%LOCAL_CONFIG%"
echo   "theme": "opencode",>> "%LOCAL_CONFIG%"
echo   "provider": {>> "%LOCAL_CONFIG%"
echo     "ollama": {>> "%LOCAL_CONFIG%"
echo       "url": "http://localhost:11434/v1",>> "%LOCAL_CONFIG%"
echo       "options": {>> "%LOCAL_CONFIG%"
echo         "num_ctx": 4096>> "%LOCAL_CONFIG%"
echo       }>> "%LOCAL_CONFIG%"
echo     }>> "%LOCAL_CONFIG%"
echo   }>> "%LOCAL_CONFIG%"
echo }>> "%LOCAL_CONFIG%"

set "OPENCODE_CONFIG=%LOCAL_CONFIG%"
D:\software\opencode\opencode.exe

REM Cleanup temp config
del "%LOCAL_CONFIG%" 2>NUL

echo.
echo Ollama model still running in background.
echo To stop: ollama stop qwen2.5-coder:1.5b
echo Or: taskkill /F /IM ollama.exe
pause
