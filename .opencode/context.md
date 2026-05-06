# ACADEMIX_CONTEXT v13.2 — Groq Deployment Trigger
# When Groq sees this phrase, it activates full project awareness

**TRIGGER PHRASE:** `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`

**When activated, Groq must:**
1. Read `erp-project-context.xml` first — full module map, config parameters, data flow
2. Read `erp-admin-paths.xml` — all file paths, deployment targets, Git repo
3. Read `erp-agent-handoff.xml` — agent routing, session state, completed/pending tasks
4. Load this file as system context — never forget these paths or ground truth

## System Identity
- **Model:** Groq qwen/qwen3-32b (cloud API, ~1s response)
- **Platform:** OpenCode 1.14.39 — Windows 10, Celeron 8GB RAM, HDD
- **User:** Mahi Kamel Abdelghani | Direction de l'Education El Bayadh, Algeria
- **Project:** ERP Académie v13.2 — Pure VBA Excel DSS, Zero External Dependencies
- **Locale:** fr-FR (UI) / ar-DZ (thesis) / French (column headers)

## Ground Truth — NEVER MODIFY
| Parameter | Value | Module |
|-----------|-------|--------|
| D_annual | 1,546 | mod_Config |
| CANON_ROP | 205.6 | mod_StockEntry_Logic |
| CANON_SS | 200 | mod_StockEntry_Logic |
| CANON_QSTAR | 176 | mod_StockEntry_Logic |
| CANON_LT | 2 days | mod_StockEntry_Logic |
| ORDER_COST_S | 500 DZD | mod_StockEngine |
| HOLDING_RATE | 0.20 | mod_StockEngine |
| MASTER_PWD | erp_secure_pwd_2026 | mod_Config |
| VERSION | v13.2 | mod_Config |

## Admin Paths — ALWAYS USE
| Key | Path |
|-----|------|
| Project Root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` |
| VBA Modules | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\VBA_Modules\` |
| Context XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-project-context.xml` |
| Admin Paths XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-admin-paths.xml` |
| Agent Handoff XML | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\erp-agent-handoff.xml` |
| Workbook | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` |
| OpenCode Config | `C:\Users\Administrator\.config\opencode\` |
| Git Repo | `https://github.com/kamelmh/logistics-public-sector-refactor` |

## Module Status
- **27 modules** — ALL CLEAN (Module1, Module2, mod_Config_Test deleted)
- **All warnings resolved** (W001-W010)
- **Critical:** mod_Config, mod_StockEngine, mod_StockEntry_Logic
- **High:** mod_SyncBridge, mod_Dashboard, mod_ExportEngine, mod_Utilities, mod_Reports, mod_Database, mod_AuditTrail, mod_ReceiptTag
- **Medium:** mod_SheetSetup, mod_Procurement, mod_Restore, mod_Backup, mod_Analysis, mod_Localization, mod_ApprovalWorkflow, mod_StockCalculations
- **Low:** mod_UI_Setup, mod_LogViewer, modNavigation, mod_BonLivraison, mod_Budget, mod_Facture

## Skills Enabled
- `omc-reference` — OMC agent catalog, team pipeline, commit protocol
- `context-injection` — Structured context templates for Groq
- `context-optimization` — Deduplicate, filter, reorder, score context
- `context-ranking` — Rank context chunks by relevance
- `context-retrieval` — RAG-based context retrieval
- `version-control` — Git workflow, branching, conflict resolution
- `refactoring` — Code quality improvement patterns
- `testing` — Test generation and coverage
- `security-audit` — Security vulnerability scanning
- `code-review` — Code review against conventions
- `technical-writing` — Technical documentation
- `report-generation` — Professional report generation

## Agentic Protocol
1. **Session Start:** Read `erp-project-context.xml` → activate trigger → load admin paths
2. **Before Edit:** Check dependencies in call graph → verify no CANON_* conflicts
3. **After Edit:** Update `erp-project-context.xml` → commit with trailers → sync configs
4. **Cross-Agent:** Use OMC team pipeline for complex tasks (`/team N:executor "task"`)
5. **Context Management:** Never exceed 70% tokens → use `/memory save` before reset
6. **Workspace Hygiene:** Always work in `$env:TEMP` → deploy to Dropbox → commit

## Trigger Word Chains
| Trigger | Action |
|---------|--------|
| `ACADEMIX_CONTEXT v13.2` | Load full project context |
| `DEPLOYED_IN_OPENCODE` | Activate OpenCode-specific behavior |
| `GROQ_API_ACTIVE` | Switch to cloud API mode (no local Ollama) |
| `ADMIN_PATHS_RESOLVED` | All file paths verified and accessible |
| `WARNINGS_CLEAR` | All W001-W010 resolved, 27 clean modules |
| `THESIS_MODE` | Switch to Arabic thesis writing mode |
| `VBA_EDIT_MODE` | Activate VBA editing conventions |
| `AGENT_ROUTING` | Enable OMC agent delegation |

## Next Session Protocol
1. Open terminal → `cd C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
2. Launch `opencode` (Groq model auto-loaded via `opencode.json`)
3. Type: `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`
4. Groq instantly knows: all paths, all modules, all ground truth, all skills
5. Proceed with high-level feature development
