@echo off
REM GitHub Models Free Tier Launcher — On-the-Go
REM Usage: gh-models.bat chat "your question"
REM        gh-models.bat models
REM        gh-models.bat env

pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0gh-models.ps1" %*
