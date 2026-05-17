# Academix v13.2 — Master Context (Loaded Every Session)
# AI: Groq Llama 3.3 70B (primary) + Qwen3 32B (fast) + Gemma 4 26B (multimodal) + Gemma 4 e2b (local)
# User: Mahi Kamel Abdelghani | El Bayadh, Algeria
# Project: ERP Académie — Direction de l'Education, Wilaya de El Bayadh
# Stack: Pure VBA Excel .xlsm | Offline-First | Zero External Dependencies | 100% Free & Open-Source

## ⚡ BOOTSTRAP PROTOCOL — DO THIS EVERY SESSION
1. Read `.opencode\bootstrap\MASTER_BOOTSTRAP.xml` (uber-context — project, paths, agents, pipelines)
2. Read `.opencode\erp-context-compact.md` (token-optimized snapshot — 9.6KB, covers all 4 XMLs + backends + skills)
3. Read `C:\Users\Administrator\.opencode\notepad.md` (session memory — last actions, state)
4. Run `/memory list` to recall OMC checkpoint
5. Call `skill` tool to load your agent-type skills (see AGENTS.md or MASTER_BOOTSTRAP.xml) — note VBA skills exist only on disk, not in global catalog
6. If disconnected: run `/memory recall 0` then resume from notepad.md last-action

## GROUND TRUTH — NEVER MODIFY
| Constant | Value | Description |
|----------|-------|-------------|
| D (Annual Demand) | 1,546 | From 38-day MOUVEMENTS observation |
| Q* (EOQ) | 176 | √(2×1546×500 / 0.20×PU) |
| ROP (Reorder Point) | 205.6 | (1546/250)×2 + 200 |
| SS (Safety Stock) | 200 | (MaxDaily − AvgDaily)×2 |
| LT (Lead Time) | 2 days | Default delivery |
| S (Order Cost) | 500 DZD | Fixed per order |
| I (Holding Rate) | 20% | Annual |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection |

## ARCHITECTURE
- **Pure VBA only** — NO Python, NO Flask, NO external APIs, NO databases
- 25 sheets, 36 .bas + 1 .frm + ThisWorkbook = 38 components, 0 compile errors
- Locale: French (column headers, tab names) / Arabic MSA (thesis)
- Compliance: CNEPD BTS Public Sector Standards

## 25 SHEETS
ACCUEIL | ARTICLES | FOURNISSEURS | CONVENTIONS | MOUVEMENTS | TABLEAU_DE_BORD | ALERTE_DASHBOARD | INVENTAIRE | RAPPORTS | CALCULS_EOQ | HISTORIQUE | BON_RECEPTION | BON_SORTIE | BON_COMMANDE | DA_DEMANDE_ACHAT | GUIDE | VBA_MODULES | AUDIT_LOG | DASHBOARD | FORM_INPUT | BORDEREAU_COMMANDE | STAGING_BUFFER | SYS_STRINGS | RECEIPT_TAG | TEMPLATE_BON

## 36 VBA MODULES
- **Critical:** mod_Config, mod_StockEngine, mod_StockEntry_Logic (FormState struct pattern), mod_TransactionSafety
- **High:** mod_SyncBridge, mod_Dashboard, mod_ExportEngine, mod_Utilities, mod_Reports, mod_Database, mod_AuditTrail, mod_ReceiptTag, mod_QRCode, mod_BudgetSetup, mod_SharedEnvironment, mod_InventoryReconciliation, mod_SupplierScorecard
- **Medium:** mod_SheetSetup, mod_Procurement, mod_Analysis, mod_Localization, mod_ApprovalWorkflow, mod_Forecasting, mod_SupplierRegistry, mod_ThemingEngine, mod_UIEnhancements, mod_DemoData, mod_Barcode, mod_CSVImportExport, mod_DataValidator, mod_StockAging, mod_StockOutPredictor
- **Low:** mod_UI_Setup, mod_Navigation, mod_Budget

## TRANSACTION DATA FLOW
frmStockEntry → mod_StockEntry_Logic.btnEnregistrer_Click → mod_Database.SecureWriteTransaction → MOUVEMENTS
  → mod_SyncBridge.SyncTransactionInternal → mod_StockEngine (CMUP, ROP check) → ARTICLES
  → mod_AuditTrail.LogTransaction → AUDIT_LOG
  → mod_ExportEngine.ExportTransactionToPDF → PDF

