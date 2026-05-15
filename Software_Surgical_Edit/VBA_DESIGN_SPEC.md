# VBA Design Specification Table — Academix v13.2

> **Architecture:** Offline-First, Pure VBA, Zero External Dependencies
> **Target:** Excel 2010 / Windows 7 — Public Sector Compliant
> **Institution:** Directorate of Education, El Bayadh

---

## §1 — Workbook Sheet Architecture (السجل الرقمي)

| # | Sheet Name (EN) | Sheet Name (AR) | Purpose | Key VBA Module | Data Flow |
|---|---|---|---|---|---|
| 1 | `ACCUEIL` | الرئيسية | Dashboard / Home — KPIs, workflow shortcuts, institution info | `mod_Dashboard.bas` | Reads from MOUVEMENTS, ARTICLES |
| 2 | `ARTICLES` | المواد | Master article catalog (12 items, ART-001 to ART-012) | `mod_StockEngine.bas` | Source of truth for all article lookups |
| 3 | `FOURNISSEURS` | الموردون | Supplier catalog with weighted evaluation (F-001 to F-003) | `mod_Procurement.bas` | Used in BC/BR generation |
| 4 | `CONVENTIONS` | الاصطلاحات | Naming conventions, document numbering rules (DA/BC/BR/BS) | `mod_Config.bas` | Reference only — not modified at runtime |
| 5 | `MOUVEMENTS` | الحركات | Core transaction ledger — all stock IN/OUT entries | `mod_StockEntry_Logic.bas` | Primary write target for all movements |
| 6 | `TABLEAU_DE_BORD` | لوحة الأداء | Performance dashboard — calculated KPIs from movements | `mod_Dashboard.bas` | Auto-refresh from MOUVEMENTS |
| 7 | `ALERTE_DASHBOARD` | لوحة التنبيهات | Stock alert dashboard — ROP/SS breach visualization | `mod_Analysis.bas` | Monitors ARTICLES vs MOUVEMENTS |
| 8 | `INVENTAIRE` | الجرد | Physical inventory count sheet | `mod_StockEngine.bas` | Comparison: physical vs system stock |
| 9 | `RAPPORTS` | التقارير | Report generation hub — summary exports | `mod_Reports.bas` | Aggregates from all data sheets |
| 10 | `CALCULS_EOQ` | حسابات EOQ | Economic Order Quantity calculations (Wilson formula) | `mod_Analysis.bas` | D=1,546, Q*=176, ROP=212.4, SS=200 |
| 11 | `HISTORIQUE` | السجل التاريخي | Archived movement history | `mod_Utilities.bas` | Long-term storage, read-only |
| 12 | `BON_RECEPTION` | وصل الاستلام | Reception form template (BR) | `mod_ReceiptTag.bas` | PDF export on BR generation |
| 13 | `BON_SORTIE` | وصل الخروج | Exit form template (BS) | `mod_ReceiptTag.bas` | PDF export on BS generation |
| 14 | `BON_COMMANDE` | أمر الشراء | Purchase order form template (BC) | `mod_Procurement.bas` | PDF export on BC generation |
| 15 | `DA_DEMANDE_ACHAT` | طلب الشراء | Purchase request form template (DA) | `mod_Procurement.bas` | PDF export on DA generation |
| 16 | `GUIDE` | الدليل | User guide — how to use the system | `mod_UI_Setup.bas` | Reference only |
| 17 | `VBA_MODULES` | وحدات المعالجة | VBA module documentation sheet | `mod_UI_Setup.bas` | Reference only |
| 18 | `AUDIT_LOG` | سجل المراجعة | Audit trail — all user actions logged | `mod_AuditTrail.bas` | Append-only write from all modules |
| 19 | `DASHBOARD` | اللوحة | Additional dashboard view | `mod_Dashboard.bas` | Reads from MOUVEMENTS |
| 20 | `FORM_INPUT` | إدخال البيانات | Data entry helper sheet | `mod_StockEntry_Logic.bas` | Temporary staging for UserForm |
| 21 | `BORDEREAU_COMMANDE` | سند الطلب | Order slip summary | `mod_Procurement.bas` | Aggregates BC data |
| 22 | `STAGING_BUFFER` | منطقة التخزين المؤقت | Local staging for batch operations (replaces staging_buffer.json) | `mod_StockEntry_Logic.bas` | Temporary — cleared after commit |
| 23 | `SYS_STRINGS` | سلاسل النظام | System strings / localization (FR/AR bilingual) | `mod_Localization.bas` | Reference only |
| 24 | `RECEIPT_TAG` | بطاقة الاستلام | Receipt tag template with verification code | `mod_ReceiptTag.bas` | PDF export with local verify code |
| 25 | `TEMPLATE_BON` | قالب السند | Generic form template | `mod_Utilities.bas` | Base template for document generation |

