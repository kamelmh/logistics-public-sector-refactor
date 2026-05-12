@'
╔══════════════════════════════════════════════════════════════╗
║           ACADEMIX v13.2 — WORKSPACE LAUNCHER                ║
║      نظام إلكتروني متكامل للتسيير التمويني                   ║
║   Direction de l'Education, Wilaya de El Bayadh, Algeria     ║
╚══════════════════════════════════════════════════════════════╝
'@ | Write-Host -ForegroundColor Cyan

Write-Host "`n[TRIGGER PHRASE] ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`n" -ForegroundColor Yellow

# ─── BOOT PROGRESS ─────────────────────────────────────────────
Write-Host " Initializing..." -ForegroundColor DarkGray
$bootSteps = @(
    "Loading project context"
    "Verifying AI providers"
    "Checking workbook integrity"
    "Scanning VBA modules"
    "Syncing git state"
    "Preparing multi-agent system"
)
for ($i = 0; $i -lt $bootSteps.Count; $i++) {
    $pct = [math]::Round(($i + 1) / $bootSteps.Count * 100)
    $bar = "#" * ($i + 1) + "-" * ($bootSteps.Count - $i - 1)
    Write-Host "`r  Boot [$bar] $pct% — $($bootSteps[$i])" -NoNewline -ForegroundColor DarkCyan
    Start-Sleep 0.3
}
Write-Host "`r  Boot [######] 100% — Ready" -ForegroundColor Green
Write-Host ""

# ─── CONFIG ───────────────────────────────────────────────────
$ROOT = Split-Path $PSScriptRoot -Parent
$WORKBOOK = Join-Path $ROOT "Software_Surgical_Edit\ERP_v13.2.xlsm"
$VBA_MODULES = Join-Path $ROOT "Software_Surgical_Edit\VBA_Modules"
$SYSTEM_CONFIG = Join-Path $ROOT "Software_Surgical_Edit\erp-project-context.xml"
$CONTEXT_XML = Join-Path $ROOT "Software_Surgical_Edit\erp-project-context.xml"
$AGENT_HANDOFF = Join-Path $ROOT "Software_Surgical_Edit\erp-agent-handoff.xml"
$OPENCODE_CONFIG = "$env:USERPROFILE\.config\opencode\opencode.json"
$AGENTS_MD = "$env:USERPROFILE\.config\opencode\AGENTS.md"
$MEMORY_JSON = "$env:USERPROFILE\.opencode\project-memory.json"
$NOTEPAD_MD = "$env:USERPROFILE\.opencode\notepad.md"
$GIT_REMOTE = "https://github.com/kamelmh/logistics-public-sector-refactor"
function Get-Secret {
    param([string]$Name, [string]$File)
    $v = [Environment]::GetEnvironmentVariable($Name, "User")
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, "Process") }
    if ($v) { return $v }
    $xmlPath = "$env:USERPROFILE\.academix-$File.xml"
    if (Test-Path $xmlPath) {
        try { return (Import-Clixml $xmlPath).GetNetworkCredential().Password } catch { }
    }
    $ocCfg = "$env:USERPROFILE\.config\opencode\opencode.json"
    if (Test-Path $ocCfg) {
        try {
            $j = Get-Content $ocCfg -Raw | ConvertFrom-Json
            $keyName = $Name -replace '_API_KEY','' -replace 'GROQ','groq' -replace 'OPENROUTER','openrouter' -replace 'OPENAI','openai' -replace 'DEEPSEEK','deepseek'
            if ($j.provider.$keyName.apiKey) { return $j.provider.$keyName.apiKey }
        } catch {}
    }
    Write-Host "  [!] $Name not set. Check opencode.json or set env var." -ForegroundColor Yellow
    return ""
}
$GROQ_API_KEY = Get-Secret -Name "GROQ_API_KEY" -File "groq"
$GROQ_MODEL = "llama-3.3-70b-versatile"
$GROQ_FAST_MODEL = "qwen/qwen3-32b"
$OPENCODE_SKILLS = "$env:USERPROFILE\.opencode\skills"
$OPENCODE_FORK_SKILLS = "$env:USERPROFILE\opencode\skills"

