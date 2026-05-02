---
title: CNEPD Standards Compliance
type: compliance
last_updated: 2026-05-02
tags: [cnepd, bts, standards, algerian-public-sector]
---

# CNEPD Standards Compliance (BTS)

**CNEPD:** Centre National des Études et de la Planification du Développement  
**BTS:** Brevet de Technicien Supérieur (Algerian Public Sector)  
**Project:** Academix v13.2 - Stock Management DSS

---

## Structural Hierarchy (Non-Negotiable)

### Thesis Structure (فصل → مبحث → مطلب)

```
فصل 1 (Chapter 1): الإطار النظري والمفاهيمي
    └── مبحث 1 (Section 1): [Topic]
        └── مطلب 1 (Requirement 1): [Topic]
            └── أولاً (First): [Sub-topic]
            └── ثانياً (Second): [Sub-topic]

فصل 2 (Chapter 2): التشخيص والميدان
    └── مبحث 1: [Topic]
        └── مطلب 1: [Topic]
            └── أولاً: [Sub-topic]

فصل 3 (Chapter 3): التصميم والمنهجية
    └── مبحث 1: [Topic]
        └── مطلب 1: [Topic]

فصل 4 (Chapter 4): النتائج والتقييم
    └── مبحث 1: [Topic]
        └── مطلب 1: [Topic]
```

**FORBIDDEN:** The word `فرع` (Branch) is BANNED from structure.

---

## Language Requirements

### Formal Academic Arabic (RTL)

| Aspect | Requirement | Example |
|--------|-------------|---------|
| **Tone** | Formal, administrative | "نظام دعم القرار" NOT "System" |
| **Direction** | RTL (Right-to-Left) | Use Arabic script |
| **Terminology** | Administrative, NOT technical | السجل الرقمي NOT Database |
| **Citations** | CNEPD footnotes (تهميش) | Bottom of each page |
| **Style** | Academic, professional | Zero colloquialisms |

---

## Terminology Mapping (Mandatory)

### Tech → Administrative Translation

| Technical Term (❌ FORBIDDEN) | Administrative (✅ REQUIRED) |
|-------------------------------|--------------------------------|
| Database | السجل الرقمي (Digital Ledger) / دفاتر البيانات |
| Python Backend / Engine | وحدات المعالجة VBA (VBA Processing Units) |
| Hybrid System / Web App | نظام دعم قرار مبني على Excel |
| Mini-ERP | نظام دعم القرار لتسيير المخزون |
| UserForms (in thesis) | استمارات العمل / نماذج الإدخال |
| Algorithm | النموذج الرياضي |
| API | واجهة الربط (if absolutely needed) |
| JSON | تنسيق البيانات (avoid entirely) |
| Flask / Web Framework | محرك الويب (avoid entirely) |

---

## Pedagogical Ladder (The "Ladder Logic")

### Progressive Complexity (Required by CNEPD)

**Level 1: Manual Science (Chapter 1)**
- Prove mathematical competence
- Manual stock management calculations
- EOQ, ROP, SS formulas derivation

**Level 2: Semi-Automated (Chapter 2)**
- Field diagnosis
- Excel basics for inventory
- Paper-based to digital transition

**Level 3: VBA Automation (Chapter 3)**
- Pure VBA DSS implementation
- UserForms for data entry
- Digital Ledger (السجل الرقمي)

**Level 4: Evaluation (Chapter 4)**
- Case study results (Toner G030)
- Performance metrics
- Cost-benefit analysis

**Narrative Rule:** Never say "The system calculates"; instead:
- "The system verifies the manual calculation"
- "The system proposes a value for validation"
- "The system automates the repetitive task of the professional"

---

## Administrative Reality (Public Sector)

### Role Separation (Preserved by DSS)

| Role | Arabic Title | Responsibility | System Support |
|------|---------------|----------------|---------------|
| **Storekeeper** | المخزني (Magasinier) | Physical flow, stock entry | UserForms, Digital Ledger |
| **Accountant** | المحاسب (Comptable) | Financial validation | Reports, PDF generation |
| **Director** | المدير | Strategic decisions | Dashboard, KPIs |

### DSS Framing (NOT Automation Replacement)

- **NOT** an automated replacement for human roles
- **IS** a Decision Support System (Système d'Aide à la Décision)
- Preserves administrative hierarchy and accountability

---

## Documentation Standards

### Citations (تهميش - Footnotes)

**Format:** Standard CNEPD footnotes at bottom of each page  
**Style:** Academic Arabic (RTL)  
**Location:** Bottom of each page (NOT endnotes)

### Tables & Figures

- **Table of Contents (TOC):** Auto-generated, 4 chapters
- **List of Tables:** Numbered sequentially
- **List of Figures:** Numbered sequentially
- **Page Numbers:** Bottom center, RTL format

---

## Jury Expectations (التوقعات)

### What They Want (Public Sector Reality)

✅ Traditional administrative approach  
✅ Zero "tech startup" terminology  
✅ Compliance with CNEPD hierarchy  
✅ Manual → Automation progression (ladder logic)  
✅ Standard Microsoft tools (Excel/VBA only)  
✅ Zero cost solution (no external dependencies)  
✅ Accountability & audit trails  

### What They Reject (Automatic Failure)

❌ Python, Flask, JSON, APIs  
❌ Term "Database" (use السجل الرقمي)  
❌ Term "Branch" (فرع) in structure  
❌ Tech jargon in thesis  
❌ Overly complex "Ferrari" solutions  
❌ Modern web frameworks  

---

## Compliance Checklist

Before submitting to jury:

- [ ] 4 chapters ONLY (6-chapter rejected)
- [ ] Hierarchy: فصل → مبحث → مطلب → أولاً، ثانياً
- [ ] NO `فرع` (Branch) anywhere
- [ ] Formal Academic Arabic (RTL)
- [ ] CNEPD footnotes on every page
- [ ] Tech terms → Administrative equivalents
- [ ] Pure VBA (NO Python/Flask/JSON/APIs)
- [ ] Pedagogical ladder (Manual → Automation)
- [ ] El Bayadh case study (Toner G030)
- [ ] Ground truth constants (D=1546, Q*=176, ROP=205.6, SS=200)
- [ ] Digital Ledger (NOT "Database")
- [ ] VBA Processing Units (NOT "Python backend")
- [ ] DSS framing (NOT automation replacement)
- [ ] Audit trail & accountability features
- [ ] Zero external dependencies

---

## Cross-Reference Files

| File | Purpose | Path |
|------|---------|------|
| Manifesto | Core rules & constraints | `ai-alignment/MANIFESTO.md` |
| Terminology Mapping | Tech → Admin translations | `project-understanding/TERMINOLOGY_MAPPING.md` |
| Project Memory | Ground truth & constants | `project-understanding/PROJECT_MEMORY.md` |
| El Bayadh Dataset | Case study data | `project-understanding/EL_BAYADH_DATASET.md` |
| Thesis Outline | 4-chapter structure | `Thesis_Surgical_Edit/THESIS_CHAPTER_OUTLINE.md` |

---

*End of CNEPD Standards Document*
