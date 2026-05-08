# ACADEMIX_CONTEXT v13.2 — Groq Deployment Trigger
# When Groq sees this phrase, it activates full project awareness

**TRIGGER PHRASE:** `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`

**When activated, Groq must:**
1. Read `erp-project-context.xml` first — full module map, config parameters, data flow
2. Load admin paths from below — all file paths, deployment targets, Git repo
3. Load this file as system context — never forget these paths or ground truth

## System Identity
- **Model:** Groq qwen/qwen3-32b (cloud API, ~1s response)
- **Platform:** OpenCode — Windows 10, Celeron 8GB RAM, HDD
- **User:** Mahi Kamel Abdelghani | Direction de l'Education El Bayadh, Algeria
- **Project:** ERP Académie v13.2 — Pure VBA Excel DSS, Zero External Dependencies
- **Locale:** fr-FR (UI) / ar-DZ (thesis) / French (column headers)
- **Compliance:** CNEPD BTS Public Sector Standards

## Ground Truth — NEVER MODIFY
| Parameter | Value | Module |
|-----------|-------|--------|
| D (Annual Demand) | 1,546 | mod_Config |
| ROP (Reorder Point) | 205.6 | mod_Config / mod_StockEntry_Logic |
| SS (Safety Stock) | 200 | mod_Config / mod_StockEntry_Logic |
| Q* (EOQ) | 176 | mod_Analysis / mod_StockEntry_Logic |
| LT (Lead Time) | 2 days | mod_Config / mod_StockEntry_Logic |
| S (Order Cost) | 500 DZD | mod_StockEngine |
| I (Holding Rate) | 20% | mod_StockEngine |
| Observation Period | 38 days | MOUVEMENTS sheet |
| Working Days | 250 | mod_Config |
| MASTER_PWD | erp_secure_pwd_2026 | mod_Config |
| VERSION | v13.2 | mod_Config |
| Case Study | ART-001: Toner G030 | ARTICLES sheet |

## 12 Articles (ART-001 → ART-012)
1. Toner imprimante G030 (noir) — Primary case study
2. Rame papier A4 80g/m²
3. Rame papier A3 80g/m²
4. Boîte archives carton
5. Agrafeuse de bureau
6. Stylos bille boîte/50
7. Registre grand format 5m
8. Encre tampon
9. Sous-chemise carton
10. Chemise cartonnée
11. Rouleau papier fax
12. Marqueur permanent noir

## 3 Suppliers
- F-001: ENAP Alger
- F-002: Bureautique Oran
- F-003: Bureau Plus

## Admin Paths — ALWAYS USE
| Key | Path |
|-----|------|
| Project Root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` |
| VBA Modules | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\VBA_Modules\` |
| Context XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-project-context.xml` |
| Admin Paths XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-admin-paths.xml` |
| Workbook | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` |
| Launcher | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\academix-launcher.ps1` |
| OpenCode Config | `C:\Users\Administrator\.config\opencode\opencode.json` |
| AGENTS.md | `C:\Users\Administrator\.config\opencode\AGENTS.md` |
| Memory JSON | `C:\Users\Administrator\.opencode\project-memory.json` |
| Notepad MD | `C:\Users\Administrator\.opencode\notepad.md` |
| Build Script | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\build.ps1` |
| Verify Script | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\verify.ps1` |
| Git Repo | `https://github.com/kamelmh/logistics-public-sector-refactor` |

## Module Status — 36 .bas + 1 .frm + ThisWorkbook = 38 Components
**10,130+ lines, 0 compile errors, 0 import failures**

### Critical (3)
mod_Config, mod_StockEngine, mod_StockEntry_Logic

### High (8)
mod_SyncBridge, mod_Dashboard, mod_ExportEngine, mod_Utilities, mod_Reports, mod_Database, mod_AuditTrail, mod_ReceiptTag
mod_QRCode, mod_Forecasting, mod_SupplierRegistry, mod_TransactionSafety, mod_SharedEnvironment, mod_DemoData, mod_BudgetSetup, mod_StockCalculations

