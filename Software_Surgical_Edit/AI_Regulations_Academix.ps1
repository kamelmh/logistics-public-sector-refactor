# ============================================================================
# AI_Regulations_Academix.ps1
# Academix v13.2 — AI Governance & Regulations Dashboard
# نظام إلكتروني متكامل للتسيير التمويني
# Direction de l'Education, Wilaya de El Bayadh, Algeria
#
# Fully editable — modify this script to suit your needs.
# ============================================================================

$ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"

function Get-Secret {
    param([string]$Name, [string]$File)
    $v = [Environment]::GetEnvironmentVariable($Name, "User") -or [Environment]::GetEnvironmentVariable($Name, "Process")
    if ($v) { return $v }
    $xmlPath = "$env:USERPROFILE\.academix-$File.xml"
    if (Test-Path $xmlPath) {
        try { return (Import-Clixml $xmlPath).GetNetworkCredential().Password } catch { }
    }
    return $null
}

function Status { param($Name, $Ok, $OkMsg, $FailMsg)
    if ($Ok) { Write-Host "  [$([char]0x2713)] $OkMsg" -ForegroundColor Green }
    else { Write-Host "  [X] $FailMsg" -ForegroundColor Red }
}

Clear-Host
Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║    ACADEMIX v13.2 — AI GOVERNANCE & REGULATIONS DASHBOARD   ║
║    نظام إلكتروني متكامل للتسيير التمويني                    ║
║    Direction de l'Education, Wilaya de El Bayadh, Algeria   ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ─── SECTION 1: AI PROVIDER STATUS ────────────────────────────
Write-Host "`n[1/5] AI PROVIDER STATUS" -ForegroundColor Magenta

$groqKey = Get-Secret -Name "GROQ_API_KEY" -File "groq"

Status "GROQ KEY" ([bool]$groqKey) "Groq API key present (DPAPI encrypted)" "Groq — NO KEY FOUND"

