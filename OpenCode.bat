@echo off
title OpenCode Launcher v3.5 ^| CrossFlow ^| Academix v13.2
:: ==============================================================
:: Portable OpenCode Launcher — Academix v13.2
:: Mahi Kamel Abdelghani | Direction de l'Education El Bayadh
:: Updated: 2026-05-10
:: ==============================================================
:: Uses %~dp0 relative paths — copy project folder anywhere.
:: Place opencode.exe in same dir, bin/, or have it on PATH.
:: ==============================================================
:: Usage:
::   OpenCode                    CLI mode (big-pickle, default)
::   OpenCode gui                Desktop GUI (v1.14.42)
::   OpenCode groq               CLI with Groq Qwen3 32B (fast explore/debug)
::   OpenCode llama              CLI with Groq Llama 3.3 70B (VBA + prose + reasoning)
::   OpenCode nemotron / on      CLI with Nemotron 120B (1M ctx, OpenRouter free)
::   OpenCode fcc                CLI via free-claude-code proxy (Nemotron 120B)
::   OpenCode gemini             CLI with Google Gemini 2.5 Flash (1M ctx)
::   OpenCode gemma / ogg        CLI with Google Gemma 4 26B (256K ctx, multimodal)
::   OpenCode gemma-local / ogg-local  CLI with Ollama Gemma 4 e2b (128K ctx, offline, 7.2GB)
::   OpenCode phi4               CLI with phi4-mini:3.8b (CPU coding, offline)
::   OpenCode qwen3              CLI with qwen3:1.7b (CPU reasoning, offline)
::   OpenCode ollama             CLI with Ollama server + model menu
::   OpenCode proxy              Start FCC proxy only (background)
::   OpenCode academix           Interactive project dashboard
::   OpenCode restore            CLI with last-session model + memory restore
::   OpenCode picker / op        Interactive model picker (TUI)
::   OpenCode autobuild          Build workbook + verify (full rebuild)
::   OpenCode autoverify         Run 137 verification checks
::   OpenCode autotest           Run macro test suite
::   OpenCode autoaudit          Run 5-phase DSS audit
::   OpenCode autothesis         Build thesis PDF
::   OpenCode autocheck          Run system health test
::   OpenCode autofix            Full pipeline: build -> verify -> test -> audit
::   OpenCode autoplan           CLI with Llama 3.3 (optimized for planning)
::   OpenCode autolog <mode>     Run any mode with timestamped log output
::   OpenCode automenu           Interactive mode picker (TUI)
::   OpenCode autoclean          Purge old logs, results, temp files (30-day)
::   OpenCode crossflow          CrossFlow status + handoff overview
::   OpenCode crossflow-sync     Sync CROSSFLOW block to all CLAUDE.md files
::   OpenCode status             Quick project health overview
::   OpenCode <mode> <name>      Launch with named session (multi-session)
::   OpenCode help               Show this help
:: ==============================================================

setlocal enabledelayedexpansion

:: ---- Portable Path Derivation ----
set "SCRIPT_ROOT=%~dp0"

:: Strip trailing backslash from SCRIPT_ROOT
if "%SCRIPT_ROOT:~-1%"=="\" set "SCRIPT_ROOT=%SCRIPT_ROOT:~0,-1%"

:: ---- Find opencode.exe (search: self dir, bin/, Desktop baseline, PATH) ----
set "OC_EXE="
if exist "%SCRIPT_ROOT%\opencode.exe" set "OC_EXE=%SCRIPT_ROOT%\opencode.exe"
if not defined OC_EXE if exist "%SCRIPT_ROOT%\bin\opencode.exe" set "OC_EXE=%SCRIPT_ROOT%\bin\opencode.exe"
if not defined OC_EXE if exist "%USERPROFILE%\Desktop\opencode-windows-x64-baseline\opencode.exe" set "OC_EXE=%USERPROFILE%\Desktop\opencode-windows-x64-baseline\opencode.exe"
if not defined OC_EXE for %%I in (opencode.exe) do set "OC_EXE=%%~$PATH:I"
if not defined OC_EXE (
    echo [ERROR] opencode.exe not found.
    echo   Place it in: %SCRIPT_ROOT%\opencode.exe
    echo   or:          %SCRIPT_ROOT%\bin\opencode.exe
    echo   or add to PATH.
    pause
    exit /b 1
)