### Medium (7)
mod_SheetSetup, mod_Procurement, mod_Restore, mod_Backup, mod_Analysis, mod_Localization, mod_ApprovalWorkflow
mod_ThemingEngine, mod_UIEnhancements, mod_Budget

### Low (5)
mod_UI_Setup, mod_LogViewer, mod_Navigation, mod_BonLivraison, mod_Facture

### Forms (1)
frmStockEntry (714 lines, 25 programmatic controls, FormState struct pattern)

## 25 Workbook Sheets
ACCUEIL, ARTICLES, FOURNISSEURS, CONVENTIONS, MOUVEMENTS, TABLEAU_DE_BORD, ALERTE_DASHBOARD, INVENTAIRE, RAPPORTS, CALCULS_EOQ, HISTORIQUE, BON_RECEPTION, BON_SORTIE, BON_COMMANDE, DA_DEMANDE_ACHAT, GUIDE, VBA_MODULES, AUDIT_LOG, DASHBOARD, FORM_INPUT, BORDEREAU_COMMANDE, STAGING_BUFFER, SYS_STRINGS, RECEIPT_TAG, TEMPLATE_BON

## Terminology (CNEPD Compliant)
| Forbidden | Required |
|-----------|----------|
| Database | السجل الرقمي (Digital Ledger) |
| Python/Backend | وحدات المعالجة VBA (VBA Processing Units) |
| Hybrid System | نظام إلكتروني متكامل (Integrated Electronic System) |
| فرع in thesis | NEVER use — use فصل → مبحث → مطلب → أولاً، ثانياً... |

## Multi-Agent System (6 Agents)

| Agent | Mode | Purpose | Trigger |
|-------|------|---------|---------|
| **explore** | explore | Codebase recon, grep, call graph trace | `/mode explore` |
| **plan** | plan | Architecture decisions, impact docs | `/mode plan` |
| **build** | build | Edit VBA, rebuild via build.ps1 | `/mode build` |
| **debug** | debug | Handoff-based VBA error diagnosis | `/mode debug` |
| **audit** | audit | 5-phase DSS audit (dss-audit.ps1) | `/mode audit` |
| **test** | test | Macro test suite (test-macros.ps1) | task tool |

**Workflows:**
- Feature: `explore → plan → build`
- Fix: `debug → build → test`
- Quality: `audit` before any release

**Commands:**
```
.\orchestrator.ps1 status     — Task queue
.\orchestrator.ps1 build      — Rebuild workbook
.\orchestrator.ps1 audit      — DSS audit
.\orchestrator.ps1 test       — Macro tests
```

See `.opencode/agents/engineering-harness.md` for full agent definitions.

## Agentic Protocol
1. **Session Start:** Read this context → verify admin paths exist
2. **Before Edit:** Check dependencies in call graph → verify no CANON_* conflicts
3. **After Edit:** Update `erp-project-context.xml` → commit with trailers
4. **Build:** Always use `build.ps1` (never manual import — p-code cache corruption)
5. **Cross-Agent:** Read memory files before handing off context
6. **Agent Routing:** Use `/mode <agent>` to switch, or task tool for sub-agent dispatch

## Trigger Word Chains
| Trigger | Action |
|---------|--------|
| `ACADEMIX_CONTEXT v13.2` | Load full project context |
| `DEPLOYED_IN_OPENCODE` | Activate OpenCode-specific behavior |
| `ADMIN_PATHS_RESOLVED` | All file paths verified and accessible |
| `MULTI_AGENT_ACTIVE` | Activate 6-agent engineering harness |
| `THESIS_MODE` | Switch to Arabic thesis writing mode |
| `VBA_EDIT_MODE` | Activate VBA editing conventions |

## Next Session Protocol
1. Open terminal → `cd C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
2. Run launcher: `.\academix-launcher.ps1` (optional — health check)
3. Launch OpenCode: `opencode`
4. Type: `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`
5. Groq instantly knows: all paths, all modules, all ground truth, all agents
6. Switch agents via `/mode explore|plan|build|debug|audit` or task tool
7. Proceed with feature development
