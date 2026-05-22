param(
    [ValidateSet("repl","pipeline","inspect","skills","checkpoint","harness","status","help")]
    [string]$Mode = "repl",

    [string]$Arg = ""
)

$ROOT = Split-Path -Parent $PSCommandPath

Write-Host @"
╔══════════════════════════════════════════════════════╗
║         ACADEMIX v13.2 — Workzone Control           ║
║  Direction de l'Éducation, El Bayadh                ║
║  $(Get-Date -Format 'yyyy-MM-dd HH:mm')                    ║
╚══════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ─── Pre-flight: Verify core paths ─────────────────────────────────────
$errors = @()
if (-not (Test-Path (Join-Path $ROOT "Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1"))) { $errors += "thesis-doctor.ps1" }
if (-not (Test-Path (Join-Path $ROOT "scripts\checkpoint.ps1"))) { $errors += "checkpoint.ps1" }
if (-not (Test-Path (Join-Path $ROOT "scripts\autonomous-mode.ps1"))) { $errors += "autonomous-mode.ps1" }
if (-not (Test-Path (Join-Path $ROOT "vbe-auto\build.ps1"))) { $errors += "build.ps1" }
if (-not (Test-Path (Join-Path $ROOT "vbe-auto\verify.ps1"))) { $errors += "verify.ps1" }

if ($errors.Count -gt 0) {
    Write-Host "  ⚠ Missing dependencies: $($errors -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ All core systems ready" -ForegroundColor Green
}

# ─── Skill inventory ───────────────────────────────────────────────────
$globalSkills = @(Get-ChildItem "C:\Users\Administrator\.opencode\skills" -Directory)
$claudeSkills = @(Get-ChildItem "C:\Users\Administrator\.claude\skills" -Directory -ErrorAction SilentlyContinue)
$superSkills = @(Get-ChildItem (Join-Path $ROOT "superpowers\skills") -Directory -ErrorAction SilentlyContinue)
Write-Host "  Skills: $($globalSkills.Count) OpenCode + $($claudeSkills.Count) Claude + $($superSkills.Count) Superpowers" -ForegroundColor Gray

# ─── Mode Router ───────────────────────────────────────────────────────
switch ($Mode) {
    "repl" {
        Write-Host "  Mode: Autonomous REPL (thesis-doctor interactive)`n" -ForegroundColor Yellow
        & (Join-Path $ROOT "scripts\autonomous-mode.ps1") -Mode repl
    }
    "pipeline" {
        Write-Host "  Mode: Full Pipeline (build → verify → score)`n" -ForegroundColor Yellow
        & (Join-Path $ROOT "scripts\autonomous-mode.ps1") -Mode full
    }
    "inspect" {
        Write-Host "  Mode: COM Inspection`n" -ForegroundColor Yellow
        & (Join-Path $ROOT "Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1") inspect:all
    }
    "skills" {
        Write-Host "  Mode: Skills Inventory`n" -ForegroundColor Yellow
        Write-Host "OpenCode Skills ($($globalSkills.Count)):"
        $globalSkills | Sort-Object Name | ForEach-Object { Write-Host "  $_($_.Name)" }
        if ($claudeSkills) {
            Write-Host "`nClaude Code Skills ($($claudeSkills.Count)):"
            $claudeSkills | Sort-Object Name | ForEach-Object { Write-Host "  $_($_.Name)" }
        }
        if ($superSkills) {
            Write-Host "`nSuperpowers Skills ($($superSkills.Count)):"
            $superSkills | Sort-Object Name | ForEach-Object { Write-Host "  $_($_.Name)" }
        }
    }
    "checkpoint" {
        & (Join-Path $ROOT "scripts\checkpoint.ps1") status
    }
    "harness" {
        Write-Host "  Mode: Engineering Harness`n" -ForegroundColor Yellow
        if ($Arg) {
            & (Join-Path $ROOT "scripts\harness.ps1") $Arg
        } else {
            & (Join-Path $ROOT "scripts\harness.ps1")
        }
    }
    "status" {
        Write-Host "`n  ── System Status ──" -ForegroundColor Cyan
        Write-Host "  Thesis:       $(if (Test-Path (Join-Path $ROOT 'Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md')) { '✓' } else { '✗' })"
        Write-Host "  ERP Source:   $('✓' * ((Get-ChildItem (Join-Path $ROOT 'Software_Surgical_Edit\VBA_Modules') -Filter '*.bas' -ErrorAction SilentlyContinue).Count -gt 0 -or (Get-ChildItem (Join-Path $ROOT 'Software_Surgical_Edit') -Filter '*.bas' -ErrorAction SilentlyContinue).Count -gt 0))"
        Write-Host "  Delivery:     $(if (Test-Path (Join-Path $ROOT 'Final_Delivery_Layout\Memoire_DSS_Logistique_ElBayadh.pdf')) { '✓' } else { '✗' })"
        Write-Host "  Desktop:      $(if (Test-Path "C:\Users\Administrator\Desktop\Academix_v13.2_Delivery") { '✓' } else { '✗' })"
        Write-Host "  Build:        $(if (Test-Path (Join-Path $ROOT 'vbe-auto\build.ps1')) { '✓' } else { '✗' })"
        Write-Host "  Verify:       $(if (Test-Path (Join-Path $ROOT 'vbe-auto\verify.ps1')) { '✓' } else { '✗' })"
        Write-Host "  Checkpoints:  $(@(Get-ChildItem (Join-Path $ROOT '.checkpoints') -Directory -ErrorAction SilentlyContinue).Count)"
        & (Join-Path $ROOT "scripts\checkpoint.ps1") list
    }
    "help" {
        Write-Host @"

  ── Workzone Commands ──

  .\workzone.ps1                 REPL mode (default) — autonomous thesis doctor
  .\workzone.ps1 pipeline        Full build → verify → score pipeline
  .\workzone.ps1 inspect         COM inspection of current DOCX
  .\workzone.ps1 skills          List all available skills
  .\workzone.ps1 checkpoint      Show checkpoint status
  .\workzone.ps1 status          System health overview
  .\workzone.ps1 harness <cmd>   Engineering harness (bg, task, unlock, etc.)
  .\workzone.ps1 help            Show this message

  ── Quick Links ──
  CLASSIFICATION.md              Project directory taxonomy
  scripts/checkpoint.ps1         Save/restore checkpoints
  scripts/autonomous-mode.ps1    Full autonomous pipeline
  scripts/update-classification.ps1  Regenerate classification

  ── Skills ──
  thesis-docx                    Autonomous DOCX/MS Word COM control
  auto-thesis                    Thesis build pipeline
  verify                         Verification gate (105 checks)
  vba-build                      VBA compilation pipeline
  naming-cheatsheet              Naming conventions
  humanizer                      Remove AI writing artifacts
"@ -ForegroundColor Gray
    }
}
