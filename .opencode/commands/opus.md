# /opus — CrossFlow-Opus Task Manager

Queue focused tasks for Claude Opus via CLI. Token-efficient, git-tracked, monitored.

## Usage

```
/opus                          # Show task board status
/opus list                     # List all tasks with status
/opus add <type> <file> "prompt"   # Add a task to the queue
/opus run                      # Execute next pending task
/opus run TASK-001             # Execute specific task
/opus run --dry-run            # Preview without executing
/opus results                  # Show latest results
/opus status                   # Token usage summary
```

## Task Types

| Type | Description | Input |
|------|-------------|-------|
| `audit-module` | Security + quality audit of a .bas file | 1 VBA module |
| `review-thesis` | Academic review of a thesis chapter | 1 chapter from MD |
| `review-paper` | IEEE compliance check | 1 paper section |
| `refactor-plan` | Refactoring proposal (no code changes) | 1 .bas file |
| `defense-qa` | Generate jury Q&A | Thesis + context |
| `custom` | Free-form analysis | Any file/prompt |

## How It Works

```
OpenCode (you)                Git                 Claude Opus (CLI)
      │                        │                        │
      │ 1. /opus add           │                        │
      │    writes task board   │                        │
      │───────────────────────>│                        │
      │                        │                        │
      │ 2. git commit          │                        │
      │───────────────────────>│                        │
      │                        │                        │
      │                        │   3. opus-execute.ps1  │
      │                        │      reads task        │
      │                        │      builds prompt     │
      │                        │      calls claude CLI  │
      │                        │───────────────────────>│
      │                        │                        │
      │                        │   4. Result written    │
      │                        │      git committed     │
      │                        │<───────────────────────│
      │                        │                        │
      │ 5. /opus results       │                        │
      │<───────────────────────│                        │
```

## Token Budget Strategy

Each task is scoped to fit within Opus's 200K context:

- **Module audit**: ~8K tokens (1 .bas file + ground truth summary)
- **Thesis review**: ~15K tokens (1 chapter + ground truth)
- **Refactor plan**: ~12K tokens (1 module + dependency map)
- **Defense Q&A**: ~20K tokens (thesis extract + context)

Total per task: ~15-25K tokens input + ~5-8K output = **~30K tokens max**
**Cost**: ~$0.15-0.30 per task (at Opus rates)

## Files

| File | Purpose |
|------|---------|
| `.crossflow/opus-tasks.md` | Task board (queue) |
| `.crossflow/opus-results.md` | Execution results |
| `.crossflow/opus-execute.ps1` | Worker script |

## Examples

```powershell
# Add a security audit task
/opus add audit-module Software_Surgical_Edit/VBA_Modules/mod_Config.bas "Audit for hardcoded secrets and injection vectors"

# Add a thesis review task
/opus add review-thesis Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md "Review Chapter 3 for formula correctness"

# Run next pending task
/opus run

# Run specific task
/opus run TASK-001

# Preview without executing
/opus run --dry-run
```