$pass = 0; $fail = 0; $warn = 0
function Check {
    param($Name, $Condition, $OkMsg, $FailMsg)
    if ($Condition) { $script:pass++; Write-Host "  [$([char]0x2713)] $OkMsg" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [X] $FailMsg" -ForegroundColor Red }
}
function Warn {
    param($Name, $Msg)
    $script:warn++; Write-Host "  [!] $Msg" -ForegroundColor Yellow
}

# ─── 1. ADMIN PATHS ───────────────────────────────────────────
Write-Host "`n[1/6] ADMIN PATHS VERIFICATION" -ForegroundColor Magenta
Check "ROOT" (Test-Path $ROOT) "Project Root: $ROOT" "Missing: $ROOT"
Check "VBA" (Test-Path $VBA_MODULES) "VBA Modules: $VBA_MODULES" "Missing: $VBA_MODULES"
Check "SYS" (Test-Path $SYSTEM_CONFIG) "System Config (SSoT): $SYSTEM_CONFIG" "Missing: $SYSTEM_CONFIG"
Check "XML" (Test-Path $CONTEXT_XML) "Context XML: $CONTEXT_XML" "Missing: $CONTEXT_XML"
Check "HND" (Test-Path $AGENT_HANDOFF) "Agent Handoff: $AGENT_HANDOFF" "Missing: $AGENT_HANDOFF"
Check "WB" (Test-Path $WORKBOOK) "Workbook: $WORKBOOK" "Missing: $WORKBOOK"
Check "CFG" (Test-Path $OPENCODE_CONFIG) "OpenCode Config: $OPENCODE_CONFIG" "Missing: $OPENCODE_CONFIG"
Check "AG" (Test-Path $AGENTS_MD) "AGENTS.md: $AGENTS_MD" "Missing: $AGENTS_MD"
Check "MEM" (Test-Path $MEMORY_JSON) "Memory JSON: $MEMORY_JSON" "Missing: $MEMORY_JSON"
Check "NP" (Test-Path $NOTEPAD_MD) "Notepad MD: $NOTEPAD_MD" "Missing: $NOTEPAD_MD"
Check "SKL" (Test-Path $OPENCODE_SKILLS) ".opencode skills: $OPENCODE_SKILLS ($((Get-ChildItem $OPENCODE_SKILLS -Directory -ea 0).Count) skills)" "Missing skills"
$gitOk = git -C $ROOT status -sb 2>$null
Check "GIT" ([bool]$gitOk) "Git repo: $GIT_REMOTE" "Not a git repo"

# ─── 2. GROQ LLAMA API (PRIMARY) ──────────────────────────────
Write-Host "`n[2/6] GROQ LLAMA-3.3-70B (PRIMARY)" -ForegroundColor Magenta
if (-not $GROQ_API_KEY) {
    Warn "LLAMA" "GROQ_API_KEY empty — try: `$env:GROQ_API_KEY='gsk_...' or check opencode.json"
} else {
    try {
        $body = @{ model = $GROQ_MODEL; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
        $groq = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
            -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $GROQ_API_KEY" } -TimeoutSec 15
        Check "LLAMA" $true "Groq $GROQ_MODEL — OK" "Llama unreachable"
    } catch { Check "LLAMA" $false "—" "Llama FAILED: $_" }
}

# ─── 3. GROQ QWEN (FAST FALLBACK) ────────────────────────────
Write-Host "`n[3/6] GROQ QWEN3-32B (FAST FALLBACK)" -ForegroundColor Magenta
if (-not $GROQ_API_KEY) {
    Warn "GROQ" "Skipping — no GROQ_API_KEY"
} else {
    try {
        $body = @{ model = $GROQ_FAST_MODEL; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
        $groq = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
            -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $GROQ_API_KEY" } -TimeoutSec 15
        Check "GROQ" $true "Groq $GROQ_FAST_MODEL — OK" "Groq unreachable"
    } catch { Check "GROQ" $false "—" "Groq FAILED: $_" }
}

# ─── 4. OLLAMA LOCAL MODELS ───────────────────────────────────
Write-Host "`n[4/6] OLLAMA LOCAL (FALLBACK)" -ForegroundColor Magenta
$ollamaProc = Get-Process ollama -ErrorAction SilentlyContinue
if (-not $ollamaProc) {
    Warn "OLLAMA" "Ollama not running. Starting..."
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru
    Start-Sleep 3
}
$ollamaProc = Get-Process ollama -ErrorAction SilentlyContinue
Check "OLLAMA" ([bool]$ollamaProc) "Ollama running (PID $($ollamaProc.Id))" "Ollama failed to start"

$models = ollama list 2>$null
if ($models) {
    $modelGemma4  = $models -match "gemma4:e2b"
    $model7b   = $models -match "qwen2.5-coder:7b"
    $model15b  = $models -match "qwen2.5-coder:1.5b"
    $modelQwen3 = $models -match "qwen3:1.7b"
    $modelPhi4  = $models -match "phi4-mini"
    Check "7B"    ([bool]$model7b)    "qwen2.5-coder:7b (4.7 GB) — Available" "7b model not found"
    Check "1.5B"  ([bool]$model15b)   "qwen2.5-coder:1.5b (986 MB) — Available" "1.5b model not found"
    Check "QWEN3" ([bool]$modelQwen3) "qwen3:1.7b (1.4 GB, CPU reasoning) — Available" "qwen3:1.7b not found"
    Check "PHI4"  ([bool]$modelPhi4)  "phi4-mini:3.8b (2.5 GB, CPU coding) — Available" "phi4-mini not found"
    Check "GEMMA4LOCAL" ([bool]$modelGemma4) "gemma4:e2b (7.2 GB, 128K ctx, offline) — Available" "gemma4:e2b not found"
} else { Warn "MODELS" "Could not list Ollama models" }

# ─── 5. WORKBOOK INTEGRITY ────────────────────────────────────
Write-Host "`n[5/6] WORKBOOK & VBA INTEGRITY" -ForegroundColor Magenta
$wb = Get-Item $WORKBOOK -ErrorAction SilentlyContinue
if ($wb) {
    Check "WB.SIZE" ($wb.Length -gt 100KB) "Size: $([math]::Round($wb.Length/1KB)) KB" "Workbook too small"
    Check "WB.DATE" ($wb.LastWriteTime -gt (Get-Date).AddDays(-30)) "Modified: $($wb.LastWriteTime)" "Older than 30 days"
} else { Check "WB.EXISTS" $false "—" "Workbook not found" }

$basCount = (Get-ChildItem "$VBA_MODULES\*.bas" -ErrorAction SilentlyContinue | Measure-Object).Count
$frmCount = (Get-ChildItem "$VBA_MODULES\*.frm" -ErrorAction SilentlyContinue | Measure-Object).Count
$clsCount = (Get-ChildItem "$VBA_MODULES\*.cls" -ErrorAction SilentlyContinue | Measure-Object).Count
$totalLines = 0
Get-ChildItem "$VBA_MODULES\*.bas", "$VBA_MODULES\*.frm", "$VBA_MODULES\*.cls" -ErrorAction SilentlyContinue |
    ForEach-Object { $totalLines += (Get-Content $_.FullName | Measure-Object -Line).Lines }

Check "BAS" ($basCount -ge 25) "$basCount .bas modules" "Only $basCount bas files"
Check "FRM" ($frmCount -ge 1) "$frmCount .frm forms" "Missing form"
Check "CLS" ($clsCount -ge 1) "$clsCount .cls classes" "Missing class"
Check "LINES" ($totalLines -gt 5000) "$totalLines total lines of VBA" "Low line count"

# ─── 6. GIT STATUS ────────────────────────────────────────────
Write-Host "`n[6/6] GIT STATUS" -ForegroundColor Magenta
$gitLog = git -C $ROOT log --oneline -3 2>$null
$gitStatus = git -C $ROOT status --short 2>$null
$commitCount = (git -C $ROOT log --oneline 2>$null | Measure-Object).Count
Check "COMMITS" ($commitCount -gt 0) "$commitCount commits total" "No commits"
if ($gitStatus) { Warn "DIRTY" "Uncommitted changes: $((@($gitStatus) | Measure-Object).Count) file(s)" }
else { Check "CLEAN" $true "Working tree clean" "—" }
Write-Host "  Recent commits:" -ForegroundColor Gray
$gitLog | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

# ─── 7. MULTI-AGENT SYSTEM ────────────────────────────────────
Write-Host "`n[7] MULTI-AGENT SYSTEM" -ForegroundColor Magenta
$omcVersion = omc --version 2>$null
Check "OMC" ([bool]$omcVersion) "OMC v$omcVersion — Multi-agent orchestrator available" "OMC not found"
Check "ORCH" (Test-Path (Join-Path $ROOT "Software_Surgical_Edit\orchestrator.ps1")) "Orchestrator: orchestrator.ps1 (6 agents)" "Orchestrator missing"
Check "HARNESS" (Test-Path (Join-Path $ROOT ".opencode\agents\engineering-harness.md")) "Engineering harness: .opencode/agents/engineering-harness.md" "Harness missing"
$skillCount = (Get-ChildItem $OPENCODE_SKILLS -Directory -ea 0).Count
Check "SKL2" ($skillCount -ge 60) "$skillCount skills in .opencode/skills/" "Only $skillCount skills"
Write-Host "  Agents: explore | plan | build | debug | audit | test" -ForegroundColor Gray
Write-Host "  Modes:  /mode explore|plan|build|debug|audit" -ForegroundColor Gray
Write-Host "  Tasks:  .\orchestrator.ps1 status|next|run T003|build|audit|test" -ForegroundColor Gray
  Write-Host "  Stack:  OpenRouter Nemotron 120B (strongest working) | Ollama phi4-mini (CPU fallback) | 5 local models" -ForegroundColor Gray

# ─── OUTPUT SUMMARY ──────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host @"
  Platform:    Windows 10, Celeron, 8GB RAM, HDD
  AI Cloud:    OpenRouter Nemotron 120B 1M ctx (WORKING) — `OpenCode nemotron`
  AI Cloud:    Groq Llama 3.3 70B / Qwen3 32B (API KEY INVALID — get new key)
  AI Cloud:    Gemini 2.5 Flash (quota exceeded)
  AI Cloud:    OpenRouter Qwen3 Coder 480B (needs valid model ID)
  AI Local:    Ollama phi4-mini 3.8B / Qwen3 1.7B / 7B / 1.5B (CPU)
  AI Local:    Gemma 4 e2b (FAILS on 8GB RAM — needs 12GB+)
  Workbook:    $WORKBOOK ($([math]::Round($wb.Length/1KB)) KB)
  VBA Source:  $basCount .bas | $frmCount .frm | $clsCount .cls = $($basCount+$frmCount+$clsCount) files | $totalLines lines
  Skills:      $skillCount .opencode skills (full fork sync)
  SSoT:        erp-system-config.xml
  Sheets:      25
  Thesis:      4 chapters + 7 annexes (PDF ~843 KB)
  Git:         $commitCount commits — $GIT_REMOTE
"@ -ForegroundColor Gray

# ─── RESULTS ──────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASS: $pass  |  FAIL: $fail  |  WARN: $warn" -ForegroundColor $(if ($fail -gt 0){"Red"}else{"Green"})
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan

# ─── TODO LIST ─────────────────────────────────────────────────
Write-Host @"

[ ACADEMIX v13.2 — MODEL STATUS (updated 2026-05-12) ]
  ╔══════════════════════════════════════════════════════════╗
  ║  CLOUD — ALL WORKING (new keys)                          ║
  ║  ─────────────────────────────                           ║
  ║  ✅ Groq Llama 3.3 70B      — OpenCode (default)        ║
  ║  ✅ Groq Qwen3 32B          — OpenCode groq              ║
  ║  ✅ Gemini 3 Flash Preview  — OpenCode gemini3 / g3      ║
  ║  ✅ Gemma 4 26B 256K        — OpenCode gemma / ogg       ║
  ║  ✅ Gemma 4 31B IT          — OpenCode gemma-31b         ║
  ║  ✅ Ring 2.6 1T (Kimi K2.6) — OpenCode ring (FREE!)     ║
  ║  ✅ Nemotron 120B 1M ctx    — OpenCode nemotron          ║
  ║                                                          ║
  ║  LOCAL — Ollama (CPU only)                               ║
  ║  ───────────────────────                                 ║
  ║  ✅ Phi4-mini 3.8B         — OpenCode phi4 (~25s)        ║
  ║  ✅ Qwen3 1.7B             — OpenCode qwen3 (~40s)       ║
  ║  ✅ Qwen2.5 7B / 1.5B      — OpenCode ollama (menu)      ║
  ║  ❌ Gemma 4 e2b            — needs 12GB+ RAM             ║
  ║                                                          ║
  ║  QUOTA-LIMITED (free tier daily cap)                     ║
  ║  ─────────────────────────                               ║
  ║  ❌ Gemini 2.5 Flash       — use gemini3 instead         ║
  ║  ❌ Gemini 2.5 Pro         — use gemini3 instead         ║
  ║  ❌ Gemini 3 Pro Preview   — use gemini3 instead         ║
  ║                                                          ║
  ║  PAID (key stored, needs billing)                        ║
  ║  ──────────────────────────                              ║
  ║  🔶 Anthropic Claude      — needs $                      ║
  ║  🔶 Kimi K2.6 (paid)     — needs OpenRouter credits     ║
  ╚══════════════════════════════════════════════════════════╝

[ STATUS — ALL TASKS COMPLETE ]
  ✅ Thesis Ch4 — integrated in final document (1887 lines)
  ✅ Defense materials — Marp slides, PPTX, Q&A guide ready
  ✅ 3 audit warnings — all PASS (sheet protection, circular dep, EOQ)
  ✅ CSV import/export (T006) — 489 lines, no TODOs
  ✅ Barcode scanner (T007) — 228 lines, no TODOs
  ✅ Public LSM — sanitize.ps1 with 25+ rules, clean sources
  ✅ Build pipeline — COMPILE: OK (771 KB, 36+1 modules)
  ✅ Verify pipeline — 97/97 PASS
  ✅ Test pipeline — 10/10 PASS
  ✅ SSD workspace — F:\Academix (COMPILE: OK)
  ✅ Session/memory system — .opencode/memory/ active
  ✅ Launcher v3.1 — Desktop OpenCode.bat with 13 modes
  ✅ Model landscape — .opencode/model-landscape-2026.md
  ✅ API keys fixed — Anthropic, OpenRouter, OpenAI, DeepSeek
  ✅ System cheatsheet — .opencode/system-context-cheatsheet.md
  ✅ Ollama models — Qwen3 1.7B + Phi4-mini 3.8B + Gemma 4 e2b installed

[ REMAINING — YOUR ACTION ]
  [ ] Defense practice — jury Q&A from DEFENSE_QA_GUIDE.md
  [ ] Print thesis — USB/printing for jury submission
"@ -ForegroundColor Green

Write-Host @"
[ INTERACTIVE MENU ]
"@ -ForegroundColor Cyan

do {
    Write-Host @"
  ┌──────────────────────────────────────────────────┐
  │  1) Launch OpenCode (Llama 3.3 70B)               │
  │  2) Rebuild workbook (build.ps1)                  │
  │  3) Run DSS audit                                 │
  │  4) Run macro tests                               │
  │  5) Save workbook data to JSON                    │
  │  6) Show agent/orchestrator status                │
  │  7) Show quick commands help                      │
  │  8) Exit                                          │
  └──────────────────────────────────────────────────┘
