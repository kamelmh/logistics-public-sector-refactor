# CrossFlow Handoff — Academix v13.4

## Current Priority (Session 33 — CRITICAL)
**Thesis Build Tools are fundamentally broken.** Despite surgical attempts to fix formatting, the resulting DOCX is rendered as 300+ pages in Word ("stuffed" effect). This is a deep OOXML/Rendering conflict between Traditional Arabic font, RTL, and 1.5 spacing.

**Decision**: Stop iterative guessing. Move to a high-reasoning model (Fable 5 / Claude) with a directed prompt to rewrite the formatting logic in `fix_thesis_all.py` and `build-thesis.ps1` to ensure Word-native compatibility.

## Active Model
**Gemma 4 31B** (Google) — Handing off to high-reasoning model.

## Active Model
**Gemma 4 31B** (Google, 256K context) — Recovery Lead.
**mimo-v2.5-free** (Gemini 2.5 Flash) — Awaiting final submission prep.

## Active Model
**Gemma 4 31B** (Google, 256K context) — Completed Tooling Amelioration.
**mimo-v2.5-free** (Gemini 2.5 Flash) — Assigned to Surgical Fixes.

## What's Complete
- ✅ ERP v13.4: 114/114 PASS, GOLDEN promoted
- ✅ Thesis PDF: 1,380 KB (Word COM automation)
- ✅ English paper PDF: 69 KB, 9 pages (pandoc, CCA'2026 format)
- ✅ English paper DOCX: 34 KB
- ✅ **Thesis Gold-Standard Pipeline**: Inspector, Fixer, COM Control, Orchestrator
- ✅ **Build script integration**: `-Regulated` parameter added to build-thesis.ps1
- ✅ **Git**: 2 commits ahead of origin/master (07f622e, 2c4587b)

## What's Broken — CRITICAL
**Thesis DOCX (Memoire_DSS_Logistique_ElBayadh.docx) is corrupted:**
- Tables don't display correctly in Word
- Document appears "stuffed" — content not properly structured
- Not regulated (formatting inconsistent)
- Recent surgical fixes (caption RTL, page numbering) may have introduced corruption
- The DOCX opened in Word shows broken table rendering

## Root Cause Analysis
1. **Surgical fix script** (`fix_thesis_surgical.py`) modified XML directly via lxml — may have broken table structure
2. **Multiple rebuild cycles** — DOCX has been rebuilt 5+ times, each time modifying XML
3. **Table style IDs differ** from backup v7c (confirmed earlier)
4. **File size mismatch** — Current 74KB vs backup 161KB (content may be missing)

## What Needs Doing — NEXT SESSION
### Task 1: Full Rebuild from Source (CRITICAL)
```powershell
# Kill any Word processes first
Get-Process WINWORD -ErrorAction SilentlyContinue | Stop-Process -Force

# Run full regulated build from markdown
& "Thesis_Surgical_Edit/build-thesis.ps1" -Regulated
```
This rebuilds from `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` → DOCX
The pipeline: Inspector → Fixer → COM Control → Orchestrator

### Task 2: Verify After Rebuild
```powershell
python "Thesis_Surgical_Edit/style/verify_docx_checks.py" "Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx"
```
Expected: 28/29 PASS (1 non-critical TOC issue)

### Task 3: Open and Inspect in Word
1. Open the rebuilt DOCX
2. Check tables render correctly
3. Check content is complete (78 pages)
4. Ctrl+A → F9 to update fields
5. Verify page numbers display

### Task 4: If Tables Still Broken
Compare with backup v7c:
```powershell
# Open backup for reference
Start-Process "Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh_v7c_BACKUP.docx"
```
May need to copy table styles from backup to current DOCX.

### Task 5: Update This File When Done

## Key Files
| File | Path |
|------|------|
| Thesis DOCX | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx |
| Thesis PDF | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf |
| Thesis BACKUP v7c | Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh_v7c_BACKUP.docx |
| Desktop golden | C:\Users\Administrator\Desktop\Memoire_DSS_Logistique_ElBayadh_v2.docx |
| Build script | Thesis_Surgical_Edit/build-thesis.ps1 |
| Quick reference | Thesis_Surgical_Edit/THESIS_BUILD_QUICKREF.md |
| Master prompt | Thesis_Surgical_Edit/MASTER_PROMPT_THESIS.md |
| English source | Thesis_Surgical_Edit/English_Research_Paper.md |
| ERP workbook | GOLDEN_ERP_v13.4.xlsm |

## Ground Truth (DO NOT MODIFY)
| Param | Value |
|-------|-------|
| D | 789 |
| Q* | 37 |
| ROP | 206 |
| SS | 200 |
| LT | 2 days |
| S | 801.45 DZD |
| I | 20% |
| MASTER_PWD | erp_secure_pwd_2026 |

## Session 33 Summary (2026-06-11) — CrossFlow Sync + Surgical Fix Gone Wrong
- CrossFlow sync completed, Gemma 4 31B completed Option C (verify_docx_checks.py enhancement)
- Gemma found: 21/21 captions missing RTL, page numbering XML wrong
- Created fix_thesis_surgical.py to fix caption RTL and page numbering
- Fixed verify_docx_checks.py OOXML attribute names (fmt vs val)
- Verification improved: 29/32 → 30/32 PASS
- **PROBLEM**: User opened DOCX in Word — tables corrupted, document stuffed/broken
- **ROOT CAUSE**: Direct XML manipulation via lxml broke table structure
- **SOLUTION NEEDED**: Full rebuild from markdown source via Gold-Standard Pipeline
- Git: 2 commits pushed (2c4587b, 07f622e)
- **NEXT**: Kill Word, run `build-thesis.ps1 -Regulated`, verify, inspect in Word