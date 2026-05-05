# Project: Academix v13.2 — Pure VBA Decision Support System

## 🎯 Goal
Pure VBA-only Decision Support System (نظام دعم قرار) for stock management at Directorate of Education, El Bayadh, Algeria. Compliant with CNEPD BTS standards. Zero external dependencies.

## 🛑 GOLDEN RULES (NEVER VIOLATE)
1. **Zero External Dependencies** — NO Python, NO Flask, NO JSON files, NO APIs, NO internet calls. Pure VBA only.
2. **Thesis hierarchy strictly**: `فصل` → `مبحث` → `مطلب` → `أولاً، ثانياً...`. The word `فرع` is STRICTLY BANNED.
3. **Language**: Formal Academic Arabic (RTL). Tone strictly administrative — emphasize "Zero Cost", "Standard Microsoft Tools", "Accountability".
4. **Citations**: Strict CNEPD footnotes (تهميش) at bottom of each page.
5. **DSS Framing**: System is a "Decision Support System" (نظام دعم قرار), NOT an automated replacement.
6. **Ladder Logic**: Must first prove "Professional Competence" (Manual Math/Science) before showing "BTS Level" (Automation).

## 📊 Ground Truth Constants (NEVER CHANGE)
- **Annual Demand (D):** 1,546 units
- **Reorder Point (ROP):** 205.6 units
- **Safety Stock (SS):** 200 units
- **Economic Order Quantity (Q*):** 176 units
- **Lead Time (LT):** 2 days
- **Case Study:** Toner G030 (ART-001)
- **Institution:** Directorate of Education, El Bayadh

## 📁 Project Structure
```
Logistics.Public.Sector.Refactor/
├── Thesis_Surgical_Edit/          # Thesis operations ONLY
│   └── Final_Thesis_Academix_v13_2.md
├── Software_Surgical_Edit/        # VBA code operations ONLY
│   ├── ERP_Academie_v13_Master.xlsm
│   └── VBA_Modules/               # 23 pure VBA files
├── Repomix_Outputs/               # AI context files
│   ├── repomix-project.xml        # Project manifest + rules
│   ├── repomix-thesis.xml         # Thesis context lock
│   └── repomix-software.xml       # VBA software context lock
├── Academic_References/           # Course PDFs, old drafts
├── Defense_Support/               # Jury defense documents
└── Final_Delivery_Layout/         # CNEPD submission package
```

## 🔄 Terminology Mapping
| Forbidden | Required |
|-----------|----------|
| Database | السجل الرقمي (Digital Ledger) |
| Python/Backend | وحدات المعالجة VBA |
| Mini-ERP | نظام دعم القرار لتسيير المخزون |
| Algorithm | النموذج الرياضي |
| API Bridge | الربط المحلي |

## 📋 Mode Selection
- **Thesis Mode**: Work in `Thesis_Surgical_Edit/` only. Edit `Final_Thesis_Academix_v13_2.md`.
- **Software Mode**: Work in `Software_Surgical_Edit/` only. Edit `.bas`/`.frm` files in `VBA_Modules/`.
- **Never mix modes** — thesis edits don't touch code, code edits don't touch thesis.

## 📖 Context Files
- `../Repomix_Outputs/repomix-project.xml` — Full project manifest, golden rules, directory structure, module inventory
- `../Repomix_Outputs/repomix-thesis.xml` — Thesis structure, key passages, formulas, references, glossary
- `../Repomix_Outputs/repomix-software.xml` — All VBA modules, sheet inventory, data flow, architecture layers

## ✅ Status
- Thesis 6→4 chapter realignment: COMPLETE
- Python/Flask/JSON removal: COMPLETE
- External API → offline verification code: COMPLETE
- Terminology cleanup: COMPLETE
- Constants sync: COMPLETE
- DSS narrative: COMPLETE
- VBA design spec: COMPLETE
- Repomix XML context files: COMPLETE
