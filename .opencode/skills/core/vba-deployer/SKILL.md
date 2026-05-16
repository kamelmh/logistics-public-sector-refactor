# VBA Deployer — Automated VBA Module Injection & Verification

## Purpose
Deploy VBA source modules (.bas, .frm, .cls) into an Excel .xlsm workbook programmatically:
clean-slate build, compile, verify — without opening Excel manually.

## Pattern Source
Academix v13.2 `vbe-auto/` toolkit. Generalized for any VBA project.

## Pipeline

```
Source modules (.bas/.frm/.cls)
        │
        ▼
1. Kill Excel (COM)
2. Open MASTER .xlsm (template workbook)
3. Strip ALL existing user modules
4. Import source files from directory
5. Inject ThisWorkbook (code-behind)
6. Compile (VBE Project compilation)
7. Generate demo/seed data (optional)
8. Apply sheet protection (optional)
9. Save as OUTPUT .xlsm
10. Verification suite
```

## Project Structure Convention
```
project-root/
├── vbe-auto/
│   ├── config.json          ← Module list, sheet list, constants, version
│   ├── build.ps1            ← Build pipeline (steps 1-9)
│   └── verify.ps1           ← Verification suite (step 10)
├── src/                     ← VBA source files
│   ├── *.bas               ← Standard modules
│   ├── *.frm               ← Forms
│   ├── *.cls               ← Class modules
│   └── ThisWorkbook.cls    ← Workbook code-behind
└── output/                  ← Built .xlsm files
```

## config.json Schema
```json
{
  "project_name": "MyProject",
  "version": "v1.0",
  "source_dir": "src/",
  "master_path": "templates/master.xlsm",
  "output_path": "output/MyProject.xlsm",
  "verification": {
    "expected_modules": ["mod_MyModule", ...],
    "expected_sheets": ["Sheet1", ...],
    "expected_constants": {"CONST_NAME": "expected_value"}
  }
}
```

## Key VBA Injection Logic (PowerShell)
```powershell
# Strip modules
$wb.VBProject.VBComponents | Where-Object {$_.Type -in @(1,2,3)} | ForEach-Object {
    $wb.VBProject.VBComponents.Remove($_)
}

# Import .bas file
$wb.VBProject.VBComponents.Import("$sourceDir\$file.bas")

# Compile
$wb.VBProject.VBComponents("mod_AnyModule").CodeModule.AddFromString("' compilation trigger")
$vbe.ActiveVBProject.VBComponents.Remove($temp)
```

## Verification Checks
- File existence + size
- COM compilation check (open via Excel.Application)
- Module inventory (37 modules expected)
- Sheet verification (26 sheets, each with data)
- Config constants (APP_VERSION, WORKING_DAYS, etc.)
- Data integrity (records count, field presence)

## Usage (any project)
```powershell
.\vbe-auto\build.ps1 -ConfigPath "vbe-auto\config.json"
.\vbe-auto\verify.ps1 -ConfigPath "vbe-auto\config.json"
```
