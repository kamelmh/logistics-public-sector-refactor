---
description: Build workbook from .bas sources + verify
agent: build
---

Run the full build pipeline:

1. Build: `pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/build.ps1 -ConfigPath vbe-auto/config.json` (from project root)
2. Verify: `pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json`

Report PASS/FAIL for each step. If build fails, stop and report the error.
