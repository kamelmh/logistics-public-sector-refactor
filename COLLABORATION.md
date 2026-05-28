# Academix v13.2 — Collaboration & DevOps Guide

## GitHub Repository
**Remote:** `https://github.com/kamelmh/logistics-public-sector-refactor.git`
**Branch:** `master` (production)

## Getting Started for Collaborators

### Prerequisites
```powershell
# Windows 10/11 with:
- Git for Windows (https://git-scm.com)
- GitHub CLI (optional: `winget install GitHub.cli`)
- Excel 2010+ (for VBA development and COM verification)
- LibreOffice (optional: for headless PDF conversion)
- Python 3.x (for thesis/paper DOCX verification)
```

### Clone
```powershell
git clone https://github.com/kamelmh/logistics-public-sector-refactor.git
cd logistics-public-sector-refactor
```

### Branch Strategy
| Branch | Purpose | Protection |
|--------|---------|------------|
| `master` | Production — all deliverables certified | Protected (CI must pass) |
| `develop` | Integration branch for features | CI must pass |
| `feat/*` | Feature branches | None |
| `fix/*` | Bug fix branches | None |
| `docs/*` | Documentation only | None |

### Commit Convention
```
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci
Examples:
  feat: add mod_BarcodeSim with Code128/EAN13/Code39 generation
  fix: correct XML declaration in fix_docx_remaining.py
  docs: update COLLABORATION.md with onboarding steps
```

## Project Structure
```
├── ERP_v13.2.xlsm              # Built ERP workbook (output)
├── GOLDEN_ERP_v13.2.xlsm       # Master workbook (VBA template) — 43 modules, clean
├── SOFTWARE_SURGICAL_EDIT/
│   └── VBA_Modules/            # All VBA source files (.bas, .frm, .cls)
│       ├── mod_Barcode.bas     # Original barcode lookup
│       ├── mod_BarcodeSim.bas  # NEW: Code128, EAN13, Code39 generation
│       ├── mod_TaskOrchestrator.bas  # NEW: Task queue & scheduler
│       ├── mod_PCControl.bas   # NEW: Shell, WMI, Registry, WinAPI
│       ├── mod_LibreBridge.bas # NEW: LibreOffice conversion bridge
│       └── MAIN_MACROS.bas     # Entry points (extended)
├── vbe-auto/
│   ├── build.ps1               # Build pipeline (strips + imports + compiles)
│   ├── verify.ps1              # 105+ verification checks
│   └── vbe-auto-config.json    # Build configuration
├── .github/workflows/ci.yml    # CI: thesis build/verify + ERP (if Excel available) + lint
└── Thesis_Surgical_Edit/       # Thesis and English paper sources
```

## Build Pipeline
```powershell
# 1. Build ERP workbook (requires Excel COM)
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"

# 2. Verify (137 checks — file integrity, COM compilation, sheets, config, data)
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"

# 3. Build thesis
& "Thesis_Surgical_Edit\build-thesis.ps1"

# 4. Build English paper
& "Thesis_Surgical_Edit\build-english-paper.ps1"

# 5. Verify thesis (29 checks)
python Thesis_Surgical_Edit/style/verify_docx_checks.py "Research_and_Development/Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx"

# 6. Verify English paper (12 checks)
pwsh -File Thesis_Surgical_Edit/verify-english-paper.ps1
```

## VBA Development Workflow
1. Edit `.bas` files in `Software_Surgical_Edit/VBA_Modules/` (never edit .xlsm directly)
2. Run `build.ps1` to rebuild from source
3. Run `verify.ps1` to run 137 checks
4. Commit source code only (output artifacts excluded by .gitignore)

## GitHub Actions CI
The CI pipeline (`ci.yml`) runs on every push to `master`:
- **thesis**: Builds DOCX, runs 29 verify checks, builds PDF
- **erp**: Builds XLSM (if Excel available), runs macro tests, 137 verify checks
- **lint**: PSScriptAnalyzer + ruff on build scripts

## Issue Tracker
Use GitHub Issues for:
- Bug reports (include verify output)
- Feature requests (reference COLLABORATION.md)
- CI failures (link to Actions run)

## VBA Module Template
All new modules follow this pattern:
```vb
Attribute VB_Name = "mod_ModuleName"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' <Description>
' ============================================================================
Option Explicit

' ... code ...

' ============================================================================
' END — mod_ModuleName.bas
' ============================================================================
```

## Contact
- **Author:** Mahi Kamel Abdelghani
- **Institution:** Direction de l'Éducation - Wilaya d'El Bayadh
- **Thesis:** Système d'Aide à la Décision pour la Gestion Logistique
- **ISIA 2026 Submission Deadline:** May 31, 2026
