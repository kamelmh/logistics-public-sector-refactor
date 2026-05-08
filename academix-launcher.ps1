@'
╔══════════════════════════════════════════════════════════════╗
║           ACADEMIX v13.2 — WORKSPACE LAUNCHER                ║
║      نظام إلكتروني متكامل للتسيير التمويني                   ║
║   Direction de l'Education, Wilaya de El Bayadh, Algeria     ║
╚══════════════════════════════════════════════════════════════╝
'@ | Write-Host -ForegroundColor Cyan

Write-Host "`n[TRIGGER PHRASE] ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`n" -ForegroundColor Yellow

# ─── CONFIG ───────────────────────────────────────────────────
$ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$WORKBOOK = "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm"
$VBA_MODULES = Join-Path $ROOT "Software_Surgical_Edit\VBA_Modules"
$SYSTEM_CONFIG = Join-Path $ROOT "Software_Surgical_Edit\erp-system-config.xml"
$CONTEXT_XML = Join-Path $ROOT "Software_Surgical_Edit\erp-project-context.xml"
$AGENT_HANDOFF = Join-Path $ROOT "Software_Surgical_Edit\erp-agent-handoff.xml"
$OPENCODE_CONFIG = "C:\Users\Administrator\.config\opencode\opencode.json"
$AGENTS_MD = "C:\Users\Administrator\.config\opencode\AGENTS.md"
$MEMORY_JSON = "C:\Users\Administrator\.opencode\project-memory.json"
$NOTEPAD_MD = "C:\Users\Administrator\.opencode\notepad.md"
$GIT_REMOTE = "https://github.com/kamelmh/logistics-public-sector-refactor"
function Get-Secret {
    param([string]$Name, [string]$File)
    # Priority: env var > encrypted DPAPI XML > warning
    $v = [Environment]::GetEnvironmentVariable($Name, "User") -or [Environment]::GetEnvironmentVariable($Name, "Process")
    if ($v) { return $v }
    $xmlPath = "$env:USERPROFILE\.academix-$File.xml"
    if (Test-Path $xmlPath) {
        try { return (Import-Clixml $xmlPath).GetNetworkCredential().Password } catch { }
    }
    Write-Host "  [!] $Name not set. See ~\.academix-groq.xml" -ForegroundColor Yellow
    return ""
}
$GROQ_API_KEY = Get-Secret -Name "GROQ_API_KEY" -File "groq"
$GROQ_MODEL = "qwen/qwen3-32b"
$FCC_PATH = "C:\Users\Administrator\free-claude-code"
$OPENCODE_SKILLS = "C:\Users\Administrator\.opencode\skills"
$OPENCODE_FORK_SKILLS = "C:\Users\Administrator\opencode\skills"

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
Check "FCC" (Test-Path $FCC_PATH) "Free Claude Code: $FCC_PATH" "Missing: $FCC_PATH"
Check "SKL" (Test-Path $OPENCODE_SKILLS) ".opencode skills: $OPENCODE_SKILLS ($((Get-ChildItem $OPENCODE_SKILLS -Directory -ea 0).Count) skills)" "Missing skills"
$gitOk = git -C $ROOT status -sb 2>$null
Check "GIT" ([bool]$gitOk) "Git repo: $GIT_REMOTE" "Not a git repo"

# ─── 2. GROQ API ──────────────────────────────────────────────
Write-Host "`n[2/6] GROQ CLOUD API (PRIMARY)" -ForegroundColor Magenta
try {
    $body = @{ model = $GROQ_MODEL; messages = @(@{ role = "user"; content = "OK" }); stream = $false } | ConvertTo-Json
    $groq = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Method Post `
        -Body $body -ContentType "application/json" -Headers @{ Authorization = "Bearer $GROQ_API_KEY" } -TimeoutSec 15
    Check "GROQ" $true "Groq $GROQ_MODEL — Response: $($groq.choices[0].message.content)" "Groq unreachable"
} catch { Check "GROQ" $false "—" "Groq FAILED: $_" }

# ─── 3. OLLAMA LOCAL MODELS ───────────────────────────────────
Write-Host "`n[3/6] OLLAMA LOCAL (FALLBACK)" -ForegroundColor Magenta
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
    $model7b = $models -match "qwen2.5-coder:7b"
    $model15b = $models -match "qwen2.5-coder:1.5b"
    Check "7B" ([bool]$model7b) "qwen2.5-coder:7b (4.7 GB) — Available" "7b model not found"
    Check "1.5B" ([bool]$model15b) "qwen2.5-coder:1.5b (986 MB) — Available" "1.5b model not found"
} else { Warn "MODELS" "Could not list Ollama models" }

# ─── 4. WORKBOOK INTEGRITY ────────────────────────────────────
Write-Host "`n[4/6] WORKBOOK & VBA INTEGRITY" -ForegroundColor Magenta
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

# ─── 5. GIT STATUS ────────────────────────────────────────────
Write-Host "`n[5/6] GIT STATUS" -ForegroundColor Magenta
$gitLog = git -C $ROOT log --oneline -3 2>$null
$gitStatus = git -C $ROOT status --short 2>$null
$commitCount = (git -C $ROOT log --oneline 2>$null | Measure-Object).Count
Check "COMMITS" ($commitCount -gt 0) "$commitCount commits total" "No commits"
if ($gitStatus) { Warn "DIRTY" "Uncommitted changes: $((@($gitStatus) | Measure-Object).Count) file(s)" }
else { Check "CLEAN" $true "Working tree clean" "—" }
Write-Host "  Recent commits:" -ForegroundColor Gray
$gitLog | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