---

## §2 — VBA Module Inventory (وحدات المعالجة)

| Module | Type | Purpose | Key Functions | Dependencies |
|---|---|---|---|---|
| `MAIN_MACROS.bas` | Standard | Entry points / macro shortcuts | `Auto_Open()`, `ShowMainMenu()` | `mod_Navigation` |
| `mod_Config.bas` | Standard | System configuration & constants | `GetROP()`, `GetSS()`, `GetQStar()` | None |
| `mod_StockEngine.bas` | Standard | Core stock calculations | `GetStockLevel()`, `UpdateStock()`, `CheckNegative()` | `mod_Config`, `mod_AuditTrail` |
| `mod_StockEntry_Logic.bas` | Standard | Stock entry form logic | `ValidateEntry()`, `AddGridRow()`, `ComputeTotal()` | `mod_StockEngine`, `mod_Localization` |
| `mod_Dashboard.bas` | Standard | Dashboard rendering & KPI calc | `RefreshDashboard()`, `CalculateKPIs()`, `ShowAlerts()` | `mod_StockEngine`, `mod_Analysis` |
| `mod_Analysis.bas` | Standard | Analytical computations (EOQ, ABC) | `CalculateEOQ()`, `ABCClassify()`, `ROPCheck()` | `mod_Config`, `mod_StockEngine` |
| `mod_Procurement.bas` | Standard | Procurement document generation | `GenerateDA()`, `GenerateBC()`, `EvaluateSupplier()` | `mod_Config`, `mod_ExportEngine` |
| `mod_ReceiptTag.bas` | Standard | Receipt tag + verification code | `GenerateReceiptTagPDF()`, `GenerateLocalVerifyCode()` | `mod_Config`, `mod_ExportEngine` |
| `mod_Reports.bas` | Standard | Report aggregation & export | `GenerateStockReport()`, `GenerateMovementReport()` | `mod_StockEngine`, `mod_ExportEngine` |
| `mod_ExportEngine_v13_2.bas` | Standard | PDF/Excel export engine | `ExportToPDF()`, `ExportToExcel()` | None (pure VBA) |
| `mod_AuditTrail.bas` | Standard | Audit logging | `LogAuditEntry()`, `GetAuditTrail()` | `mod_Config` |
| `mod_Localization.bas` | Standard | FR/AR bilingual strings | `GetLocalizedString()`, `GetFieldName()` | `SYS_STRINGS` sheet |
| `mod_Navigation.bas` | Standard | Sheet navigation | `GoToSheet()`, `ShowWelcome()` | None |
| `mod_UI_Setup.bas` | Standard | UI initialization | `SetupAllSheets()`, `ApplyFormatting()` | `mod_Config` |
| `mod_Utilities.bas` | Standard | General utilities | `IsValidDate()`, `FormatCurrency()`, `CreateFolder()` | None |
| `mod_SheetSetup.bas` | Standard | Sheet creation & protection | `SetupProtectedSheet()`, `ApplyDataValidation()` | `mod_Config` |
| `mod_Backup.bas` | Standard | Workbook backup | `CreateBackup()`, `ListBackups()` | `mod_Utilities` |
| `mod_Restore.bas` | Standard | Backup restore | `RestoreFromBackup()`, `VerifyBackup()` | `mod_Backup` |
| `mod_LogViewer.bas` | Standard | Log viewing UserForm | `ShowLogViewer()`, `FilterLogs()` | `mod_AuditTrail` |
| `mod_SyncBridge.bas` | Standard | Internal sheet sync (replaces Python bridge) | `SyncSheets()`, `CommitStaging()` | `mod_StockEngine`, `mod_AuditTrail` |

---

## §3 — UserForm Inventory (استمارات العمل)

| Form | Purpose | Key Controls | Bound Module |
|---|---|---|---|
| `frmStockEntry` | Stock movement entry form | `txtDate`, `cmbArticle`, `cmbTypeDoc`, `txtQuantite`, `txtPrixUnitaire`, `lstGrid`, `btnEnregistrer`, `chkAuditTrail` | `mod_StockEntry_Logic` |
| `frmSystemLog` | System log viewer | `lstLogEntries`, `cmbFilter`, `btnRefresh` | `mod_LogViewer` |

---

