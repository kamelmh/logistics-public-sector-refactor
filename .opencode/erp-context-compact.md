# ERP Académie v13.2 — Compact Context Snapshot
# Institution: Direction de l'Education, Wilaya de El Bayadh (Algeria)
# User: Mahi Kamel Abdelghani | Stack: Pure VBA Excel | Offline-First | Zero Dependencies
# Compliance: CNEPD BTS Public Sector Standards | Locale: fr-FR/ar-DZ
# Generated: 2026-05-09 | ~5K tokens | Inject at session start

## GROUND TRUTH (Canonical — Do Not Modify)
| Param | Value | Description |
|-------|-------|-------------|
| D | 1,546 | Annual demand (38-day observation) |
| Q* (EOQ) | 176 | √(2DS / IPU) — Wilson formula |
| ROP | 212.4 | (D/250)×LT + SS |
| SS | 200 | Safety Stock |
| LT | 2 days | Lead Time |
| S | 500 DZD | Order Cost |
| I | 20% | Holding Rate |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection |
| VERSION | v13.2 | Current |
| Article Case | ART-001 Toner G030 (HP LaserJet) | Thesis case study |

## 25 Sheets
ACCUEIL | ARTICLES | FOURNISSEURS | CONVENTIONS | MOUVEMENTS | TABLEAU_DE_BORD | ALERTE_DASHBOARD | INVENTAIRE | RAPPORTS | CALCULS_EOQ | HISTORIQUE | BON_RECEPTION | BON_SORTIE | BON_COMMANDE | DA_DEMANDE_ACHAT | GUIDE | VBA_MODULES | AUDIT_LOG | DASHBOARD | FORM_INPUT | BORDEREAU_COMMANDE | STAGING_BUFFER | SYS_STRINGS | RECEIPT_TAG | TEMPLATE_BON

## 37 VBA Modules (30 .bas + 1 .frm + MAIN_MACROS.bas + ThisWorkbook.cls = ~11.5K lines, 0 compile errors)
### Critical
| Module | Deps | Key API | Consumers |
|--------|------|---------|-----------|
| mod_Config | none | SYS_TITLE, MASTER_PWD, DOC_TYPE_*, SHEET_* consts, COL_ART_*/COL_MOUV_*/COL_FOU_* column consts | All |
| mod_StockEngine | Config | GetSafetyStock, ComputeEOQ, ComputeROP, ValidateStockLevel, UpdateArticleStockBalance, GetAnnualDemandFromHistory, CalculateCMUP, RefreshAllCMUP, UpdateAllABCClassifications | Dashboard, Procurement, StockEntry_Logic, SyncBridge |
| mod_StockEntry_Logic | Config, Utilities, Localization, Database, SyncBridge, AuditTrail, ExportEngine, TransactionSafety | InitializeForm, cmb*_Change, GenerateAutoRef, btn*_Click, FormState struct pattern | MAIN_MACROS, Navigation |
| mod_TransactionSafety | SharedEnvironment | BeginTransaction, CommitTransaction, RollbackTransaction, DetectCrashRecovery | StockEntry_Logic |

