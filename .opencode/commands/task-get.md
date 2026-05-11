---
description: s07 — Get task details by ID
agent: build
---

Get full task JSON:

```
pwsh -NoProfile -File scripts/harness.ps1 task get <id>
```

Returns: id, subject, description, status, owner, blockedBy, worktree, created.
