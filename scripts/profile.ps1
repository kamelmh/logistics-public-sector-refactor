# =============================================================================
# Academix v13.2 — Portable Profile Module
# Source this from your PowerShell $PROFILE to get all shortcuts + PATH setup
# Location: Project root (move project anywhere, update one path in $PROFILE)
# Updated: 2026-05-10 — Portable launcher paths, OpenCode wrapper function
# =============================================================================

$script:ProjRoot = Split-Path $PSScriptRoot -Parent
$script:Desktop   = "$env:USERPROFILE\Desktop"
$script:OcBin     = "$Desktop\opencode-windows-x64-baseline"
$script:OcBat     = "$ProjRoot\OpenCode.bat"

# ── PATH Setup ──────────────────────────────────────────────────────────────
$needed = @($Desktop, $OcBin)
$current = $env:Path -split ';'
$add = $needed | Where-Object { $_ -and ($current -notcontains $_) }
if ($add) {
    $env:Path = ($needed -join ';') + ';' + $env:Path
}

# ── Navigation ──────────────────────────────────────────────────────────────
function cdproj  { Set-Location $script:ProjRoot; Write-Host "ProjRoot: $script:ProjRoot" -ForegroundColor Cyan }
function cdsrc   { Set-Location "$script:ProjRoot\Software_Surgical_Edit\VBA_Modules"; Write-Host "VBA Modules" -ForegroundColor Cyan }
function cdthesis { Set-Location "$script:ProjRoot\Thesis_Surgical_Edit"; Write-Host "Thesis" -ForegroundColor Cyan }
function cdbuild { Set-Location "$script:ProjRoot\Software_Surgical_Edit"; Write-Host "Build folder" -ForegroundColor Cyan }
function cddesk  { Set-Location $script:Desktop; Write-Host "Desktop" -ForegroundColor Cyan }

# ── OpenCode Launcher Shortcuts ─────────────────────────────────────────────
# Rule of thumb:
#   oc / ol  → Llama 3.3 70B (fast VBA + prose, daily driver)
#   og       → Qwen3 32B (fastest explore/debug/audit)
#   ogg      → Gemma 4 26B (256K ctx, multimodal)
#   ogg31b   → Gemma 4 31B IT (stronger reasoning)
#   og3      → Gemini 3 Flash Preview (replaces 2.5 Flash)
#   oring    → Ring 2.6 1T (Kimi K2.6, 262K ctx, FREE OpenRouter)
#   on       → Nemotron 120B (1M ctx, OpenRouter free)
#   ophi4    → Phi4-mini 3.8B (CPU coding, offline)
#   oo       → Qwen 1.5B (offline fallback, slow)
function oc     { Push-Location $script:ProjRoot; OpenCode llama; Pop-Location }
function ol     { Push-Location $script:ProjRoot; OpenCode llama; Pop-Location }
function og     { Push-Location $script:ProjRoot; OpenCode groq; Pop-Location }
function ogg    { Push-Location $script:ProjRoot; OpenCode gemma; Pop-Location }
function ogg31b { Push-Location $script:ProjRoot; OpenCode gemma-31b; Pop-Location }
function oggl   { Push-Location $script:ProjRoot; OpenCode gemma-local; Pop-Location }
function og3    { Push-Location $script:ProjRoot; OpenCode gemini3; Pop-Location }
function oring  { Push-Location $script:ProjRoot; OpenCode ring; Pop-Location }
function on     { Push-Location $script:ProjRoot; OpenCode nemotron; Pop-Location }
function ophi4  { Push-Location $script:ProjRoot; OpenCode phi4; Pop-Location }
function oqwen3 { Push-Location $script:ProjRoot; OpenCode qwen3; Pop-Location }
function oo     { Push-Location $script:ProjRoot; OpenCode ollama; Pop-Location }
function opicker { Push-Location $script:ProjRoot; & $script:OcBat "picker"; Pop-Location }

# ── Build & Verify ──────────────────────────────────────────────────────────
function build  { & "$script:ProjRoot\vbe-auto\build.ps1" -ConfigPath "$script:ProjRoot\vbe-auto\vbe-auto-config.json" }
function verify { & "$script:ProjRoot\vbe-auto\verify.ps1" -ConfigPath "$script:ProjRoot\vbe-auto\vbe-auto-config.json" }
function health { & "$script:ProjRoot\scripts\system-health-test.ps1" }
function thesis { & "$script:ProjRoot\Thesis_Surgical_Edit\build-thesis.ps1" }