### High
| Module | Deps | Key API |
|--------|------|---------|
| mod_SyncBridge | Config, StockEngine | SyncTransactionInternal, SyncMetricsFromLedger, GetMetricFromLedger, GetStockFromLedger, GetSkuMetrics |
| mod_Dashboard | Config, StockEngine | RefreshDashboard (private: UpdateKPIs, UpdateCriticalTable, UpdateABCXYZSummary) |
| mod_ExportEngine | Config, Utilities, QRCode | ExportTransactionToPDF, ExportToExcel, ExportDashboardPDF |
| mod_Utilities | Config | SafeVal, GetArticleField, IsValidDate, SetupLocationDropdown, ApplyInventoryHeatmap, ExportLowStockPDF |
| mod_Reports | Config, StockEngine | GenerateMonthlyReport, GenerateStockCard, ExportStockCardPDF |
| mod_Database | Config | SecureReadCell, SecureWriteTransaction, FindLastRow, FindLastCol, tableExists |
| mod_AuditTrail | Config | LogAction, QueryAuditLog, ClearAuditLogs |
| mod_ReceiptTag | Config, Utilities | GenerateReceiptTagPDF, SetupReceiptTagSheet |
| mod_QRCode | Config | GenerateQRCodeForForm, GenerateQRCodeForSheet, GenerateLocalQRFallback, VerifyDocumentQR, GetDocumentVerifyCode |
| mod_SharedEnvironment | none | GetSharedExportPath, GetCurrentUser, AcquireFileLock, ReleaseFileLock, BulkImportMouvements, ScheduleAutoBackup |
| mod_InventoryReconciliation | Config, StockEngine | ReconcileInventory, GenerateReconciliationReport |
| mod_SupplierScorecard | Config | ScoreSupplier, EvaluateDeliveryPerformance, GenerateScorecard |

### Medium
mod_SheetSetup | mod_Procurement | mod_Analysis | mod_Localization | mod_ApprovalWorkflow | mod_Forecasting (3/7/14-day MA, 30-day proj, MAD) | mod_SupplierRegistry (NIF/NIS/RC/Art tax IDs) | mod_ThemingEngine | mod_UIEnhancements | mod_DemoData (38-day thesis demo) | mod_DataValidator | mod_StockAging | mod_StockOutPredictor | mod_EntryPoints (20-entry registry)

### Low
mod_UI_Setup | mod_Navigation | mod_Budget | mod_CSVImportExport | mod_Barcode (keyboard-wedge)

### Entry-Point Modules (registered in mod_EntryPoints — 20 entries with trigger type + description)
Run `Call mod_EntryPoints.ListAllEntryPoints` in Immediate Window to see all registered entry points.
Covers: mod_Dashboard | mod_Reports | mod_DemoData | mod_Navigation | mod_Analysis | mod_Forecasting | mod_ApprovalWorkflow | mod_ReceiptTag | mod_SheetSetup | mod_UIEnhancements | mod_ThemingEngine | mod_DataValidator | mod_StockAging | mod_StockOutPredictor | mod_SupplierScorecard | mod_InventoryReconciliation | mod_Utilities | mod_ExportEngine | mod_Barcode | mod_CSVImportExport

## Transaction Data Flow
frmStockEntry → StockEntry_Logic.btnEnregistrer_Click → Database.SecureWriteTransaction → MOUVEMENTS sheet
  → SyncBridge.SyncTransactionInternal → StockEngine (CMUP, ROP check) → ARTICLES sheet
  → AuditTrail.LogTransaction → AUDIT_LOG sheet
  → ExportEngine.ExportTransactionToPDF → PDF file

## Call Graph
mod_Config (leaf) ← Utilities, Localization, Database, StockEngine, StockCalculations, AuditTrail, QRCode
mod_StockEngine ← SyncBridge, Dashboard, Reports, Procurement
mod_SharedEnvironment (leaf) ← TransactionSafety
SyncBridge + Utilities + QRCode → ExportEngine
8 deps → StockEntry_Logic (heaviest consumer)

## 12 Articles + 3 Suppliers
ART-001 Toner G030 (noir) [case study], ART-002 Rame A4, ART-003 Rame A3, ART-004 Boîte archives, ART-005 Agrafeuse, ART-006 Stylos 50x, ART-007 Registre 5m, ART-008 Encre tampon, ART-009 Sous-chemise, ART-010 Chemise, ART-011 Rouleau fax, ART-012 Marqueur
F-001 ENAP Alger | F-002 Bureautique Oran | F-003 Bureau Plus

