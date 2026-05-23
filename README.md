# Logistics Public Sector Refactor (ERP v13.2)

This repository contains the VBA‑based ERP system for the Algerian Public Sector (Direction de l'Education El Bayadh).  The codebase is pure VBA, built via the `vbe-auto` toolkit, and includes a thesis, verification pipelines, and auxiliary automation.

## New Skills Added (May 2026)

### `crossflow-deepseek-ask`
- **Purpose**: Send a question to DeepSeek V4 Flash via the CrossFlow sync topology and capture the answer as an ask artifact.
- **Usage**: `/crossflow-deepseek-ask "<your question>"`
- **Location**: `.opencode/skills/crossflow-deepseek-ask/SKILL.md`
- **Example**:
  ```bash
  /crossflow-deepseek-ask "Assess the priority of using CrossFlow for our EPIC project architecture."
  ```

### `crossflow-sync`
- **Purpose**: Multi‑window synchronization – reads handoff, checks context freshness, loads the orchestrator skill, and prompts to update the session log.
- **Usage**: `/crossflow-sync` (run at session start and after any high‑impact task).
- **Location**: `.opencode/skills/crossflow-sync/SKILL.md`
- **Workflow**:
  1. Read `.crossflow/HANDOFF.md` – pending items and recent sign‑offs.
  2. Read `.crossflow/MASTER_CONTEXT.md` – last‑updated timestamp.
  3. Load `crossflow-orchestrator` skill.
  4. Prompt: “Did you perform work that may affect another window? (y/n)”. If **y**, open `SESSION_LOG.md` for appending.

### `autoaudit`
- **Purpose**: Run the full verification suite (`verify.ps1`) to ensure workbook health.
- **Usage**: `/autoaudit`
- **Location**: `.opencode/skills/autoaudit/SKILL.md`

## Core Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `autobuild` | `build.ps1` | Rebuild the ERP workbook from VBA sources. |
| `autoverify` | `verify.ps1` | Run 137 verification checks. |
| `autotest` | `test-macros.ps1` | Execute the macro test suite. |
| `autoaudit` | `verify.ps1` (see skill) | Full verification health check. |
| `autothesis` | `thesis-doctor.ps1 pipeline:full` | Build, verify, and metrics for the thesis. |
| `crossflow-sync` | (skill) | Synchronize windows and update session log. |
| `crossflow-deepseek-ask` | (skill) | Ask DeepSeek V4 Flash via CrossFlow. |

## Verification & Testing

- After any VBA edit, run `autoverify` to ensure no regressions.
- Run `autotest` to confirm macro functionality.
- Use `crossflow-sync` at session start and after edits that affect shared state (e.g., after a build or a handoff update).
- Use `crossflow-deepseek-ask` for quick priority assessments, architecture questions, or any ad‑hoc DeepSeek V4 Flash query.

## Build Instructions

1. **Re‑build the workbook**
   ```powershell
   & "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"
   ```
2. **Verify**
   ```powershell
   & "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"
   ```
3. **Run macro tests**
   ```powershell
   & "Software_Surgical_Edit\test-macros.ps1"
   ```

## Thesis Pipeline

- Full build, verify, and metrics:
  ```powershell
  & "Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1" pipeline:full
  ```
- This yields a DOCX, runs 28 verification checks, and outputs metrics JSON.

## Notes

- All VBA edits must be made to the `*.bas` source files; never edit the `.xlsm` directly (stale p‑code cache).
- Always rebuild after editing VBA sources.
- The CrossFlow skills rely on the `crossflow-orchestrator` skill being present.
- Commit only after user approval and a clean verification run.
