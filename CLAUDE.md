# Academix v13.2 — ERP Académie

**نظام إلكتروني متكامل للتسيير التمويني** — Integrated Electronic Inventory Management System

Direction de l'Éducation, Wilaya de El Bayadh, Algeria

---

## Project Identity

| Field | Value |
|-------|-------|
| **Name** | Academix v13.2 |
| **Type** | Pure VBA Excel Decision Support System (DSS) |
| **Architecture** | Offline-First, Zero External Dependencies |
| **Sheets** | 25 |
| **Modules** | 37 (clean — no dead code) || **Compliance** | CNEPD BTS Public Sector Standards |
| **Locale** | fr-FR (UI) / ar-DZ (thesis) |

## Ground Truth — NEVER MODIFY

| Parameter | Value | Description |
|-----------|-------|-------------|
| **D** (Annual Demand) | 1,546 | From 38-day MOUVEMENTS observation |
| **Q*** (EOQ) | 176 | Wilson formula: √(2DS/Ih) |
| **ROP** (Reorder Point) | 205.6 | (D/250) × LT + SS |
| **SS** (Safety Stock) | 200 | (MaxDaily - AvgDaily) × LT |
| **LT** (Lead Time) | 2 days | Default delivery time |
| **S** (Order Cost) | 500 DZD | Fixed cost per order |
| **I** (Holding Rate) | 20% | Annual holding cost |
| **MASTER_PWD** | erp_secure_pwd_2026 | Sheet protection |
| **VERSION** | v13.2 | Current software version |

## AI Backend (100% Free & Open-Source)

| Provider | Model | Role | Response |
|----------|-------|------|----------|
| **Groq (Primary)** | llama-3.3-70b-versatile | Arabic prose, VBA logic | ~2s (cloud) |
| **Groq (Fast)** | qwen/qwen3-32b | Explore, debug, audit | ~1s (cloud) |
| **Google** | gemini-2.5-flash | Large context (1M), vision, deep reasoning | ~2s (cloud) |
| **OpenRouter** | nemotron-3-super-120b | 1M context (429-limited) | ~3s (cloud) |
| **Ollama (CPU)** | phi4-mini:3.8b | Offline coding | ~25s (local) |
| **Ollama (CPU)** | qwen3:1.7b | Offline reasoning | ~40s (local) |
| **Ollama (CPU)** | qwen2.5-coder:1.5b | Offline fallback | ~95s (local) |

## Default Model
- `opencode/big-pickle` — CLI default (daily driver)

## Thesis Constraints

- **Hierarchy:** فصل → مبحث → مطلب → أولاً، ثانياً...
- **Forbidden:** NO `فرع` (Branch) in thesis structure
- **Terminology:**
  - ❌ Database → ✅ السجل الرقمي (Digital Ledger)
  - ❌ Python/Backend → ✅ وحدات المعالجة VBA
  - ❌ Hybrid System → ✅ نظام إلكتروني متكامل

## VBA Modules (37 — All Clean)

**Critical:** mod_Config, mod_StockEngine, mod_StockEntry_Logic, mod_TransactionSafety
**High:** mod_SyncBridge, mod_Dashboard, mod_ExportEngine, mod_Utilities, mod_Reports, mod_Database, mod_AuditTrail, mod_ReceiptTag, mod_QRCode, mod_SharedEnvironment, mod_InventoryReconciliation, mod_SupplierScorecard, mod_SupplierRegistry, mod_StockAging, mod_StockOutPredictor, mod_Forecasting, mod_DataValidator, mod_DemoData, mod_Barcode, mod_CSVImportExport, mod_EntryPoints, mod_ThemingEngine
**Medium:** mod_SheetSetup, mod_Procurement, mod_Analysis, mod_Localization, mod_ApprovalWorkflow, mod_Navigation, mod_Budget, mod_BudgetSetup, mod_UIEnhancements
**Low:** mod_UI_Setup

**Dead code DELETED:** Module1, Module2, mod_Config_Test, mod_StockEntry_Logic_Enhanced, mod_TestHarness, frmSystemLog, frmStockEntry_Enhanced (7 total)

## Admin Paths

| Key | Path |
|-----|------|
| Project Root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` |
| VBA Modules | `Software_Surgical_Edit\VBA_Modules\` |
| Context XML | `Software_Surgical_Edit\erp-project-context.xml` |
| Workbook | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` |
| Git | `https://github.com/kamelmh/logistics-public-sector-refactor` (master) |

## Warnings Status — ALL RESOLVED

W001 ✅ · W002 ✅ · W003 ✅ · W004 ✅ · W005 ✅ · W006 ✅ · W007 ✅ · W008 ✅ · W009 ✅ · W010 ✅
