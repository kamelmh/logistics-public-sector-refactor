# Claude Desktop GUI — Deep Verification Handoff Plan
> Academix v13.4 | Session 46 | 2026-06-14

## Pre-Session Status

| Item | Status |
|------|--------|
| Thesis DOCX | **32/32 PASS** ✅ (rebuilt from corrected markdown) |
| Ground truth | **ALL CORRECT** — D=789, PU=4,500, Q*=37, ROP=206, SS=200, S=801.45, I=20% |
| Tables | 27 (was 26 in backup — +1 from improved pandoc conversion) |
| Paragraphs | 312 body + 867 table cells |
| Footnotes | 46 (RTL verified) |
| RTL | 1,189 paragraphs + 51 footnote runs fixed |
| File size | 146 KB |

## What Was Fixed (Before Handoff)

1. **Markdown table (line 382)**: PU=400 → PU=4,500 for ART-001
2. **Markdown ABC text (line 308)**: 789 × 400 = 618,000 → 789 × 4,500 = 3,550,500
3. **Markdown ERP table (line 872)**: ART-002 ROP=400.0 → ROP=69.6
4. **DOCX rebuilt** from corrected markdown with full formatting pipeline
5. **32/32 verification** — all checks pass including RTL, page numbering, captions

---

## Rate Limit Strategy

Claude Desktop GUI has rate limits depending on your plan. Here's how to maximize output:

| Plan | Typical Limit | Strategy |
|------|--------------|----------|
| Free | ~25 messages/4h | 5 phases, 5 messages each |
| Pro | ~100 messages/4h | 7 phases, 10-15 messages each |
| Team/Enterprise | Higher | Full 7-phase deep dive |

**Key principle**: Each phase below is designed to be completable in **one conversation turn**. If you hit a rate limit mid-phase, the phase can be resumed in the next turn by pasting the "Resume Prompt" at the bottom of that phase.

---

## PHASE 1: Content Completeness Check (1-2 turns)

### Turn 1 — Load Context + Structure Check

**Paste this prompt into Claude Desktop:**

```
Please read these files to understand the project:

1. CLAUDE.md (project root)
2. THESIS_CONTEXT.md (project root)

Then read the thesis DOCX:
3. Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

And the source markdown for comparison:
4. Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md

Verify that ALL of the following are present and complete:

A. Structure:
   - 4 chapters (Introduction, Theory, Practical, DSS, Results)
   - Front matter: dedication, acknowledgments, TOC, abstract (AR+FR)
   - Back matter: bibliography, glossary, annexes

B. Chapter Content (check each):
   - Chapter 1: 5 مباحث covering logistics, SCM, warehouses, EOQ/ABC/CMUP, suppliers
   - Chapter 2: 4 مباحث with field diagnosis, ABC/Wilson application, gap analysis
   - Chapter 3: DSS design, architecture, VBA modules, transaction flow
   - Chapter 4: Results, verification, recommendations

C. Ground Truth Values (must appear correctly in tables AND text):
   - D = 789 (Annual Demand)
   - Q* = 37 (EOQ)
   - ROP = 206 (Reorder Point)
   - SS = 200 (Safety Stock)
   - S = 801.45 DZD (Order Cost)
   - PU = 4,500 DZD (Unit Price)
   - I = 20% (Holding Rate)

D. Tables (27 expected):
   - Wilson EOQ table with correct values (D=789, PU=4,500, Q*=37, ROP=206)
   - ABC classification table
   - Gap analysis table
   - ERP module comparison table

Report any MISSING content, INCORRECT values, or STRUCTURAL issues.
```

### Resume Prompt (if rate-limited mid-phase):
```
Continue Phase 1 content check. You were checking chapter completeness and ground truth values. Report findings so far.
```

---

## PHASE 2: References & Footnotes Integration (1-2 turns)

### Turn 1 — Footnote Verification

