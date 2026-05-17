# ============================================================================
# system-health-test.ps1 — Academix v13.2 Ultimate System Verification
# Tests: paths, configs, tools, workbooks, bootstrap, memory, skills, pipeline
# ============================================================================

$ErrorActionPreference = "Continue"
$ROOT = Split-Path $PSScriptRoot -Parent
$OPENCODE_CONFIG = "$env:USERPROFILE\.config\opencode"
$DESKTOP = "$env:USERPROFILE\Desktop"
$PASS = 0; $FAIL = 0; $WARN = 0; $TOTAL = 0

function Test-Step {
    param([string]$Name, [scriptblock]$Block)
    $script:TOTAL++
    Write-Host "  " -NoNewline
    Write-Host "[$($script:TOTAL)]" -NoNewline -ForegroundColor Cyan
    Write-Host " $Name... " -NoNewline
    try {
        $result = & $Block
        if ($result -eq $true -or $result -eq $null) {
            Write-Host "[OK]" -ForegroundColor Green
            $script:PASS++
        } else {
            Write-Host "[FAIL] $result" -ForegroundColor Red
            $script:FAIL++
        }
    } catch {
        Write-Host "[FAIL] $_" -ForegroundColor Red
        $script:FAIL++
    }
}

function Test-Warn {
    param([string]$Name, [scriptblock]$Block)
    $script:TOTAL++
    Write-Host "  " -NoNewline
    Write-Host "[$($script:TOTAL)]" -NoNewline -ForegroundColor Cyan
    Write-Host " $Name... " -NoNewline
    try {
        $result = & $Block
        if ($result -eq $true -or $result -eq $null) {
            Write-Host "[OK]" -ForegroundColor Green
            $script:PASS++
        } else {
            Write-Host "[WARN] $result" -ForegroundColor Yellow
            $script:WARN++
        }
    } catch {
        Write-Host "[WARN] $_" -ForegroundColor Yellow
        $script:WARN++
    }
}

# ============================================================
Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  Academix v13.2 — ULTIMATE SYSTEM HEALTH CHECK" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# SECTION 1: CRITICAL PATHS
# ============================================================
Write-Host "─── [1/7] Critical Paths ───" -ForegroundColor Yellow

Test-Step "Project root exists" { Test-Path $ROOT }
Test-Step "Active workbook" { Test-Path "$ROOT\..\ERP_v13.2.xlsm" }
Test-Step "Compiled workbook" { Test-Path "$ROOT\ERP_v13.2.xlsm" }
Test-Step "VBA modules dir" { Test-Path "$ROOT\Software_Surgical_Edit\VBA_Modules" }
Test-Step "Thesis source" { Test-Path "$ROOT\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md" }
Test-Step "OpenCode config dir" { Test-Path $OPENCODE_CONFIG }
Test-Step "OpenCode opcode binary" { Test-Path "$DESKTOP\opencode-windows-x64-baseline\opencode.exe" }
Test-Step "Launcher v3.0" { Test-Path "$ROOT\OpenCode.bat" }

# ============================================================
# SECTION 2: CONFIGURATION FILES
# ============================================================
Write-Host ""
Write-Host "─── [2/7] Configuration Files ───" -ForegroundColor Yellow

Test-Step "opencode.json" { Test-Path "$OPENCODE_CONFIG\opencode.json" }
Test-Step "instructions.md" { Test-Path "$OPENCODE_CONFIG\instructions.md" }
Test-Step "AGENTS.md" { Test-Path "$OPENCODE_CONFIG\AGENTS.md" }
Test-Step "tui.json" { Test-Path "$OPENCODE_CONFIG\tui.json" }

# Validate opencode.json has all providers
$json = Get-Content "$OPENCODE_CONFIG\opencode.json" -Raw | ConvertFrom-Json
Test-Step "opencode.json has groq provider" { [bool]($json.provider.groq) }
Test-Step "opencode.json has google provider" { [bool]($json.provider.google) }
Test-Step "opencode.json has anthropic provider" { [bool]($json.provider.anthropic) }
Test-Step "opencode.json has openrouter provider" { [bool]($json.provider.openrouter) }
Test-Step "opencode.json has ollama provider" { [bool]($json.provider.ollama) }

