# Academix v13.4 — Claude Debug Task
**Task:** Fix/debug thesis DOCX, verify calculations, check git status  
**Date:** 2026-06-26  
**Priority:** HIGH — Pre-submission verification

---

## 🎯 TASK FOR CLAUDE

> **Project:** Academix v13.4 — VBA/Excel DSS for Direction de l'Education El Bayadh  
> **Thesis:** BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب  
> **Ground Truth (LOCKED):**
> - ART-001 (Papier A4): D=2007, PU=400, Q*=50, ROP=416
> - ART-002 (Toner G030): D=33, PU=1200, Q*=15, ROP=200, SS=200, LT=2 days, S=801.45 DZD, I=20%
> - MASTER_PWD=erp_secure_pwd_2026
> 
> **Current State:** 32/32 automated PASS, PDF generated. Need human verification of:
> 1. **Numbers/calculations** — EOQ, ROP, safety stock, ABC/XYZ, Wilson model
> 2. **DOCX integrity** — page numbers, hyperlinks, RTL, tables, footnotes
> 3. **Git status** — confirm clean, all changes committed
> 
> **Files to examine:**
> - `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx` (150 KB)
> - `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf` (1,284 KB)
> - `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` (153 KB) — **SOURCE FOR EDITS**
> - `Thesis_Surgical_Edit/style/word_automation.py` (COM v13)
> - `Thesis_Surgical_Edit/build-thesis.ps1` (pipeline)

---

## 🔍 SPECIFIC VERIFICATION TASKS

### 1. Numbers & Calculations (Critical)
Open the DOCX and verify these values match ground truth:

| Parameter | ART-001 (Papier A4) | ART-002 (Toner G030) | Location |
|-----------|---------------------|----------------------|----------|
| **D (Annual Demand)** | 2007 | 33 | Chapter 3, Table 4 |
| **PU (Unit Price)** | 400 DZD | 1200 DZD | Chapter 3 |
| **S (Order Cost)** | 801.45 DZD | 801.45 DZD | Chapter 3 |
| **I (Holding Rate)** | 20% | 20% | Chapter 3 |
| **Q* (EOQ)** | 50 | 15 | Chapter 3, Wilson model |
| **ROP (Reorder Point)** | 416 | 200 | Chapter 3 |
| **SS (Safety Stock)** | — | 200 | Chapter 3 |
| **LT (Lead Time)** | — | 2 days | Chapter 3 |

**Check:** EOQ formula = √(2DS/I·PU), ROP = (D/250)×LT + SS

### 2. DOCX Integrity (Open in Word)
- [ ] Open `Memoire_DSS_Logistique_ElBayadh.docx`
- [ ] **Ctrl+A → F9** (update all fields)
- [ ] Verify TOC: single field, clickable links, correct page numbers
- [ ] Verify TOF: single field, clickable links, correct page numbers  
- [ ] Check page numbering: continuous decimal from cover (cover=1 hidden)
- [ ] Check RTL: Arabic text right-aligned, footnotes RTL
- [ ] Check tables: 25 tables, borders, widths, captions
- [ ] Check footnotes: 46, all RTL, readable
- [ ] Check hyperlinks: TOC entries clickable, TOF entries clickable

### 3. Git Status
```bash
git status
git log --oneline -5
```
Confirm: clean working tree, all commits pushed (cd5541e)

---

## 📁 MINIMAL CONTEXT FILES (Phased)

### Phase 1 — Initial Context (Give First)
```
1. CLAUDE.md                              # 8 KB - project overview
2. THESIS_CONTEXT.md                      # 12 KB - thesis details
3. .crossflow/HANDOFF.md                  # 6 KB - current state
4. .opencode/notepad.md                   # 3 KB - ground truth
5. Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md  # 153 KB - SOURCE FOR EDITS
```
**Total: ~182 KB text** — well within limits. No binary files yet.

### Phase 2 — After Plan (Give If Needed)
```
6. Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx  # 150 KB - for verification
```

---

## 🎯 PHASED TASK FOR CLAUDE

### Phase 1: Analysis & Plan (with MD source only)
> **Given:** 5 text files above (no DOCX)
> **Task:** 
> 1. Read the MD thesis source and verify calculations match ground truth
> 2. Identify any content issues (numbers, formulas, structure)
> 3. **Report back a plan** for DOCX verification
> 4. List specific checks you'll perform when given the DOCX

### Phase 2: DOCX Verification (after plan approved)
> **Given:** DOCX file
> **Task:** Execute your plan — verify formatting, hyperlinks, page numbers, etc.

---

## 🚀 HOW TO RUN PIPELINE (If Rebuild Needed)

```powershell
# From project root: C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor
taskkill /F /IM WINWORD.EXE
& "Thesis_Surgical_Edit\build-thesis.ps1"
# Wait 3-5 min → 32/32 PASS + PDF
```

---

## ⚠️ KNOWN NON-BLOCKING ISSUES

1. Cover page may show page number (single-section with titlePg)
2. 104 TOC entries have inline page numbers (manual from pandoc)
3. EOQ/ROP keywords flagged missing in content coverage (they're in tables)
4. Dummy logos removed — Golden Source has 1 real logo (10.7 KB)

---

## 📋 EXPECTED OUTPUT FROM CLAUDE

Please provide:
1. **Calculation verification** — each formula result matches ground truth
2. **DOCX issues found** — any formatting, numbering, hyperlink problems
3. **Git status** — clean? uncommitted changes?
4. **Submission readiness** — YES/NO with reasons
5. **Fixes needed** — if any, specific file/line references