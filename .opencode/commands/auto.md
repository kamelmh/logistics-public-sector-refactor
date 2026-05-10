---
description: AUTO pipeline — build, verify, test, audit, plan, thesis, check, fix
agent: build
---

# AUTO Workflow Command

Run automated workflows for the ERP Academix v13.2 project.

## Usage
/auto build       — Build workbook from .bas sources, then verify
/auto verify      — Run 137 verification checks
/auto test        — Run macro test suite
/auto audit       — Run 5-phase DSS audit
/auto thesis      — Build thesis PDF
/auto check       — Run system health diagnostics
/auto plan        — Planning workflow (architecture, task breakdown)
/auto fix         — Full pipeline: build → verify → test → audit
/auto             — Run full pipeline (default: same as fix)

## Implementation
Use the bash tool to run the appropriate script from the project root.
Project root: C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor

Scripts:
- Build:   pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/build.ps1 -ConfigPath vbe-auto/config.json
- Verify:  pwsh -NoProfile -ExecutionPolicy Bypass -File vbe-auto/verify.ps1 -ConfigPath vbe-auto/config.json
- Test:    pwsh -NoProfile -ExecutionPolicy Bypass -File Software_Surgical_Edit/test-macros.ps1
- Audit:   pwsh -NoProfile -ExecutionPolicy Bypass -File milestone_13_2/tests/dss-audit.ps1
- Thesis:  pwsh -NoProfile -ExecutionPolicy Bypass -File Thesis_Surgical_Edit/build-thesis.ps1
- Health:  pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/system-health-test.ps1

For "plan", load the plan skill and do a planning session for the current task.

After each step, report the result clearly (PASS/FAIL) and stop on failure for pipeline mode.
