---
description: s12 — Remove git worktree, optionally complete bound task
agent: build
---

Remove a worktree and optionally complete its bound task:

```
pwsh -NoProfile -File scripts/harness.ps1 worktree remove <name>
```

Emits event to `.worktrees/events.jsonl`. To auto-complete the bound task,
use `task-update` with status=completed on the associated task ID.
