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
| **Modules** | 27 (clean — no dead code) |
| **Compliance** | CNEPD BTS Public Sector Standards |
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

## Thesis Constraints

- **Hierarchy:** فصل → مبحث → مطلب → أولاً، ثانياً...
- **Forbidden:** NO `فرع` (Branch) in thesis structure
- **Terminology:**
  - ❌ Database → ✅ السجل الرقمي (Digital Ledger)
  - ❌ Python/Backend → ✅ وحدات المعالجة VBA
  - ❌ Hybrid System → ✅ نظام إلكتروني متكامل

## VBA Modules (27 — All Clean)

**Critical:** `mod_Config`, `mod_StockEngine`, `mod_StockEntry_Logic`
**High:** `mod_SyncBridge`, `mod_Dashboard`, `mod_ExportEngine`, `mod_Utilities`, `mod_Reports`, `mod_Database`, `mod_AuditTrail`, `mod_ReceiptTag`
**Medium:** `mod_SheetSetup`, `mod_Procurement`, `mod_Restore`, `mod_Backup`, `mod_Analysis`, `mod_Localization`, `mod_ApprovalWorkflow`, `mod_StockCalculations`
**Low:** `mod_UI_Setup`, `mod_LogViewer`, `modNavigation`, `mod_BonLivraison`, `mod_Budget`, `mod_Facture`

**Dead code DELETED:** Module1, Module2, mod_Config_Test (2026-05-06)

## Admin Paths

| Key | Path |
|-----|------|
| Project Root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` |
| VBA Modules | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\VBA_Modules\` |
| Context XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-project-context.xml` |
| Workbook | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` |
| Git | `https://github.com/kamelmh/logistics-public-sector-refactor` (master) |

## AI Context Trigger

Type at session start:
```
ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
```
This loads: all XML context files, admin paths, ground truth, skills, and agentic protocols from `.opencode/context.md`.

## AI Backend

| Provider | Model | Response |
|----------|-------|----------|
| **Groq (Primary)** | qwen/qwen3-32b | ~1 second (cloud) |
| **Ollama (Fallback)** | qwen2.5-coder:1.5b | ~108 seconds (local HDD) |

## Warnings Status — ALL RESOLVED

W001 ✅ · W002 ✅ · W003 ✅ · W004 ✅ · W005 ✅ · W006 ✅ · W007 ✅ · W008 ✅ · W009 ✅ · W010 ✅

## Thesis Progress

| Chapter | Status |
|---------|--------|
| Ch1 — Theoretical framework | ✅ DONE |
| Ch2 — Institution presentation | ✅ DONE |
| Ch3 — Field diagnosis + ABC/Wilson/CMUP | ✅ DONE |
| Ch4 — Mini ERP solution + results | ✅ DONE (Draft_Chapter4_Implementation.md) |
| Front matter | ✅ DONE |

**Supervisor:** دهيني ميمونة (مصلحة الميزانيات والاقتصاد)

## Cross-Agent Protocol

1. Read `erp-project-context.xml` FIRST
2. Check dependencies before code changes
3. Update `erp-project-context.xml` after changes
4. Work on copy in `$env:TEMP`, then deploy to Dropbox
5. Never modify mod_Config constants or CANON_* values
6. Never remove sheet protection without re-protecting
7. Never commit without explicit user approval
