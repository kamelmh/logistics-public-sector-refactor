---
description: Run system health diagnostics
agent: build
---

Run the system health check:
`pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/system-health-test.ps1` (from project root)

Also run git status to check for uncommitted changes.
Report overall health: OK, WARNING, or CRITICAL.
