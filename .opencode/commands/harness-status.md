---
description: Unified health check — all 5 harness layers (s06/s07/s08/s09/s12)
agent: build
---

Run a unified health check across all deployed harness layers:

```
pwsh -NoProfile -File scripts/harness.ps1 status
```

Reports: transcripts count, task DAG stats, bg runner status, team roster, worktree list.
