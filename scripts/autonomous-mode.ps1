param(
    [ValidateSet("full","build","inspect","fix","verify","repl","skills","checkpoint")]
    [string]$Mode = "repl",

    [string]$Command = ""
)

$ROOT = Split-Path -Parent $PSScriptRoot
$THESIS_DOCTOR = Join-Path $ROOT "Thesis_Surgical_Edit\thesis-doctor.ps1"
$CHECKPOINT = Join-Path $ROOT "scripts\checkpoint.ps1"
$HANDOFF = Join-Path $ROOT ".crossflow\HANDOFF.md"
$NOTEPAD = "C:\Users\Administrator\.opencode\notepad.md"

# ─── Skill Loader ────────────────────────────────────────────────────────────
function Invoke-SkillLoader {
    Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  AUTONOMOUS MODE — Skill Loader" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan

    $criticalSkills = @(
        @{Name="verify"; Path="C:\Users\Administrator\.opencode\skills\verify\SKILL.md"}
        @{Name="thesis-docx"; Path="C:\Users\Administrator\.opencode\skills\thesis-docx\SKILL.md"}
        @{Name="auto-thesis"; Path="C:\Users\Administrator\.opencode\skills\auto-thesis\SKILL.md"}
        @{Name="vba-build"; Path="C:\Users\Administrator\.opencode\skills\vba-build\SKILL.md"}
        @{Name="vba-debug"; Path="C:\Users\Administrator\.opencode\skills\vba-debug\SKILL.md"}
        @{Name="naming-cheatsheet"; Path="C:\Users\Administrator\.opencode\skills\naming-cheatsheet\SKILL.md"}
        @{Name="humanizer"; Path="C:\Users\Administrator\.opencode\skills\humanizer\SKILL.md"}
    )

    $loaded = 0; $missing = 0
    foreach ($skill in $criticalSkills) {
        if (Test-Path $skill.Path) {
            Write-Host "  ✓ $($skill.Name)" -ForegroundColor Green
            $loaded++
        } else {
            Write-Host "  ✗ $($skill.Name) (SKILL.md not found)" -ForegroundColor Yellow
            $missing++
        }
    }
    Write-Host "  Skills loaded: $loaded  Missing: $missing" -ForegroundColor $(
        if ($missing -eq 0) { "Green" } else { "Yellow" }
    )
    Write-Host "───────────────────────────────────────────`n" -ForegroundColor Gray
}

# ─── Workflow ─────────────────────────────────────────────────────────────────
function Invoke-Pipeline {
    param([string]$Mode)

    switch ($Mode) {
        "build" {
            & $CHECKPOINT save "pre-build"
            & $THESIS_DOCTOR pipeline:build
            & $CHECKPOINT save "post-build"
            break
        }
        "inspect" {
            & $THESIS_DOCTOR inspect:all
            break
        }
        "fix" {
            & $CHECKPOINT save "pre-fix"
            & $THESIS_DOCTOR fix:none
            & $THESIS_DOCTOR pipeline:verify
            & $CHECKPOINT save "post-fix"
            break
        }
        "verify" {
            & $THESIS_DOCTOR pipeline:verify
            break
        }
        "full" {
            Write-Host "`n  [AUTONOMOUS] Starting full pipeline..." -ForegroundColor Cyan
            & $CHECKPOINT save "pre-full"

            # Step 1: Build
            Write-Host "`n  [STEP 1/4] Building..." -ForegroundColor Yellow
            & $THESIS_DOCTOR pipeline:build

            # Step 2: Verify
            Write-Host "`n  [STEP 2/4] Verifying..." -ForegroundColor Yellow
            & $THESIS_DOCTOR pipeline:verify

            # Step 3: Score
            Write-Host "`n  [STEP 3/4] Scoring..." -ForegroundColor Yellow
            & $THESIS_DOCTOR score:all

            # Step 4: Save report
            Write-Host "`n  [STEP 4/4] Saving report..." -ForegroundColor Yellow
            & $THESIS_DOCTOR save:report

            & $CHECKPOINT save "post-full"
            Write-Host "`n  [AUTONOMOUS] Full pipeline complete." -ForegroundColor Green
            break
        }
        "skills" {
            Invoke-SkillLoader
            break
        }
        "checkpoint" {
            switch ($Command) {
                "save"    { & $CHECKPOINT save "manual-$(Get-Date -Format 'HHmmss')" }
                "list"    { & $CHECKPOINT list }
                "restore" { & $CHECKPOINT restore "latest" }
                default   { & $CHECKPOINT status }
            }
            break
        }
        "repl" {
            Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
            Write-Host "  AUTONOMOUS MODE — Thesis Doctor REPL" -ForegroundColor Cyan
            Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
            Write-Host "  Skills: pre-loaded" -ForegroundColor Gray
            Write-Host "  Checkpoint: active" -ForegroundColor Gray
            Write-Host "  Thesis Doctor: ready" -ForegroundColor Gray
            Write-Host "───────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "  REPL Commands:" -ForegroundColor White
            Write-Host "    pipeline:full      Full build+verify+score" -ForegroundColor Gray
            Write-Host "    pipeline:build     Build only" -ForegroundColor Gray
            Write-Host "    pipeline:verify    Verify only" -ForegroundColor Gray
            Write-Host "    inspect:all        COM inspection" -ForegroundColor Gray
            Write-Host "    fix:none           Apply all fixes" -ForegroundColor Gray
            Write-Host "    score:all          Quality scorecard" -ForegroundColor Gray
            Write-Host "    save:report        Save inspection report" -ForegroundColor Gray
            Write-Host "    save:pdf           Save as PDF" -ForegroundColor Gray
            Write-Host "    help               Show all commands" -ForegroundColor Gray
            Write-Host "    quit               Exit autonomous mode" -ForegroundColor Gray
            Write-Host "───────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "  Type 'save:report' after each session." -ForegroundColor Yellow
            Write-Host "  Type 'help' for full command list.`n" -ForegroundColor Gray

            & $THESIS_DOCTOR
            break
        }
    }
}

# ─── Main ─────────────────────────────────────────────────────────────────────
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "  ACADEMIX v13.3 — Autonomous Mode" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Gray
Write-Host ("=" * 50) -ForegroundColor Cyan

Invoke-SkillLoader

if ($Mode -eq "full" -and -not $Command) {
    Invoke-Pipeline "full"
} elseif ($Mode -eq "checkpoint") {
    Invoke-Pipeline "checkpoint"
} else {
    Invoke-Pipeline $Mode
}

Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Session complete." -ForegroundColor Green
Write-Host "  Next: & '.\scripts\autonomous-mode.ps1' -Mode repl" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