## AI Backends (14 providers, 35+ models)
| Key | Provider | Model | Ctx | Speed | Cost | Best For |
|-----|----------|-------|-----|-------|------|----------|
| primary | Groq | Llama 3.3 70B | 32K | ~2s | free | VBA logic, prose, daily driver |
| fast | Groq | Qwen3 32B | 32K | ~1s | free | explore, debug, audit |
| gemini | Google | Gemini 2.5 Flash | 1M | ~2s | free | large context, thesis, images |
| gemma | Google | Gemma 4 26B (A4B) | 256K | ~2s | free | multimodal, vision, open-weight (Apache 2.0) |
| gemma-31b | Google | Gemma 4 31B | 32K | ~2s | free | stronger reasoning, dense model |
| or-free | FreeLLM (auto) | free (auto-route) | varies | varies | free | max uptime, 6 providers aggregated |
| or-coder | FreeLLM (Cerebras) | Qwen3 235B | 128K | ~1s | free | VBA code gen (replaces 429-prone OpenRouter) |
| or-nemotron | FreeLLM (NVIDIA NIM) | Nemotron 70B | 128K | ~3s | free | SKIPPED — SMS verification unavailable |
| completions | Completions.me | Claude Opus 4.6 | 200K | ~2s | free | unlimited Claude/GPT/Gemini, no rate limits |
| local-7b | Ollama | Qwen2.5 Coder 7B | 8K | ~30s | free | offline debugging |
| local-1.5b | Ollama | Qwen2.5 Coder 1.5B | 4K | ~95s | free | last-resort offline |
| local-qwen3 | Ollama | Qwen3 1.7B | 16K | ~40s | free | CPU reasoning |
| local-phi4 | Ollama | Phi4-mini 3.8B-q4_K_M | 16K | ~25s | free | CPU coding (best local) |
| local-gemma4 | Ollama | Gemma 4 e2b | 128K | ~40-60s | free | Offline Gemma 4 (text+image) |

> Note: VBA skills (vba-build, vba-debug) exist on disk at `.opencode/skills/` but aren't in OpenCode's global skill catalog. Load VBA context via instructions.md + XML files instead.
| fcc-proxy | proxy→OR | Nemotron 120B (bridge) | 1M | ~3s | free | FCC fallback via localhost:8082 |
| claude | Anthropic | Claude Sonnet 4 | 200K | ~3s | paid | best overall (needs $) |
| gpt-4o | OpenAI | GPT-4o | 128K | ~2s | paid | multimodal alt (needs $) |

## Agents & Routing
| Agent | Model | Purpose |
|-------|-------|---------|
| build | Groq Llama 3.3 70B | VBA code writing, build.ps1 |
| plan | Groq Llama 3.3 70B | Architecture, plans in .opencode/plans/ |
| explore | Groq Qwen3 32B | Codebase recon (read-only) |
| debug | Groq Qwen3 32B | Handoff VBA diagnosis |
| audit | Groq Qwen3 32B | 5-phase DSS audit |
| test | Groq Qwen3 32B | Macro test suite |
| or-free | FreeLLM free | Auto-routed general inference (6 providers, 27 models) |
| or-coder | FreeLLM Cerebras Qwen3 235B | Heavy code generation (active key) |
| completions | Completions.me Claude Opus 4.6 | Unlimited free Claude/GPT (direct provider) |

Workflows: feature (explore→plan→build) | fix (debug→build→test) | quality (audit→explore→build)

## Skills Projection (Key Targets)
| Skill | High-Value Targets |
|-------|-------------------|
| security-audit | mod_Config (MASTER_PWD plaintext), mod_ApprovalWorkflow (no role verify), mod_Database (unprotect/protect), mod_AuditTrail (Clear no admin lock), StockEntry_Logic (no auth) |
| testing | mod_StockEngine (ROP/EOQ/CMUP), mod_StockCalculations, mod_Utilities (SafeVal) |
| data-validation | StockEntry_Logic (qty bounds, duplicate ref), Database (type check), SyncBridge (artCode exists) |
| performance | StockEngine (CMUP O(n) per article), SyncBridge (batch ops) |

