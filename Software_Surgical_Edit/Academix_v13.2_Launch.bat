@echo off
title Academix v13.2 — ERP Academie | Groq Cloud AI
echo.
echo ============================================
echo   ACADEMIX v13.2 — ERP Academie
echo   Direction de l'Education El Bayadh
echo   AI: Groq qwen/qwen3-32b (cloud, ~1s)
echo ============================================
echo.
echo [1/3] Checking Groq API key...
set "GROQ_KEY_FILE=%USERPROFILE%\Desktop\groq api key - LSM in public sector education.txt"
if exist "%GROQ_KEY_FILE%" (
    echo   ✓ Groq API key found
) else (
    echo   ✗ WARNING: Groq API key file not found
)
echo.
echo [2/3] Checking project context files...
set "CTX=%USERPROFILE%\Dropbox\Logistics.Public.Sector.Refactor\.opencode\context.md"
if exist "%CTX%" (
    echo   ✓ context.md loaded
) else (
    echo   ✗ WARNING: context.md missing
)
echo.
echo [3/4] Launching OpenCode with Groq model...
echo.
echo   TIP: Type this at session start:
echo   ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
echo.
echo ============================================
D:\software\opencode\opencode.exe
echo.
echo OpenCode closed.
pause
