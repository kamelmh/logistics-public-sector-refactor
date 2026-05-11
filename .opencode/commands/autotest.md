---
description: Macro test suite (harness-aware)
agent: build
---

Run the macro test suite:

1. **Create task**: `pwsh -NoProfile -File scripts/harness.ps1 task create "Test" "Macro test suite"`
2. **Run with bg runner**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 bg run "pwsh -NoProfile -ExecutionPolicy Bypass -File Software_Surgical_Edit/test-macros.ps1"
   ```
3. **Check**: `pwsh -NoProfile -File scripts/harness.ps1 bg list`
4. PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed`
   FAIL → report errors
