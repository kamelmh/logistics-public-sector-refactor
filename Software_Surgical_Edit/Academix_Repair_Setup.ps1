# =============================================================================
# Academix_Repair_Setup.ps1  — FIXED
# Academix v13.2 — OpenCode Environment Repair & Structural Setup
# Run from Admin PowerShell: .\Academix_Repair_Setup.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$OPENCODE_BIN = "C:\Users\Administrator\Desktop\opencode-windows-x64-baseline\opencode.exe"
$CONFIG_DIR   = "$env:USERPROFILE\.config\opencode"
$DESKTOP      = "$env:USERPROFILE\Desktop"
$OPENCODE_CTX = "$PROJECT_ROOT\.opencode"
$LAUNCHER_BAT = "$DESKTOP\Academix_Launch.bat"

function Write-Section($t) { Write-Host "`n$('─'*60)`n $t`n$('─'*60)" -ForegroundColor Cyan }
function Write-OK($m)   { Write-Host "  [OK]  $m" -ForegroundColor Green }
function Write-WARN($m) { Write-Host "  [!!]  $m" -ForegroundColor Yellow }
function Write-FAIL($m) { Write-Host "  [XX]  $m" -ForegroundColor Red }
function Write-INFO($m) { Write-Host "  [..]  $m" -ForegroundColor Gray }

# ── STEP 1: SCAN DESKTOP TXT FILES FOR API KEYS ────────────────────────────────
Write-Section "STEP 1 — Scanning Desktop for API Keys"

$groqKey      = ""
$anthropicKey = ""

$txtFiles = Get-ChildItem -Path $DESKTOP -Filter "*.txt" -ErrorAction SilentlyContinue

if ($txtFiles.Count -eq 0) {
    Write-WARN "No .txt files on Desktop."
} else {
    Write-INFO "Found $($txtFiles.Count) .txt file(s) — scanning..."
    foreach ($f in $txtFiles) {
        $raw = (Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue).Trim()
        $key = ($raw -split "\s+")[0].Trim()
        if ($key.StartsWith("gsk_")) {
            $groqKey = $key
            Write-OK "Groq key found in '$($f.Name)': $($key.Substring(0,14))..."
        } elseif ($key.StartsWith("sk-ant-")) {
            $anthropicKey = $key
            Write-OK "Anthropic key found in '$($f.Name)': $($key.Substring(0,14))..."
        } elseif ($key.StartsWith("sk-")) {
            Write-INFO "OpenAI key found in '$($f.Name)' — not used by OpenCode, skipping"
        } else {
            Write-WARN "Unrecognized content in '$($f.Name)' — skipping"
        }
    }
}

if ($groqKey -eq "") {
    Write-WARN "No Groq key detected. opencode.json will contain a placeholder."
    $groqKey = "PASTE_YOUR_GROQ_KEY_HERE"
}

# ── STEP 2: CLEAN ROGUE DESKTOP ARTIFACTS ──────────────────────────────────────
Write-Section "STEP 2 — Cleaning Rogue Desktop Artifacts"

foreach ($pattern in @("opencode.json","context.md",".opencode","opencode.log","opencode.pid")) {
    $t = Join-Path $DESKTOP $pattern
    if (Test-Path $t) { Remove-Item $t -Recurse -Force; Write-OK "Removed: $pattern" }
}

Get-ChildItem $DESKTOP | Where-Object {
    $_.Name -match "(?i)opencode" -and $_.FullName -ne $LAUNCHER_BAT
} | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force
    Write-OK "Removed rogue: $($_.Name)"
}

Write-OK "Desktop clean"

# ── STEP 3: REBUILD opencode.json ──────────────────────────────────────────────
Write-Section "STEP 3 — Rebuilding opencode.json"

New-Item -ItemType Directory -Force -Path $CONFIG_DIR | Out-Null

$groqBlock = "    `"groq`": {`n      `"apiKey`": `"$groqKey`"`n    }"

if ($anthropicKey -ne "") {
    $anthropicBlock = "    `"anthropic`": {`n      `"apiKey`": `"$anthropicKey`"`n    },"
    $providerLines = "$anthropicBlock`n$groqBlock"
} else {
    $providerLines = $groqBlock
}