"@ -ForegroundColor Cyan
    $choice = Read-Host "  Choose [1-9]"

    switch ($choice) {
        "1" {
            Write-Host @"
  Run in your terminal (choose a backend):

    opencode                 Default (Groq Llama 3.3 70B — fastest, primary)
    OpenCode groq            Groq Qwen3 32B (fast explore/debug)
    OpenCode gemini3 / g3    Gemini 3 Flash Preview (NEW — replaces 2.5 Flash)
    OpenCode gemma / ogg     Gemma 4 26B 256K (multimodal)
    OpenCode gemma-31b       Gemma 4 31B IT (stronger reasoning)
    OpenCode ring            Ring 2.6 1T (Kimi K2.6 clone, 262K ctx, FREE)
    OpenCode nemotron        Nemotron 120B (1M ctx, OpenRouter)
    OpenCode phi4            Ollama Phi4-mini 3.8B (offline CPU, ~25s)
    OpenCode qwen3           Ollama Qwen3 1.7B (offline CPU reasoning)
    OpenCode ollama          Ollama model picker (all 4 local models)

  Then type trigger phrase in chat:
    ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
  Or use /academix command for live context reload with git status
"@ -ForegroundColor Green
            break
        }
        "2" {
            Write-Host "  Rebuilding workbook..." -ForegroundColor Yellow
            & "$ROOT\vbe-auto\build.ps1" -ConfigPath "$ROOT\vbe-auto\config.json"
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "3" {
            Write-Host "  Running DSS audit..." -ForegroundColor Yellow
            & "$ROOT\milestone_13_2\tests\dss-audit.ps1"
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "4" {
            Write-Host "  Running macro tests..." -ForegroundColor Yellow
            & "$ROOT\Software_Surgical_Edit\test-macros.ps1"
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "5" {
            Write-Host "  Saving workbook data..." -ForegroundColor Yellow
            & "$ROOT\Software_Surgical_Edit\data-persist.ps1" save
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "6" {
            & "$ROOT\Software_Surgical_Edit\orchestrator.ps1" status
            Write-Host "`n  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "7" {
            Write-Host @"
  [ QUICK COMMANDS ]
    opencode                                        Launch CLI (default)
    OpenCode nemotron                               Nemotron 120B 1M ctx (STRONGEST WORKING)
    OpenCode fcc                                    Nemotron 120B via FCC proxy (auto-start)
    OpenCode groq                                   Groq Llama 3.3 70B (needs new API key)
    OpenCode phi4                                   Ollama Phi4-mini 3.8B (CPU, ~25s)
    OpenCode qwen3                                  Ollama Qwen3 1.7B (CPU, ~40s)
    OpenCode ollama                                 Ollama model selection menu
    OpenCode gemini3 / g3                           Gemini 3 Flash Preview (NEW)
    OpenCode ring                                   Ring 2.6 1T / Kimi K2.6 (FREE, 262K)
    OpenCode gemma-31b                              Gemma 4 31B IT (stronger reasoning)
    .\vbe-auto\build.ps1 -ConfigPath .\vbe-auto\config.json   Rebuild
    .\vbe-auto\verify.ps1 -ConfigPath .\vbe-auto\config.json  Verify
    .\milestone_13_2\tests\dss-audit.ps1                Audit
    .\Software_Surgical_Edit\test-macros.ps1        Tests
    .\Software_Surgical_Edit\data-persist.ps1 save  Backup data
    .\Software_Surgical_Edit\orchestrator.ps1 status  Agent status
    git -C "$ROOT" push                             Push to GitHub

  [ TRIGGER PHRASE ]
    >>> ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
    >>> /academix  (slash command — reloads context + live git status)

  [ AGENT MODES ]
    /mode explore|plan|build|debug|audit
"@ -ForegroundColor DarkGray
            Write-Host "`n  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "8" {
            Write-Host "  Goodbye." -ForegroundColor Green
            break
        }
        default {
            Write-Host "  Invalid choice. Enter 1-8." -ForegroundColor Red
        }
    }
} while ($choice -ne "1" -and $choice -ne "8")