## §4 — Data Flow & Documentary Chain (السلسلة الوثائقية)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   DA (طلب)  │────>│ Stock Check │────>│  BC (أمر)   │────>│  BR (وصل)   │────>│  BS (صرف)   │
│  Demand     │     │  Verification│     │  Order      │     │  Reception  │     │  Exit       │
│  d'Achat    │     │             │     │  d'Achat    │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                    │                    │                    │                    │
      ▼                    ▼                    ▼                    ▼                    ▼
  PDF Export          MOUVEMENTS           PDF Export          MOUVEMENTS          PDF Export
  DA_DEMANDE_ACHAT   sheet read            BON_COMMANDE        sheet write         BON_SORTIE
```

---

## §5 — Ground Truth Constants (الثوابت المرجعية)

| Constant | Value | Module | Sheet |
|---|---|---|---|
| Annual Demand (D) | 1,546 units | `mod_Config.bas` | `CALCULS_EOQ` |
| Reorder Point (ROP) | 212.4 units | `mod_Config.bas` | `CALCULS_EOQ` |
| Safety Stock (SS) | 200 units | `mod_Config.bas` | `CALCULS_EOQ` |
| Economic Order Qty (Q*) | 176 units | `mod_Analysis.bas` | `CALCULS_EOQ` |
| Lead Time (LT) | 2 days | `mod_Config.bas` | `CALCULS_EOQ` |
| Case Study Article | ART-001 (Toner G030) | All modules | `ARTICLES` |

---

## §6 — Style Mapping (HTML .flx → Excel Styles)

| flx Class | Background | Color | Size | Weight | Usage |
|---|---|---|---|---|---|
| `.flx1` | #176b30 (green) | white | 16pt | bold | Main title banner |
| `.flx2` | #37474f (dark) | white | 10pt | italic | Subtitle / version info |
| `.flx6` | #0c3547 (navy) | white | 11pt | bold | Section header |
| `.flx25` | #176b30 (green) | white | 13pt | bold | Sheet title (ARTICLES) |
| `.flx27/.flx28` | #176b30 (green) | white | 9pt | bold | Column headers |
| `.flx29` | #fcebeb (red tint) | black | 11pt | bold | Data cell — ART-001 |
| `.flx31` | #ffc7ce (red) | #9c0006 | 11pt | bold | Alert/rupture indicator |
| `.flx44` | #eaf3de (green tint) | black | 11pt | bold | Data cell — standard |
| `.flx51` | #0c3547 (navy) | white | 13pt | bold | Sheet title (FOURNISSEURS) |
| `.flx57` | white | black | 14pt | bold | Sheet title (CONVENTIONS) |
| `.flx83` | #c8c8c8 (gray) | white | 12pt | bold | Section divider |

---

## §7 — Guard Chain (سلسلة الحماية)

Execution order on **AJOUTER LIGNE** (Add Line):

| # | Guard | Condition | Action on Fail | Thesis Finding |
|---|---|---|---|---|
| 1 | Date format | `IsValidDate(txtDate)` | Stop + focus | — |
| 2 | Ref mandatory | `Len(txtRefDoc) > 0` | Stop + focus | Phantom stock root cause |
| 3 | Article selected | `m_CurrentArticle ≠ ""` | Stop | — |
| 4 | Article in master | `m_StockActuel ≠ -1` | Stop | — |
| 5 | Qty > 0 | `IsNumeric + CLng > 0` | Stop + focus | — |
| 6 | PU for BR | `m_IsBRMode → PU > 0` | Stop + focus | CMUP accuracy |
| 7 | Negative stock | `stock - gridQty - qty ≥ 0` | Stop + MsgBox detail | Core ERP guard |
| 8 | ROP breach | `projected ≤ ROP=212.4` | YesNo confirm → continue/abort | Canonical ROP alert |

---

## §8 — Cleanup Status (حالة التنظيف)

| Item | Status | Notes |
|---|---|---|
| Python/Flask removal | ✅ Complete | All `.py` files moved to `_Legacy_Archive` |
| JSON dependency removal | ✅ Complete | `stock_ledger.json` → `STAGING_BUFFER` sheet |
| External API removal | ✅ Complete | `mod_ReceiptTag.bas` QR API → local `GenerateLocalVerifyCode()` |
| .bak file cleanup | ✅ Complete | `frmStockEntry.frm.bak`, `mod_StockEntry_Logic.bas.bak` removed |
| Spec table update | ✅ Complete | `frmStockEntry_spec_table.html` — Python refs → Audit Trail |
| Terminology mapping | ✅ Complete | Database → السجل الرقمي, Backend → وحدات المعالجة VBA |
| Constants sync | ✅ Complete | D=1,546, ROP=212.4, SS=200, Q*=176, LT=2 |