$cfg = "{`n  `"providers`": {`n$providerLines`n  },`n  `"model`": `"groq/qwen/qwen3-32b`",`n  `"autoshare`": false,`n  `"theme`": `"opencode`"`n}"
Set-Content "$CONFIG_DIR\opencode.json" $cfg -Encoding UTF8

Write-OK "opencode.json written to: $CONFIG_DIR\opencode.json"
Write-INFO "Active model: groq/qwen/qwen3-32b"
if ($anthropicKey -ne "") { Write-INFO "Anthropic key also registered" }

# ── STEP 4: VERIFY PROJECT ROOT & RESTORE context.md ───────────────────────────
Write-Section "STEP 4 — Verifying Project Root & Context"

if (-not (Test-Path $PROJECT_ROOT)) {
    Write-FAIL "Project root missing: $PROJECT_ROOT — is Dropbox synced?"
} else {
    Write-OK "Project root OK"
}

New-Item -ItemType Directory -Force -Path $OPENCODE_CTX | Out-Null

$ctxDest   = "$OPENCODE_CTX\context.md"
$ctxSource = "$PROJECT_ROOT\instructions.md"

if (Test-Path $ctxSource) {
    Copy-Item $ctxSource $ctxDest -Force
    Write-OK "context.md restored from instructions.md"
} elseif (-not (Test-Path $ctxDest)) {
    $minimal  = "# ACADEMIX_CONTEXT v13.2"
    $minimal += "`n# TRIGGER: ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE"
    $minimal += "`n`n## Ground Truth"
    $minimal += "`n- ART-001: Toner G030 | D=1546 | Q*=176 | ROP=205.6 | SS=200 | LT=2d"
    $minimal += "`n- MASTER_PWD: erp_secure_pwd_2026 | VERSION: v13.2"
    $minimal += "`n- 27 modules clean | W001-W010 resolved | Ch4 thesis PENDING"
    Set-Content $ctxDest $minimal -Encoding UTF8
    Write-WARN "instructions.md not found — minimal context.md written"
} else {
    Write-OK "context.md already present"
}

foreach ($xml in @("erp-project-context.xml","erp-admin-paths.xml","erp-agent-handoff.xml")) {
    $p = "$PROJECT_ROOT\Software_Surgical_Edit\$xml"
    if (Test-Path $p) { Write-OK "XML OK: $xml" } else { Write-WARN "XML missing: $xml" }
}

# ── STEP 5: VERIFY OPENCODE BINARY ─────────────────────────────────────────────
Write-Section "STEP 5 — Verifying OpenCode Binary"

if (-not (Test-Path $OPENCODE_BIN)) {
    Write-WARN "Not at Desktop baseline — checking PATH..."
    $found = Get-Command "opencode" -ErrorAction SilentlyContinue
    if ($found) {
        $OPENCODE_BIN = $found.Source
        Write-OK "Found in PATH: $OPENCODE_BIN"
    } else {
        Write-FAIL "OpenCode binary not found. Install: npm install -g opencode-ai"
    }
} else {
    Write-OK "Binary confirmed: $OPENCODE_BIN"
}

# ── STEP 6: WRITE LAUNCHER BAT ─────────────────────────────────────────────────
Write-Section "STEP 6 — Writing Academix_Launch.bat"

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("@echo off")
$lines.Add("title Academix v13.2 ^| ERP Academie DSS")
$lines.Add("echo.")
$lines.Add("echo  Academix v13.2  ^|  Direction de l'Education El Bayadh")
$lines.Add("echo.")
$lines.Add("cd /d `"$PROJECT_ROOT`"")
$lines.Add("set GROQ_API_KEY=$groqKey")
if ($anthropicKey -ne "") {
    $lines.Add("set ANTHROPIC_API_KEY=$anthropicKey")
}
$lines.Add("echo  CWD: %CD%")
$lines.Add("echo  Launching OpenCode...")
$lines.Add("echo.")
$lines.Add("`"$OPENCODE_BIN`"")

[System.IO.File]::WriteAllLines($LAUNCHER_BAT, $lines, [System.Text.Encoding]::ASCII)
Write-OK "Launcher written: $LAUNCHER_BAT"

# ── STEP 7: FINAL VALIDATION ───────────────────────────────────────────────────
Write-Section "STEP 7 — Final Validation"

$allOK = $true
$checks = @(
    @{ L="opencode.json";        P="$CONFIG_DIR\opencode.json" }
    @{ L=".opencode/context.md"; P="$OPENCODE_CTX\context.md" }
    @{ L="Academix_Launch.bat";  P=$LAUNCHER_BAT }
    @{ L="OpenCode binary";      P=$OPENCODE_BIN }
    @{ L="Project root";         P=$PROJECT_ROOT }
    @{ L="ERP_v13.2.xlsm";       P="C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm" }
    @{ L="VBA_Modules dir";      P="$PROJECT_ROOT\Software_Surgical_Edit\VBA_Modules" }
)

foreach ($c in $checks) {
    if (Test-Path $c.P) { Write-OK $c.L } else { Write-FAIL "$($c.L) — NOT FOUND"; $allOK = $false }
}

Write-Host ""
if ($allOK) {
    Write-Host "  ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host "  -> Double-click Academix_Launch.bat on Desktop" -ForegroundColor Green
    Write-Host "  -> Type: ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE" -ForegroundColor Green
} else {
    Write-Host "  PARTIAL — review FAIL items above" -ForegroundColor Yellow
}
Write-Host ""
