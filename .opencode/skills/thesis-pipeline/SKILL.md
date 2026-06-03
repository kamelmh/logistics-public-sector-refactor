---
name: thesis-pipeline
description: Academix thesis build pipeline — run-thesis-pipeline.ps1 5-phase orchestrator
level: 2
---

# Thesis Pipeline

Use this skill when building, fixing, verifying, or auditing the Arabic thesis DOCX or English paper.

## Overview

The thesis pipeline (`Thesis_Surgical_Edit\run-thesis-pipeline.ps1`) is a **5-phase comprehensive orchestrator** that handles the full lifecycle:

| Phase | Name | What It Does |
|-------|------|-------------|
| 0 | Environment Check | Verify tools (python, pandoc), golden source, script inventory |
| 1 | Source Prep | Copy golden DOCX or build from MD via pandoc |
| 2 | Section Fixes | `fix_docx_sections.py` — A4 page size, section breaks |
| 3 | Comprehensive Fixes | `fix_thesis_all.py` — 9 steps (page numbering, tables, fonts, PAGE field, namespace) |
| 4 | Verification | Audit + verify (29 checks) + sync + measure |
| 5 | Report | Generate structured pipeline report (JSON + TXT) |

## Important Ordering

**Pipeline phases 2→3 order is CRITICAL:**
- Phase 2 (`fix_docx_sections.py`) uses python-docx — this must run **BEFORE** phase 3
- Phase 3 (`fix_thesis_all.py`) runs namespace+PAGE fix **LAST** (step 9)
- Reason: python-docx `doc.save()` regenerates ns0/ns1 prefixes AND cached PAGE result — namespace+PAGE fix must be the final write

## Commands

```powershell
# Full pipeline (all 5 phases)
& "Thesis_Surgical_Edit\run-thesis-pipeline.ps1"

# Quick verify only
& "Thesis_Surgical_Edit\run-thesis-pipeline.ps1" -Phase verify

# Build + fix only (phases 0-3)
& "Thesis_Surgical_Edit\run-thesis-pipeline.ps1" -Phase build

# Build English paper (CCA'2026)
& "Thesis_Surgical_Edit\build-cca2026.ps1"

# Legacy build script (still works)
& "Thesis_Surgical_Edit\build-thesis.ps1"
```

## Verification

After pipeline completes, **29 checks** are verified:
- Page size (A4)
- Section count (4)
- Footnote count (46)
- Font (Traditional Arabic)
- RTL alignment
- Page numbering: cover=none, TOC=lowerRoman, body=decimal
- PAGE field: no cached result
- Namespace: no ns0/ns1 prefixes
- Document structure, margins, page breaks

## Known Issues

- `python-docx` is the root cause of footnotes.xml corruption (ns0 prefixes) and PAGE field corruption (cached result) — every `doc.save()` reintroduces both
- Pipeline ordering (phases 2→3) was specifically designed to work around this
- `verify_docx_checks.py` has `_fix_xml_namespace()` fallback for standalone use
- Golden source at `Desktop\Memoire_DSS_Logistique_ElBayadh_v2.docx` (clean namespaces)

## Ground Truth (Thesis Values)

| Param | Value | Source |
|-------|-------|--------|
| D | 789 | 38-day MOUVEMENTS observation |
| Q* (EOQ) | 37 | Wilson formula |
| ROP | 206 | (D/250)×LT + SS |
| SS | 200 | Safety Stock |
| S | 801.45 DZD | Field analysis |
| PU | 4,500 DZD | ART-001 Toner G030 |
| I | 20% | Holding rate |

ERP workbook may compute different annualized values from actual data.
