# Academix v13.4 — DSS Logistique El Bayadh

[![CI](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml/badge.svg)](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml)
[![VBA Validate](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml/badge.svg?job=vba-validate)](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml)
[![Lint](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml/badge.svg?job=lint)](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/ci.yml)
[![Model Health](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/model-health.yml/badge.svg)](https://github.com/kamelmh/logistics-public-sector-refactor/actions/workflows/model-health.yml)
[![Release](https://img.shields.io/github/v/release/kamelmh/logistics-public-sector-refactor?include_prereleases&label=release)](https://github.com/kamelmh/logistics-public-sector-refactor/releases)
[![VBA](https://img.shields.io/badge/VBA-Excel%202010%2B-green)](https://docs.microsoft.com/en-us/office/vba/)
[![Thesis](https://img.shields.io/badge/Thesis-DSS%20Logistique%20El--Bayadh-8A2BE2)](https://github.com/kamelmh/lsm-vba-core)
[![GitHub Models](https://img.shields.io/badge/GitHub_Models-Free_tier-181717?logo=github)](tools/gh-models.ps1)

Decision Support System for inventory management at the **Direction de l'Éducation d'El Bayadh** (Algerian Ministry of Education). Pure VBA, Excel 2010+ compatible.

**Master's thesis in Logistics & Supply Chain Management — ENP Oran / CNEPD 2026.**

| Parameter | Value | Description |
|-----------|-------|-------------|
| D | 789 units/yr | Annual demand |
| Q* | 37 units | Wilson EOQ |
| ROP | 206 units | Reorder Point |
| SS | 200 units | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4,500 DZD | Unit Price |
| I | 20% | Holding Rate |

> Canonical thesis constants — locked, never modify.

## Repositories

| Repo | Visibility | Purpose |
|------|-----------|---------|
| [`logistics-public-sector-refactor`](https://github.com/kamelmh/logistics-public-sector-refactor) | 🔒 **PRIVATE** | Thesis drafts, exploration repos, full project context |
| [`lsm-vba-core`](https://github.com/kamelmh/lsm-vba-core) | 🌍 PUBLIC | Sanitized VBA framework — referenced in thesis bibliography |

## Build Instructions

### ERP Workbook
```powershell
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"
& "Software_Surgical_Edit\test-macros.ps1"
```

### Thesis (DOCX + PDF)
```powershell
# Full pipeline (build → fix → audit → verify → metrics)
& "Thesis_Surgical_Edit\build-thesis.ps1"

# Use Golden Source directly (No Rebuild)
& "Thesis_Surgical_Edit\build-thesis.ps1" -NoRebuild

# Restore Golden Source from latest backup
& "Thesis_Surgical_Edit\build-thesis.ps1" -Restore

# Or rebuild from MD via pandoc
& "Thesis_Surgical_Edit\build-thesis.ps1" -FromMD
```

### English Paper
```powershell
& "Thesis_Surgical_Edit\build-english-paper.ps1"
& "Thesis_Surgical_Edit\verify-english-paper.ps1"
```

## CI Status

| Job | Required | Description |
|-----|----------|-------------|
| `thesis` | ✅ Must pass | Builds DOCX + PDF, 28 verify checks, uploads artifacts |
| `erp` | ⚠️ Optional | Requires Excel (skips on GitHub Actions runners) |
| `lint` | ✅ Must pass | PSScriptAnalyzer + ruff checks |
| `model-health` | ✅ Must pass | Checks model version and availability |

## Architecture

```
Private Repo (this)
├── Thesis_Surgical_Edit/       ← Thesis source (MD) + build + verify scripts
│   ├── Memoire_DSS_Logistique_ElBayadh.md
│   ├── English_Research_Paper.md
│   ├── build-thesis.ps1        ← 5 build modes (build, pandoc-only, copy-desktop, sync-md, restore)
│   ├── style/
│   │   ├── fix_thesis_all.py   ← 7-step comprehensive fixer
│   │   ├── surgical_polish.py  ← RTL footnotes, link removal, CNEPD scrubbing
│   │   ├── verify_docx_checks.py ← 32 checks
│   │   ├── docx_md_sync.py     ← MD ↔ DOCX sync tool
│   │   ├── audit_thesis_comprehensive.py
│   │   └── ...
│   └── submission/             ← ISIA 2026 submission package
├── Software_Surgical_Edit/     ← VBA source modules
├── vbe-auto/                   ← Build toolkit (build.ps1, verify.ps1)
├── external/lsm-vba-core ──→   PUBLIC submodule @ kamelmh/lsm-vba-core
├── milestone_13_2/public-lsm ──→ (same submodule, snapshot)
├── Research_and_Development/   ← Exploration, refs, images
└── .github/workflows/ci.yml    ← CI pipeline (3 jobs)
```

## Verification Metrics

| Check | Count | Tools |
|-------|-------|-------|
| Thesis DOCX | 32/32 | verify_docx_checks.py (python-docx) |
| English Paper | 12/12 | verify-english-paper.ps1 |
| ERP Build | 174/174 | vbe-auto verify.ps1 |
| ERP Macro Tests | 20/20 | test-macros.ps1 |
| ERP DSS Audit | 16/16 | dss-audit.ps1 |

## Rules

- **All VBA edits in `.bas` source files** — never edit `.xlsm` directly (stale p-code cache)
- **Rebuild after every VBA change**
- **Commit only after clean verify run**
- **Never expose secrets, absolute paths, or real inventory data** (pre-push sanitize scripts in public repo)
