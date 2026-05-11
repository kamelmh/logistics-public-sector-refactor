---
description: s07 — Claim a task for an agent
agent: build
---

Claim ownership of a task and set it to in_progress:

```
pwsh -NoProfile -File scripts/harness.ps1 task claim <id> <owner_name>
```

Used by autonomous agents (s11) to claim unowned tasks during idle polling.
