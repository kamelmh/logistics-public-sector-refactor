# Prompt Pack + Claude Desktop Auto‑Skill – Design Specification (Approach B)

**Version:** 2026‑05‑27

---

## 1. Overview
This skill provides a seamless, one‑click way for a user working inside Claude Desktop to generate a **Prompt Pack** (`PromptPack.md`), take a **snapshot** of the current repository state, invoke Claude Desktop to process the prompt, and automatically run the thesis‑assembly pipeline when Claude finishes. If Claude reaches its context/token limit, it pauses, returns a partial result, and writes a **manifest** that an OpenCode agent can later resume.

---

## 2. File Layout
| Path | Purpose |
|------|---------|
| `docs/superpowers/prompt‑pack/PromptPack.md` | The prompt package that Claude will execute. |
| `docs/superpowers/specs/2026-05-27-prompt‑pack‑design.md` | This design specification (the file you are reading). |
| `scripts/snapshot‑context.ps1` | PowerShell script that gathers git information, key config files, the prompt pack, and the latest thesis build output, then creates a zip snapshot. |
| `scripts/run‑prompt‑pack.ps1` | Wrapper script that calls `snapshot‑context.ps1`, invokes the Claude CLI, and delegates post‑processing based on Claude’s response. |
| `.claude/commands/prompt‑pack‑run.md` | Slash‑command definition (`/prompt‑pack‑run`) that users type inside Claude Desktop. |
| `.claude/agents/prompt‑pack‑agent.md` | Post‑hook agent that watches Claude’s output, runs the thesis build/verify steps, or writes a manifest when Claude signals a pause. |
| `manifest/` | Directory where pause‑manifests (`*.json`) are written for the OpenCode resume agent. |
| `scripts/resume‑manifest.ps1` | Simple watcher that picks up a new manifest, launches a fresh Claude session with the same snapshot attached, and feeds the next prompt. |

---

## 3. Trigger
**Slash command:** `/prompt‑pack‑run`

- No arguments are required.
- When executed, Claude Desktop loads the command definition, which in turn runs `scripts/run‑prompt‑pack.ps1`.
- The command is visible in Claude Desktop under **Commands → prompt‑pack‑run** after installing this skill.

---

## 4. Snapshot Script (`scripts/snapshot‑context.ps1`)
```powershell
# ---------------------------------------------------------------
# snapshot‑context.ps1 – Capture repo state for Claude Desktop
# ---------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$workDir = (Get-Location).Path
$snapDir = Join-Path $workDir "snapshot_temp_$timestamp"
New-Item -ItemType Directory -Path $snapDir | Out-Null

# 1. Git information
git status > "$snapDir\git-status.txt"
git diff   > "$snapDir\git-diff.txt"
git log -n 10 --oneline > "$snapDir\git-log.txt"

# 2. Key configuration files (always copy if they exist)
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

# 4. Create zip
$zipPath = Join-Path $workDir "snapshot/$timestamp-snapshot.zip"
if (-not (Test-Path -LiteralPath "snapshot")) { New-Item -ItemType Directory -Path "snapshot" | Out-Null }
Compress-Archive -Path "$snapDir\*" -DestinationPath $zipPath -Force

# Cleanup temporary folder
Remove-Item -LiteralPath $snapDir -Recurse -Force

Write-Output "Snapshot created at: $zipPath"
```
The script produces a single zip file under `snapshot/` that will be attached to Claude.

---

## 5. Claude Interaction (`scripts/run‑prompt‑pack.ps1`)
```powershell
# ---------------------------------------------------------------
# run‑prompt‑pack.ps1 – Main orchestrator for Approach B
# ---------------------------------------------------------------
# 1. Create snapshot
$snapshotPath = & "${PSScriptRoot}\snapshot-context.ps1"
# The script prints the path; capture it
$snapshotPath = $snapshotPath -replace "Snapshot created at: ", ""
$snapshotPath = $snapshotPath.Trim()

# 2. Define prompt file location
$promptFile = "docs/superpowers/prompt-pack/PromptPack.md"

# 3. Invoke Claude CLI
# --model chooses a robust Claude model (Opus) and attaches the snapshot.
$claudeCmd = "claude --model opus --prompt-file `"$promptFile`" --attachment `"$snapshotPath`" --output temp/claude-response.txt"
Write-Host "Running Claude: $claudeCmd"
Invoke-Expression $claudeCmd