## 12 ARTICLES (ART-001 → ART-012)
1. ART-001: Toner imprimante G030 (noir) — **Primary case study**
2. ART-002: Rame papier A4 80g/m²
3. ART-003: Rame papier A3 80g/m²
4. ART-004: Boîte archives carton
5. ART-005: Agrafeuse de bureau
6. ART-006: Stylos bille boîte/50
7. ART-007: Registre grand format 5m
8. ART-008: Encre tampon
9. ART-009: Sous-chemise carton
10. ART-010: Chemise cartonnée
11. ART-011: Rouleau papier fax
12. ART-012: Marqueur permanent noir

## 3 SUPPLIERS
F-001: ENAP Alger | F-002: Bureautique Oran | F-003: Bureau Plus

## CODING CONVENTIONS
- PascalCase modules, French comments, French column headers
- Special chars: Chr(233) for é, Chr(201) for É
- No XLOOKUP (Excel 2010 / Windows 7 compat)
- RTL: Arabic right-aligned, French left-aligned
- FormState struct: form owns UI, logic owns business rules. No direct frmStockEntry.{control} refs in logic

## TERMINOLOGY (CNEPD COMPLIANT)
- ❌ "Database" → ✅ "السجل الرقمي" (Digital Ledger)
- ❌ "Python/Backend" → ✅ "وحدات المعالجة VBA"
- ❌ "Hybrid System" → ✅ "نظام إلكتروني متكامل"
- ❌ "فرع" → FORBIDDEN in thesis (use فصل → مبحث → مطلب → أولاً، ثانياً...)

## DO NOT TOUCH
- mod_StockEntry_Logic.bas (core transaction logic, heavily interconnected)
- mod_Config.bas (all canonical thesis values — leaf module)
- ARTICLES sheet (production catalog, 12+ articles)
- MOUVEMENTS sheet (production transaction ledger)
- CANON_* constants in any module

## BUILD / VERIFY / TEST
- Rebuild workbook: `.\vbe-auto\build.ps1 -ConfigPath .\vbe-auto\config.json`
- Verify workbook: `.\vbe-auto\verify.ps1 -ConfigPath .\vbe-auto\config.json`
- DSS Audit: `.\milestone_13_2\tests\dss-audit.ps1`
- Macro tests: `.\Software_Surgical_Edit\test-macros.ps1`
- Build thesis: `.\Thesis_Surgical_Edit\build-thesis.ps1`
- Git push: `git -C "$ROOT" push`

## SESSION PROTOCOL
- Start: `/memory list` (recall previous state)
- End: `/memory save "Done: [task] | Next: [task]"`
- Switch agents: `/mode explore|plan|build|debug|audit`
- Sub-agent: `task subagent_type=explore|general "description"`
- Limit: 30 min / session → `/session reset` before 90% context

## PROJECT PATHS
- Root: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
- VBA Modules: `Software_Surgical_Edit\VBA_Modules\*.bas`
- Workbook: `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm`
- Thesis source: `Thesis_Surgical_Edit\Final_Thesis_Academix_v13_2_FIXED.md`

## THESIS
- Ch1 (Theoretical framework): DONE
- Ch2 (Institution presentation): DONE
- Ch3 (Field diagnosis + ABC/Wilson/CMUP): DONE
- Ch4 (Mini ERP solution + results): DONE
- Front matter: DONE (intro, abstract AR+FR, glossary, dedication)
- Supervisor: دهيني ميمونة (مصلحة الميزانيات والاقتصاد)

## DEAD CODE — ALL DELETED (2026-05-06)
Module1, Module2, frmStockEntry_Enhanced, mod_StockEntry_Logic_Enhanced, mod_TestHarness, frmSystemLog, mod_Config_Test (7 total)

## TRIGGER PHRASE — ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
When the user types this trigger phrase in chat, execute full context reload:

1. Re-read `bootstrap/MASTER_BOOTSTRAP.xml` — uber-context (paths, agents, pipelines)
2. Re-read `erp-context-compact.md` — token-optimized snapshot
3. Read `C:\Users\Administrator\.opencode\notepad.md` — session memory
4. Run `/memory list` — OMC checkpoint recall
5. Confirm: "Academix v13.2 context loaded. Ready."

Use `/academix` command for the same reload with live git status.
