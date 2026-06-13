@echo off
title Claude Code + Enhanced FCC Proxy
setlocal enabledelayedexpansion

set "FCC_DIR=%USERPROFILE%\.opencode\plugins\fcc-proxy"
set "FCC_PORT=8082"

echo ========================================
echo   Claude Code via Enhanced FCC Proxy
echo   Primary:  Claude Fable 5 (Best Model)
echo   Fallback: DeepSeek V4-Pro (Best Value)
echo   Free:     Qwen3-235B (Open Source)
echo ========================================
echo.
echo   Quality Index: 100/100 (Fable 5)
echo   Context: 1M tokens
echo   Speed: 58 t/s
echo.

:: Check if proxy is running, start if not
powershell -Command "try { Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo   Starting enhanced proxy on port %FCC_PORT%...
    pushd "%FCC_DIR%"
    start "FCC Proxy Enhanced" cmd /c ".venv\Scripts\python.exe -m uvicorn server:app --host 0.0.0.0 --port %FCC_PORT% --timeout-graceful-shutdown 5"
    popd
    set "RETRIES=0"
    :retry
    set /a RETRIES+=1
    ping 127.0.0.1 -n 4 >nul
    powershell -Command "try { Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 3 | Out-Null; exit 0 } catch { exit 1 }"
    if errorlevel 1 (
        if !RETRIES! LSS 10 (
            echo   Waiting... (!RETRIES!/10)
            goto retry
        )
        echo   WARNING: Proxy may not have started.
    ) else (
        echo   Enhanced proxy is running.
    )
) else (
    echo   Enhanced proxy already running on port %FCC_PORT%.
)

:: Update .env with better model
echo.
echo   Configuring enhanced model...
echo.

:: Backup current .env
copy "%FCC_DIR%\.env" "%FCC_DIR%\.env.backup" /Y >nul

:: Update model configuration
(
echo # Enhanced Model Configuration
echo MODEL="open_router/anthropic/claude-fable-5"
echo # Fallback models
echo MODEL_OPUS=open_router/anthropic/claude-opus-4.8
echo MODEL_SONNET=open_router/anthropic/claude-fable-5
echo MODEL_HAIKU=open_router/deepseek/deepseek-v4-pro
echo.
echo # Free alternative models
echo # MODEL="open_router/qwen/qwen3-235b:free"
echo # MODEL="open_router/meta-llama/llama-4-maverick:free"
echo # MODEL="open_router/deepseek/deepseek-chat-v3:free"
) > "%FCC_DIR%\.env.model"

:: Merge configurations
powershell -Command "$env = Get-Content '%FCC_DIR%\.env' | Where-Object { $_ -notmatch '^MODEL' -and $_ -notmatch '^MODEL_OPUS' -and $_ -notmatch '^MODEL_SONNET' -and $_ -notmatch '^MODEL_HAIKU' }; $model = Get-Content '%FCC_DIR%\.env.model'; $env + $model | Set-Content '%FCC_DIR%\.env'"

echo   Model configured: Claude Fable 5 (100/100 quality)
echo.

:: Launch Claude Code with enhanced routing
echo.
echo   Launching Claude Code with enhanced model...
echo   Model: Claude Fable 5 (Best available, 1M context)
echo   Quality: 100/100 (Top of leaderboard)
echo   Speed: 58 t/s
echo.
echo   Once loaded, type:
echo     /oh-my-claudecode:omc-setup  - Setup OMC plugin
echo     /oh-my-claudecode:omc-doctor - Check OMC status
echo     /autopilot - Autonomous execution mode
echo.
set "ANTHROPIC_BASE_URL=http://localhost:%FCC_PORT%"
set "ANTHROPIC_AUTH_TOKEN=freecc"
claude