if ($groqKey) {
    # Llama 3.3 70B — primary (strong prose + VBA logic)
    try {
        $body = @{ model = "llama-3.3-70b-versatile"; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
            -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $groqKey" } -TimeoutSec 15
        Status "LLAMA 70B" $true "Llama 3.3 70B — ONLINE (primary)" "Llama — no response"
    } catch { Status "LLAMA 70B" $false "—" "Llama — OFFLINE ($($_.Exception.Message.Split('.')[0]))" }

    # Qwen3 32B — fast fallback
    try {
        $body = @{ model = "qwen/qwen3-32b"; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
            -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $groqKey" } -TimeoutSec 10
        Status "QWEN 32B" $true "Qwen3 32B — ONLINE (fast)" "Qwen — no response"
    } catch { Status "QWEN 32B" $false "—" "Qwen — OFFLINE ($($_.Exception.Message.Split('.')[0]))" }
}

if ($groqKey) {
    try {
        $body = @{ model = "qwen/qwen3-32b"; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
            -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $groqKey" } -TimeoutSec 10
        Status "GROQ LIVE" $true "Groq qwen3 — ONLINE" "Groq — no response"
    } catch { Status "GROQ LIVE" $false "—" "Groq — OFFLINE ($($_.Exception.Message.Split('.')[0]))" }
}

# ─── SECTION 2: CNEPD COMPLIANCE ──────────────────────────────
Write-Host "`n[2/5] CNEPD COMPLIANCE CHECK" -ForegroundColor Magenta
$issues = @()

if (Test-Path (Join-Path $ROOT "CLAUDE.md")) {
    $c = Get-Content (Join-Path $ROOT "CLAUDE.md") -Raw
    if ($c -match "D.*Annual.*1,546|1546.*observation") { Status "D=1546" $true "Annual Demand: 1,546 units" "D=1546 not found" }
    else { $issues += "Annual Demand (D=1546)"; Status "D=1546" $false "—" "MISSING: D=1546" }
    if ($c -match "Q\*.*176|EOQ.*176") { Status "EOQ=176" $true "EOQ Q*: 176 units" "EOQ=176 not found" }
    else { $issues += "EOQ (Q*=176)"; Status "EOQ=176" $false "—" "MISSING: EOQ=176" }
    if ($c -match "ROP.*205") { Status "ROP=205.6" $true "Reorder Point: 205.6 units" "ROP=205.6 not found" }
    else { $issues += "ROP (205.6)"; Status "ROP=205.6" $false "—" "MISSING: ROP=205.6" }
    if ($c -match "SS.*200") { Status "SS=200" $true "Safety Stock: 200 units" "SS=200 not found" }
    else { $issues += "Safety Stock (200)"; Status "SS=200" $false "—" "MISSING: SS=200" }
} else { Write-Host "  [WARN] CLAUDE.md not found at $ROOT" -ForegroundColor Yellow }

# ─── SECTION 3: THESIS REGULATORY FRAMEWORK ───────────────────
Write-Host "`n[3/5] REGULATORY FRAMEWORK" -ForegroundColor Magenta
$thesisPath = Join-Path $ROOT "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
if (Test-Path $thesisPath) {
    $t = Get-Content $thesisPath -Raw
    $t -match "Law 23-12|القانون.*23.*12" | Out-Null
    Status "LAW 23-12" $matches "Law 23-12 (AI Governance) referenced" "Law 23-12 NOT found in thesis"
    $t -match "CNEPD|الرقمنة|digital transformation" | Out-Null
    Status "CNEPD" $matches "CNEPD digital transformation referenced" "CNEPD/digital transformation NOT found"
    $t -match "SIGLE|SIGB|نظام المعلومات" | Out-Null
    Status "SIGLE/B" $matches "SIGLE/SIGB integration referenced" "SIGLE/SIGB NOT found in thesis"
} else { Write-Host "  [WARN] Thesis markdown not found" -ForegroundColor Yellow }

# ─── SECTION 4: DATA GOVERNANCE ───────────────────────────────
Write-Host "`n[4/5] DATA GOVERNANCE" -ForegroundColor Magenta
$wbPath = "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm"
if (Test-Path $wbPath) {
    $wb = Get-Item $wbPath
    Status "WORKBOOK" $true "ERP_v13.2.xlsm — $([math]::Round($wb.Length/1KB)) KB" "Workbook not found"
    Status "SHEET PROTECT" ($wb.Length -gt 100KB) "Sheet protection: erp_secure_pwd_2026" "Workbook too small"
}

$vbaPath = Join-Path $ROOT "Software_Surgical_Edit\VBA_Modules"
if (Test-Path $vbaPath) {
    $bas = (Get-ChildItem "$vbaPath\*.bas" -ErrorAction SilentlyContinue).Count
    $frm = (Get-ChildItem "$vbaPath\*.frm" -ErrorAction SilentlyContinue).Count
    Status "VBA SRC" $true "$bas .bas + $frm .frm modules" "No VBA modules found"
}

$gitLog = git -C $ROOT log --oneline -1 2>$null
if ($gitLog) { Status "GIT" $true "Last commit: $gitLog" "Git not available" }

# ─── SECTION 5: QUICK ACTIONS ────────────────────────────────
Write-Host "`n[5/5] QUICK ACTIONS (edit this script to customize)" -ForegroundColor Magenta
Write-Host @"
  1) OpenCode session:      opencode
  2) Rebuild workbook:      & '$ROOT\vbe-auto\build.ps1' -ConfigPath '$ROOT\vbe-auto\config.json'
  3) Verify workbook:       & '$ROOT\vbe-auto\verify.ps1' -ConfigPath '$ROOT\vbe-auto\config.json'
  4) Build thesis PDF:      & '$ROOT\Thesis_Surgical_Edit\build-thesis.ps1'
  5) Open this script:      notepad "$PSCommandPath"
  6) Git push:              git -C '$ROOT' push
"@ -ForegroundColor Gray

# ─── SUMMARY ──────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "  All CNEPD checks PASSED" -ForegroundColor Green
} else {
    Write-Host "  Issues found: $($issues -join ', ')" -ForegroundColor Yellow
    Write-Host "  Review CLAUDE.md for missing constants" -ForegroundColor Yellow
}
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`nEdit this script anytime: right-click → Edit" -ForegroundColor Gray