# ── AUTO Pipeline ──────────────────────────────────────────────────────────
function autobuild  { build; verify }
function autoverify { verify }
function autotest   { & "$script:ProjRoot\Software_Surgical_Edit\test-macros.ps1" }
function autoaudit  { & "$script:ProjRoot\milestone_13_2\tests\dss-audit.ps1" }
function autocheck  { health; git -C $script:ProjRoot status }
function autofix    { build; verify; autotest; autoaudit }
function OpenCode   { & $script:OcBat $args }
function autoclean  { & $script:OcBat autoclean }
function status     { & $script:OcBat status }

# ── File Browsers ───────────────────────────────────────────────────────────
function docs   { notepad "$script:ProjRoot\USER_GUIDE.md" }
function ox     { Invoke-Item $script:ProjRoot }
function notes  { notepad "$env:USERPROFILE\.opencode\notepad.md" }

# ── Listings ────────────────────────────────────────────────────────────────
function lsrc  { Get-ChildItem "$script:ProjRoot\Software_Surgical_Edit\VBA_Modules\*.bas" | Select-Object Name }
function lt    { Get-ChildItem "$script:ProjRoot\Thesis_Surgical_Edit\*.md" | Select-Object Name }
function lxml  { Get-ChildItem "$script:ProjRoot\Software_Surgical_Edit\*.xml" | Select-Object Name }

# ── Git (Quick) ─────────────────────────────────────────────────────────────
function gst   { git -C $script:ProjRoot status }
function gdiff { git -C $script:ProjRoot diff }
function glog  { git -C $script:ProjRoot log --oneline -10 }

# ── Welcome ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Academix v13.2  Portable Profile Active" -ForegroundColor Magenta
Write-Host "cdproj  Project root" -ForegroundColor Cyan
Write-Host "cdsrc   VBA source files" -ForegroundColor Cyan
Write-Host "cdthesis  Thesis folder" -ForegroundColor Cyan
Write-Host "build   Rebuild workbook" -ForegroundColor Cyan
Write-Host "verify  137 checks" -ForegroundColor Cyan
Write-Host "health  System test" -ForegroundColor Cyan
Write-Host "oc/ol   Llama 3.3 70B (fast VBA/prose)" -ForegroundColor Green
Write-Host "og      Qwen 3 32B (coding, fast)" -ForegroundColor Green
Write-Host "ogg     Gemma 4 26B (256K ctx, multimodal)" -ForegroundColor Cyan
Write-Host "ogg31b  Gemma 4 31B IT (stronger reasoning)" -ForegroundColor Cyan
Write-Host "oggl    Gemma 4 e2b local (128K ctx, offline)" -ForegroundColor DarkCyan
Write-Host "og3     Gemini 3 Flash Preview (replaces 2.5)" -ForegroundColor Cyan
Write-Host "oring   Ring 2.6 1T / Kimi K2.6 (262K ctx, FREE)" -ForegroundColor Cyan
Write-Host "on      Nemotron 120B (1M ctx, OpenRouter)" -ForegroundColor DarkYellow
Write-Host "opicker Model picker (TUI, interactive)" -ForegroundColor Cyan
Write-Host "oo      Ollama Qwen 1.5B (slow fallback)" -ForegroundColor Yellow
Write-Host "ophi4   Phi4-mini 3.8B (CPU coding)" -ForegroundColor DarkCyan
Write-Host "oqwen3  Qwen3 1.7B (CPU reasoning)" -ForegroundColor DarkCyan
Write-Host "autobuild  Build + verify" -ForegroundColor Magenta
Write-Host "autotest  Run macro tests" -ForegroundColor Magenta
Write-Host "autoaudit Run DSS audit" -ForegroundColor Magenta
Write-Host "autofix   Full pipeline (build+verify+test+audit)" -ForegroundColor Magenta
Write-Host "autocheck System health + git status" -ForegroundColor Magenta
Write-Host "autoclean Purge old files (30-day)" -ForegroundColor Magenta
Write-Host "status    Project health overview" -ForegroundColor Magenta
Write-Host "docs    Open user guide" -ForegroundColor Cyan
Write-Host "ox      Open project in Explorer" -ForegroundColor Cyan
Write-Host ""
