# /pipeline — Run the Full ERP Pipeline

Run all validation stages end-to-end: `vba-check → build → verify → test-macros → dss-audit`

## Description
Chains every verification script in the Academix v13.2 ERP project into a single unified pipeline. Outputs a structured pass/fail summary with timing for every stage.

Stages:
1. **VBA_PRE_CHECK** — vba-check.py (12 static analysis checks on .bas/.frm source)
2. **BUILD** — build.ps1 (clean-slate rebuild from GOLDEN_ERP → source import → compile)
3. **VERIFY** — verify.ps1 (112-point post-build verification)
4. **MACRO_TESTS** — test-macros.ps1 (20 injected macro tests)
5. **DSS_AUDIT** — dss-audit.ps1 (5-phase DSS structural/security/data/graph/compliance audit)

## Usage
```
/pipeline                  # Full pipeline, stop on first failure
/pipeline -ContinueOnError # Run all stages regardless of failures
/pipeline -SkipBuild       # Skip rebuild, verify existing workbook only
```

## Exit codes
- 0: All stages passed
- 1: One or more stages failed

## Dependencies
- Excel COM (for build, verify, test-macros, dss-audit)
- Python 3.x (for vba-check)
- PowerShell 7+
- Writable: `vbe-auto/results/` directory for pipeline report

## Report
A JSON report is saved to `vbe-auto/results/pipeline-report_<timestamp>.json` after each run.
