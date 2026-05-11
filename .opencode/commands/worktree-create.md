---
description: s12 — Create git worktree bound to task
agent: build
---

Create an isolated git worktree, optionally bound to a task:

```
# Create worktree for a task
pwsh -NoProfile -File scripts/harness.ps1 worktree create <name> [task_id]

# Example: create for task 3
pwsh -NoProfile -File scripts/harness.ps1 worktree create auth-refactor 3
```

Creates `git worktree add -b wt/<name> .worktrees/<name> HEAD`.
Records in `.worktrees/index.json`. Binds to task (auto-sets in_progress).
