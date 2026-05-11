---
description: Full pipeline — build, verify, test, audit (harness-aware)
agent: build
---

Run the complete pipeline using the engineering harness:

1. **Create task DAG**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 task create "Build" "Rebuild .xlsm"
   pwsh -NoProfile -File scripts/harness.ps1 task create "Verify" "137 checks" 1
   pwsh -NoProfile -File scripts/harness.ps1 task create "Test" "Macro test suite" 2
   pwsh -NoProfile -File scripts/harness.ps1 task create "Audit" "5-phase DSS audit" 2
   ```

2. **Build**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/build.ps1 -ConfigPath vbe-auto/config.json
   ```
   PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed`
   FAIL → `pwsh -NoProfile -File scripts/harness.ps1 task update 1 deleted` and stop

3. **Verify**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json
   ```
   PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 2 completed`
   FAIL → stop

4. **Test + Audit in parallel** (s08 bg runner):
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 bg run "pwsh -NoProfile -ExecutionPolicy Bypass -File Software_Surgical_Edit/test-macros.ps1"
   pwsh -NoProfile -File scripts/harness.ps1 bg run "pwsh -NoProfile -ExecutionPolicy Bypass -File milestone_13_2/tests/dss-audit.ps1"
   ```

5. **Check results**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 bg list
   ```
   On all PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 3 completed` and `task update 4 completed`
   On any FAIL → stop and report

6. **Save transcript**: `pwsh -NoProfile -File scripts/harness.ps1 compact save`

Stop on any failure. Report each phase clearly with PASS/FAIL.
