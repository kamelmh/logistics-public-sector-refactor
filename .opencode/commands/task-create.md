---
description: s07 — Create a persistent file task
agent: build
---

Create a task in the DAG-backed task system:

```
pwsh -NoProfile -File scripts/harness.ps1 task create "<subject>" ["<description>"] ["<blockedBy: comma-separated IDs>"]
```

Returns JSON with: id, subject, description, status ("pending"), owner, blockedBy, worktree.
Tasks persist across sessions in `.tasks/task_{id}.json`.
