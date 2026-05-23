# resume

**Description**: Full project context restore. Run this at the start of every daily session to load all Academix v13.2 context, memory, skills, and state. Works with any model/provider.

**Usage**: `/resume` or `resume`

**What it does** (7 steps, automated):

### Step 1 — Read uber-context
Read these files in order:
- `.opencode/bootstrap/MASTER_BOOTSTRAP.xml` — project identity, ground truth, architecture, paths, known issues
- `.opencode/erp-context-compact.md` — token-optimized snapshot (~5K tokens, covers all XML context files)
- `.crossflow/HANDOFF.md` — read from bottom: current state, pending tasks, final sign-off
- `C:\Users\Administrator\.opencode\notepad.md` — session memory, last-action line, completion status

### Step 2 — Load OMC memory checkpoint
Run: `/memory recall 0`

This loads the latest machine-state checkpoint from `C:\Users\Administrator\.omc\state\sessions\memory-checkpoint-latest.md`

### Step 3 — Load critical skills
Run these skill loads in order:
1. `skill load project` — project operations (tests, commit, review, PR, organize)
2. `skill load remember` — knowledge management and memory surfaces
3. `skill load crossflow-sync` — cross-window context sync
4. `skill load autoaudit` — 5-phase DSS audit
5. `skill load verify` — verification protocol
6. `skill load planning-and-task-breakdown` — task decomposition

### Step 4 — Check current state
- Read `vbe-auto/results/` — most recent verify_results_*.json for ERP health
- Check `output/metrics/` — most recent build-*.json for thesis metrics
- Run: `git status --short` — quick dirty check

### Step 5 — Report status
Print a concise status board:
```
╔══════════════════════════════════════════╗
║  ACADEMIX v13.2 — SESSION RESUME        ║
╠══════════════════════════════════════════╣
║  Last action: <from notepad.md>         ║
║  ERP verify: <latest result>            ║
║  Thesis verify: <latest result>         ║
║  Active phase: <from HANDOFF.md>        ║
║  Pending: <next tasks>                  ║
╚══════════════════════════════════════════╝
```

### Step 6 — Offer continuation
Ask user: "Resume from last action? Or switch to a different task?"

### Step 7 — Save on exit
Before closing: `/memory save "Done: X | Next: Y"`

### Example full command (for other models/CLI)
```powershell
# If /resume doesn't exist, run these manually:
opencode gemini   # or: opencode (default)
# Then in chat:
/memory recall 0
# Then load skills one by one:
/skill load project
/skill load remember
/skill load crossflow-sync
```

### Files referenced by this command
| File | Purpose |
|------|---------|
| `.opencode/bootstrap/MASTER_BOOTSTRAP.xml` | Uber-context (must read first) |
| `.opencode/erp-context-compact.md` | Token-optimized snapshot |
| `.crossflow/HANDOFF.md` | Current state and pending tasks |
| `C:\Users\Administrator\.opencode\notepad.md` | Session memory and last-action |
| `C:\Users\Administrator\.omc\state\sessions\memory-checkpoint-latest.md` | OMC checkpoint |
| `.opencode/skills/` | Skill files (project, remember, crossflow-sync, autoaudit, verify) |
| `vbe-auto/results/` | ERP verification results |
| `output/metrics/` | Thesis build metrics |