```
Please verify the thesis footnotes for academic integrity:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. Read all 46 footnotes
2. For each footnote, check:
   a. Is the reference complete? (Author, title, journal/publisher, year, pages)
   b. Is the citation format consistent? (same style throughout)
   c. Does the footnote number match the in-text citation?
   d. Is the content academically relevant to the claim it supports?

3. Cross-reference with the bibliography:
   - Are all footnoted sources in the bibliography?
   - Are there bibliography entries NOT cited in footnotes?
   - Any duplicate or near-duplicate entries?

4. Check for common academic issues:
   - Self-citation without disclosure
   - Wikipedia or non-academic sources
   - Outdated references (pre-2000 for technology topics)
   - Missing DOIs for journal articles

Report: Total footnotes, issues found, completeness score.
```

### Resume Prompt:
```
Continue Phase 2 footnote check. You were verifying citation completeness and cross-referencing with bibliography.
```

---

## PHASE 3: RTL & Bilingual Quality (1-2 turns)

### Turn 1 — Arabic RTL Verification

```
Please verify the Arabic RTL formatting and bilingual quality:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. RTL Layout Check:
   - All Arabic paragraphs should be right-to-left
   - Arabic numbers should be correctly oriented
   - Mixed Arabic/French text should maintain RTL flow
   - Table cells with Arabic content should be RTL-aligned

2. Arabic Language Quality:
   - Check for grammar errors in MSA (Modern Standard Arabic)
   - Verify technical terms are used correctly
   - Check diacritical marks (تشكيل) where present
   - Look for French words incorrectly left untranslated

3. French Language Quality:
   - Verify French technical terms are correctly used
   - Check for grammar/spelling errors in French sections
   - Ensure bilingual consistency (same term in AR and FR)

4. Terminology Consistency:
   - Same concept = same term throughout
   - No conflicting translations
   - Technical terms match ERP system naming

Report: RTL status, language quality issues, terminology inconsistencies.
```

### Resume Prompt:
```
Continue Phase 3 RTL check. You were verifying Arabic/French bilingual quality and terminology consistency.
```

---

## PHASE 4: Formatting & Design Style (1-2 turns)

### Turn 1 — Visual Design Verification

```
Please verify the thesis formatting and design:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. Page Layout:
   - A4 (21.0 × 29.7 cm)
   - Margins: 2.5 cm all sides
   - Page numbering: continuous decimal, cover hidden, TOC=page 2

2. Typography:
   - Body: Traditional Arabic 14pt
   - Line spacing: 1.5
   - Headings: proper hierarchy (H1 > H2 > H3)
   - Consistent font usage throughout

3. Tables (27 total):
   - Consistent styling across all tables
   - Proper borders and cell padding
   - Column widths appropriate for content
   - RTL text in Arabic columns
   - Headers clearly distinguishable

4. Visual Hierarchy:
   - Clear chapter/section/subsection separation
   - Proper indentation
   - Consistent spacing between elements
   - Professional academic appearance

Report: Formatting compliance score, visual issues, design recommendations.
```

### Resume Prompt:
```
Continue Phase 4 formatting check. You were verifying visual design, table styling, and typography.
```

---

## PHASE 5: TOC, Figures & Numbering Mapping (1-2 turns)

### Turn 1 — Numbering System Verification

```
Please verify the thesis numbering systems:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. Table of Contents (TOC):
   - Verify TOC entries match actual headings
   - Check page numbers in TOC match actual pages
   - Ensure all levels are included (H1, H2, H3)

2. Table of Figures (if present):
   - Check if figures are numbered sequentially
   - Verify captions match figure numbers

3. Table Numbering:
   - Tables should be numbered sequentially (جدول 1, جدول 2, ...)
   - Each table should have a descriptive caption
   - Table references in text should match actual table numbers

4. Footnote Numbering:
   - Sequential numbering (1, 2, 3, ...)
   - No gaps or duplicates
   - In-text superscript numbers match footnote entries

5. Heading Numbering:
   - Check if chapters are numbered (الفصل الأول, الثاني, ...)
   - Sections within chapters are numbered (المبحث الأول, ...)
   - Subsections are numbered (المطلب الأول, ...)

6. Cross-Reference Check:
   - "see Table X" references match actual table numbers
   - "as shown in Chapter Y" references match actual chapters
   - No broken or incorrect references

Report: Numbering issues, cross-reference errors, TOC accuracy.
```