## Build/Verify/Test Commands
| Cmd | Action |
|-----|--------|
| `.\vbe-auto\build.ps1 -ConfigPath .\vbe-auto\config.json` | Rebuild workbook from .bas sources (8 steps: kill→open→strip→import→compile→protect→demo+save→cleanup) |
| `.\vbe-auto\verify.ps1 -ConfigPath .\vbe-auto\config.json` | 137-point verification (file→COM→modules→sheets→constants) |
| `.\milestone_13_2\tests\dss-audit.ps1` | 5-phase DSS audit |
| `.\Software_Surgical_Edit\test-macros.ps1` | Automated macro tests |
| `.\Thesis_Surgical_Edit\build-thesis.ps1` | Build thesis PDF |
| `git -C "$ROOT" push` | Push to GitHub |

## Known Issues (All Resolved/Fixed)
- UTF-8 em dashes in .bas → syntax errors on import (replace with -)
- Public Const after procedures → syntax error (move before)
- MASTER_PWD Public Const cross-module → use Property Get
- Comments between _ continuations → parser breaks
- Stale p-code cache → always rebuild from .bas sources

## Coding Conventions
- Pure VBA only — NO Python, NO Flask, NO databases, NO XLOOKUP (Excel 2010 compat)
- PascalCase modules, French comments & column headers, tab names in French
- Special chars: Chr(233) for é, Chr(201) for É
- RTL: Arabic right-aligned, French left-aligned
- FormState struct pattern: form owns UI, logic owns business rules
- Fix .bas source files, NOT .xlsm directly
- Never modify mod_Config constants or CANON_* values
- Dead code removed: Module1, Module2, mod_Config_Test, mod_StockEntry_Logic_Enhanced, mod_TestHarness, frmSystemLog, frmStockEntry_Enhanced

## Thesis
- Ch1 (Theoretical framework): DONE | Ch2 (Institution presentation): DONE
- Ch3 (Field diagnosis + ABC/Wilson/CMUP): DONE | Ch4 (Mini ERP + results): DONE
- Front matter: DONE (intro, abstract AR+FR, glossary, dedication)
- Supervisor: دهيني ميمونة (مصلحة الميزانيات والاقتصاد)
- Thesis source: `Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md`
- Build: `& "Thesis_Surgical_Edit\build-thesis.ps1"` → output DOCX + PDF in `Thesis_Surgical_Edit\output\`
- Pipeline: pandoc MD→DOCX → Python table/cover formatting → Word COM → PDF
- Terminology: ❌ "Database"/"Python"/"Hybrid System"/"فرع" → "السجل الرقمي"/"وحدات المعالجة VBA"/"نظام إلكتروني متكامل" instead
- Chapter outline: `Thesis_Surgical_Edit\THESIS_CHAPTER_OUTLINE.md`
- Full terminology map: `Thesis_Surgical_Edit\THESIS_TERMINOLOGY_MAPPING.md`
- Session handoff: `Thesis_Surgical_Edit\SESSION_HANDOFF.md`

## Workflow Rules (Every Agent Must Follow)
- Edit .bas source files ONLY — never modify .xlsm directly
- Source files in: `Software_Surgical_Edit\VBA_Modules\*.bas`
- After edits: build.ps1 → verify.ps1 → report results
- Build: `& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"`
- Verify: `& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"`
- Audit: `& "milestone_13_2\tests\dss-audit.ps1"`
- Report format: what was fixed, what files changed, build/verify/audit results
- No XLOOKUP (Excel 2010 compat), pure VBA only, no Python/Flask/databases
- French headers & tab names, PascalCase modules

## Project Paths (Essential)
| Path | Location |
|------|----------|
| Root | C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor |
| VBA source | Software_Surgical_Edit\VBA_Modules\*.bas |
| Active workbook | C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm |
| Compiled | Software_Surgical_Edit\ERP_Academie_v13_2.xlsm |
| Config dir | .config\opencode\ |
| Context XMLs | Software_Surgical_Edit\erp-*.xml (4 files) |
| Launcher | Desktop\OpenCode.bat (v3.3, 26 modes) |
| Git remote | https://github.com/kamelmh/logistics-public-sector-refactor |