# ============================================================
# SECTION 3: BOOTSTRAP & MEMORY
# ============================================================
Write-Host ""
Write-Host "─── [3/7] Bootstrap & Memory ───" -ForegroundColor Yellow

Test-Step "MASTER_BOOTSTRAP.xml" { Test-Path "$ROOT\.opencode\bootstrap\MASTER_BOOTSTRAP.xml" }
Test-Step "SKILL_INDEX.md" { Test-Path "$ROOT\.opencode\bootstrap\SKILL_INDEX.md" }
Test-Step "AGENT_BOOTSTRAP.md" { Test-Path "$ROOT\.opencode\bootstrap\AGENT_BOOTSTRAP.md" }
Test-Step "VBA_BUILDER.md" { Test-Path "$ROOT\.opencode\bootstrap\VBA_BUILDER.md" }
Test-Step "Engineering harness" { Test-Path "$ROOT\.opencode\agents\engineering-harness.md" }
Test-Step "notepad.md" { Test-Path "$HOME\.opencode\notepad.md" }
Test-Step "project-memory.json" { Test-Path "$HOME\.opencode\project-memory.json" }

# ============================================================
# SECTION 4: XML CONTEXT FILES
# ============================================================
Write-Host ""
Write-Host "─── [4/7] XML Context Files ───" -ForegroundColor Yellow

Test-Step "erp-project-context.xml" { Test-Path "$ROOT\Software_Surgical_Edit\erp-project-context.xml" }
Test-Step "erp-admin-paths.xml" { Test-Path "$ROOT\Software_Surgical_Edit\erp-admin-paths.xml" }
Test-Step "erp-agent-handoff.xml" { Test-Path "$ROOT\Software_Surgical_Edit\erp-agent-handoff.xml" }
Test-Step "erp-skills-projection.xml" { Test-Path "$ROOT\Software_Surgical_Edit\erp-skills-projection.xml" }
Test-Step "lsm-rag-context.xml" { Test-Path "$ROOT\milestone_13_2\rag\lsm-rag-context.xml" }

# ============================================================
# SECTION 5: BUILD TOOLKIT
# ============================================================
Write-Host ""
Write-Host "─── [5/7] Build Toolkit ───" -ForegroundColor Yellow

Test-Step "test-macros.ps1" { Test-Path "$ROOT\Software_Surgical_Edit\test-macros.ps1" }
Test-Step "vbe.ps1 (surgical edit)" { Test-Path "$ROOT\Software_Surgical_Edit\vbe.ps1" }
Test-Step "orchestrator.ps1" { Test-Path "$ROOT\Software_Surgical_Edit\orchestrator.ps1" }
Test-Step "thesis build.ps1" { Test-Path "$ROOT\Thesis_Surgical_Edit\build-thesis.ps1" }
Test-Step "dss-audit.ps1" { Test-Path "$ROOT\milestone_13_2\tests\dss-audit.ps1" }
Test-Step "protect-sheets.ps1" { Test-Path "$ROOT\milestone_13_2\tests\protect-sheets.ps1" }

# vbe-auto toolkit
Test-Step "vbe-auto build.ps1" { Test-Path "$ROOT\vbe-auto\build.ps1" }
Test-Step "vbe-auto verify.ps1" { Test-Path "$ROOT\vbe-auto\verify.ps1" }
Test-Step "vbe-auto vbe.ps1" { Test-Path "$ROOT\vbe-auto\vbe.ps1" }
Test-Step "vbe-auto config.json" { Test-Path "$ROOT\vbe-auto\vbe-auto-config.json" }

# ============================================================
# SECTION 6: SKILLS & AGENT SYSTEM
# ============================================================
Write-Host ""
Write-Host "─── [6/7] Skills & Agent System ───" -ForegroundColor Yellow

Test-Step "Skills directory exists" { Test-Path "$HOME\.opencode\skills" }