# 4. Analyse Claude response
$resp = Get-Content -LiteralPath "temp/claude-response.txt" -Raw
if ($resp -match "<<DOCX‑READY>>") {
    Write-Host "Claude signaled completion – building thesis..."
    & "Research_and_Development/Thesis_Surgical_Edit/build-thesis.ps1"
    & "Research_and_Development/Thesis_Surgical_Edit/verify-thesis.ps1"
    Write-Host "Build and verification finished."
} elseif ($resp -match "<<PAUSE>>") {
    Write-Host "Claude paused – generating manifest for resume."
    $manifest = @{
        stage      = "prompt‑pack"
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
The script decides what to do based on Claude’s **control tokens** (`<<DOCX‑READY>>` or `<<PAUSE>>`).

---

## 6. Post‑Hook Agent (`.claude/agents/prompt‑pack‑agent.md`)
```markdown
# Agent: prompt‑pack‑agent

**Purpose**: React to the output of the `/prompt‑pack‑run` command.

- When Claude returns `<<DOCX‑READY>>`, the agent runs the thesis build (`build‑thesis.ps1`) and verification (`verify‑thesis.ps1`).
- When Claude returns `<<PAUSE>>`, the agent creates a JSON manifest under `manifest/` (see `run‑prompt‑pack.ps1`).
- The agent logs all actions to `logs/prompt‑pack-agent.log` for auditability.

**Activation**: This agent is automatically attached to the `/prompt‑pack‑run` command via the `post‑action` field in the command definition.
```
(Implementation details are handled by the command runner; the agent file merely documents the behavior.)

---

## 7. Manifest Format (`manifest/*.json`)
```json
{
  "stage": "prompt-pack",
  "snapshot": "snapshot/20260527-1530-snapshot.zip",
  "partialResultPath": "temp/claude-response.txt",
  "nextPrompt": "Continue from where Claude stopped.",
  "timestamp": "2026-05-27T15:30:12Z"
}
```
The OpenCode **resume agent** reads this file, re‑attaches the same snapshot, and feeds `nextPrompt` as the new prompt to Claude.

---

## 8. OpenCode Resume Agent (`scripts/resume-manifest.ps1`)
```powershell
# ---------------------------------------------------------------
# resume-manifest.ps1 – Watch for new manifests and continue work
# ---------------------------------------------------------------
$watchPath = "manifest"
Write-Host "Watching $watchPath for new *.json manifests..."
while ($true) {
    $files = Get-ChildItem -Path $watchPath -Filter "*.json" -File
    foreach ($f in $files) {
        $manifest = Get-Content -LiteralPath $f.FullName -Raw | ConvertFrom-Json
        Write-Host "Resuming stage ${($manifest.stage)} using snapshot ${($manifest.snapshot)}"
        # Re‑run Claude with the same snapshot and the next prompt
        $cmd = "claude --model opus --prompt \"${manifest.nextPrompt}\" --attachment \"${manifest.snapshot}\" --output temp/resumed-response.txt"
        Invoke-Expression $cmd
        # After resume, clean up the manifest
        Remove-Item -LiteralPath $f.FullName -Force
    }
    Start-Sleep -Seconds 5
}
```
Run this watcher in a separate PowerShell window (or as a background job) while you are working on the thesis.

---

## 9. Failure Modes & Mitigations
| Situation | Detection | Mitigation |
|-----------|-----------|------------|
| Snapshot creation fails (missing file) | PowerShell error code ≠ 0 | Abort and display a clear message telling the user which file is absent. |
| Claude CLI not installed | `claude --version` returns non‑zero | Abort with instruction to install the Claude CLI (`brew install claude` on macOS or the Windows installer). |
| Claude returns neither token | Script falls into the `else` branch | Exit with error code 1 and dump the raw response to `logs/claude‑unexpected.txt` for debugging. |
| Build or verify step fails | Non‑zero exit status from `build‑thesis.ps1` or `verify‑thesis.ps1` | Stop further processing, write the error to `logs/build‑error.txt`, and leave the manifest untouched (so the user can fix the issue and re‑run). |
| Manifest JSON malformed | `ConvertFrom‑Json` throws | Log the exception, delete the malformed manifest, and alert the user. |

---

## 10. Security & Cleanup
- **No secrets** are copied into the snapshot; the script only includes source files and git metadata.
- Temporary folders (`snapshot_temp_*`) are removed immediately after zipping.
- The `snapshot/` directory is listed in `.gitignore` to avoid committing large zip files.
- All generated logs are written under `logs/` and are also ignored by Git.

---

## 11. Acceptance Criteria
1. Running `/prompt‑pack‑run` creates a zip snapshot under `snapshot/` and attaches it to Claude.
2. If Claude finishes the prompt and emits `<<DOCX‑READY>>`, the thesis DOCX & PDF appear in `Research_and_Development/Thesis_Surgical_Edit/output/` and `verify‑thesis.ps1` reports **PASS** for all 25 checks.
3. If Claude emits `<<PAUSE>>`, a JSON manifest appears in `manifest/` and the OpenCode resume agent (`resume-manifest.ps1`) can pick it up, launch a new Claude session with the same snapshot, and continue until the final `<<DOCX‑READY>>` token is produced.
4. All scripts run on Windows PowerShell 7+ without requiring additional dependencies.
5. Logging files are created under `logs/` for audit.

---

## 12. Future Extensions
- **CI Integration** – reuse `snapshot-context.ps1` inside a GitHub Actions workflow to run the whole pipeline on every push.
- **Gemini CLI fallback** – if the Claude CLI is unavailable, the wrapper can automatically switch to `gemini` with equivalent flags.
- **Parameterized prompt** – allow the slash command to accept a custom prompt file path for ad‑hoc runs.
- **Dynamic token‑limit handling** – expose an optional argument to set the max‑tokens for Claude, making the `<<PAUSE>>` behavior configurable.

---

*Design author: OpenCode Agent (brainstorming step).*
