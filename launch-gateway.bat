@echo off
cd /d "%~dp0\.."
cd .opencode\gateway
echo Starting OpenCode Gateway...
if not exist node_modules (
    echo Installing dependencies...
    call npm install
)
call npm start
pause
