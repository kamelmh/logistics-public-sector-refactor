# Prompt Pack Auto Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB‑SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task‑by‑task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fully‑automated Claude Desktop skill that creates a prompt pack, snapshots the repo, invokes Claude, handles token‑limit pauses via manifests, and runs the thesis build/verify pipeline automatically.

**Architecture:** A slash‑command (`/prompt‑pack‑run`) triggers a PowerShell wrapper that (1) snapshots git state and key config files, (2) calls the Claude CLI with the snapshot attached, (3) parses Claude’s control tokens (`<<DOCX‑READY>>` or `<<PAUSE>>`). A post‑hook agent reacts to those tokens: on success it runs the thesis build/verification; on pause it writes a JSON manifest for an OpenCode resume agent (`resume-manifest.ps1`) to pick up later.

**Tech Stack:** PowerShell 7+, Claude CLI (`claude`), Git, file‑system (zip), JSON, Claude Desktop slash‑command framework.

---

### Task 1: Verify Prompt Pack exists

**Files:**
- Verify: `docs/superpowers/prompt-pack/PromptPack.md`

- [ ] **Step 1: Check existence**
  ```powershell
  Test-Path -LiteralPath "docs/superpowers/prompt-pack/PromptPack.md"
  ```
- [ ] **Step 2: If missing, create a placeholder** (not expected – abort if not present).

---

### Task 2: Create snapshot‑context.ps1

**Files:**
- Create: `scripts/snapshot-context.ps1`

- [ ] **Step 1: Write the PowerShell script**
  ```powershell
  # ---------------------------------------------------------------
  # snapshot-context.ps1 – Capture repo state for Claude Desktop
  # ---------------------------------------------------------------
  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $workDir = (Get-Location).Path
  $snapDir = Join-Path $workDir "snapshot_temp_$timestamp"
  New-Item -ItemType Directory -Path $snapDir | Out-Null
  
  # 1. Git information
  git status > "$snapDir\git-status.txt"
  git diff   > "$snapDir\git-diff.txt"
  git log -n 10 --oneline > "$snapDir\git-log.txt"
  
  # 2. Key configuration files (copy if they exist)
  $files = @(
      "MASTER_BOOTSTRAP.xml",
      "erp-context-compact.md",
      "CLAUDE.md",
      "Gemini.md",
      "docs/superpowers/prompt-pack/PromptPack.md"
  )
  foreach ($f in $files) {
      $src = Join-Path $workDir $f
      if (Test-Path -LiteralPath $src) {
          Copy-Item -LiteralPath $src -Destination $snapDir
      }
  }
  
  # 3. Latest thesis output (if present)
  $thesisOut = "Research_and_Development/Thesis_Surgical_Edit/output"
  if (Test-Path -LiteralPath $thesisOut) {
      Copy-Item -Path $thesisOut -Destination $snapDir -Recurse -Force
  }
  
  # 4. Create zip archive
  $zipPath = Join-Path $workDir "snapshot/$timestamp-snapshot.zip"
  if (-not (Test-Path -LiteralPath "snapshot")) { New-Item -ItemType Directory -Path "snapshot" | Out-Null }
  Compress-Archive -Path "$snapDir\*" -DestinationPath $zipPath -Force
  
  # 5. Cleanup temporary folder
  Remove-Item -LiteralPath $snapDir -Recurse -Force
  
  Write-Output "Snapshot created at: $zipPath"
  ```
- [ ] **Step 2: Run a quick smoke‑test** to ensure it creates a zip without error.
  ```powershell
  .\scripts\snapshot-context.ps1
  ```
- [ ] **Step 3: Commit the new script**
  ```bash
  git add scripts/snapshot-context.ps1
  git commit -m "feat: add snapshot‑context script for Prompt Pack automation"
  ```

---

### Task 3: Create run‑prompt‑pack.ps1

**Files:**
- Create: `scripts/run-prompt-pack.ps1`

