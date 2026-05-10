# =============================================================================
# Academix v13.2 — Portable Profile Module
# Source this from your PowerShell $PROFILE to get all shortcuts + PATH setup
# Location: Project root (move project anywhere, update one path in $PROFILE)
# =============================================================================

$script:ProjRoot = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$script:Desktop   = "C:\Users\Administrator\Desktop"
$script:OcBin     = "$Desktop\opencode-windows-x64-baseline"

# ── PATH Setup ──────────────────────────────────────────────────────────────
# Ensure Desktop + opencode binary are in PATH (avoids orphan npm conflicts)
$needed = @($Desktop, $OcBin)
$current = $env:Path -split ';'
$add = $needed | Where-Object { $_ -and ($current -notcontains $_) }
if ($add) {
    $env:Path = ($needed -join ';') + ';' + $env:Path
}

# ── Navigation ──────────────────────────────────────────────────────────────
function cdproj  { Set-Location $script:ProjRoot; Write-Host "📍 $script:ProjRoot" -ForegroundColor Cyan }
function cdsrc   { Set-Location "$script:ProjRoot\Software_Surgical_Edit\VBA_Modules"; Write-Host "📁 VBA Modules" -ForegroundColor Cyan }
function cdthesis{ Set-Location "$script:ProjRoot\Thesis_Surgical_Edit"; Write-Host "📄 Thesis" -ForegroundColor Cyan }
function cdbuild { Set-Location "$script:ProjRoot\Software_Surgical_Edit"; Write-Host "🔧 Build folder" -ForegroundColor Cyan }
function cddesk  { Set-Location $script:Desktop; Write-Host "🖥️  Desktop" -ForegroundColor Cyan }

# ── OpenCode Launcher Shortcuts (runs in current terminal — no vanishing windows) ──
# Rule of thumb:
#   oc / ol  → Llama 3.3 70B (fast VBA + prose, zero rate limits)
#   on       → Nemotron 120B (1M ctx, heavy analysis, deep reasoning)
#   og       → Qwen3 32B (fastest, explore/debug)
function oc     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "groq/llama-3.3-70b-versatile"; Pop-Location }
function ol     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "groq/llama-3.3-70b-versatile"; Pop-Location }
function og     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "groq/qwen/qwen3-32b"; Pop-Location }
function ov     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "groq/meta-llama/llama-4-scout-17b-16e-instruct"; Pop-Location }
function ogm    { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "google/gemini-2.5-flash"; Pop-Location }
function oq     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "openrouter/qwen/qwen3.6-plus"; Pop-Location }
function ophi4  { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "ollama/phi4-mini:3.8b-q4_K_M"; Pop-Location }
function oqwen3 { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "ollama/qwen3:1.7b"; Pop-Location }
function oo     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "ollama/qwen2.5-coder:1.5b"; Pop-Location }
function on     { Push-Location $script:ProjRoot; & "$script:OcBin\opencode.exe" -m "openrouter/nvidia/nemotron-3-super-120b-a12b:free"; Pop-Location }

# ── Build & Verify ──────────────────────────────────────────────────────────
function build  { & "$script:ProjRoot\Software_Surgical_Edit\build.ps1" }
function verify { & "$script:ProjRoot\Software_Surgical_Edit\verify.ps1" }
function health { & "$script:ProjRoot\system-health-test.ps1" }
function thesis { & "$script:ProjRoot\Thesis_Surgical_Edit\build-thesis.ps1" }

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
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  Academix v13.2 — Portable Profile Active ║" -ForegroundColor Magenta
Write-Host "╠══════════════════════════════════════════╣" -ForegroundColor Magenta
Write-Host "║  cdproj   → Project root                 ║" -ForegroundColor Cyan
Write-Host "║  cdsrc    → VBA source files             ║" -ForegroundColor Cyan
Write-Host "║  cdthesis → Thesis folder                ║" -ForegroundColor Cyan
Write-Host "║  build    → Rebuild workbook             ║" -ForegroundColor Cyan
Write-Host "║  verify   → 97 checks                    ║" -ForegroundColor Cyan
Write-Host "║  health   → System test                  ║" -ForegroundColor Cyan
Write-Host "║  oc/ol    → Llama 3.3 70B (fast VBA/prose) ║" -ForegroundColor Green
Write-Host "║  og       → Qwen 3 32B (coding, fast)       ║" -ForegroundColor Green
Write-Host "║  ov       → Llama 4 Scout (VISION, 128K)  ║" -ForegroundColor Cyan
Write-Host "║  ogm      → Gemini 2.5 Flash (VISION, 1M) ║" -ForegroundColor Cyan
Write-Host "║  oq       → Qwen 3.6 Plus (1M ctx, FREE!)║" -ForegroundColor Magenta
Write-Host "║  on       → Nemotron 120B (1M ctx, Opus-tier)║" -ForegroundColor Magenta
Write-Host "║  oo       → Ollama Qwen 1.5B (slow)        ║" -ForegroundColor Yellow
Write-Host "║  ophi4    → Phi4-mini 3.8B (CPU coding)   ║" -ForegroundColor DarkCyan
Write-Host "║  oqwen3   → Qwen3 1.7B (CPU reasoning)    ║" -ForegroundColor DarkCyan
Write-Host "║  docs     → Open user guide              ║" -ForegroundColor Cyan
Write-Host "║  ox       → Open project in Explorer     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
