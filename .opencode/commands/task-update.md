---
description: s07 — Update task status or dependencies
agent: build
---

Update a task's status or dependency edges:

```
# Set status
pwsh -NoProfile -File scripts/harness.ps1 task update <id> <status>

# Status values: pending, in_progress, completed, deleted
# completed auto-clears this ID from all dependents' blockedBy
# deleted removes the task file
```

Returns updated task JSON.
