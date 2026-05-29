# VBA Pre-Build Validator Skill (v1.2)

## Purpose
Automatically validate all VBA source files (.bas, .frm, .cls) for syntax and encoding errors BEFORE building the ERP workbook. No Excel/COM needed — pure static analysis.

Catches all known VBA-breaking patterns including:
- Missing `Attribute VB_Name` header
- UTF-8 BOM / invalid control bytes that VBA can't parse
- PHP/ASP template artifacts (`%>`, `<?`)
- Line continuations broken by comments
- `Const` declarations using `Array()` (runtime function in Const)
- `Return` statement (VB.NET syntax — use `FunctionName = value`)
- `Name:=` in `Application.OnTime` (must be `Procedure:=`)
- Parameter named `format` (conflicts with built-in `Format()`)

## Checks (12 total)

| # | Check | Severity | Category |
|---|-------|----------|----------|
| 1 | UTF-8 BOM presence | Error | Encoding |
| 2 | Invalid Windows-1252 control bytes (0x80-0x9F) | Error | Encoding |
| 3 | Missing `Attribute VB_Name` header | Error | Structure |
| 4 | Missing `Option Explicit` | Warning | Best Practice |
| 5 | PHP/ASP template artifacts (`%>`, `<?`) | Error | Artifacts |
| 6 | Comments between line continuations (`_`) | Error | Parser |
| 7 | Suspiciously short files (< 5 lines) | Warning | Structure |
| 8 | Comment continuations without leading `'` | Error | Parser |
| 9 | `Const` using `Array()` (runtime function) | Error | Syntax |
| 10 | `Return` statement (VB.NET syntax) | Error | Syntax |
| 11 | `Name:=` in `Application.OnTime` | Error | Syntax |
| 12 | Parameter named `format` (built-in conflict) | Error | Naming |

## Usage
```powershell
# Standalone validation
python vbe-auto/vba-check.py

# Part of build pipeline (auto-runs step 0/10)
& "vbe-auto/build.ps1"

# Part of full pipeline (stage 1/5)
& "vbe-auto/pipeline-full.ps1"

# From OpenCode chat
/vba-validate
/pipeline
```

## Integration
- **build.ps1** — auto-runs as step [0/10] before compile
- **pipeline-full.ps1** — stage 1/5 (vba-check → build → verify → macros → audit)
- **vba-autofix.ps1** — Phase 1 of OCR-based error scanning
- **CI/CD** — runs on `ubuntu-latest` as standalone `vba-validate` job (no Excel needed)
- **OpenCode** — `/vba-validate` and `/pipeline` commands

## History
| Version | Date | Changes |
|---------|------|---------|
| v1.2 | 2026-05-29 | Added checks 10-12 (Return, Name:=OnTime, format param) |
| v1.1 | 2026-02-26 | Added check 8 (comment continuations) and check 9 (Array in Const) |
| v1.0 | 2026-02-24 | Initial release (checks 1-7) |
