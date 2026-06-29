<#
.SYNOPSIS
    Academix Unified Backup Script
    Creates timestamped backups of critical project files
    
.DESCRIPTION
    Backs up:
    - ERP Workbook (ERP_v13.4.xlsm)
    - Thesis Golden Source (Latest-thesis-backup-1-*.docx)
    - Project configuration files
    - OpenCode/Claude settings
    
.EXAMPLE
    .\backup-project.ps1
    .\backup-project.ps1 -QuickBackup
    .\backup-project.ps1 -FullBackup
#>

param(
    [switch]$QuickBackup,
    [switch]$FullBackup,
    [switch]$CleanOld
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$projectRoot = Split-Path -Parent $PSScriptRoot
$backupRoot = "$projectRoot\backups"
$archiveRoot = "$projectRoot\archive"

# Create backup directories
New-Item -ItemType Directory -Path "$backupRoot\$timestamp" -Force | Out-Null

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ACADEMIX UNIFIED BACKUP" -ForegroundColor Cyan
Write-Host "  Timestamp: $timestamp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Quick Backup - Essential files only
if ($QuickBackup -or (-not $FullBackup)) {
    Write-Host "[QUICK] Backing up essential files..." -ForegroundColor Yellow
    
    # ERP Workbook
    if (Test-Path "$projectRoot\ERP_v13.4.xlsm") {
        Copy-Item "$projectRoot\ERP_v13.4.xlsm" "$backupRoot\$timestamp\"
        Write-Host "  ✓ ERP Workbook" -ForegroundColor Green
    }
    
    # Thesis Golden Source
    $thesisFiles = Get-ChildItem "$projectRoot\Thesis_Surgical_Edit\output\Latest-thesis-backup-1-*.docx" -ErrorAction SilentlyContinue
    if ($thesisFiles) {
        $thesisFiles | ForEach-Object { Copy-Item $_.FullName "$backupRoot\$timestamp\" }
        Write-Host "  ✓ Thesis Golden Source" -ForegroundColor Green
    }
    
    # Configuration files
    Copy-Item "$projectRoot\.crossflow\HANDOFF.md" "$backupRoot\$timestamp\" -ErrorAction SilentlyContinue
    Copy-Item "$projectRoot\CLAUDE.md" "$backupRoot\$timestamp\" -ErrorAction SilentlyContinue
    Copy-Item "$projectRoot\.claude\mcp-unified.json" "$backupRoot\$timestamp\" -ErrorAction SilentlyContinue
    Write-Host "  ✓ Configuration files" -ForegroundColor Green
}

# Full Backup - Everything
if ($FullBackup) {
    Write-Host "[FULL] Backing up all files..." -ForegroundColor Yellow
    
    # Copy entire project structure (excluding large build artifacts)
    $excludeDirs = @('.git', 'node_modules', '.opencode\plugins', 'bin')
    Get-ChildItem $projectRoot -Directory | Where-Object { $_.Name -notin $excludeDirs } | ForEach-Object {
        Copy-Item $_.FullName "$backupRoot\$timestamp\" -Recurse -ErrorAction SilentlyContinue
    }
    Write-Host "  ✓ Full project structure" -ForegroundColor Green
    
    # OpenCode settings
    if (Test-Path "C:\Users\Administrator\.config\opencode\opencode.json") {
        Copy-Item "C:\Users\Administrator\.config\opencode\opencode.json" "$backupRoot\$timestamp\opencode-settings.json"
        Write-Host "  ✓ OpenCode settings" -ForegroundColor Green
    }
    
    # Claude settings
    if (Test-Path "C:\Users\Administrator\.claude\settings.json") {
        Copy-Item "C:\Users\Administrator\.claude\settings.json" "$backupRoot\$timestamp\claude-settings.json"
        Write-Host "  ✓ Claude settings" -ForegroundColor Green
    }
}

# Clean old backups (keep last 5)
if ($CleanOld) {
    Write-Host ""
    Write-Host "[CLEAN] Removing old backups (keeping last 5)..." -ForegroundColor Yellow
    Get-ChildItem $backupRoot -Directory | 
        Sort-Object Name | 
        Select-Object -First ((Get-ChildItem $backupRoot -Directory).Count - 5) | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ Old backups cleaned" -ForegroundColor Green
}

# Summary
$backupSize = (Get-ChildItem "$backupRoot\$timestamp" -Recurse -File | Measure-Object -Property Length -Sum).Sum
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  BACKUP COMPLETE" -ForegroundColor Green
Write-Host "  Location: $backupRoot\$timestamp" -ForegroundColor Green
Write-Host "  Size: $([math]::Round($backupSize/1MB,2)) MB" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