# Check key skills
$SKILLS = "$HOME\.opencode\skills"
Test-Step "vba-build skill" { Test-Path "$SKILLS\vba-build\SKILL.md" }
Test-Step "vba-debug skill" { Test-Path "$SKILLS\vba-debug\SKILL.md" }
Test-Step "vba-excel-sync skill" { Test-Path "$SKILLS\vba-excel-sync\SKILL.md" }
Test-Step "naming-cheatsheet skill" { Test-Path "$SKILLS\naming-cheatsheet\SKILL.md" }
Test-Step "verify skill" { Test-Path "$SKILLS\verify\SKILL.md" }
Test-Step "ralph skill" { Test-Path "$SKILLS\ralph\SKILL.md" }
Test-Step "plan skill" { Test-Path "$SKILLS\plan\SKILL.md" }
Test-Step "humanizer skill" { Test-Path "$SKILLS\humanizer\SKILL.md" }

# Agent routing files
Test-Step "agent-routing.xml" { Test-Path "$ROOT\milestone_13_2\config\agent-routing.xml" }
Test-Step "agent-system.xml" { Test-Path "$ROOT\milestone_13_2\config\agent-system.xml" }
Test-Step "milestone-13.2.xml" { Test-Path "$ROOT\milestone_13_2\config\milestone-13.2.xml" }
Test-Step "recap-next-moves.md" { Test-Path "$ROOT\milestone_13_2\recap-next-moves.md" }

# ============================================================
# SECTION 7: VBA MODULE VERIFICATION
# ============================================================
Write-Host ""
Write-Host "─── [7/7] VBA Modules ───" -ForegroundColor Yellow

$VBA = "$ROOT\Software_Surgical_Edit\VBA_Modules"
$basFiles = Get-ChildItem "$VBA\*.bas" -ErrorAction SilentlyContinue
$frmFiles = Get-ChildItem "$VBA\*.frm" -ErrorAction SilentlyContinue
$clsFiles = Get-ChildItem "$VBA\*.cls" -ErrorAction SilentlyContinue

Test-Step "VBA modules exist" { ($basFiles.Count -gt 0) }
Test-Step "VBA .bas count >= 29" { ($basFiles.Count -ge 29) }
Test-Step "VBA .frm exists" { ($frmFiles.Count -ge 1) }
Test-Step "VBA .cls exists" { ($clsFiles.Count -ge 1) }

# Check critical modules exist
$criticalModules = @("mod_Config", "mod_StockEngine", "mod_StockEntry_Logic", "mod_TransactionSafety", "MAIN_MACROS")
foreach ($mod in $criticalModules) {
    $path = "$VBA\$mod.bas"
    Test-Step "Module: $mod.bas" { Test-Path $path }
}

# Count total VBA lines
$totalLines = 0
Get-ChildItem "$VBA\*.bas", "$VBA\*.frm", "$VBA\*.cls" -ErrorAction SilentlyContinue | ForEach-Object {
    $totalLines += (Get-Content $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
}
Test-Warn "Total VBA source lines" { $totalLines -gt 9000 }

# Check for UTF-8 em dashes (known VBA issue)
$emDashCount = 0
Get-ChildItem "$VBA\*.bas", "$VBA\*.frm" -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match "[\u2014\u2013]") { $emDashCount++ }
}
Test-Warn "No UTF-8 em dashes in VBA" { 
    if ($emDashCount -gt 0) { "Found in $emDashCount files" } else { $true }
}

# ============================================================
# SUMMARY
# ============================================================
Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  RESULTS" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

$color = if ($FAIL -gt 0) { "Red" } elseif ($WARN -gt 0) { "Yellow" } else { "Green" }
Write-Host "  Passed: $PASS / $TOTAL" -ForegroundColor $color
Write-Host "  Failed: $FAIL" -ForegroundColor $(if ($FAIL -gt 0) { "Red" } else { "Green" })
Write-Host "  Warnings: $WARN" -ForegroundColor $(if ($WARN -gt 0) { "Yellow" } else { "Green" })

$pct = [math]::Round(($PASS / $TOTAL) * 100, 1)
Write-Host ""
Write-Host "  Score: $pct%" -ForegroundColor $color

if ($FAIL -gt 0) {
    Write-Host ""
    Write-Host "  ❌ $FAIL test(s) FAILED. Check above for ❌ entries." -ForegroundColor Red
}
if ($WARN -gt 0) {
    Write-Host "  ⚠️  $WARN warning(s). Non-critical but review if needed." -ForegroundColor Yellow
}
if ($FAIL -eq 0 -and $WARN -eq 0) {
    Write-Host "  ✅ ALL TESTS PASSED. System is healthy." -ForegroundColor Green
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
