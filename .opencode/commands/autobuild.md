---
description: Build workbook from .bas sources + verify (harness-aware)
agent: build
---

Run the build pipeline using the engineering harness:

1. **Create task in DAG**:
   ```powershell
   pwsh -NoProfile -File scripts/harness.ps1 task create "Build" "Rebuild .xlsm from .bas sources"
   pwsh -NoProfile -File scripts/harness.ps1 task create "Verify" "137-point verification" 1
   ```

2. **Run build**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/build.ps1 -ConfigPath vbe-auto/config.json
   ```
   On PASS: `pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed`
   On FAIL: `pwsh -NoProfile -File scripts/harness.ps1 task update 1 deleted` and stop

3. **Run verify**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json
   ```
   On PASS: `pwsh -NoProfile -File scripts/harness.ps1 task update 2 completed`
   On FAIL: stop and report

4. **Save transcript**: `pwsh -NoProfile -File scripts/harness.ps1 compact save`

Report PASS/FAIL for each step. Stop on failure.
