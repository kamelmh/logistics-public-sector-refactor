---
description: s08 — Run a shell command in background thread
agent: build
---

Start a long-running command in the background:

```
pwsh -NoProfile -File scripts/harness.ps1 bg run "<command>"
```

Returns a task_id immediately. The command runs asynchronously.
Check status with `bg-check`; list all with `bg-list`.
