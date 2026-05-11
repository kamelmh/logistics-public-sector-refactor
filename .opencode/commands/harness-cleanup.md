---
description: GC stale bg tasks, old transcripts, orphaned worktrees
agent: build
---

Garbage-collect stale harness artifacts:

```
pwsh -NoProfile -File scripts/harness.ps1 cleanup
```

Cleans:
- s08: completed/error/orphaned bg task directories
- s06: transcripts older than 7 days
- s12: worktree index entries with missing directories
