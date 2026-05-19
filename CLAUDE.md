# Academix v13.2 — Thesis Submission Context
## Mahi Kamel Abdelghani | CNEPD BTS GSL (TAG1801) | El Bayadh Education Directorate

## PROJECT OVERVIEW
- **Thesis**: "نظام دعم القرار لتسيير المخزونات" — DSS for inventory management in public sector
- **Language**: Arabic (MSA / فصحى), with French administrative terms, English technical terms
- **Source**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` (142.5 KB, 4 chapters, 14 مباحث, 23 مطالب)
- **الفصل الرابع**: Merged into main source (lines 618-696)
- **Build pipeline**: `Thesis_Surgical_Edit/build-thesis.ps1` (335 lines) — Pandoc + Word COM
- **Verify**: `Thesis_Surgical_Edit/verify-thesis.ps1` — 25 checks
- **Reference styling**: `Thesis_Surgical_Edit/style/`

## GROUND TRUTH (locked — do not modify)
| Param | Value | Param | Value |
|-------|-------|-------|-------|
| D (ART-001) | 1,546 | Q* (EOQ) | 176 |
| ROP | 212.4 | SS | 200 |
| LT | 2 days | S | 801.45 DZD |
| I | 20% | PU | 400 DZD |
| Service Level | 99.7% | Working Days | 250 |
| Articles | 12 (ART-001→ART-012) | Observation | 38 days |
| Field transactions | 62 | Footnotes | 3 (CNEPD format) |
| Bibliography | 56 entries | Tables | 21 (enumerated) |

## BUILD STATUS (2026-05-19)
- **Source MD5**: `116E80E06F88331A9CECDF26592CEF1C` (unchanged)
- **DOCX**: 126 KB / **PDF**: 1,095 KB (golden baseline: 20260519-165448)
- **Verify**: 25/25 ALL PASS
- **Arabic Manual**: `Thesis_Surgical_Edit/USER_MANUAL_AR.md` (925 lines, 26 sections)
- **English Paper**: `Thesis_Surgical_Edit/English_Research_Paper.md` (235 lines, IEEE format)

## REPOMIX CONTEXT
Full project context XML: `Thesis_Surgical_Edit/claude-context/repomix-output.xml`
Contains complete thesis source, build pipeline, tools, and project structure.

## YOUR ROLE
You are the final academic editor and DOCX production specialist for this CNEPD BTS thesis. Your task is:
1. Read the full source via repomix XML
2. Perform comprehensive academic analysis (scoring against CNEPD TAG1801 criteria)
3. Generate the final, submission-ready DOCX via the build pipeline
4. Verify script runs clean — 25/25 PASS
5. Deliver the completed DOCX at `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`

## KEY FILES (for quick access)
| File | Path |
|------|------|
| Thesis source | `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` |
| Build script | `Thesis_Surgical_Edit/build-thesis.ps1` |
| Verify script | `Thesis_Surgical_Edit/verify-thesis.ps1` |
| Ground truth | `Thesis_Surgical_Edit/THESIS_GROUND_TRUTH.md` |
| Reference DOCX | `Thesis_Surgical_Edit/style/reference-golden.docx` |
| Cover page | `Thesis_Surgical_Edit/bismillah-page.docx` |
| Footnoter tool | `Thesis_Surgical_Edit/tools/convert-footnotes.py` |
