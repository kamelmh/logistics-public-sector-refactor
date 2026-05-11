---
description: s12 — List all worktrees with their bound tasks
agent: build
---

List all active worktrees and their task bindings:

```
pwsh -NoProfile -File scripts/harness.ps1 worktree list
```

Shows: name, path, branch, bound task ID, status (active|removed).
