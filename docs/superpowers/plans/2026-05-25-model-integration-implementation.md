# Model Integration & Maintenance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate model health‑checking, add launcher shortcuts for instant model‑infrastructure verification, and integrate a daily CI health report.

**Architecture:** A single PowerShell script (`scripts/model-health-check.ps1`) validates environment variables, tests provider connectivity, and verifies the Claude‑Code (Sonnet) plugin. Two new `OpenCode` modes (`model‑health`, `verify‑sonnet`) wrap the script. A daily GitHub Actions workflow keeps the system monitored.

**Tech Stack:** PowerShell 7+, OpenCode batch launcher, GitHub Actions.

---

### Task 1: Create the model health‑check script

**Files:**
- Create: `scripts/model-health-check.ps1`

- [ ] **Step 1: Write `Test‑EnvVars` function**

```powershell
# scripts/model-health-check.ps1
function Test-EnvVars {
    $requiredKeys = @("GEMINI_API_KEY", "OPENAI_API_KEY", "ANTHROPIC_API_KEY")
    $allSet = $true
    foreach ($key in $requiredKeys) {
        $val = [Environment]::GetEnvironmentVariable($key, "User")
        if ([string]::IsNullOrEmpty($val)) {
            Write-Host "FAIL: $key is not set" -ForegroundColor Red
            $allSet = $false
        } else {
            Write-Host "PASS: $key is set" -ForegroundColor Green
        }
    }
    return $allSet
}
```

- [ ] **Step 2: Add `Test‑Connectivity` function**

```powershell
function Test-Connectivity {
    $providers = @(
        @{ Name = "Google AI"; Url = "https://generativelanguage.googleapis.com/v1/models"; KeyVar = "GEMINI_API_KEY" },
        @{ Name = "OpenAI";    Url = "https://api.openai.com/v1/models";               KeyVar = "OPENAI_API_KEY" },
        @{ Name = "Anthropic"; Url = "https://api.anthropic.com/v1/messages";           KeyVar = "ANTHROPIC_API_KEY" }
    )
    $allOk = $true
    foreach ($p in $providers) {
        $key = [Environment]::GetEnvironmentVariable($p.KeyVar, "User")
        if ([string]::IsNullOrEmpty($key)) { continue }
        try {
            $response = Invoke-RestMethod -Uri $p.Url -Headers @{ "Authorization" = "Bearer $key" } -TimeoutSec 5
            Write-Host "PASS: $($p.Name) reachable" -ForegroundColor Green
        } catch {
            Write-Host "FAIL: $($p.Name) not reachable ($($_.Exception.Message))" -ForegroundColor Red
            $allOk = $false
        }
    }
    return $allOk
}
```

- [ ] **Step 3: Add `Test‑ClaudeCodeBackend` function**

```powershell
function Test-ClaudeCodeBackend {
    # 1. Plugin presence
    $pluginOut = & "opencode.exe" plugins list 2>&1
    if ($pluginOut -match "everything-claude-code") {
        Write-Host "PASS: Plugin loaded" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Plugin not found" -ForegroundColor Red
        return $false
    }

    # 2. Model availability
    $modelOut = & "omc.exe" model list 2>&1
    if ($modelOut -match "claude-code-sonnet") {
        Write-Host "PASS: Sonnet model available" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Sonnet model not in list" -ForegroundColor Red
        return $false
    }

    # 3. E2E test query
    try {
        $answer = & "omc.exe" ask /ask claude-code-sonnet "reply with the word READY" 2>&1
        if ($answer -match "READY") {
            Write-Host "PASS: Claude Code backend responds correctly" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL: test query returned unexpected: $answer" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "FAIL: test query threw: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}
```

- [ ] **Step 4: Add main entry point and `‑Mode` parameter**

```powershell
param(
    [ValidateSet("env","connectivity","sonnet","all")]
    [string]$Mode = "all"
)

$exitCode = 0

if ($Mode -in @("all","env")) {
    if (-not (Test-EnvVars)) { $exitCode = 1 }
}
if ($Mode -in @("all","connectivity")) {
    if (-not (Test-Connectivity)) { $exitCode = 1 }
}
if ($Mode -in @("all","sonnet")) {
    if (-not (Test-ClaudeCodeBackend)) { $exitCode = 1 }
}

exit $exitCode
```

- [ ] **Step 5: Run a quick smoke test** (verify the script parses and runs without error)

```powershell
# From repo root
.\scripts\model-health-check.ps1 -Mode env
```
Expected output: green "PASS" lines for each set variable (or red "FAIL" lines if a variable is missing – either is a correct parse test).

- [ ] **Step 6: Commit**

```bash
git add scripts/model-health-check.ps1
git commit -m "feat: add model health-check script (env, connectivity, sonnet)"
```

---

### Task 2: Register OpenCode launcher aliases

**Files:**
- Modify: `OpenCode.bat`

- [ ] **Step 1: Add two new modes to the mode registry**

Insert line 108 (after the existing `CLI_MODES` definition):

```
set "CLI_MODES=%CLI_MODES% model-health verify-sonnet"
```

- [ ] **Step 2: Add launcher labels**

Insert the following block just before the `:help` label (around line 1100 of the current file):

```bat
:model-health
echo [OpenCode] Running full model health check...
"%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_ROOT%\scripts\model-health-check.ps1" -Mode all
goto :EOF

:verify-sonnet
echo [OpenCode] Verifying Claude Code backend...
"%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_ROOT%\scripts\model-health-check.ps1" -Mode sonnet
goto :EOF
```

- [ ] **Step 3: Test the new alias**

```powershell
# From repo root
.\OpenCode.bat model-health
```
Expected: runs the health‑check script and shows colour‑coded passes/fails.

- [ ] **Step 4: Commit**

```bash
git add OpenCode.bat
git commit -m "feat: add model-health and verify-sonnet launcher modes"
```

---

### Task 3: Create daily CI health‑check workflow

**Files:**
- Create: `.github/workflows/model-health.yml`

- [ ] **Step 1: Write the workflow**

```yaml
name: Model Health Check

on:
  schedule:
    - cron: '0 6 * * *'   # daily 06:00 UTC
  workflow_dispatch:       # allow manual trigger from Actions tab

jobs:
  health:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run full health check
        shell: pwsh
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          .\scripts\model-health-check.ps1 -Mode all

      - name: Notify on failure
        if: failure()
        run: echo "::error::Model health check failed – check the diagnostic artifact and rotate keys if needed."
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/model-health.yml
git commit -m "ci: add daily model health-check workflow"
```
