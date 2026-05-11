---
description: 5-phase DSS audit (harness-aware)
agent: build
---

Run the 5-phase DSS audit:

1. **Create task**: `pwsh -NoProfile -File scripts/harness.ps1 task create "Audit" "5-phase DSS audit"`
2. **Create worktree** for isolated audit: `pwsh -NoProfile -File scripts/harness.ps1 worktree create audit-run 1`
3. **Run audit in worktree**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File milestone_13_2/tests/dss-audit.ps1
   ```
4. PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed`
   FAIL → report
5. **Cleanup**: `pwsh -NoProfile -File scripts/harness.ps1 worktree remove audit-run`
