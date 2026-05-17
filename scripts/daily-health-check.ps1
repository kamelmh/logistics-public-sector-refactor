# Academix v13.2 — Automated Daily Health Check
# Usage: Scheduled via Windows Task Scheduler (daily at 09:00)
# Logs to: .opencode/state/health-logs/

$ErrorActionPreference = "Continue"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$logDir = Join-Path $root ".opencode\state\health-logs"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "health-$timestamp.log"

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry -Encoding UTF8
}

Write-Log "=== DAILY HEALTH CHECK START ===" "INFO"

# 1. Git Status
try {
    $status = git status --porcelain 2>$null
    $modified = ($status | Measure-Object).Count
    if ($modified -gt 0) {
        Write-Log "WARNING: $modified uncommitted files" "WARN"
    } else {
        Write-Log "Git: clean" "INFO"
    }
} catch {
    Write-Log "Git check failed: $_" "ERROR"
}

# 2. Core Files
$coreFiles = @(
    "ERP_v13.2.xlsm",
    "Software_Surgical_Edit\VBA_Modules",
    "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md",
    ".crossflow\MASTER_CONTEXT.md",
    ".crossflow\HANDOFF.md",
    "scripts\harness.ps1",
    "vbe-auto\build.ps1",
    "vbe-auto\verify.ps1"
)
$missing = @()
foreach ($f in $coreFiles) {
    if (-not (Test-Path (Join-Path $root $f))) {
        $missing += $f
        Write-Log "MISSING: $f" "ERROR"
    }
}
if ($missing.Count -eq 0) {
    Write-Log "Core files: ALL PRESENT" "INFO"
}

# 3. ERP Workbook Size
try {
    $erp = Get-Item (Join-Path $root "ERP_v13.2.xlsm")
    $sizeKB = [math]::Round($erp.Length/1KB)
    Write-Log "ERP workbook: ${sizeKB} KB" "INFO"
    if ($sizeKB -lt 500) {
        Write-Log "WARNING: ERP workbook unusually small (<500 KB)" "WARN"
    }
} catch {
    Write-Log "ERP size check failed: $_" "ERROR"
}

# 4. Thesis Output
try {
    $docx = Get-Item (Join-Path $root "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx")
    $pdf = Get-Item (Join-Path $root "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.pdf")
    Write-Log "Thesis DOCX: $([math]::Round($docx.Length/1KB)) KB" "INFO"
    Write-Log "Thesis PDF: $([math]::Round($pdf.Length/1KB)) KB" "INFO"
} catch {
    Write-Log "Thesis output check failed: $_" "ERROR"
}

# 5. Symlink Hub
try {
    $links = Get-ChildItem -Path (Join-Path $root "links") -Recurse -Force | Where-Object { $_.LinkType -eq 'SymbolicLink' }
    $broken = @()
    foreach ($link in $links) {
        if (-not (Test-Path $link.Target)) {
            $broken += $link.Name
        }
    }
    if ($broken.Count -gt 0) {
        Write-Log "WARNING: $($broken.Count) broken symlinks: $($broken -join ', ')" "WARN"
    } else {
        Write-Log "Symlinks: $($links.Count) active, 0 broken" "INFO"
    }
} catch {
    Write-Log "Symlink check failed: $_" "ERROR"
}

# 6. Disk Space
try {
    $drive = Get-PSDrive C
    $freeGB = [math]::Round($drive.Free/1GB, 1)
    Write-Log "Disk space (C:): ${freeGB} GB free" "INFO"
    if ($freeGB -lt 5) {
        Write-Log "CRITICAL: Less than 5 GB free on C:" "CRITICAL"
    }
} catch {
    Write-Log "Disk space check failed: $_" "ERROR"
}

# 7. Backup
try {
    $backupName = "ERP_v13.2_BACKUP_$(Get-Date -Format 'yyyyMMdd').xlsm"
    $backupPath = Join-Path $root $backupName
    if (-not (Test-Path $backupPath)) {
        Copy-Item (Join-Path $root "ERP_v13.2.xlsm") $backupPath -Force
        Write-Log "Backup created: $backupName" "INFO"
    } else {
        Write-Log "Backup already exists for today" "INFO"
    }
} catch {
    Write-Log "Backup failed: $_" "ERROR"
}

# Summary
Write-Log "=== DAILY HEALTH CHECK COMPLETE ===" "INFO"

# Exit with error code if any critical issues
$hasCritical = Select-String -Path $logFile -Pattern "CRITICAL" -Quiet
if ($hasCritical) {
    Write-Host "CRITICAL ISSUES DETECTED - Check $logFile" -ForegroundColor Red
    exit 1
}
exit 0
