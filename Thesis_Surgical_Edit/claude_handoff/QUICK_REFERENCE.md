# Academix v13.4 — Quick Reference for Claude
**Phased verification — minimal tokens first**

---

## 🔑 GROUND TRUTH (LOCKED — DO NOT CHANGE)

| Item | ART-001 (Papier A4) | ART-002 (Toner G030) |
|------|---------------------|---------------------|
| **D** (Annual Demand) | 2007 | 33 |
| **PU** (Unit Price) | 400 DZD | 1200 DZD |
| **Q*** (EOQ) | 50 | 15 |
| **ROP** (Reorder Point) | 416 | 200 |
| **SS** (Safety Stock) | — | 200 |
| **LT** (Lead Time) | — | 2 days |
| **S** (Order Cost) | — | 801.45 DZD |
| **I** (Holding Rate) | — | 20% |

**MASTER_PWD:** `erp_secure_pwd_2026`

---

## 📊 CURRENT DELIVERABLES

| File | Size | Status |
|------|------|--------|
| `Memoire_DSS_Logistique_ElBayadh.docx` | 150 KB | 32/32 PASS |
| `Memoire_DSS_Logistique_ElBayadh.pdf` | 1,284 KB | Generated |
| `English_Research_Paper_IEEE.pdf` | 68 KB | Ready |
| `ERP_v13.4.xlsm` | 669 KB | 114/114 PASS |

---

## ✅ VERIFICATION RESULTS (32/32)

| Check | Result | Details |
|-------|--------|---------|
| TOC fields | 1 | No duplicates |
| TOF fields | 1 | No duplicates |
| Hyperlinks | 104 | `w:anchor` to bookmarks |
| Bookmarks | 116 | All headings |
| PAGEREF fields | 129 | With `\h` switch |
| Footnote RTL | 0 bad | 46 fixed |
| Caption RTL | 0/35 bad | All fixed |
| Page numbering | PASS | fmt=decimal, start=1 |
| Tables | 25 | Borders, widths, padding |
| Arabic RTL | 1,419 paras | All bidi+rtl |

---

## 🔧 PIPELINE (build-thesis.ps1)

```
Golden Source → fix_docx_sections → surgical_polish → fix_thesis_all
→ verify (32/32) → COM (word_automation.py v13)
→ Fields.Update() → PDF export → post-COM fixes → verify (32/32)
```

**COM v13 key fix:** Checks next paragraph for existing TOC/TOF field → **UPDATES** instead of inserting duplicate → calls `doc.Fields.Update()` for hyperlinks.

---

## 🎯 PHASED VERIFICATION TASKS

### Phase 1: MD Source Analysis (Give 5 text files first)
1. **Verify calculations** in MD match ground truth table above
2. **Check formulas** — EOQ, ROP, SS, LT correctly shown
3. **Verify structure** — 4 chapters, 17 مباحث, 52 مطالب
4. **Report plan** for Phase 2 DOCX verification

### Phase 2: DOCX Verification (After plan approved, give DOCX)
1. **Open DOCX** → Ctrl+A F9 → verify TOC/TOF page numbers
2. **Click TOC links** → should jump to headings
3. **Check tables** for EOQ, ROP, SS, ABC/XYZ values
4. **Confirm** no duplicate TOC/TOF fields
5. **Verify** hyperlinks, RTL, page numbering

---

## 📁 PHASED FILES FOR CLAUDE

### Phase 1 — Initial (Give First)
| # | File | Purpose |
|---|------|---------|
| 1 | `CLAUDE.md` | Full project context |
| 2 | `THESIS_CONTEXT.md` | Thesis details, verification |
| 3 | `.crossflow/HANDOFF.md` | Current state |
| 4 | `.opencode/notepad.md` | Ground truth, session memory |
| 5 | `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` | **SOURCE FOR EDITS** (153 KB) |

**Total: ~182 KB text** — no binary files.

### Phase 2 — After Plan Approved
| # | File | Purpose |
|---|------|---------|
| 6 | `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx` | For verification (150 KB) |

---

## 🛠 COMMANDS FOR CLAUDE

```bash
# Git status
git status
git log --oneline -5

# Verify pipeline (if needed)
taskkill /F /IM WINWORD.EXE
& "Thesis_Surgical_Edit\build-thesis.ps1"

# Quick DOCX check via Python
python -c "
from docx import Document
doc = Document(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx')
print(f'Paras: {len(doc.paragraphs)}')
print(f'Tables: {len(doc.tables)}')
print(f'Sections: {len(doc.sections)}')
"
```

---

## ✅ PHASE 1 CHECKLIST

- [ ] **Numbers**: All calculations in MD match ground truth
- [ ] **Formulas**: EOQ, ROP, SS, LT correctly shown
- [ ] **Structure**: 4 chapters, 17 مباحث, 52 مطالب present
- [ ] **Content**: No missing sections, no contradictions
- [ ] **Report**: Plan for Phase 2 DOCX verification

---

## ✅ PHASE 2 CHECKLIST

- [ ] **TOC**: 1 field, clickable, correct pages
- [ ] **TOF**: 1 field, clickable, correct pages  
- [ ] **Page numbers**: Continuous decimal from cover
- [ ] **RTL**: Arabic text, footnotes, captions all RTL
- [ ] **Tables**: 25 tables, formatted, captioned
- [ ] **Footnotes**: 46, all RTL, readable
- [ ] **Hyperlinks**: TOC + TOF entries clickable
- [ ] **Git**: Clean, all committed (cd5541e)

---

## ⚠️ KNOWN NON-BLOCKING ISSUES

1. Cover may show page number (single-section + titlePg)
2. 104 TOC entries have inline page numbers (pandoc manual typing)
3. EOQ/ROP keywords flagged missing (in tables, not headings)
4. Dummy logos removed (Golden Source has 1 real 10.7 KB logo)

---

## 🚀 RESUME PROMPT

```
Project: Academix v13.4 — VBA/Excel DSS for Direction de l'Education El Bayadh
Ground Truth: ART-001 D=2007 Q*=50 ROP=416 | ART-002 D=33 Q*=15 ROP=200 SS=200 LT=2 S=801.45 I=20% MASTER_PWD=erp_secure_pwd_2026
Phase: 1 (MD analysis) or 2 (DOCX verification)
Files: CLAUDE.md, THESIS_CONTEXT.md, .crossflow/HANDOFF.md, .opencode/notepad.md, Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md
```