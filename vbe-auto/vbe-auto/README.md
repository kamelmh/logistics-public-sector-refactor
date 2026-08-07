# VBE Auto — Universal Excel VBE Control Suite

Automated Excel VBE lifecycle management for **any** VBA project. Build, verify, test, and debug VBA codebases with a single toolkit.

## Quick Start

### 1. Configure Your Project

Create `vbe-auto-config.json` in your project root:

```json
{
  "project_name": "My VBA Project",
  "version": "v1.0",
  "master_workbook": "path\\to\\Master.xlsm",
  "output_workbook": "path\\to\\Output.xlsm",
  "vba_source_dir": "path\\to\\VBA_Modules",
  "verification": {
    "expected_sheets": ["Sheet1", "Sheet2"],
    "expected_modules": ["mod_Config", "mod_Engine"],
    "expected_constants": [
      { "name": "VERSION", "value": "v1.0" }
    ]
  }
}
```

### 2. Build

```powershell
& "C:\Users\Administrator\Desktop\vbe-auto\build.ps1"
```

### 3. Verify

```powershell
& "C:\Users\Administrator\Desktop\vbe-auto\verify.ps1"
```

### 4. Control

```powershell
. "C:\Users\Administrator\Desktop\vbe-auto\vbe.ps1"  # dot-source
vbe help                                              # list commands
vbe open                                              # open workbook
vbe macro-all                                         # test all macros
vbe snapshot                                          # session state
```

## Tool Reference

### `vbe.ps1` — Interactive VBE Control

| Command | Description |
|---------|-------------|
| `vbe open` | Open workbook with full COM automation |
| `vbe open -Path "file.xlsm"` | Open specific workbook |
| `vbe open -Visible` | Open with visible UI |
| `vbe open -ListProjects` | List registered projects |
| `vbe close` | Close Excel session cleanly |
| `vbe save` | Save current workbook |
| `vbe compile` | Compile VBA project |
| `vbe macro <Name>` | Run a macro |
| `vbe macro-all` | Test all discovered macros |
| `vbe modules` | List all modules with line counts |
| `vbe module-read <Name>` | Read module source code |
| `vbe export-all` | Export all modules to folder |
| `vbe sheets` | List sheets with dimensions |
| `vbe sheet <Name>` | Inspect sheet content |
| `vbe snapshot` | Full session state |
| `vbe log` | Show recent operations |
| `vbe excel` | Access raw COM objects (`$VBE.Excel`, `$VBE.Workbook`) |

### `build.ps1` — Automated Build

Rebuilds workbook from source files using the clean-slate protocol:

```
Kill Excel → Open MASTER → Strip modules → Import sources → Compile → Save
```

### `verify.ps1` — Verification Suite

5-stage verification:

1. **File Integrity** — Existence, size, accessibility
2. **COM Compilation** — VBA compile check
3. **Module Inventory** — All modules present with line counts
4. **Sheet Verification** — All expected sheets exist
5. **Configuration** — Constants, passwords, cross-module safety

### `config.json` — Project Configuration

Schema:

| Field | Required | Description |
|-------|----------|-------------|
| `project_name` | Yes | Human-readable project name |
| `version` | Yes | Version string |
| `master_workbook` | Yes | Clean base workbook (never modified) |
| `output_workbook` | Yes | Built output file |
| `vba_source_dir` | Yes | Directory with .bas/.frm/.cls files |
| `thisworkbook_source` | No | Path to ThisWorkbook.cls |
| `verification.expected_sheets` | No | List of required sheet names |
| `verification.expected_modules` | No | List of required module names |
| `verification.expected_constants` | No | Constants to validate |
| `protection.sheet_password` | No | Sheet protection password |
| `macros.startup` | No | Macros to run on startup |
| `macros.test_all` | No | Macros for full test suite |

## Build Protocol

### Why Clean-Slate Rebuild?

VBA's p-code cache gets corrupted when you manually import modules into an existing workbook. This causes **false compile errors** — the code compiles fine via COM but shows errors in Excel UI.

The rebuild script guarantees a fresh p-code cache every time:

1. **Kill Excel** — No stale processes
2. **Open MASTER** — Clean base workbook (never modified after creation)
3. **Strip ALL user modules** — Remove everything except sheets
4. **Import fresh sources** — Import all .bas/.frm from source directory
5. **Inject ThisWorkbook** — Special handling for document modules
6. **Compile** — Fresh compilation = fresh p-code cache
7. **Save as NEW file** — Forces new internal structure

### Creating a Master Workbook

1. Create a blank .xlsm workbook with all required sheets
2. Set up sheet protection, formatting, headers, formulas
3. Save as `Master.xlsm` — **never modify this file again**
4. All VBA code lives in source files, not in the master

## Debug Workflow

### Handoff Protocol

When VBA shows a compile/runtime error:

1. User copies highlighted code from VBE → saves to `Desktop\handoffN.txt`
2. AI reads handoff, diagnoses error
3. AI fixes source `.bas` in `VBA_Modules/`
4. AI runs `build.ps1` to rebuild
5. AI runs `verify.ps1` to validate
6. AI reports: Fix applied, Build OK, Safe to open

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Syntax error" at End Sub | UTF-8 em dash (—) | Replace with hyphen (-) |
| "Expected: identifier" | BOM in file | Save as UTF-8 WITHOUT BOM |
| "Method not found" | Const after procedure | Move Const before Sub/Function |
| False compile errors | Stale p-code | Full rebuild |

## Security

- Sheet passwords stored as `Property Get`, not `Public Const`
- Audit logging active for all operations
- Transaction safety: Begin → Commit/Rollback
- User input validated before sheet writes
- COM automation uses `Interactive=False` to prevent dialog exposure

## Portability

This toolkit works with **any** VBA project. To deploy for a new project:

1. Copy the `vbe-auto/` folder to your project root
2. Create a `vbe-auto-config.json` with your project values
3. Export your VBA modules to the source directory
4. Create a master workbook with sheets/formulas only
5. Run `build.ps1` to generate your first build

## File Structure

```
vbe-auto/
├── vbe.ps1              # VBE control suite
├── build.ps1            # Automated build script
├── verify.ps1           # Verification suite
├── config.json          # Project configuration template
├── README.md            # This file
└── vbe-auto.log         # Operations log (auto-created)
```

## Requirements

- PowerShell 7+ (pwsh)
- Excel 2010 or later (Windows)
- .NET Framework 4.5+

## License

Internal tool — no license restrictions.
