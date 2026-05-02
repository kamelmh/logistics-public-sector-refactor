---
title: Terminology Mapping
type: glossary
last_updated: 2026-05-02
tags: [terminology, translation, tech-to-admin, arabic]
---

# Terminology Mapping (Tech → Administrative)

## Mandatory Translation Table

AI Agents must **automatically** translate technical concepts into administrative equivalents when writing thesis or documentation.

---

## Core Terminology

### System & Architecture

| Technical Term (❌ FORBIDDEN) | Administrative Equivalent (✅ REQUIRED) | Arabic Translation |
|-------------------------------|------------------------------------------|-------------------|
| Database | Digital Ledger | السجل الرقمي / دفاتر البيانات |
| Python Backend / Engine | VBA Processing Units | وحدات المعالجة VBA |
| Hybrid System / Web App | Excel-based Decision Support System | نظام دعم قرار مبني على Excel |
| Mini-ERP | Stock Management DSS | نظام دعم القرار لتسيير المخزون |
| Algorithm | Mathematical Model | النموذج الرياضي |
| API | (Avoid entirely) | واجهة الربط (use only if necessary) |
| JSON | (Avoid entirely) | تنسيق البيانات |
| Flask / Web Framework | (Avoid entirely) | محرك الويب |
| UserForms (in thesis) | Work Forms / Input Templates | استمارات العمل / نماذج الإدخال |
| User Interface | Work Interface | واجهة العمل |
| Frontend | User Interface | واجهة المستخدم |
| Backend | Processing Units | وحدات المعالجة |

---

## Stock Management Terms

| Technical Term (❌) | Administrative (✅) | Arabic |
|---------------|--------------------|--------|
| Inventory | Stock / Ledger | المخزون / السجل |
| Item / Product | Article | المادة |
| Stock Level | Stock Status | حالة المخزون |
| Reorder Point | Reorder Limit | حد إعادة الطلب |
| Safety Stock | Safety Reserve | الاحتياطي الأمني |
| Economic Order Quantity | Economic Order Size | حجم الطلب الاقتصادي |
| Lead Time | Supply Period | أجل التوريد |
| Stock Entry | Receipt | الاستلام |
| Stock Exit | Delivery | التسليم |
| Supplier | Provider | المورد |
| Storekeeper | Storekeeper (Magasinier) | المخزني |
| Accountant | Accountant (Comptable) | المحاسب |

---

## Documents & Reports

| Technical Term (❌) | Administrative (✅) | Arabic |
|---------------|--------------------|--------|
| Invoice | Receipt Document | وثيقة الاستلام |
| Purchase Order | Purchase Request | طلب الشراء |
| Delivery Note | Delivery Document | وثيقة التسليم |
| Stock Card | Stock Ledger | بطاقة المخزون |
| Report | Official Report | التقرير الرسمي |
| Dashboard | Command Dashboard | لوحة القيادة |
| Audit Trail | Tracking Record | سجل التتبع |
| Backup | Data Preservation | حفظ البيانات |

---

## VBA-Specific Terms

| Technical Term (❌) | Administrative (✅) | Arabic |
|---------------|--------------------|--------|
| Module (.bas) | Processing Unit | وحدة المعالجة |
| Form (.frm) | Work Form | استمارة العمل |
| Sheet | Digital Ledger Page | صفحة السجل الرقمي |
| Macro | Automated Procedure | الإجراء المؤتمت |
| Array | Data Table | جدول البيانات |
| Function | Calculation Unit | وحدة الحساب |
| Sub | Execution Procedure | إجراء التنفيذ |

---

## Thesis Writing Rules

### When Writing Thesis (Chapter 1-4)

1. **NEVER use:** Database, Python, Algorithm, API, JSON, Flask, Hybrid System
2. **ALWAYS use:** السجل الرقمي, وحدات المعالجة VBA, النموذج الرياضي
3. **Narrative style:** "The system verifies..." NOT "The system calculates..."
4. **Tone:** Formal Academic Arabic (RTL)

### Example Transformations

| Technical Sentence (❌) | Administrative Sentence (✅) |
|--------------------------|---------------------------|
| "The system calculates EOQ using Python" | "النظام يتحقق من حجم الطلب الاقتصادي باستخدام وحدات المعالجة VBA" |
| "The database stores articles" | "السجل الرقمي يحفظ المواد" |
| "The algorithm optimizes stock" | "النموذج الرياضي يحسن المخزون" |
| "The API connects to supplier" | "واجهة الربط تصل بالمورد" (avoid APIs entirely!) |

---

## Code Comments (VBA Modules)

### In VBA Code (English OK, but Arabic in thesis)

```vb
' Good (for VBA code - English comments OK)
Function CalculateEOQ(D As Double, S As Double, H As Double) As Double
    CalculateEOQ = Sqr((2 * D * S) / H)
End Function

' BUT in Thesis Chapter 3:
' "تقوم وحدة المعالجة بحساب حجم الطلب الاقتصادي استناداً إلى النموذج الرياضي"
' (NOT: "The algorithm calculates EOQ...")
```

---

## Quick Reference Card

### Most Common Mistakes

| ❌ Wrong | ✅ Correct |
|----------|----------|
| Database | السجل الرقمي |
| Python | وحدات المعالجة VBA |
| Algorithm | النموذج الرياضي |
| Branch (فرع) | مبحث (Section) |
| API | (avoid entirely) |
| JSON | (avoid entirely) |
| Hybrid | نظام دعم القرار مبني على Excel |

---

## Agent Instructions

### When Agent Detects Wrong Terminology

```
⚠️ TERMINOLOGY VIOLATION: Administrative terminology required
→ Detected: {Database/Algorithm/Hybrid/Python}
→ Correct: {السجل الرقمي/النموذج الرياضي/نظام دعم القرار/وحدات المعالجة VBA}
→ Reference: TERMINOLOGY_MAPPING.md
→ Workspace: Thesis_Surgical_Edit (Arabic RTL)
```

### Auto-Correction Protocol

1. Agent detects technical term in thesis context
2. Agent checks `TERMINOLOGY_MAPPING.md`
3. Agent replaces with administrative equivalent
4. Agent warns user of correction
5. Agent logs to `logs/ALIGNMENT_LOG.md`

---

## Cross-Reference

| File | Purpose |
|------|---------|
| MANIFESTO.md | Core rules (Section 2: Terminology Mapping) |
| CNEPD_STANDARDS.md | Compliance requirements |
| PROJECT_MEMORY.md | Project context & constants |
| EL_BAYADH_DATASET.md | Case study data |

---

*End of Terminology Mapping*