:: ---- Derive all project paths from SCRIPT_ROOT (project root) ----
set "PROJECT_ROOT=%SCRIPT_ROOT%"
set "GUI_EXE=%LOCALAPPDATA%\Programs\@opencode-aidesktop\OpenCode.exe"
set "CONFIG_DIR=%USERPROFILE%\.config\opencode"
set "CONFIG_FILE=%CONFIG_DIR%\opencode.json"
set "DEFAULT_MODEL=opencode/big-pickle"
set "GROQ_MODEL=groq/qwen/qwen3-32b"
set "LLAMA_MODEL=groq/llama-3.3-70b-versatile"
set "NEMOTRON_MODEL=openrouter/nvidia/nemotron-3-super-120b-a12b:free"
set "GEMINI_MODEL=google/gemini-2.5-flash"
set "GEMMA4_MODEL=google/gemma-4-26b-a4b-it"
set "OLLAMA_MODEL=ollama/qwen2.5-coder:1.5b"
set "OLLAMA_FAST_MODEL=ollama/qwen2.5-coder:7b"
set "OLLAMA_QWEN3=ollama/qwen3:1.7b"
set "OLLAMA_PHI4=ollama/phi4-mini:3.8b-q4_K_M"
set "OLLAMA_GEMMA4_LOCAL=ollama/gemma4:e2b"

:: ---- Mode Registry (Single Source of Truth) ----
set "CLI_MODES=cli groq llama gemini gemma gemma-local phi4 qwen3 nemotron ollama"
set "OLLAMA_MODES=phi4 qwen3 gemma-local"
set "PIPELINE_MODES=autobuild autoverify autotest autoaudit autothesis autocheck autofix autoplan autolog automenu autoclean status crossflow crossflow-sync"
set "SPECIAL_MODES=gui fcc proxy academix restore picker help"
:: Menu display categories
set "MENU_AUTO=autobuild autoverify autotest autoaudit autofix autocheck"
set "MENU_CROSS=crossflow crossflow-sync"
set "MENU_OTHER=academix gui picker autoclean status help"
set "FCC_DIR=%USERPROFILE%\.opencode\plugins\fcc-proxy"
set "FCC_PORT=8082"
set "MEMORY_DIR=%USERPROFILE%\.opencode\memory"
set "MEMORY_FILE=%MEMORY_DIR%\session.log"
set "LAST_SESSION=%MEMORY_DIR%\last-session.txt"
set "OLLAMA_EXE=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
set "HANDOFF_DIR=%USERPROFILE%\Desktop"
set "CROSSFLOW_DIR=%PROJECT_ROOT%\.crossflow"
set "CROSSFLOW_HANDOFF=%CROSSFLOW_DIR%\HANDOFF.md"
set "CROSSFLOW_LOG=%CROSSFLOW_DIR%\SESSION_LOG.md"
set "CROSSFLOW_CONTEXT=%CROSSFLOW_DIR%\MASTER_CONTEXT.md"
set "LOG_DIR=%PROJECT_ROOT%\logs"

:: ---- Pipeline Script Paths (all relative to PROJECT_ROOT) ----
set "VBE_AUTO=%PROJECT_ROOT%\vbe-auto"
set "BUILD_SCRIPT=%VBE_AUTO%\build.ps1"
set "VERIFY_SCRIPT=%VBE_AUTO%\verify.ps1"
set "CONFIG_PATH=%VBE_AUTO%\config.json"
set "TEST_SCRIPT=%PROJECT_ROOT%\Software_Surgical_Edit\test-macros.ps1"
set "AUDIT_SCRIPT=%PROJECT_ROOT%\milestone_13_2\tests\dss-audit.ps1"
set "THESIS_SCRIPT=%PROJECT_ROOT%\Thesis_Surgical_Edit\build-thesis.ps1"
set "HEALTH_SCRIPT=%PROJECT_ROOT%\scripts\system-health-test.ps1"
set "ACADEMIX_SCRIPT=%PROJECT_ROOT%\scripts\academix-launcher.ps1"
set "PWSH=pwsh -NoProfile -ExecutionPolicy Bypass"

:: ---- Remove trailing backslash from OC_EXE dir for BASEDIR ----
for %%I in ("%OC_EXE%") do set "BASEDIR=%%~dpI"
if "%BASEDIR:~-1%"=="\" set "BASEDIR=%BASEDIR:~0,-1%"

:: ---- Parse arguments ----
set "MODE=%~1"
set "SESSION_NAME=%~2"
if "%MODE%"=="" set "MODE=cli"
if "%SESSION_NAME%"=="" set "SESSION_NAME=default"

set "WINDOW_TITLE=OpenCode [%MODE%] - %SESSION_NAME%"
echo %MODE% > "%LAST_SESSION%"
(echo %MODE% & echo %SESSION_NAME% & echo %DATE% & echo %TIME%) > "%MEMORY_DIR%\last-session-%SESSION_NAME%.txt" 2>nul

