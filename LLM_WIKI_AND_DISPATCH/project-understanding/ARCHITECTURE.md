---
title: VBA DSS Architecture
type: architecture
last_updated: 2026-05-02
tags: [vba, dss, architecture, digital-ledger]
---

# VBA DSS Architecture (Academix v13.2)

## System Overview

**Type:** Decision Support System (DSS) - نظام دعم القرار  
**Platform:** Microsoft Excel + VBA (Pure, No External Dependencies)  
**Compliance:** CNEPD BTS Standards (Algerian Public Sector)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    EXCEL WORKBOOK                       │
│  (ERP_Academie_v13_Master.xlsm)                    │
├─────────────────────────────────────────────────────────┤
│                     VBA LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │
│  │Processing Units│  │ UserForms    │  │Reports  │ │
│  │(وحدات المعالجة)│  │(استمارات    │  │(تقارير) │ │
│  └──────────────┘  └──────────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────┤
│                    DATA LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │
│  │Digital Ledger │  │ Stock Sheets │  │Config   │ │
│  │(السجل الرقمي)│  │(جرد مخزني)  │  │(إعدادات)│ │
│  └──────────────┘  └──────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## VBA Processing Units (وحدات المعالجة VBA)

### Core Modules

| Module | Arabic Name | Purpose |
|--------|-------------|---------|
| `mod_StockEngine.bas` | محرك المخزون | EOQ, ROP, SS calculations |
| `mod_ExportEngine.bas` | محرك التصدير | PDF generation (Bon de Réception, etc.) |
| `mod_Database.bas` | إدارة السجل الرقمي | Digital Ledger management |
| `mod_Reports.bas` | التقارير | Dashboard, KPIs, audit trails |
| `mod_Utilities.bas` | وظائف مساعدة | Helper functions |
| `mod_Config.bas` | الإعدادات | System configuration |
| `mod_AuditTrail.bas` | سجل التدقيق | Track all changes |
| `mod_Backup.bas` | النسخ الاحتياطي | Auto-backup functionality |
| `mod_Restore.bas` | الاستعادة | Data restoration |
| `mod_SyncBridge.bas` | جسر التزامن | Local sheet storage sync |
| `mod_Procurement.bas` | المشتريات | Purchase order generation |
| `mod_ReceiptTag.bas` | وسوم الاستلام | Receipt labeling |
| `mod_Dashboard.bas` | لوحة القيادة | Stock Critique dashboard |
| `mod_LogViewer.bas` | عارض السجل | View audit trails |
| `mod_Localization.bas` | التعريب | Arabic RTL support |
| `mod_Navigation.bas` | التنقل | Menu navigation |
| `mod_SheetSetup.bas` | إعداد الأوراق | Auto-create sheets |
| `mod_Analysis.bas` | التحليل | Data analysis (VBA arrays only) |
| `mod_UI_Setup.bas` | واجهة المستخدم | UI initialization |

---

## UserForms (استمارات العمل)

| Form | Arabic Name | Purpose |
|------|-------------|---------|
| `frmStockEntry.frm` | استمارة إدخال المخزون | Stock entry form |
| `frmSystemLog.frm` | سجل النظام | System log viewer |
| `frmStockEntry` (spec) | جدول المواصفات | HTML spec table |

**Security Features:**
- Prevents raw cell deletion
- Role-based access (Storekeeper vs. Accountant)
- One-click official PDF generation

---

## Digital Ledger (السجل الرقمي)

### Sheet Structure

| Sheet Name | Arabic Name | Purpose |
|------------|-------------|---------|
| `tbl_Inventory` | جرد المخزون | Current stock levels |
| `tbl_Movements` | حركات المخزون | All IN/OUT movements |
| `tbl_Articles` | المواد | Article master data |
| `tbl_Suppliers` | الموردون | Supplier information |
| `tbl_Receipts` | وصولات الاستلام | Bon de Réception records |
| `tbl_Deliveries` | وصولات التسليم | Bon de Sortie records |
| `tbl_Config` | الإعدادات | System parameters |
| `tbl_AuditTrail` | سجل التدقيق | All changes log |

---

## Calculation Engine (النموذج الرياضي)

### EOQ Calculation (Economic Order Quantity)

```vb
' mod_StockEngine.bas
Function CalculateEOQ(D As Double, S As Double, H As Double) As Double
    ' D = Annual Demand (1,546 units)
    ' S = Ordering Cost (per order)
    ' H = Holding Cost (per unit per year)
    CalculateEOQ = Sqr((2 * D * S) / H)
    ' Expected result for Toner G030: 176 units
End Function
```

### ROP Calculation (Reorder Point)

```vb
Function CalculateROP(d As Double, LT As Double, SS As Double) As Double
    ' d = Daily Demand (D/365)
    ' LT = Lead Time (2 days)
    ' SS = Safety Stock (200 units)
    CalculateROP = (d * LT) + SS
    ' Expected result for Toner G030: 205.6 units
End Function
```

---

## Dashboard (لوحة القيادة)

### Stock Critique (الجرد النقدي)

| Indicator | Status | Action |
|-----------|--------|--------|
| Stock > ROP + SS | ✅ Normal | No action |
| Stock  ROP | ⚠️ Warning | Prepare to reorder |
| Stock ≤ ROP | 🔴 Critical | **REORDER NOW** |
| Stock ≤ SS | 🚨 Emergency | **URGENT ORDER** |

---

## Data Flow (تدفق البيانات)

```
User Input (UserForm)
    ↓
Validation (VBA)
    ↓
Update Digital Ledger (Sheet)
    ↓
Recalculate (EOQ/ROP)
    ↓
Update Dashboard
    ↓
Generate PDF (if needed)
```

---

## Security & Integrity

### Access Control
- **Storekeeper (Magasinier):** Stock entry, movements
- **Accountant (Comptable):** Reports, financial validation
- **Director:** Dashboard, KPIs

### Audit Trail (سجل التدقيق)
- Every change logged to `tbl_AuditTrail`
- Timestamp, user, old value, new value
- No deletion - only soft deletes (flag as inactive)

---

## Integration Points

### With Thesis (Ch 3 & 4)
- VBA code maps to Chapter 3 (Design & Methodology)
- Case study results map to Chapter 4 (Results & Evaluation)
- Toner G030 (ART-001) data used throughout

### With El Bayadh Case Study
- All calculations use ground truth data
- D=1,546, ROP=205.6, SS=200, Q*=176, LT=2

---

*End of Architecture Document*
