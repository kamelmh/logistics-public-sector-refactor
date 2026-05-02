---
title: Project Memory (Ground Truth)
type: memory
status: active
last_updated: 2026-05-02
tags: [ground-truth, el-bayadh, constants, case-study]
---

# Project Memory (Ground Truth)

## Project Identity

**Name:** Academix v13.2 (Public Sector Refactor)  
**Type:** Decision Support System (DSS) for Stock Management  
**Compliance:** CNEPD BTS Standards (Algerian Public Sector)  
**Tech Stack:** 100% Microsoft Excel / VBA (Pure, No External Dependencies)

---

## Ground Truth Data (DO NOT ALTER)

All formulas, code tests, and thesis evaluations must align with this case study:

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Institution** | Directorate of Education, El Bayadh | Algerian Public Sector |
| **Case Study Article** | Toner G030 (ART-001) | Reference article for all calculations |
| **Annual Demand (D)** | 1,546 units | Yearly consumption |
| **Reorder Point (ROP)** | 205.6 units | When to trigger reorder |
| **Safety Stock (SS)** | 200 units | Buffer inventory |
| **Economic Order Quantity (Q*)** | 176 units | Optimal order size |
| **Lead Time (LT)** | 2 days | Supplier delivery time |

---

## Project Structure (Clean Room)

### Root: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`

```
Logistics.Public.Sector.Refactor/
├── Thesis_Surgical_Edit/          # Thesis writing (4 chapters, Arabic RTL)
│   ├── Final_Thesis_Academix_v13_2.md
│   ├── THESIS_CHAPTER_OUTLINE.md
│   ├── THESIS_TERMINOLOGY_MAPPING.md
│   └── images/
│
├── Software_Surgical_Edit/         # VBA code refactoring
│   ├── ERP_Academie_v13_Master.xlsm
│   ├── VBA_DESIGN_SPEC.md
│   └── VBA_Modules/              # Pure .bas and .frm files
│       ├── mod_StockEngine.bas
│       ├── mod_ExportEngine.bas
│       ├── frmStockEntry.frm
│       └── [other modules...]
│
├── Repomix_Outputs/               # Isolated context files
│   ├── repomix-project.xml
│   ├── repomix-software.xml
│   └── repomix-thesis.xml
│
├── Academic_References/           # Course PDFs (Semesters 1-4)
├── Defense_Support/               # Jury presentation docs
│   ├── TECHNICAL_DEFENSE_REPORT.md
│   ├── SOFTWARE_ORIGINALITY.md
│   └── VALIDATION_LOG.md
│
├── Final_Delivery_Layout/         # Final submission files
│   ├── 01_Memoire_Final/
│   ├── 02_Systeme_Academix_v13_1/
│   └── 03_Documents_Generes_Exemples/
│
├── Claude_Desktop/                # Claude Desktop config
│   └── CLAUDE.md
│
├── AGENTIC_AI_ALIGNMENT_MANIFESTO.md  # Core manifesto
├── CLAUDE.md                      # Project instructions
└── CNEPD_REQUIREMENTS.md         # Compliance requirements
```

---

## Thesis Structure (4 Chapters)

**Language:** Formal Academic Arabic (RTL)  
**Hierarchy:** فصل (Chapter) → مبحث (Section) → مطلب (Requirement) → أولاً، ثانياً...

| Chapter | Title (Arabic) | Title (English) | Content |
|---------|-------------------|-------------------|---------|
| **Ch 1** | الإطار النظري والمفاهيمي | Theory & Concepts | Mathematical models, EOQ, ROP, SS formulas |
| **Ch 2** | التشخيص والميدان | Field Diagnosis | Geographic/institutional framework, El Bayadh case |
| **Ch 3** | التصميم والمنهجية | Design & Methodology | Pure VBA DSS, UserForms, Digital Ledger |
| **Ch 4** | النتائج والتقييم | Results & Evaluation | Case study Toner G030, performance metrics |

