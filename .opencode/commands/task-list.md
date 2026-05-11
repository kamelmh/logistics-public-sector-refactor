---
description: s07 — List all tasks with status
agent: build
---

List all tasks in the DAG system:

```
pwsh -NoProfile -File scripts/harness.ps1 task list
```

Shows: `[ ]` pending, `[>]` in_progress, `[x]` completed, plus owner and blockedBy info.
