---
description: Full pipeline — build, verify, test, audit
agent: build
---

Run the complete pipeline in sequence:

1. **Build**: `pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/build.ps1 -ConfigPath vbe-auto/config.json`
2. **Verify**: `pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json`
3. **Test**: `pwsh -NoProfile -ExecutionPolicy Bypass -File Software_Surgical_Edit/test-macros.ps1`
4. **Audit**: `pwsh -NoProfile -ExecutionPolicy Bypass -File milestone_13_2/tests/dss-audit.ps1`

Stop on any failure. Report each phase clearly with PASS/FAIL.
