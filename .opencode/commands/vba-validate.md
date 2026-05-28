# /vba-validate

Run the VBA Pre-Build Validator (v1.2, 12 checks) on all source files in `Software_Surgical_Edit/VBA_Modules/`.

## Description
Scans all 44 .bas/.frm/.cls files for VBA-breaking errors across 12 categories:

| # | Check | Severity |
|---|-------|----------|
| 1 | UTF-8 BOM presence | Error |
| 2 | Invalid Windows-1252 control bytes (0x80-0x9F) | Error |
| 3 | Missing `Attribute VB_Name` header | Error |
| 4 | Missing `Option Explicit` | Warning |
| 5 | PHP/ASP template artifacts (`%>`, `<?`) | Error |
| 6 | Comments between line continuations (`_`) | Error |
| 7 | Suspiciously short files (< 5 lines) | Warning |
| 8 | Comment continuations without leading `'` | Error |
| 9 | `Const` declarations using `Array()` (runtime function) | Error |
| 10 | `Return` statement (VB.NET syntax, invalid in VBA) | Error |
| 11 | `Name:=` in `Application.OnTime` (must be `Procedure:=`) | Error |
| 12 | Parameter named `format` (conflicts with built-in `Format()`) | Error |

## Usage
```
/vba-validate
```

## Exit codes
- 0: All checks passed, safe to build
- 1: Errors found, fix before building

## Integration
- Auto-runs as step [0/10] in the `build.ps1` pipeline before compile
- Also runs as stage 1/5 in the `/pipeline` full pipeline
- Also runs as Phase 1 in `vba-autofix.ps1`

## History
| Version | Date | Changes |
|---------|------|---------|
| v1.2 | 2026-05-29 | Added checks 10-12 (Return, Name:=OnTime, format param) |
| v1.1 | 2026-02-26 | Added check 8 (comment continuations) and check 9 (Array in Const) |
| v1.0 | 2026-02-24 | Initial release (checks 1-7)