:: ---- Mode Dispatch ----
:: CLI modes (single loop — add once, works everywhere)
for %%m in (%CLI_MODES%) do if /i "!MODE!"=="%%m" goto :%%m
:: Aliases
if /i "%MODE%"=="on" goto :nemotron
if /i "%MODE%"=="ogg" goto :gemma
if /i "%MODE%"=="ogg-local" goto :gemma-local
if /i "%MODE%"=="op" goto :picker
:: Pipeline modes
for %%m in (%PIPELINE_MODES%) do if /i "!MODE!"=="%%m" goto :%%m
:: Special modes
for %%m in (%SPECIAL_MODES%) do if /i "!MODE!"=="%%m" goto :%%m
:: Unknown
echo Unknown mode: %MODE%
goto :help

:: ==============================================================
:: Ollama Auto-Start
:: ==============================================================
:ensure-ollama
echo [OpenCode] Checking Ollama server...
if not exist "%OLLAMA_EXE%" (
    echo   ERROR: Ollama not found at %OLLAMA_EXE%
    echo   Install from: https://ollama.ai
    pause
    exit /b 1
)
powershell -Command "try { $r = Invoke-RestMethod 'http://localhost:11434/api/tags' -TimeoutSec 2; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo   Starting Ollama server (background)...
    start "Ollama Server" "%OLLAMA_EXE%" serve
    echo   Waiting for Ollama server (may take 10-15s)...
    ping 127.0.0.1 -n 16 >nul
    powershell -Command "try { $r = Invoke-RestMethod 'http://localhost:11434/api/tags' -TimeoutSec 5; exit 0 } catch { exit 1 }"
    if errorlevel 1 (
        echo   WARNING: Ollama server may not be ready yet.
    ) else (
        echo   Ollama server is running.
    )
) else (
    echo   Ollama server already running.
)
goto :eof

:: ==============================================================
:: CLI Modes
:: ==============================================================
:cli
title %WINDOW_TITLE%
echo [OpenCode] Launching CLI (big-pickle) — Session: %SESSION_NAME%
echo.
"%OC_EXE%" --model "%DEFAULT_MODEL%" "%PROJECT_ROOT%"
goto :end

:gui
echo [OpenCode] Launching Desktop GUI (v1.14.42)...
if not exist "%GUI_EXE%" (
    echo ERROR: GUI not found at %GUI_EXE%
    pause
    exit /b 1
)
start "" "%GUI_EXE%"
goto :end

:groq
title %WINDOW_TITLE%
echo [OpenCode] Launching with Groq Qwen3 32B — Session: %SESSION_NAME%
echo   Model: %GROQ_MODEL%
echo.
"%OC_EXE%" --model "%GROQ_MODEL%" "%PROJECT_ROOT%"
goto :end

:llama
title %WINDOW_TITLE%
echo [OpenCode] Launching with Groq Llama 3.3 70B — Session: %SESSION_NAME%
echo   Model: %LLAMA_MODEL%
echo.
"%OC_EXE%" --model "%LLAMA_MODEL%" "%PROJECT_ROOT%"
goto :end

:nemotron
title %WINDOW_TITLE%
echo [OpenCode] Launching with Nemotron 3 Super 120B — Session: %SESSION_NAME%
echo   Model: %NEMOTRON_MODEL% (1M context)
echo.
"%OC_EXE%" --model "%NEMOTRON_MODEL%" "%PROJECT_ROOT%"
goto :end

:fcc
echo [OpenCode] Launching via free-claude-code proxy — Session: %SESSION_NAME%
echo.
if not exist "%FCC_DIR%" (
    echo ERROR: free-claude-code not found at:
    echo %FCC_DIR%
    echo.
    echo Install: git clone https://github.com/Alishahryar1/free-claude-code.git
    echo to: %FCC_DIR%
    echo Then: cd %FCC_DIR% ^&^& uv sync
    pause
    exit /b 1
)
powershell -Command "try { $r = Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 2; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo   Proxy not running. Starting on port %FCC_PORT%...
    pushd "%FCC_DIR%"
    start "FCC Proxy" cmd /c "uv run uvicorn server:app --host 0.0.0.0 --port %FCC_PORT% --timeout-graceful-shutdown 5"
    popd
    set "RETRY_COUNT=0"
    :fcc-retry
    set /a RETRY_COUNT+=1
    ping 127.0.0.1 -n 4 >nul
    powershell -Command "try { $r = Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 3; exit 0 } catch { exit 1 }"
    if errorlevel 1 (
        if !RETRY_COUNT! LSS 5 (
            echo   Retry !RETRY_COUNT!/5...
            goto :fcc-retry
        )
        echo   WARNING: Proxy may not have started.
    ) else (
        echo   Proxy is running.
    )
) else (
    echo   Proxy already running on port %FCC_PORT%.
)
echo.
echo   Model: Nemotron 3 Super 120B (free, 1M ctx, via OpenRouter)
echo.
set "ANTHROPIC_BASE_URL=http://localhost:%FCC_PORT%"
set "ANTHROPIC_AUTH_TOKEN=freecc"
title %WINDOW_TITLE%
"%OC_EXE%" "%PROJECT_ROOT%"
goto :end

