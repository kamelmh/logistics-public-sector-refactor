# VBA Pre-Build Validator Skill

## Purpose
Automatically validate all VBA source files (.bas, .frm) for syntax and encoding errors BEFORE building the ERP workbook. Catches issues like:
- Missing `Attribute VB_Name` header
- UTF-8 characters that VBA can't parse
- PHP/ASP template artifacts (`%>`, `<?`)
- Line continuations broken by comments
- UTF-8 BOM

## Usage
```powershell
# Run validator
python vbe-auto/vba-check.py

# Or as part of build pipeline (auto-runs before compile)
& "vbe-auto/build.ps1"
```

## How It Works
1. Scans all 43+ source files in `Software_Surgical_Edit/VBA_Modules/`
2. Checks each for 6 categories of errors
3. Reports errors BEFORE build attempt
4. If errors = 0, badge says ✅ SAFE TO BUILD
5. Prevents wasted build cycles from known-preventable compile errors

## Integration
- Called automatically by `build.ps1` before step [5/9] Compiling
- Also available as standalone `/vba-validate` command in OpenCode
