---
description: s08 — Check background task status
agent: build
---

Check the status and result of a background task:

```
# Specific task
pwsh -NoProfile -File scripts/harness.ps1 bg check <task_id>

# List all
pwsh -NoProfile -File scripts/harness.ps1 bg list
```

Shows: running, completed, or error with result snippet.
