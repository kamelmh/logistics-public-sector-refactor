---
title: Chapter 3 - Design & Methodology
type: thesis
chapter: 3
status: pending
last_updated: 2026-05-02
tags: [thesis, chapter-3, design, vba, dss]
---

# الفصل الثالث: التصميم والمنهجية

## المبحث الأول: تصميم نظام دعم القرار

### المطلب الأول: وحدات المعالجة VBA

#### أولاً: محرك المخزون (mod_StockEngine.bas)

```vb
' النموذج الرياضي في VBA
Function CalculateEOQ(D As Double, S As Double, H As Double) As Double
    CalculateEOQ = Sqr((2 * D * S) / H)
End Function

' للوحدة Toner G030:
' D = 1546 وحدة/سنة
' النتيجة المتوقعة: 176 وحدة
```

#### ثانياً: محرك التصدير (mod_ExportEngine.bas)

[يتم كتابة كود PDF generation هنا]

### المطلب الثاني: واجهة العمل (UserForms)

#### أولاً: استمارة إدخال المخزون (frmStockEntry.frm)

[يتم كتابة وصف الاستمارة هنا]

#### ثانياً: تأمين سجل التدقيق

[يتم كتابة نظام التدقيق هنا]

---

## المبحث الثاني: المنهجية

### المطلب الأول: السجل الرقمي (Digital Ledger)

#### أولاً: هيكلية الأوراق

| ورقة العمل | العربية | الغرض |
|------------|----------|---------|
| tbl_Inventory | جرد المخزون | مستويات المخزون الحالية |
| tbl_Movements | حركات المخزون | كل الحركات IN/OUT |
| tbl_Articles | المواد | بيانات المواد الأساسية |

#### ثانياً: تأمين البيانات

[يتم كتابة نظام الحفظ والاستعادة هنا]

---

*Chapter 3 - Pending Completion*
