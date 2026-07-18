# Academix v13.4 — DSS Logistique El Bayadh

[![CI](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml/badge.svg)](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml)
[![VBA](https://img.shields.io/badge/VBA-Excel%202010%2B-green)](https://docs.microsoft.com/en-us/office/vba/)
[![Thesis](https://img.shields.io/badge/Thesis-DSS%20Logistique%20El--Bayadh-8A2BE2)](https://github.com/kamelmh/logistics-public-sector-refactor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Decision Support System for inventory management at the **Direction de l'Éducation d'El Bayadh** (Algerian Ministry of Education). Pure VBA, Excel 2010+ compatible.

**Master's thesis in Logistics & Supply Chain Management — ENP Oran / CNEPD 2026.**

> **Consolidated repo** — combines `lsm-vba-core` and `Academix-v13.2` into a single source of truth.

## Quick Start

| Parameter | Value | Description |
|-----------|-------|-------------|
| D | 789 units/yr | Annual demand (38-day projection) |
| Q* | 37 units | Wilson EOQ |
| ROP | 206 units | Reorder Point |
| SS | 200 units | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4,500 DZD | Unit Price |
| I | 20% | Holding Rate |

> All parameters are configurable via the CONFIG sheet — no VBA editing needed.

## Features

- **44 VBA modules** — Stock Engine, Wilson EOQ, Procurement, Budget, Audit Trail, Barcode/QR, Supplier Scorecard
- **113 automated tests** — full CI pipeline
- **26-sheet workbook** with CONFIG layer
- **Bilingual** — French/Arabic
- **4 Algerian stock documents** — Bon de Réception, Bon de Sortie, Bon de Commande, Demande d'Achat

## Build Instructions

### ERP Workbook
```powershell
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"
& "Software_Surgical_Edit\test-macros.ps1"
```

### Thesis (DOCX + PDF)
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1"
```

## Project Structure

```
logistics-public-sector-refactor/
├── Software_Surgical_Edit/     ← VBA source (45 .bas + .frm)
├── Thesis_Surgical_Edit/       ← Thesis source + build scripts
├── vbe-auto/                   ← Build toolkit
├── tests/                      ← Test suite
├── tools/                      ← Utility scripts
├── scripts/                    ← Automation
└── .github/workflows/          ← CI pipeline
```

## CI Status

| Job | Status | Description |
|-----|--------|-------------|
| `thesis` | ✅ | Builds DOCX + PDF, 28 verify checks |
| `lint` | ✅ | PSScriptAnalyzer + ruff |
| `model-health` | ✅ | Model version and availability |

## Verification

| Check | Count | Tool |
|-------|-------|------|
| Thesis DOCX | 32/32 | verify_docx_checks.py |
| ERP Build | 174/174 | vbe-auto verify.ps1 |
| ERP Macro Tests | 20/20 | test-macros.ps1 |
| ERP DSS Audit | 16/16 | dss-audit.ps1 |

## Rules

- All VBA edits in `.bas` source files — never edit `.xlsm` directly
- Rebuild after every VBA change
- Commit only after clean verify run
- Never expose secrets, absolute paths, or real inventory data

## Author

**MAHI Kamel Abdelghani** — [kamelmahi71@gmail.com](mailto:kamelmahi71@gmail.com)
Portfolio: [kamelmahi.netlify.app](https://kamelmahi.netlify.app)

## License

MIT
