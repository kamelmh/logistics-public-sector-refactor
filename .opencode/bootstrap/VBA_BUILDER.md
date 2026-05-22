# VBA Builder Bootstrap
ERP_Academie v13.2 — Pure VBA Excel DSS

## Skill Auto-Load
On session start, load these skills via `skill` tool:
1. `vba-build` — Patterns, build pipeline, compile safety
2. `vba-debug` — Error diagnosis guide
3. `vba-excel-sync` — Sheet safety patterns
4. `naming-cheatsheet` — VBA naming conventions

## Context Files (read on start)
1. `Software_Surgical_Edit/erp-project-context.xml` — Full project architecture
2. `Software_Surgical_Edit/erp-agent-handoff.xml` — Session state + ground truth
3. `Software_Surgical_Edit/erp-admin-paths.xml` — All file paths
4. `CLAUDE.md` — Project identity + thesis constraints

## Build Pipeline
```
build.ps1 → rebuild workbook from .bas sources
verify.ps1 → 97-point verification
test-macros.ps1 → automated macro test
```

## Ground Truth (NEVER modify)
D=1546, Q*=176, ROP=212.4, SS=200, LT=2d, S=500DZD, I=20%
MASTER_PWD=erp_secure_pwd_2026, VERSION=v13.2

## Critical Rules
- French column headers/tab names — NEVER translate
- Fix .bas files, NEVER .xlsm directly
- NO Python, NO Flask, NO databases, NO XLOOKUP
- Arabic thesis: MSA academic register, فصل→مبحث→مطلب hierarchy

