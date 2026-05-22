# crossflow-sync

**Description**: CrossFlow multi-window sync — read handoff, update session log, check context freshness.

**Usage**: `/crossflow-sync` or `crossflow-sync`

**Workflow**:
1. Reads `.crossflow/HANDOFF.md` — shows pending items
2. Reads `.crossflow/MASTER_CONTEXT.md` — checks last-updated timestamp
3. Loads `crossflow-orchestrator` skill for full multi-window context
4. Prompts to append to `SESSION_LOG.md` if work was done

**When to use**: On every session start, and after completing any task that might affect another window.

**CrossFlow Skill**: `crossflow-orchestrator` (`.opencode/skills/crossflow-orchestrator/SKILL.md`)

**Windows**:
- `main-hub` (this window) — VBA, build, verify
- `gemini-thesis` — Thesis analysis, DOCX generation
- `claude-project` — Discussion, review
