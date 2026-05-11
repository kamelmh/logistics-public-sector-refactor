---
description: CrossFlow handoff sync — update HANDOFF.md + SESSION_LOG.md
agent: build
---

Sync the current session state to CrossFlow:

```
pwsh -NoProfile -File scripts/harness.ps1 sync "<what was done>"
```

Example:
```
pwsh -NoProfile -File scripts/harness.ps1 sync "Deployed s08 persistent bg runner + fixed error handling"
```

Updates HANDOFF.md with date + last action.
Appends entry to SESSION_LOG.md with incrementing ID.
