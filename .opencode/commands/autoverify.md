---
description: 137-point verification (harness-aware)
agent: build
---

Run the verification suite:

1. **Create task**: `pwsh -NoProfile -File scripts/harness.ps1 task create "Verify" "137-point check"`
2. **Run verify**:
   ```powershell
   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json
   ```
3. PASS → `pwsh -NoProfile -File scripts/harness.ps1 task update 1 completed`
   FAIL → report errors
4. `pwsh -NoProfile -File scripts/harness.ps1 compact save`
