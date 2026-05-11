---
description: End-to-end demo — s06/s07/s08/s12 full chain
agent: build
---

Run a complete end-to-end demo of the engineering harness:

1. **Save transcript** (s06):
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 compact save
   ```

2. **Create task DAG** (s07):
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 task create "Audit VBA" "Scan for dead code"
   pwsh -NoProfile -File scripts/harness.ps1 task create "Rebuild" "Run build.ps1" 1
   pwsh -NoProfile -File scripts/harness.ps1 task create "Verify" "Run verify.ps1" 2
   ```

3. **Complete first task** — see cascade unblock:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed
   pwsh -NoProfile -File scripts/harness.ps1 task list
   ```

4. **Start rebuild in background** (s08):
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 bg run "Write-Output 'build OK'"
   ```

5. **Create worktree for audit** (s12):
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 worktree create audit-wt
   ```

6. **Show status**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 status
   ```

7. **Cleanup**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 task update 2 completed
   pwsh -NoProfile -File scripts/harness.ps1 task update 3 completed
   pwsh -NoProfile -File scripts/harness.ps1 worktree remove audit-wt
   ```