**Forbidden:** The word `فرع` (Branch) is BANNED from structure.

---

## Software Architecture (VBA DSS)

### Core Components

1. **Digital Ledger (السجل الرقمي)** - Internal structured sheets (no Database term)
2. **VBA Processing Units (وحدات المعالجة VBA)** - Replaces "Python backend"
3. **UserForms (استمارات العمل)** - Data entry forms (replaces raw cell input)
4. **Dashboard** - Stock Critique, reorder point alerts

### VBA Modules (Pure, No Python Bridges)

| Module | Purpose |
|--------|---------|
| `mod_StockEngine.bas` | Core inventory calculations (EOQ, ROP, SS) |
| `mod_ExportEngine.bas` | PDF generation (Bon de Réception, Bon de Sortie) |
| `mod_Database.bas` | Digital Ledger management (NOT "Database") |
| `mod_Reports.bas` | Dashboard and reporting |
| `mod_Utilities.bas` | Helper functions |
| `frmStockEntry.frm` | Stock entry form (UserForm) |
| `mod_SyncBridge.bas` | Local sheet storage (NO Python bridges!) |

---

## Critical Rules (Non-Negotiable)

### The "Clean Room" Constraints
1. **Zero External Dependencies:** NO Python, NO Flask, NO JSON, NO APIs
2. **Pure VBA:** Everything runs locally in Excel via VBA Processing Units
3. **Administrative Terminology:** Tech terms → Arabic administrative equivalents
4. **CNEPD Hierarchy:** Strict فصل → مبحث → مطلب structure
5. **Formal Arabic (RTL):** No colloquial, no technical jargon in thesis

### Translation Table (Mandatory)

| Technical Term | Administrative Equivalent (Arabic) |
|---------------|----------------------------------------|
| Database | السجل الرقمي (Digital Ledger) / دفاتر البيانات |
| Python Backend | وحدات المعالجة VBA (VBA Processing Units) |
| Hybrid System | نظام دعم قرار مبني على Excel |
| Mini-ERP | نظام دعم القرار لتسيير المخزون |
| UserForms | استمارات العمل / نماذج الإدخال |
| Algorithm | النموذج الرياضي |

---

## Pedagogical Ladder (The "Ladder Logic")

The project must demonstrate progression:

1. **Manual Science** (Ch 1) - Prove mathematical competence
2. **Semi-Automated** (Ch 2) - Field diagnosis, Excel basics
3. **VBA Automation** (Ch 3) - Pure VBA DSS implementation
4. **Evaluation** (Ch 4) - Case study results, performance metrics

**Narrative Rule:** Never say "The system calculates"; instead:
- "The system verifies the manual calculation"
- "The system proposes a value for validation"
- "The system automates the repetitive task of the professional"

---

## Administrative Reality

### Role Separation (Public Sector)

| Role | Responsibility | System Support |
|------|-----------------|----------------|
| **Storekeeper (Magasinier)** | Physical flow, stock entry | UserForms, Digital Ledger |
| **Accountant (Comptable)** | Financial validation | Reports, PDF generation |
| **Director** | Strategic decisions | Dashboard, KPIs |

### DSS Framing
- **NOT** an automated replacement for human roles
- **IS** a Decision Support System (Système d'Aide à la Décision)
- **Preserves** administrative hierarchy and accountability

---

## Session Continuity

### What to Load When Switching Contexts

| Context | Repomix File | Workspace |
|---------|---------------|-----------|
| Thesis Writing | `repomix-thesis.xml` | `Thesis_Surgical_Edit/` |
| VBA Coding | `repomix-software.xml` | `Software_Surgical_Edit/` |
| Full Project | `repomix-project.xml` | Root directory |

### Preventing Hallucinations
1. Use Repomix to isolate context (no cross-contamination)
2. Read `MANIFESTO.md` before any task
3. Check `MODEL_DISPATCH.md` for correct model
4. Verify El Bayadh constants before calculations

---

*End of Project Memory*
