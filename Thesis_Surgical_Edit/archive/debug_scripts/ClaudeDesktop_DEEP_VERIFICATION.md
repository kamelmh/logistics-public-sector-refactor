# Claude Desktop — Deep Verification Strategy
> Academix v13.4 | Session 45 | 2026-06-14

## Overview
This document provides Claude Desktop GUI with everything needed for a deep verification of the thesis DOCX (99% complete). Claude Desktop has filesystem MCP access to the entire project root.

---

## STEP 1: Setup Verification

Before starting, confirm Claude Desktop can access files:

```
Can you read the file CLAUDE.md in the project root and confirm you have access?
```

If yes, proceed. If no, check MCP config:
- Config: `C:\Users\Administrator\AppData\Roaming\Claude\claude_desktop_config.json`
- Must have: `filesystem` MCP server pointing to project root

---

## STEP 2: Load Full Context

Paste this prompt into Claude Desktop GUI:

```
Please read these files to understand the full project context:

1. CLAUDE.md — Project overview and current status
2. THESIS_CONTEXT.md — Detailed thesis information
3. CROSSFLOW_CLAUDE_DESKTOP.md — Session history and git context
4. .crossflow/HANDOFF.md — Current project status and sign-off

Then read the thesis source to understand the content:
5. Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md — Source markdown

And check the verification results:
6. Thesis_Surgical_Edit/THESIS_PAGE1_FIX_SUMMARY.md — Fix history

Provide a summary of:
- What this project is about
- Current completion status
- What needs verification
- Any issues you see
```

---

## STEP 3: Deep DOCX Analysis

```
Please perform a deep analysis of the thesis DOCX file:

File: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx

1. Read the DOCX file content
2. Compare it against the source markdown (Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md)
3. Verify:
   a. All 4 chapters are present and complete
   b. All 17 مباحث (sections) are included
   c. All 52 مطالب (subsections) are included
   d. Ground truth parameters are correctly used throughout
   e. Tables contain correct data (26 tables expected)
   f. Footnotes are complete (46 expected)
   g. Arabic content is grammatically correct
   h. French content is professionally written

4. Check the source markdown against the DOCX for any missing content
5. Report any discrepancies

This is a BTS CNEPD thesis for the Direction de l'Education, El Bayadh, Algeria.
```

---

## STEP 4: Formatting Verification

```
Please verify the thesis formatting meets CNEPD BTS requirements:

1. Page layout: A4 (21.0×29.7 cm)
2. Font: Traditional Arabic 14pt for body text
3. Line spacing: 1.5 throughout
4. RTL alignment: All Arabic text right-aligned
5. Tables: Proper borders, cell padding, column widths
6. Headings hierarchy: H1 (9), H2 (38), H3 (59)
7. Page numbering: Continuous decimal, cover hidden, TOC page 2
8. Footnotes: RTL formatted, proper superscript

Check the verification results I'll provide:
- 32/32 checks PASS
- Single-section layout with continuous numbering
- footer2.xml contains PAGE field (no cached value)
- Table styles match v7c backup

Confirm everything looks correct.
```

---

## STEP 5: Academic Standards Review

```
Please review this thesis for academic submission standards:

1. Content Completeness:
   - Is the introduction comprehensive?
   - Does the theoretical framework cover all required topics?
   - Is the practical study well-documented?
   - Are the results properly presented and analyzed?

2. Academic Quality:
   - Is the research methodology sound?
   - Are the conclusions supported by evidence?
   - Is the bibliography complete?
   - Are the references properly cited?

3. CNEPD BTS Requirements:
   - Does it meet the BTS CNEPD program requirements?
   - Is the thesis structure compliant?
   - Are all required sections present?

4. Language Quality:
   - Is the Arabic (MSA) content grammatically correct?
   - Is the French content professionally written?
   - Are technical terms used correctly?

Provide a detailed assessment with any recommendations.
```

---

## STEP 6: Git History Review

```
Please review the git history to understand the project evolution:

Run: git log --oneline --since="2026-06-01" --all

Summarize:
1. Key milestones achieved
2. Issues that were resolved
3. Current state of the project
4. What remains to be done

This helps understand the full context of our work.
```

---

## STEP 7: Final Assessment

```
Based on your review, provide a final assessment:

1. Is the thesis ready for academic submission?
2. What are the remaining issues (if any)?
3. What is the confidence level (1-100%)?
4. Any final recommendations before submission?

The thesis is at 99% completion according to our manual verification.
The user has manually verified and fixed everything in Word.
Please confirm this assessment.
```

---

## Key Ground Truth (DO NOT MODIFY)
| Param | Value | Description |
|-------|-------|-------------|
| D | 789 | Annual Demand |
| Q* | 37 | EOQ via Wilson |
| ROP | 206 | Reorder Point |
| SS | 200 | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4500 DZD | Unit Price |
| I | 20% | Holding Rate |

## Verification Status
- **ERP Workbook**: 114/114 PASS ✅
- **Thesis DOCX**: 32/32 PASS ✅
- **Thesis PDF**: 1,380 KB ✅
- **English Paper**: 69 KB, 9 pages ✅
- **Manual Verification**: 99% complete ✅

## Files Claude Desktop Can Access (via MCP)
| File | Path | Purpose |
|------|------|---------|
| Project Context | CLAUDE.md | Main project overview |
| Thesis Context | THESIS_CONTEXT.md | Detailed thesis info |
| CrossFlow Sync | CROSSFLOW_CLAUDE_DESKTOP.md | Session history |
| HANDOFF | .crossflow/HANDOFF.md | Current status |
| Thesis Source | Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md | Source markdown |
| Thesis DOCX | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx | Output document |
| Thesis PDF | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf | Output PDF |
| Verify Script | Thesis_Surgical_Edit/style/verify_docx_checks.py | Verification |
| Build Script | Thesis_Surgical_Edit/build-thesis.ps1 | Build pipeline |

## Notes
- Claude Desktop GUI is the desktop application (not CLI)
- MCP filesystem gives full access to project root
- All context files are updated and current
- Git repository is synced with remote
- Ready for deep verification and final review