- [ ] **Step 1: Write the orchestrator script**
  ```powershell
  # ---------------------------------------------------------------
  # run-prompt-pack.ps1 – Main orchestrator for Approach B
  # ---------------------------------------------------------------
  # 1. Create snapshot (captures path in output)
  $snapshotOutput = & "${PSScriptRoot}\snapshot-context.ps1"
  $snapshotPath = $snapshotOutput -replace "Snapshot created at: ", ""
  $snapshotPath = $snapshotPath.Trim()
  
  # 2. Prompt file location
  $promptFile = "docs/superpowers/prompt-pack/PromptPack.md"
  
  # 3. Invoke Claude CLI (Opus model, attach snapshot)
  $claudeCmd = "claude --model opus --prompt-file `"$promptFile`" --attachment `"$snapshotPath`" --output temp/claude-response.txt"
  Write-Host "Running Claude: $claudeCmd"
  Invoke-Expression $claudeCmd
  
  # 4. Analyse response for control tokens
  $resp = Get-Content -LiteralPath "temp/claude-response.txt" -Raw
  if ($resp -match "<<DOCX‑READY>>") {
      Write-Host "Claude signaled completion – building thesis..."
      & "Research_and_Development/Thesis_Surgical_Edit/build-thesis.ps1"
      & "Research_and_Development/Thesis_Surgical_Edit/verify-thesis.ps1"
      Write-Host "Build and verification finished."
  } elseif ($resp -match "<<PAUSE>>") {
      Write-Host "Claude paused – generating manifest for resume."
      $manifest = @{
          stage      = "prompt-pack"
          snapshot   = $snapshotPath
          partialResultPath = "temp/claude-response.txt"
          nextPrompt = "Continue from where Claude stopped."
          timestamp  = (Get-Date).ToString("o")
      }
      $manifestPath = "manifest/${([guid]::NewGuid()).ToString()}.json"
      $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
      Write-Host "Manifest written to $manifestPath"
  } else {
      Write-Error "Unexpected Claude output – no control token found."
      exit 1
  }
  ```
- [ ] **Step 2: Smoke‑test the script with a dummy prompt** that prints `<<DOCX‑READY>>` to verify the success branch.
- [ ] **Step 3: Commit** the script.
  ```bash
  git add scripts/run-prompt-pack.ps1
  git commit -m "feat: orchestrator script for Prompt Pack automation"
  ```

---

### Task 4: Add slash‑command definition

**Files:**
- Create: `.claude/commands/prompt-pack-run.md`

- [ ] **Step 1: Write the command markdown**
  ```markdown
  # /prompt-pack-run
  
  **Description:** Execute the Prompt Pack automation pipeline.
  
  **Usage:** simply type `/prompt-pack-run` inside Claude Desktop. No arguments are required.
  
  **Implementation:** runs `scripts/run-prompt-pack.ps1`.
  
  ```yaml
  command: scripts/run-prompt-pack.ps1
  ```
  ```
- [ ] **Step 2: Register the command** (Claude Desktop automatically loads files under `.claude/commands`). Verify with `/skill list` that `prompt‑pack‑run` appears.
- [ ] **Step 3: Commit** the new command file.
  ```bash
  git add .claude/commands/prompt-pack-run.md
  git commit -m "feat: add /prompt-pack-run slash command"
  ```

---

### Task 5: Add post‑hook agent

**Files:**
- Create: `.claude/agents/prompt-pack-agent.md`

- [ ] **Step 1: Write the agent description**
  ```markdown
  # Agent: prompt-pack-agent
  
  **Purpose:** React to the output of `/prompt-pack-run`.
  
  - When Claude returns `<<DOCX‑READY>>`, this agent runs the thesis build (`build-thesis.ps1`) and verification (`verify-thesis.ps1`).
  - When Claude returns `<<PAUSE>>`, it generates a JSON manifest under `manifest/` (as implemented in `run-prompt-pack.ps1`).
  
  **Activation:** This agent is attached to the `/prompt-pack-run` command via the `post‑action` field in the command definition.
  
  **Logging:** All actions are logged to `logs/prompt-pack-agent.log`.
  ```
- [ ] **Step 2: Ensure the `logs/` directory exists** (create if missing).
  ```powershell
  if (-not (Test-Path -LiteralPath "logs")) { New-Item -ItemType Directory -Path "logs" }
  ```
- [ ] **Step 3: Commit** the agent file.
  ```bash
  git add .claude/agents/prompt-pack-agent.md
  git commit -m "feat: post‑hook agent for Prompt Pack automation"
  ```

---

### Task 6: Create `manifest/` folder and ignore artifacts

**Files:**
- Create folder: `manifest/`
- Modify: `.gitignore`

- [ ] **Step 1: Create the directory**
  ```powershell
  if (-not (Test-Path -LiteralPath "manifest")) { New-Item -ItemType Directory -Path "manifest" }
  ```
- [ ] **Step 2: Update `.gitignore`** to avoid committing large snapshots and logs.
  ```bash
  echo "snapshot/*.zip" >> .gitignore
  echo "logs/" >> .gitignore
  echo "manifest/*.json" >> .gitignore
  ```
- [ ] **Step 3: Commit the new folder and .gitignore changes**
  ```bash
  git add manifest .gitignore
  git commit -m "chore: add manifest folder and ignore snapshot/log artifacts"
  ```

---

### Task 7: Write resume‑manifest.ps1 (OpenCode watcher)

**Files:**
- Create: `scripts/resume-manifest.ps1`

- [ ] **Step 1: Write the watcher script**
  ```powershell
  # ---------------------------------------------------------------
  # resume-manifest.ps1 – Watch for new manifest JSON files and continue Claude work
  # ---------------------------------------------------------------
  $watchPath = "manifest"
  Write-Host "Watching $watchPath for new *.json manifests..."
  while ($true) {
      $files = Get-ChildItem -Path $watchPath -Filter "*.json" -File
      foreach ($f in $files) {
          $manifest = Get-Content -LiteralPath $f.FullName -Raw | ConvertFrom-Json
          Write-Host "Resuming stage $($manifest.stage) using snapshot $($manifest.snapshot)"
          $cmd = "claude --model opus --prompt \"$($manifest.nextPrompt)\" --attachment \"$($manifest.snapshot)\" --output temp/resumed-response.txt"
          Invoke-Expression $cmd
          # After resume, delete the manifest so we don't process it again
          Remove-Item -LiteralPath $f.FullName -Force
      }
      Start-Sleep -Seconds 5
  }
  ```
- [ ] **Step 2: Test the watcher** by manually creating a dummy manifest file and confirming the script invokes Claude.
- [ ] **Step 3: Commit** the new script.
  ```bash
  git add scripts/resume-manifest.ps1
  git commit -m "feat: OpenCode resume‑manifest watcher for paused Claude runs"
  ```

---

### Task 8: Documentation & README updates

**Files:**
- Modify: `README.md` (or a dedicated docs page) to mention the new `/prompt-pack-run` command and the auto‑skill.

- [ ] **Step 1: Add a short usage section**
  ```markdown
  ## Prompt‑Pack Automation
  
  Run the full thesis‑assembly pipeline with a single command inside Claude Desktop:
  
  ```
  /prompt-pack-run
  ```
  
  The command snapshots the repository, invokes Claude, and automatically builds & verifies the thesis. If Claude hits its token limit, the process pauses, writes a manifest, and the OpenCode `resume-manifest.ps1` watcher will continue the work.
  ```
- [ ] **Step 2: Commit documentation changes**
  ```bash
  git add README.md
  git commit -m "docs: add Prompt Pack automation usage to README"
  ```

---

### Task 9: Final verification checklist

- [ ] Run `/prompt-pack-run` inside Claude Desktop with the real PromptPack.md and confirm that:
  - A snapshot zip appears under `snapshot/`.
  - Claude processes the prompt and returns `<<DOCX‑READY>>`.
  - The thesis DOCX/PDF are regenerated in `Research_and_Development/Thesis_Surgical_Edit/output/`.
  - `verify-thesis.ps1` reports **PASS** for all checks.
- [ ] If Claude returns `<<PAUSE>>`, verify that a JSON manifest appears under `manifest/` and that `scripts/resume-manifest.ps1` picks it up and eventually completes the pipeline.
- [ ] Push all changes to the remote repository.

---

**Plan saved to** `docs/superpowers/plans/2026-05-22-prompt-pack-auto-skill-implementation.md`.

**Execution options:**
1. **Subagent‑Driven (recommended)** – dispatch a fresh subagent for each task, review after each step.
2. **Inline Execution** – run the whole plan in this session using `executing-plans`.

Which approach would you like to take?