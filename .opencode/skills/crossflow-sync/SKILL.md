---
name: crossflow-sync
description: CrossFlow multi-window sync — read handoff, update session log, check context freshness.
level: 3
---
# CrossFlow Sync

## Description
CrossFlow multi‑window sync ensures that every window (main‑hub, gemini‑thesis, claude‑project) has a consistent view of the global state. It does three things:
1. Reads `.crossflow/HANDOFF.md` – shows pending items and recent sign‑offs.
2. Reads `.crossflow/MASTER_CONTEXT.md` – checks the `last-updated` timestamp and any changed GUIDs.
3. Loads the `crossflow-orchestrator` skill to refresh the full multi‑window context.
4. Prompts the user to append a note to `SESSION_LOG.md` if work was performed that could affect another window.

## Usage
Run at session start and after any high‑impact task (e.g., after a build, verify, or edit that changes shared state).

```
/crossflow-sync
```
or simply:
```
crossflow-sync
```

## Workflow
1. **Read HANDOFF** – prints the pending items and the last sign‑off line.
2. **Read MASTER_CONTEXT** – displays the last‑updated timestamp and warns if the context is stale.
3. **Load orchestrator** – ensures the `crossflow-orchestrator` skill is active, which refreshes all window‑specific caches.
4. **Session log prompt** – asks: "Did you perform work that may affect another window? (y/n)". If **y**, opens the default editor to append a timestamped entry to `SESSION_LOG.md`.

## When to use
- **Every session start** – guarantees you begin with a fresh, shared view.
- **After any task that touches shared files** – e.g., after running `pipeline:full`, `build‑english‑paper.ps1`, `verify‑thesis.ps1`, or any edit to `.crossflow/HANDOFF.md` or `.crossflow/MASTER_CONTEXT.md`.

## CrossFlow Skill
The skill depends on `crossflow-orchestrator` (`.opencode/skills/crossflow-orchestrator/SKILL.md`). Ensure that skill is present; it provides the underlying window‑coordination primitives.

## Windows involved
- **`main-hub`** – this window (VBA, build, verify, general ERP work).
- **`gemini-thesis`** – thesis analysis, DOCX generation, verification.
- **`claude-project`** – discussion, review, documentation work.

## Example session
```
> crossflow-sync
[CrossFlow Sync] Reading HANDOFF.md …
[CrossFlow Sync] Pending items: …
[CrossFlow Sync] Last sign‑off: 2026-05-23 10:45:12 UTC – Unconditional Sign‑off Issued …
[CrossFlow Sync] Reading MASTER_CONTEXT.md …
[CrossFlow Sync] Last‑updated: 2026-05-23 11:08:03 UTC – context fresh.
[CrossFlow Sync] Loading crossflow‑orchestrator skill … OK
Did you perform work that may affect another window? (y/n) y
[Opening SESSION_LOG.md in default editor…]
```
After you save and close the editor, the sync routine finishes.
