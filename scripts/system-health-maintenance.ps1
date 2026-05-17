# Academix v13.2 — System Health & Maintenance Script
# Usage: .\system-health-maintenance.ps1
# Runs full health check + maintenance routines

$ErrorActionPreference = "Stop"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$links = Join-Path $root "links"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ACADEMIX v13.2 — HEALTH + MAINTENANCE" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ============================================================
# PHASE 1: HEALTH CHECK
# ============================================================
Write-Host "`n[PHASE 1] System Health Check" -ForegroundColor Yellow

# Git
$gitStatus = git status --porcelain 2>$null
$modifiedCount = ($gitStatus | Measure-Object).Count
Write-Host "  Git: $(if ($modifiedCount -gt 0) { "$modifiedCount modified files" } else { "clean" })"

# Symlinks
$brokenLinks = @()
if (Test-Path $links) {
    $allLinks = Get-ChildItem -Path $links -Recurse -Force | Where-Object { $_.LinkType -eq 'SymbolicLink' }
    foreach ($link in $allLinks) {
        $target = $link.Target
        if (-not (Test-Path $target)) {
            $brokenLinks += $link.FullName
        }
    }
}
Write-Host "  Symlinks: $(if ($brokenLinks.Count -eq 0) { "ALL OK" } else { "$($brokenLinks.Count) BROKEN" })" -ForegroundColor $(if ($brokenLinks.Count -eq 0) { "Green" } else { "Red" })

# Core files
$coreFiles = @(
    "ERP_v13.2.xlsm",
    "Software_Surgical_Edit\VBA_Modules",
    "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md",
    ".crossflow\MASTER_CONTEXT.md",
    ".crossflow\HANDOFF.md",
    ".opencode\bootstrap\MASTER_BOOTSTRAP.xml",
    "scripts\harness.ps1",
    "vbe-auto\build.ps1",
    "vbe-auto\verify.ps1"
)
$missingFiles = @()
foreach ($f in $coreFiles) {
    if (-not (Test-Path (Join-Path $root $f))) {
        $missingFiles += $f
    }
}
Write-Host "  Core files: $(if ($missingFiles.Count -eq 0) { "ALL PRESENT" } else { "$($missingFiles.Count) MISSING" })" -ForegroundColor $(if ($missingFiles.Count -eq 0) { "Green" } else { "Red" })

# ============================================================
# PHASE 2: MAINTENANCE
# ============================================================
Write-Host "`n[PHASE 2] Maintenance Routines" -ForegroundColor Yellow

# Clean .tmp files
$tmpCount = (Get-ChildItem -Path $root -Filter "*.tmp" -Recurse -ErrorAction SilentlyContinue).Count
if ($tmpCount -gt 0) {
    Write-Host "  Found $tmpCount .tmp files (leaving in place — may be in use)"
}

# Check overflow size
$overflowPath = Join-Path $root ".crossflow\OVERFLOW"
if (Test-Path $overflowPath) {
    $overflowSize = (Get-ChildItem -Path $overflowPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host "  Overflow: $([math]::Round($overflowSize/1KB, 1)) KB ($(Get-ChildItem -Path $overflowPath -File).Count files)"
}

# Check task staleness
$tasksPath = Join-Path $root ".tasks"
if (Test-Path $tasksPath) {
    $tasks = Get-ChildItem -Path $tasksPath -Filter "task_*.json" -ErrorAction SilentlyContinue
    $completedCount = 0
    foreach ($task in $tasks) {
        $content = Get-Content $task.FullName -Raw | ConvertFrom-Json
        if ($content.status -eq "completed") { $completedCount++ }
    }
    Write-Host "  Tasks: $($tasks.Count) total, $completedCount completed"
}

# Verify symlink hub integrity
if (Test-Path $links) {
    $linkCount = (Get-ChildItem -Path $links -Recurse -Force | Where-Object { $_.LinkType -eq 'SymbolicLink' }).Count
    Write-Host "  Symlink hub: $linkCount active links"
    if ($brokenLinks.Count -gt 0) {
        Write-Host "  WARNING: $($brokenLinks.Count) broken symlinks detected!" -ForegroundColor Red
        $brokenLinks | ForEach-Object { Write-Host "    BROKEN: $_" -ForegroundColor Red }
    }
}

# ============================================================
# PHASE 3: RECOMMENDATIONS
# ============================================================
Write-Host "`n[PHASE 3] Recommendations" -ForegroundColor Yellow

if ($modifiedCount -gt 0) {
    Write-Host "  → $modifiedCount uncommitted changes — consider committing or stashing" -ForegroundColor Yellow
}
if ($brokenLinks.Count -gt 0) {
    Write-Host "  → Run symlink repair to fix $($brokenLinks.Count) broken links" -ForegroundColor Red
}
if ($missingFiles.Count -gt 0) {
    Write-Host "  → CRITICAL: Core files missing — check git status" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  MAINTENANCE COMPLETE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