### Resume Prompt:
```
Continue Phase 5 numbering check. You were verifying TOC, table numbering, and cross-references.
```

---

## PHASE 6: Hypothesis & Calculations Verification (1-2 turns)

### Turn 1 — Mathematical Accuracy Check

```
Please verify the thesis calculations and hypotheses:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. Wilson EOQ Formula Verification:
   Q* = √(2DS / I×PU) = √(2 × 789 × 801.45 / 0.20 × 4,500)
   = √(1,264,688.1 / 900) = √1,405.21 ≈ 37 units

   Verify this calculation appears correctly in the thesis.
   Check all intermediate steps are shown.

2. ROP Calculation:
   ROP = (D/250) × LT + SS = (789/250) × 2 + 200
   = 6.312 × 2 + 200 = 206.3 ≈ 206 units

   Verify this calculation appears correctly.

3. Total Cost Calculation:
   TC(Q*) = (D/Q*)×S + (Q*/2)×I×PU
   = (789/37)×801.45 + (37/2)×0.20×4,500
   = 17,089 + 16,650 = 33,739 DZD

   Verify this appears correctly.

4. Hypothesis Verification:
   - H1: "Absence of automatic alerts causes stockouts" — Is this proven?
   - H2: "Excel/VBA DSS improves tracking accuracy and reduces processing time" — Is this proven?
   - Are the conclusions supported by the data?

5. Performance Claims:
   - "99.7% reduction in processing time" — Is this calculated correctly?
   - "20-30 minutes → less than 5 seconds" — Is this documented?
   - "Zero stockouts after implementation" — Is this verified?

Report: Calculation accuracy, hypothesis validation, evidence quality.
```

### Resume Prompt:
```
Continue Phase 6 calculations check. You were verifying Wilson formula, ROP, total cost, and hypothesis proof.
```

---

## PHASE 7: Final Assessment & Sign-Off (1 turn)

### Turn 1 — Comprehensive Final Review

```
Based on all previous phases, provide a FINAL ASSESSMENT:

1. Content Completeness: ___/100
2. Academic Standards: ___/100
3. RTL & Bilingual Quality: ___/100
4. Formatting & Design: ___/100
5. Numbering & References: ___/100
6. Calculations & Hypotheses: ___/100
7. OVERALL SCORE: ___/100

For each area:
- What passes?
- What needs fixing?
- What are the recommendations?

Final verdict: Is this thesis READY for academic submission?

Provide a signed assessment with:
- Date
- Your confidence level (1-100%)
- Any remaining issues
- Recommendation: APPROVE / APPROVE WITH MINOR FIXES / REJECT
```

---

## Key Files Reference

| File | Path | Purpose |
|------|------|---------|
| Thesis DOCX | Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx | Main output (Golden Source) |
| Thesis PDF | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf | PDF version |
| Source Markdown | Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md | Source of truth |
| Verify Script | Thesis_Surgical_Edit/style/verify_docx_checks.py | 32-point check |
| Build Script | Thesis_Surgical_Edit/build-thesis.ps1 | Rebuild pipeline |
| Project Context | CLAUDE.md | Main overview |
| Thesis Context | THESIS_CONTEXT.md | Detailed info |

## Ground Truth (DO NOT MODIFY)

| Param | Value | Description |
|-------|-------|-------------|
| D | 789 | Annual Demand |
| Q* | 37 | EOQ via Wilson |
| ROP | 206 | Reorder Point |
| SS | 200 | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4,500 DZD | Unit Price |
| I | 20% | Holding Rate |

## Current Status

- ✅ 32/32 verification checks PASS
- ✅ Ground truth values CORRECT in all tables and text
- ✅ RTL formatting applied (1,189 paragraphs, 51 footnote runs)
- ✅ Page numbering: continuous decimal, cover hidden
- ✅ All 4 chapters complete with 17 مباحث and 52 مطالب
- ✅ 27 tables with correct data
- ✅ 46 footnotes with RTL formatting
- ✅ Ready for Claude Desktop deep verification