# ─── 6. MULTI-AGENT SYSTEM ────────────────────────────────────
Write-Host "`n[6/7] MULTI-AGENT SYSTEM" -ForegroundColor Magenta
$omcVersion = omc --version 2>$null
Check "OMC" ([bool]$omcVersion) "OMC v$omcVersion — Multi-agent orchestrator available" "OMC not found"
Check "ORCH" (Test-Path (Join-Path $ROOT "Software_Surgical_Edit\orchestrator.ps1")) "Orchestrator: orchestrator.ps1 (6 agents)" "Orchestrator missing"
Check "HARNESS" (Test-Path (Join-Path $ROOT ".opencode\agents\engineering-harness.md")) "Engineering harness: .opencode/agents/engineering-harness.md" "Harness missing"
$fccProc = Get-Process -Name "python*" -ea 0 | Where-Object CommandLine -match "uvicorn"
Check "FCC" ([bool]$fccProc) "Free Claude Code server running (PID $($fccProc.Id)) on :8082" "FCC server not running"
$skillCount = (Get-ChildItem $OPENCODE_SKILLS -Directory -ea 0).Count
Check "SKL2" ($skillCount -ge 60) "$skillCount skills in .opencode/skills/" "Only $skillCount skills"
Write-Host "  Agents: explore | plan | build | debug | audit | test" -ForegroundColor Gray
Write-Host "  Modes:  /mode explore|plan|build|debug|audit" -ForegroundColor Gray
Write-Host "  Tasks:  .\orchestrator.ps1 status|next|run T003|build|audit|test" -ForegroundColor Gray
Write-Host "  FCC:    http://localhost:8082 (x-api-key: freecc)" -ForegroundColor Gray

# ─── 7. SYSTEM SUMMARY ────────────────────────────────────────
Write-Host "`n[7/7] SYSTEM SUMMARY" -ForegroundColor Magenta
Write-Host @"
  Platform:    Windows 10, Celeron, 8GB RAM, HDD
  AI Primary:  Groq $GROQ_MODEL (~1s)
  AI Fallback: Ollama qwen2.5-coder:7b (~30-60s) / 1.5b (~100s)
  AI Tertiary: FCC server :8082 (ollama/qwen2.5-coder:1.5b)
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
  ✅ Launcher linked — desktop + PATH

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
  │  1) Launch OpenCode (Groq + full context)         │
  │  2) Rebuild workbook (build.ps1)                  │
  │  3) Run DSS audit                                 │
  │  4) Run macro tests                               │
  │  5) Save workbook data to JSON                    │
  │  6) Show agent/orchestrator status                │
  │  7) Start/restart FCC server (tertiary AI)        │
  │  8) Show quick commands help                      │
  │  9) Exit                                          │
  └──────────────────────────────────────────────────┘
"@ -ForegroundColor Cyan
    $choice = Read-Host "  Choose [1-9]"

    switch ($choice) {
        "1" {
            Write-Host @"
  Run this in your terminal:
    opencode
  Then type trigger phrase:
    ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE

  Or launch directly with:
    opencode -m "ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE"
"@ -ForegroundColor Green
            break
        }
        "2" {
            Write-Host "  Rebuilding workbook..." -ForegroundColor Yellow
            & "$ROOT\Software_Surgical_Edit\build.ps1"
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "3" {
            Write-Host "  Running DSS audit..." -ForegroundColor Yellow
            & "$ROOT\Software_Surgical_Edit\milestone_13_2\tests\dss-audit.ps1"
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
            Write-Host "  Restarting Free Claude Code server..." -ForegroundColor Yellow
            Get-Process -Name "python*" -ea 0 | Where-Object CommandLine -match "uvicorn" | Stop-Process -Force -ea 0
            Start-Sleep 2
            $fccJob = Start-Process -FilePath "uv" -ArgumentList "run uvicorn server:app --host 0.0.0.0 --port 8082 --timeout-graceful-shutdown 5" `
                -WorkingDirectory $FCC_PATH -WindowStyle Hidden -PassThru
            Write-Host "  FCC server starting (PID $($fccJob.Id))..." -ForegroundColor Yellow
            Start-Sleep 8
            try {
                $health = Invoke-RestMethod "http://localhost:8082/health" -Method Get -TimeoutSec 3 -ErrorAction Stop
                Write-Host "  FCC server READY — Health: $($health.status)" -ForegroundColor Green
            } catch { Write-Host "  FCC server may still be starting up..." -ForegroundColor Yellow }
            Write-Host "  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "8" {
            Write-Host @"
  [ QUICK COMMANDS ]
    opencode                                        Launch CLI
    .\Software_Surgical_Edit\build.ps1              Rebuild
    .\Software_Surgical_Edit\verify.ps1             Verify
    .\Software_Surgical_Edit\milestone_13_2\tests\dss-audit.ps1   Audit
    .\Software_Surgical_Edit\test-macros.ps1        Tests
    .\Software_Surgical_Edit\data-persist.ps1 save  Backup data
    .\Software_Surgical_Edit\orchestrator.ps1 status  Agent status
    git -C "$ROOT" push                             Push to GitHub

  [ TRIGGER PHRASE ]
    >>> ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE

  [ AGENT MODES ]
    /mode explore|plan|build|debug|audit
"@ -ForegroundColor DarkGray
            Write-Host "`n  Press Enter to continue..." -ForegroundColor Gray
            $null = Read-Host
        }
        "9" {
            Write-Host "  Goodbye." -ForegroundColor Green
            break
        }
        default {
            Write-Host "  Invalid choice. Enter 1-9." -ForegroundColor Red
        }
    }
} while ($choice -ne "1" -and $choice -ne "9")