:gemini
title %WINDOW_TITLE%
echo [OpenCode] Launching with Google Gemini 2.5 Flash — Session: %SESSION_NAME%
echo   Model: %GEMINI_MODEL%
echo.
"%OC_EXE%" --model "%GEMINI_MODEL%" "%PROJECT_ROOT%"
goto :end

:gemma
title %WINDOW_TITLE%
echo [OpenCode] Launching with Google Gemma 4 26B — Session: %SESSION_NAME%
echo   Model: %GEMMA4_MODEL% (256K context, multimodal)
echo.
"%OC_EXE%" --model "%GEMMA4_MODEL%" "%PROJECT_ROOT%"
goto :end

:gemma-local
call :ensure-ollama
:mode-dispatch-gemma-local
title %WINDOW_TITLE%
echo [OpenCode] Launching with Ollama Gemma 4 e2b — Session: %SESSION_NAME%
echo   Model: %OLLAMA_GEMMA4_LOCAL% (128K context, 7.2GB, offline fallback)
echo.
cd /d "%BASEDIR%"
"%OC_EXE%" --model "%OLLAMA_GEMMA4_LOCAL%" "%PROJECT_ROOT%"
goto :end

:phi4
call :ensure-ollama
:mode-dispatch-phi4
title %WINDOW_TITLE%
echo [OpenCode] Launching with phi4-mini:3.8b — Session: %SESSION_NAME%
echo   Model: %OLLAMA_PHI4%
echo.
cd /d "%BASEDIR%"
"%OC_EXE%" --model "%OLLAMA_PHI4%" "%PROJECT_ROOT%"
goto :end

:qwen3
call :ensure-ollama
:mode-dispatch-qwen3
title %WINDOW_TITLE%
echo [OpenCode] Launching with qwen3:1.7b — Session: %SESSION_NAME%
echo   Model: %OLLAMA_QWEN3%
echo.
cd /d "%BASEDIR%"
"%OC_EXE%" --model "%OLLAMA_QWEN3%" "%PROJECT_ROOT%"
goto :end

:ollama
call :ensure-ollama
:mode-dispatch-ollama-menu
title %WINDOW_TITLE%
echo [OpenCode] Ollama Model Selection — Session: %SESSION_NAME%
echo.
echo Available Ollama models:
echo   1) qwen2.5-coder:1.5b     (986 MB, fastest)
echo   2) qwen3:1.7b             (1.4 GB, CPU reasoning)
echo   3) phi4-mini:3.8b-q4_K_M  (2.5 GB, CPU coding)
echo   4) qwen2.5-coder:7b       (4.7 GB, highest quality)
echo.
set /p OLLAMA_CHOICE="Select model [1-4] (default: 2): "
if "%OLLAMA_CHOICE%"=="" set "OLLAMA_CHOICE=2"
if "%OLLAMA_CHOICE%"=="1" set "SELECTED_MODEL=%OLLAMA_MODEL%"
if "%OLLAMA_CHOICE%"=="2" set "SELECTED_MODEL=%OLLAMA_QWEN3%"
if "%OLLAMA_CHOICE%"=="3" set "SELECTED_MODEL=%OLLAMA_PHI4%"
if "%OLLAMA_CHOICE%"=="4" set "SELECTED_MODEL=%OLLAMA_FAST_MODEL%"
echo   Model: %SELECTED_MODEL%
echo.
cd /d "%BASEDIR%"
"%OC_EXE%" --model "%SELECTED_MODEL%" "%PROJECT_ROOT%"
goto :end

:: ==============================================================
:proxy
echo [OpenCode] Starting FCC proxy only (background)...
echo.
if not exist "%FCC_DIR%" (
    echo ERROR: free-claude-code not found at %FCC_DIR%
    pause
    exit /b 1
)
powershell -Command "try { $r = Invoke-RestMethod 'http://localhost:%FCC_PORT%/health' -TimeoutSec 2; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    pushd "%FCC_DIR%"
    start "FCC Proxy" cmd /c "uv run uvicorn server:app --host 0.0.0.0 --port %FCC_PORT% --timeout-graceful-shutdown 5"
    popd
    echo   Started FCC proxy on port %FCC_PORT%.
    echo   To use: OpenCode fcc
) else (
    echo   Proxy already running on port %FCC_PORT%.
)
goto :end

:: ==============================================================
:academix
title %WINDOW_TITLE%
echo [Academix] Interactive Project Dashboard — Session: %SESSION_NAME%
echo.
if not exist "%ACADEMIX_SCRIPT%" (
    echo ERROR: academix-launcher.ps1 not found at:
    echo %ACADEMIX_SCRIPT%
    pause
    exit /b 1
)
cd /d "%PROJECT_ROOT%"
pwsh -NoExit -ExecutionPolicy Bypass -File "%ACADEMIX_SCRIPT%"
echo.
pause
goto :end

