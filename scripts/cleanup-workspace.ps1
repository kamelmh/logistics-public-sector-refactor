<#
.SYNOPSIS
    Academix Workspace Cleanup Script
    Cleans caches, temp files, and old sessions
    
.DESCRIPTION
    Cleans:
    - OpenCode logs and cache
    - Claude sessions older than 7 days
    - Dropbox Temp folder
    - Project temp files
    
.EXAMPLE
    .\cleanup-workspace.ps1
    .\cleanup-workspace.ps1 -DeepClean
#>

param(
    [switch]$DeepClean
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ACADEMIX WORKSPACE CLEANUP" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$totalFreed = 0

# Clean OpenCode logs
Write-Host "[1/5] Cleaning OpenCode logs..." -ForegroundColor Yellow
$ocLogs = Get-ChildItem "C:\Users\Administrator\.opencode\logs\*" -ErrorAction SilentlyContinue
if ($ocLogs) {
    $ocSize = ($ocLogs | Measure-Object -Property Length -Sum).Sum
    $ocLogs | Remove-Item -Force
    $totalFreed += $ocSize
    Write-Host "  ✓ Freed $([math]::Round($ocSize/1MB,2)) MB" -ForegroundColor Green
} else {
    Write-Host "  ✓ No logs to clean" -ForegroundColor Green
}

# Clean Claude sessions older than 7 days
Write-Host "[2/5] Cleaning old Claude sessions..." -ForegroundColor Yellow
$oldSessions = Get-ChildItem "C:\Users\Administrator\.claude\sessions\" -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
if ($oldSessions) {
    $sessionSize = ($oldSessions | Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $oldSessions | Remove-Item -Recurse -Force
    $totalFreed += $sessionSize
    Write-Host "  ✓ Freed $([math]::Round($sessionSize/1MB,2)) MB" -ForegroundColor Green
} else {
    Write-Host "  ✓ No old sessions to clean" -ForegroundColor Green
}

# Clean Dropbox Temp
Write-Host "[3/5] Cleaning Dropbox Temp..." -ForegroundColor Yellow
$projectRoot = Split-Path -Parent $PSScriptRoot
$tempFiles = Get-ChildItem "$projectRoot\..\Temp\*" -ErrorAction SilentlyContinue
if ($tempFiles) {
    $tempSize = ($tempFiles | Measure-Object -Property Length -Sum).Sum
    $tempFiles | Remove-Item -Force
    $totalFreed += $tempSize
    Write-Host "  ✓ Freed $([math]::Round($tempSize/1MB,2)) MB" -ForegroundColor Green
} else {
    Write-Host "  ✓ No temp files to clean" -ForegroundColor Green
}

# Clean project temp files
Write-Host "[4/5] Cleaning project temp files..." -ForegroundColor Yellow
$projectTemp = Get-ChildItem "$projectRoot\*.tmp" -ErrorAction SilentlyContinue
if ($projectTemp) {
    $tmpSize = ($projectTemp | Measure-Object -Property Length -Sum).Sum
    $projectTemp | Remove-Item -Force
    $totalFreed += $tmpSize
    Write-Host "  ✓ Freed $([math]::Round($tmpSize/1MB,2)) MB" -ForegroundColor Green
} else {
    Write-Host "  ✓ No temp files to clean" -ForegroundColor Green
}

# Deep clean - optional
if ($DeepClean) {
    Write-Host "[5/5] Deep cleaning (pip cache, npm cache)..." -ForegroundColor Yellow
    
    # Clean pip cache
    pip cache purge 2>$null
    Write-Host "  ✓ pip cache cleaned" -ForegroundColor Green
    
    # Clean npm cache
    npm cache clean --force 2>$null
    Write-Host "  ✓ npm cache cleaned" -ForegroundColor Green
} else {
    Write-Host "[5/5] Skipping deep clean (use -DeepClean to enable)" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  CLEANUP COMPLETE" -ForegroundColor Green
Write-Host "  Total freed: $([math]::Round($totalFreed/1MB,2)) MB" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
