# /vba-validate

Run the VBA Pre-Build Validator on all source files in `Software_Surgical_Edit/VBA_Modules/`.

## Description
Scans all 43 .bas/.frm files for 7 categories of VBA-breaking errors:
1. UTF-8 BOM presence
2. Invalid Windows-1252 control bytes (0x80-0x9F)
3. Missing `Attribute VB_Name` header
4. Missing `Option Explicit`
5. PHP/ASP template artifacts (`%>`, `<?`)
6. Comments between line continuations (`_`)
7. Suspiciously short files

## Usage
```
/vba-validate
```

## Exit codes
- 0: All checks passed, safe to build
- 1: Errors found, fix before building

## Integration
Auto-runs as step [0/10] in the `build.ps1` pipeline before compile.
