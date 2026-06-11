@echo off
title Claude Code + Free Proxy
setlocal enabledelayedexpansion

set "FCC_DIR=%USERPROFILE%\.opencode\plugins\fcc-proxy"
set "FCC_PORT=8082"

echo ========================================
echo   Claude Code via Free Proxy
echo   Primary:  Fable 5 (Claude 3.5 Sonnet)
echo   Fallback: Ollama Cloud (API key set)
echo ========================================
echo.

:: Check if proxy is running, start if not
powershell -Command "try { Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo   Starting proxy on port %FCC_PORT%...
    pushd "%FCC_DIR%"
    start "FCC Proxy" cmd /c ".venv\Scripts\python.exe -m uvicorn server:app --host 0.0.0.0 --port %FCC_PORT% --timeout-graceful-shutdown 5"
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
        echo   Proxy is running.
    )
) else (
    echo   Proxy already running on port %FCC_PORT%.
)

:: Launch Claude Code with proxy routing
echo.
echo   Launching Claude Code CLI via proxy...
echo   Model: Nemotron 3 Super 120B (free, 1M ctx)
echo.
echo   Once loaded, type:
echo     /plugin install C:\Users\Administrator\.opencode\plugins\oh-my-claudecode
echo.
set "ANTHROPIC_BASE_URL=http://localhost:%FCC_PORT%"
set "ANTHROPIC_AUTH_TOKEN=freecc"
claude