:: ==============================================================
:restore
echo [OpenCode] Restoring last session...
if not exist "%LAST_SESSION%" (
    echo   No saved session found. Launching default CLI.
    goto :cli
)
set /p LAST_MODE=<"%LAST_SESSION%"
echo   Restoring mode: %LAST_MODE%
set "MODE=%LAST_MODE%"
:: Resolve aliases
if /i "%MODE%"=="on" set "MODE=nemotron"
if /i "%MODE%"=="ogg" set "MODE=gemma"
if /i "%MODE%"=="ogg-local" set "MODE=gemma-local"
:: Validate against known mode lists, then goto directly
set "VALID="
for %%m in (%CLI_MODES%) do if /i "!MODE!"=="%%m" set "VALID=1"
for %%m in (%PIPELINE_MODES%) do if /i "!MODE!"=="%%m" set "VALID=1"
for %%m in (%SPECIAL_MODES%) do if /i "!MODE!"=="%%m" set "VALID=1"
if defined VALID goto :!MODE!
:: Fallback
echo   Unknown mode, falling back to CLI.
goto :cli

:: ==============================================================
:picker
title OpenCode [PICKER] - %SESSION_NAME%
echo [OpenCode] Launching Model Picker...
if not exist "%PROJECT_ROOT%\scripts\model-picker.ps1" (
    echo ERROR: scripts\model-picker.ps1 not found
    pause
    exit /b 1
)
cd /d "%PROJECT_ROOT%"
%PWSH% -File "%PROJECT_ROOT%\scripts\model-picker.ps1"
goto :end

