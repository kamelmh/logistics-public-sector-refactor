# Submission Package — Project Deliverables

This guide covers the two main submission artefacts for the v13.4 release:

1. **English Research Paper** — for CCA'2026 conference
2. **Thesis (Mémoire)** — for the BTS DSS defense (Direction de l'Education El Bayadh)

---

## 1. English Research Paper — CCA'2026

## Target Venue: CCA'2026 (1st Conference on Cybersecurity and Applications)
- **Date:** November 25-26, 2026
- **Location:** National School of Cybersecurity, Sidi Abdallah, Algiers
- **Format:** IEEE conference, max 8 pages including figures and references
- **Submission deadline:** August 15, 2026 (75 days remaining)
- **Acceptance notification:** September 30, 2026
- **Camera-ready:** October 20, 2026
- **Registration deadline:** November 2, 2026
- **Submit via:** https://cmt3.research.microsoft.com/CCA2026/
- **Contact:** cca@enscs.edu.dz
- **Topics covered:** Cybersecurity, Decision Support Systems, Software Engineering, Data Integrity

## Previous Venue (missed)
- **ISIA 2026** — deadline May 31, 2026 (passed)

## Paper Status (v13.3, CCA'2026 ready)
| Item | Status |
|------|--------|
| Title and abstract | ✅ Updated to v13.3 |
| IMRaD structure | ✅ All sections present |
| DSS Intelligence Pillars | ✅ Section IV.E added |
| IEEE double-column format | ✅ PDF generated (158 KB) |
| Double-blind version | ✅ Author names removed |
| References (17) | ✅ IEEE bracket format |
| Verification counts | ✅ Updated to 144/144 |
| Cover letter | ✅ Updated to v13.3 |
| Author metadata | ✅ Updated to v13.3 |

## Files for Submission
| File | Path | Purpose |
|------|------|---------|
| Paper (PDF, blind) | `output/English_Research_Paper_CCA2026.pdf` | **Submit this** (double-blind) |
| Paper (DOCX, blind) | `output/English_Research_Paper_CCA2026.docx` | Backup/reference |
| Source (MD) | `Thesis_Surgical_Edit/English_Research_Paper.md` | Source of truth |
| Cover letter | `Thesis_Surgical_Edit/submission/cover-letter.md` | For review |
| Author metadata | `Thesis_Surgical_Edit/submission/author-metadata.md` | For review |
| Build script | `Thesis_Surgical_Edit/build-cca2026.ps1` | Rebuild if needed |

## Submission Checklist
- [x] Paper ≤ 8 pages (CCA requirement)
- [x] IEEE double-column format (IEEEtran class)
- [x] Double-blind: author names removed from manuscript
- [x] PDF generated (158 KB, text searchable)
- [x] Cover letter prepared (v13.3)
- [x] Author metadata form prepared (v13.3)
- [x] ORCID ID registered: `0009-0004-8958-3464`
- [ ] All authors consent to submission
- [ ] No duplicate submission to other venues
- [ ] Submit via Microsoft CMT before August 15, 2026

---

## 2. Thesis Submission (Mémoire)

## Thesis Submission
- **Target:** BTS DSS defense, Direction de l'Education El Bayadh
- **Defense deadline:** 2026-08-15
- **Format:** A4, 2.5 cm margins, RTL body, Traditional Arabic 14pt, 1.5 line spacing
- **Language:** French (with Arabic passages where required)
- **Build:** v13.4
- **File:** `Thesis_Surgical_Edit/submission/package/Memoire_DSS_Logistique_ElBayadh.docx`
- **PDF:** `Thesis_Surgical_Edit/submission/package/Memoire_DSS_Logistique_ElBayadh.pdf`
- **Status:** 29/29 PASS, 91 pages, ready for defense
- **Page numbering:** decimal, start=4 on TOC

### Page numbering scheme
| Section | Format | Start | Description |
|---------|--------|-------|-------------|
| 0 | `none` | — | Cover page (no number) |
| 1 | `decimal` | **4** | Front matter — TOC begins at page 4 |
| 2 | `decimal` | — | Body (continues from 5) |
| 3 | `decimal` | — | Annexes / back matter (continues) |

### Document profile (from `verify_docx_checks.py`)
- 702 paragraphs
- 26 tables
- 46 footnotes
- 4 sections
- 9 H1, 38 H2, 59 H3 headings
- 17 references
- A4 page size, 2.5 cm margins on all sides

### Footer structure
- `footer1.xml`, `footer3.xml`: empty (by design)
- `footer2.xml`: SDT-wrapped `PAGE` field, direct child of `<w:ftr>`, with `docPartObj` + `Page Numbers (Bottom of Page)` gallery and a preserved cached `<w:t>1</w:t>` value
- All 4 sections reference footer2.xml via `rId12`

### Files in the package
| File | Path | Purpose |
|------|------|---------|
| Thesis (DOCX) | `Thesis_Surgical_Edit/submission/package/Memoire_DSS_Logistique_ElBayadh.docx` | **Submit this** (canonical source) |
| Thesis (PDF)  | `Thesis_Surgical_Edit/submission/package/Memoire_DSS_Logistique_ElBayadh.pdf` | Render-only export |
| Package README | `Thesis_Surgical_Edit/submission/package/README.md` | Verification & structure notes |

### Defense checklist
- [x] Document opens without corruption (python-docx OK)
- [x] All 29 automated checks pass
- [x] Page numbering: decimal, start=4 on TOC (no Roman numerals)
- [x] Footer2 SDT structure preserved (no "PAGE1" literal-text bug)
- [x] Abstract, Bibliography, Annexes, TOC heading all present
- [x] RTL body, Traditional Arabic 14pt, 1.5 line spacing
- [x] Backup of pre-sectPr fix kept at `package/Memoire_DSS_Logistique_ElBayadh.docx.pre_sectfmt.bak`
- [ ] Defense rehearsal (read-through)
- [ ] Print 3 bound copies for the jury
- [ ] Submit bound + electronic copies to Direction de l'Education El Bayadh before 2026-08-15
