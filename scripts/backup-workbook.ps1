# ============================================================================
# backup-workbook.ps1 — Academix v13.2 Automated Workbook Backup
# Creates versioned snapshots of ERP_v13.2.xlsm with integrity checks
# Usage: .\scripts\backup-workbook.ps1 [-MaxBackups 10]
# ============================================================================

param(
    [int]$MaxBackups = 10
)

$ErrorActionPreference = "Stop"
$ROOT = Split-Path $PSScriptRoot -Parent
$BACKUP_DIR = Join-Path $ROOT "backups"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LOG_FILE = Join-Path $BACKUP_DIR "backup-log.txt"

# Create backup directory
if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    Write-Host "[BACKUP] Created backup directory: $BACKUP_DIR" -ForegroundColor Cyan
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry -ForegroundColor Gray
    Add-Content -Path $LOG_FILE -Value $logEntry
}

# Find workbook (check multiple locations)
$workbookPaths = @(
    (Join-Path $ROOT "ERP_v13.2.xlsm"),
    "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm",
    (Join-Path $ROOT "..\ERP_v13.2.xlsm")
)

$workbook = $null
foreach ($path in $workbookPaths) {
    if (Test-Path $path) {
        $workbook = (Get-Item $path).FullName
        break
    }
}

if (-not $workbook) {
    Write-Log "ERROR: ERP_v13.2.xlsm not found in any expected location"
    exit 1
}

Write-Log "Starting backup of: $workbook"

# Create backup filename
$backupName = "ERP_v13.2_backup_$TIMESTAMP.xlsm"
$backupPath = Join-Path $BACKUP_DIR $backupName

# Copy workbook
try {
    Copy-Item -Path $workbook -Destination $backupPath -Force
    $backupSize = (Get-Item $backupPath).Length
    Write-Log "Backup created: $backupName ($([math]::Round($backupSize/1KB, 1)) KB)"
} catch {
    Write-Log "ERROR: Failed to create backup - $_"
    exit 1
}

# Verify backup integrity (file exists and non-zero)
if (-not (Test-Path $backupPath)) {
    Write-Log "ERROR: Backup file not found after copy"
    exit 1
}

$backupFile = Get-Item $backupPath
if ($backupFile.Length -eq 0) {
    Write-Log "ERROR: Backup file is empty"
    exit 1
}

$originalSize = (Get-Item $workbook).Length
$sizeDiff = [math]::Abs($backupFile.Length - $originalSize)
$sizePct = [math]::Round(($sizeDiff / $originalSize) * 100, 2)

if ($sizePct -gt 5) {
    Write-Log "WARNING: Backup size differs by ${sizePct}% from original"
} else {
    Write-Log "Backup integrity verified (size match: ${sizePct}% diff)"
}

# Clean up old backups (keep only MaxBackups most recent)
$existingBackups = Get-ChildItem -Path $BACKUP_DIR -Filter "ERP_v13.2_backup_*.xlsm" | Sort-Object LastWriteTime -Descending
if ($existingBackups.Count -gt $MaxBackups) {
    $toDelete = $existingBackups | Select-Object -Skip $MaxBackups
    foreach ($old in $toDelete) {
        Remove-Item $old.FullName -Force
        Write-Log "Deleted old backup: $($old.Name)"
    }
}

# Summary
$remainingBackups = Get-ChildItem -Path $BACKUP_DIR -Filter "ERP_v13.2_backup_*.xlsm"
$totalSize = ($remainingBackups | Measure-Object -Property Length -Sum).Sum

Write-Log "Backup complete: $($remainingBackups.Count) backups, $([math]::Round($totalSize/1MB, 1)) MB total"
Write-Host "`n[BACKUP] Summary:" -ForegroundColor Green
Write-Host "  Backups retained: $($remainingBackups.Count) / $MaxBackups" -ForegroundColor Green
Write-Host "  Total backup size: $([math]::Round($totalSize/1MB, 1)) MB" -ForegroundColor Green
Write-Host "  Latest: $backupName" -ForegroundColor Green