:: ==============================================================
:: AUTO Pipeline Modes
:: ==============================================================
:autobuild
title OpenCode [AUTOBUILD] - %SESSION_NAME%
echo   === AUTO BUILD ===
if not exist "%BUILD_SCRIPT%" ( echo ERROR: build.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%BUILD_SCRIPT%" -ConfigPath "%CONFIG_PATH%"
if errorlevel 1 ( echo   BUILD FAILED & pause & exit /b 1 ) else ( echo   BUILD OK )
echo.
echo   Running verification...
%PWSH% -File "%VERIFY_SCRIPT%" -ConfigPath "%CONFIG_PATH%"
echo.
echo  Build complete.
pause
goto :end

:autoverify
title OpenCode [AUTOVERIFY] - %SESSION_NAME%
echo   === AUTO VERIFY ===
if not exist "%VERIFY_SCRIPT%" ( echo ERROR: verify.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%VERIFY_SCRIPT%" -ConfigPath "%CONFIG_PATH%"
pause
goto :end

:autotest
title OpenCode [AUTOTEST] - %SESSION_NAME%
echo   === AUTO TEST ===
if not exist "%TEST_SCRIPT%" ( echo ERROR: test-macros.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%TEST_SCRIPT%"
pause
goto :end

:autoaudit
title OpenCode [AUTOAUDIT] - %SESSION_NAME%
echo   === AUTO AUDIT ===
if not exist "%AUDIT_SCRIPT%" ( echo ERROR: dss-audit.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%AUDIT_SCRIPT%"
pause
goto :end

:autothesis
title OpenCode [AUTOTHESIS] - %SESSION_NAME%
echo   === AUTO THESIS ===
if not exist "%THESIS_SCRIPT%" ( echo ERROR: build-thesis.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%THESIS_SCRIPT%"
pause
goto :end

:autocheck
title OpenCode [AUTOCHECK] - %SESSION_NAME%
echo   === AUTO HEALTH CHECK ===
if not exist "%HEALTH_SCRIPT%" ( echo ERROR: system-health-test.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%HEALTH_SCRIPT%"
pause
goto :end

:autofix
title OpenCode [AUTOFIX] - %SESSION_NAME%
echo   === AUTO FULL PIPELINE ===
echo  Phase 1: Build
if not exist "%BUILD_SCRIPT%" ( echo ERROR: build.ps1 not found & pause & exit /b 1 )
%PWSH% -File "%BUILD_SCRIPT%" -ConfigPath "%CONFIG_PATH%"
if errorlevel 1 ( echo   BUILD FAILED & pause & exit /b 1 ) else ( echo   BUILD OK )
echo  Phase 2: Verify
%PWSH% -File "%VERIFY_SCRIPT%" -ConfigPath "%CONFIG_PATH%"
echo  Phase 3: Test
%PWSH% -File "%TEST_SCRIPT%"
echo  Phase 4: Audit
%PWSH% -File "%AUDIT_SCRIPT%"
echo   === FULL PIPELINE COMPLETE ===
pause
goto :end

:autoplan
title OpenCode [AUTOPLAN] - %SESSION_NAME%
echo   === AUTO PLAN ===
"%OC_EXE%" --model "%LLAMA_MODEL%" "%PROJECT_ROOT%"
goto :end

:: ==============================================================
:autolog
title OpenCode [AUTOLOG] - %SESSION_NAME%
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
set "LOG_TIMESTAMP=%DATE:/=-%_%TIME::=-%"
set "LOG_TIMESTAMP=%LOG_TIMESTAMP: =0%
set "LOG_FILE=%LOG_DIR%\opencode-%SESSION_NAME%-%LOG_TIMESTAMP%.log"
echo   === AUTO LOG ===
echo  Mode: %SESSION_NAME%
echo  Log:  %LOG_FILE%
echo.
if /i "%SESSION_NAME%"=="default" (
    echo   Usage: OpenCode autolog ^<mode^>
    pause
    goto :end
)
echo ===== OpenCode Log: %DATE% %TIME% ===== >> "%LOG_FILE%"
echo Mode: %SESSION_NAME% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
call :%SESSION_NAME% >> "%LOG_FILE%" 2>&1
echo. >> "%LOG_FILE%"
echo ===== Log End: %DATE% %TIME% ===== >> "%LOG_FILE%"
echo  Log saved: %LOG_FILE%
pause
goto :end

:: ==============================================================
:autoclean
title OpenCode [AUTOCLEAN] - %SESSION_NAME%
echo   === AUTO CLEAN ===
echo  Purging files older than 30 days...
set "CLEANED=0"
if exist "%LOG_DIR%" (
    forfiles /p "%LOG_DIR%" /s /m *.* /d -30 /c "cmd /c del @path" >nul 2>&1
    set /a CLEANED+=1
)
if exist "%VBE_AUTO%\results" (
    forfiles /p "%VBE_AUTO%\results" /s /m *.json /d -30 /c "cmd /c del @path" >nul 2>&1
    set /a CLEANED+=1
)
forfiles /p "%VBE_AUTO%" /s /m verify_results_*.json /d -30 /c "cmd /c del @path" >nul 2>&1
forfiles /p "%PROJECT_ROOT%" /s /m *.tmp /d -30 /c "cmd /c del @path" >nul 2>&1
forfiles /p "%PROJECT_ROOT%" /s /m *.temp /d -30 /c "cmd /c del @path" >nul 2>&1
if exist "%PROJECT_ROOT%\.tmp.driveupload" (
    rmdir /s /q "%PROJECT_ROOT%\.tmp.driveupload"
    set /a CLEANED+=1
)
if exist "%MEMORY_DIR%" (
    pushd "%MEMORY_DIR%"
    for /f "skip=5 delims=" %%f in ('dir /b /o-d last-session-*.txt 2^>nul') do del "%%f" 2>nul
    popd
)
echo  Cleaned %CLEANED% categories. Files older than 30 days removed.
pause
goto :end

:: ==============================================================
:status
title OpenCode [STATUS] - %SESSION_NAME%
echo   === PROJECT STATUS ===
echo  Academix v13.2 ^| El Bayadh
if exist "%PROJECT_ROOT%\.git" (
    echo  Git: REPO OK
    pushd "%PROJECT_ROOT%"
    for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD 2^>nul') do echo  Branch: %%a
    for /f "tokens=*" %%a in ('git log --oneline -1 2^>nul') do echo  Last commit: %%a
    for /f "tokens=*" %%a in ('git status --porcelain ^| find /c /v "" 2^>nul') do echo  Uncommitted: %%a file(s)
    popd
) else ( echo  Git: NOT A REPO )
echo.
echo  Pipeline:
if exist "%BUILD_SCRIPT%" ( echo  Build script:     OK ) else ( echo  Build script:     MISSING )
if exist "%VERIFY_SCRIPT%" ( echo  Verify script:    OK ) else ( echo  Verify script:    MISSING )
echo.
echo  Config: %CONFIG_PATH%
echo  Binary: %OC_EXE%
echo  Port:   %FCC_PORT%
echo.
pause
goto :end

:: ==============================================================
:automenu
title OpenCode [AUTOMENU] - Academix v13.2
:menu-loop
cls
echo  ===========================================
echo    OpenCode Launcher v3.4 — Mode Selector
echo    Academix v13.2 ^| El Bayadh
echo  ===========================================
echo.
echo  OPENCODE CLI MODES:
set /a _n=1
for %%m in (%CLI_MODES%) do (
    set "_d="
    if "%%m"=="cli" set "_d=big-pickle (default)"
    if "%%m"=="groq" set "_d=Qwen3 32B (fast)"
    if "%%m"=="llama" set "_d=Llama 3.3 70B (VBA + prose)"
    if "%%m"=="gemini" set "_d=Gemini 2.5 Flash (1M ctx)"
    if "%%m"=="gemma" set "_d=Gemma 4 26B (256K ctx, multimodal)"
    if "%%m"=="gemma-local" set "_d=Gemma 4 e2b (Ollama, 128K, offline)"
    if "%%m"=="phi4" set "_d=Phi4-mini 3.8B (CPU coding)"
    if "%%m"=="qwen3" set "_d=Qwen3 1.7B (CPU reasoning)"
    if "%%m"=="nemotron" set "_d=Nemotron 120B (1M ctx)"
    if "%%m"=="ollama" set "_d=Ollama model menu"
    echo    [!_n!]  %%m  !_d!
    set /a _n+=1
)
echo.
echo  AUTO PIPELINE MODES:
for %%p in (%MENU_AUTO%) do (
    set "_d="
    if "%%p"=="autobuild" set "_d=Build + verify"
    if "%%p"=="autoverify" set "_d=137 verification checks"
    if "%%p"=="autotest" set "_d=Macro test suite"
    if "%%p"=="autoaudit" set "_d=5-phase DSS audit"
    if "%%p"=="autofix" set "_d=Full pipeline"
    if "%%p"=="autocheck" set "_d=System health"
    echo    [!_n!]  %%p  !_d!
    set /a _n+=1
)
echo.
echo  CROSSFLOW:
for %%c in (%MENU_CROSS%) do (
    set "_d="
    if "%%c"=="crossflow" set "_d=CrossFlow status"
    if "%%c"=="crossflow-sync" set "_d=Sync CLAUDE.md blocks"
    echo    [!_n!]  %%c  !_d!
    set /a _n+=1
)
echo.
echo  OTHER:
for %%o in (%MENU_OTHER%) do (
    set "_d="
    if "%%o"=="academix" set "_d=Project dashboard"
    if "%%o"=="picker" set "_d=Interactive model picker"
    if "%%o"=="gui" set "_d=Desktop GUI"
    if "%%o"=="autoclean" set "_d=Purge old files (30-day)"
    if "%%o"=="status" set "_d=Project health overview"
    if "%%o"=="help" set "_d=Show help"
    echo    [!_n!]  %%o  !_d!
    set /a _n+=1
)
echo    [0]  Exit
echo.
set /p MENU_CHOICE="Select mode [0]: "
if "%MENU_CHOICE%"=="" goto :menu-loop
if "%MENU_CHOICE%"=="0" exit /b
:: Map number to mode (same order as display: CLI→AUTO→CROSS→OTHER)
set "MENU_MODE="
set /a _n=1
for %%x in (%CLI_MODES% %MENU_AUTO% %MENU_CROSS% %MENU_OTHER%) do (
    if "!MENU_CHOICE!"=="!_n!" set "MENU_MODE=%%x"
    set /a _n+=1
)
if not defined MENU_MODE goto :menu-loop
set "MODE=!MENU_MODE!"
:: Resolve aliases for goto
if /i "!MODE!"=="on" set "MODE=nemotron"
if /i "!MODE!"=="ogg" set "MODE=gemma"
if /i "!MODE!"=="ogg-local" set "MODE=gemma-local"
goto :!MODE!

:: ==============================================================
:help
echo.
echo OpenCode Launcher v3.4 -- Academix v13.2
echo ===============================================
echo.
echo Usage: OpenCode ^<mode^> [session-name]
echo.
echo Modes:
echo   (no arg)   CLI mode -- big-pickle (default)
echo   gui        Desktop GUI v1.14.42
echo   groq       CLI with Groq Qwen3 32B
echo   llama      CLI with Groq Llama 3.3 70B
echo   nemotron   CLI with Nemotron 120B (OpenRouter free)
echo   on         Alias for nemotron
echo   fcc        CLI via FCC proxy (auto-start)
echo   gemini     CLI with Google Gemini 2.5 Flash
echo   gemma      CLI with Google Gemma 4 26B (256K ctx, multimodal)
echo   ogg        Alias for gemma
echo   gemma-local CLI with Ollama Gemma 4 e2b (128K ctx, offline)
echo   ogg-local  Alias for gemma-local
echo   phi4       CLI with phi4-mini:3.8b (CPU, offline)
echo   qwen3      CLI with qwen3:1.7b (CPU, offline)
echo   ollama     CLI with model menu + auto-start server
echo   proxy      Start FCC proxy only (background)
echo   academix   Interactive project dashboard
echo   picker     Interactive model picker (TUI)
echo   op         Alias for picker
echo   autobuild  Build + verify
echo   autoverify 137 verification checks
echo   autotest   Macro test suite
echo   autoaudit  5-phase DSS audit
echo   autothesis Build thesis PDF
echo   autocheck  System health test
echo   autofix    Full pipeline
echo   autoplan   CLI with Llama 3.3 (planning)
echo   autolog    Run any mode with logging
echo   automenu   Interactive mode selector
echo   autoclean  Purge old files (30-day)
echo   crossflow  CrossFlow status + handoff overview
echo   crossflow-sync Sync CROSSFLOW block to CLAUDE.md files
echo   status     Project health overview
echo   help       This screen
echo.
echo Multi-Session: OpenCode groq thesis  -- named session "thesis"
echo.
goto :end

:: ==============================================================
:: CrossFlow Modes
:: ==============================================================
:crossflow
title OpenCode [CROSSFLOW] - %SESSION_NAME%
echo   === CROSSFLOW STATUS ===
echo.
if not exist "%CROSSFLOW_DIR%" (
    echo  [WARN] .crossflow/ directory not found.
    echo  Run in project root or initialize with: mkdir .crossflow
    pause
    goto :end
)
echo  CrossFlow Directory: %CROSSFLOW_DIR%
echo.
if exist "%CROSSFLOW_HANDOFF%" (
    echo  --- Last Handoff ---
    for /f "tokens=*" %%a in ('findstr /i "Last action" "%CROSSFLOW_HANDOFF%"') do echo  %%a
    for /f "tokens=*" %%a in ('findstr /i "Next step" "%CROSSFLOW_HANDOFF%"') do echo  %%a
    for /f "tokens=*" %%a in ('findstr /i "Current phase" "%CROSSFLOW_HANDOFF%"') do echo  %%a
) else (
    echo  [INFO] No handoff file yet.
)
echo.
if exist "%CROSSFLOW_LOG%" (
    for /f %%s in ('powershell -Command "(Get-Item '%CROSSFLOW_LOG%').Length"') do set "LOG_SIZE=%%s"
    echo  Session log: %LOG_SIZE% bytes
    for /f "tokens=*" %%a in ('powershell -Command "Get-Content '%CROSSFLOW_LOG%' | Select-Object -Last 3"') do echo  %%a
)
echo.
echo  CLAUDE.md files:
if exist "%USERPROFILE%\.claude\CLAUDE.md" (findstr "CROSSFLOW:START" "%USERPROFILE%\.claude\CLAUDE.md" >nul && echo   ~/.claude/CLAUDE.md:   SYNCED || echo   ~/.claude/CLAUDE.md:   MISSING)
if exist "%USERPROFILE%\.agentic-hub\CLAUDE.md" (findstr "CROSSFLOW:START" "%USERPROFILE%\.agentic-hub\CLAUDE.md" >nul && echo   ~/.agentic-hub/CLAUDE.md: SYNCED || echo   ~/.agentic-hub/CLAUDE.md: MISSING)
if exist "%PROJECT_ROOT%\CLAUDE.md" (findstr "CROSSFLOW:START" "%PROJECT_ROOT%\CLAUDE.md" >nul && echo   project/CLAUDE.md:        SYNCED || echo   project/CLAUDE.md:        MISSING)
echo.
echo  Commands: /crossflow sync ^| /crossflow handoff "msg"
pause
goto :end

:crossflow-sync
title OpenCode [CROSSFLOW-SYNC] - %SESSION_NAME%
echo   === CROSSFLOW SYNC ===
echo.
if not exist "%CROSSFLOW_DIR%" (
    echo  [ERROR] .crossflow/ directory not found.
    pause
    goto :end
)
echo  Syncing CROSSFLOW block to all CLAUDE.md files...
echo.
if exist "%USERPROFILE%\.claude\CLAUDE.md" (
    findstr "CROSSFLOW:START" "%USERPROFILE%\.claude\CLAUDE.md" >nul
    if errorlevel 1 (
        echo  [WARN] ~/.claude/CLAUDE.md missing CROSSFLOW block — add manually
    ) else (
        echo   ~/.claude/CLAUDE.md: block present
    )
)
if exist "%USERPROFILE%\.agentic-hub\CLAUDE.md" (
    findstr "CROSSFLOW:START" "%USERPROFILE%\.agentic-hub\CLAUDE.md" >nul
    if errorlevel 1 (
        echo  [WARN] ~/.agentic-hub/CLAUDE.md missing CROSSFLOW block
    ) else (
        echo   ~/.agentic-hub/CLAUDE.md: block present
    )
)
if exist "%PROJECT_ROOT%\CLAUDE.md" (
    echo   project/CLAUDE.md: present
)
echo.
echo  MASTER_CONTEXT.md: %CROSSFLOW_CONTEXT%
echo  HANDOFF:           %CROSSFLOW_HANDOFF%
echo  SESSION_LOG:       %CROSSFLOW_LOG%
echo.
echo  CrossFlow sync check complete.
pause
goto :end

:: ==============================================================
:end
endlocal
