# CrossFlow Master Context — Academix v13.4
> Unified context payload shared across OpenCode, Claude Code, OMC, ECC, FCC.
> Auto-loaded by all agents via CROSSFLOW block in their CLAUDE.md files.
> Last updated: 2026-06-09

## PROJECT IDENTITY
- **Project**: Logistics Public Sector Refactor — Academix v13.4
- **Author**: ماحي كمال عبد الغني (Mahi Kamel Abdelghani)
- **Supervisor**: د. دهيني ميمونة (مصلحة الميزانيات والاقتصاد)
- **Institution**: المعهد الوطني المتخصص في التكوين المهني — بن سعيدي عبد العاطي، البيض
- **Host**: مديرية التربية لولاية البيض
- **Compliance**: CNEPD BTS Public Sector Standards
- **Scope**: VBA/Excel DSS for inventory management (offline-first, pure VBA, zero dependencies)
- **Locale**: French (headers/tabs), Arabic MSA (thesis)

## TOOL CROSS-REFERENCE
| Tool | Session | Config Path | Role | Entry Point |
|------|---------|------------|------|-------------|
| OpenCode big-pickle | `main-hub` | `~/.config/opencode/AGENTS.md` | VBA dev, build, verify, orchestration hub | `~/.config/opencode/instructions.md` |
| OpenCode Gemini | `gemini-thesis` | `~/.config/opencode/AGENTS.md` | Thesis-wide analysis (1M ctx) | `~/.config/opencode/instructions.md` |
| OpenCode Gemma 4 | `gemma-4` | `~/.config/opencode/AGENTS.md` | 256K ctx, multimodal, vision | `~/.config/opencode/instructions.md` |
| Claude Desktop | `claude-project` | `C:\Users\Administrator\AppData\Roaming\Claude\claude_desktop_config.json` | Give-and-take on thesis + project | Desktop app |
| Claude Code | `claude-code` | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis | `~/.agentic-hub/CLAUDE.md` |
| OMC | — | `~/.claude/CLAUDE.md` | Agent orchestration | Embedded in Claude Code |
| ECC | — | `~/.agentic-hub/plugins/everything-claude-code/` | 28 agents, 116 skills | Plugin index |
| FreeLLM Gateway | — | `~/.opencode/plugins/freellm/` | Local aggregator (6 providers, 27 models) | `scripts/freellm-launcher.ps1` |
| Completions.me | — | OpenCode config | Free Claude Opus 4.6, GPT-5.2 (26 models) | Direct provider |

## PROJECT PATHS
| Resource | Path |
|----------|------|
| Project root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\` |
| ERP workbook (active) | `C:\Users\Administrator\Dropbox\ERP_v13.4.xlsm` |
| GOLDEN master | `GOLDEN_ERP_v13.4.xlsm` (promoted from ERP_v13.4.xlsm) |
| Thesis source | `Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md` |
| Thesis PDF | `Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.pdf` (1,380 KB) |
| Thesis DOCX | `Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx` |
| Thesis verify | `Thesis_Surgical_Edit\style\verify_docx_checks.py` |
| English paper source | `Thesis_Surgical_Edit\English_Research_Paper.md` |
| English paper PDF | `Thesis_Surgical_Edit\output\English_Research_Paper_IEEE.pdf` (69 KB, 9 pages) |
| English paper DOCX | `Thesis_Surgical_Edit\output\English_Research_Paper_IEEE.docx` (34 KB) |
| Master prompt | `Thesis_Surgical_Edit\MASTER_PROMPT_THESIS.md` |
| Submission package | `Thesis_Surgical_Edit\submission\` |
| VBA source | `Software_Surgical_Edit\VBA_Modules\*.bas` (44 modules) |
| Build config | `vbe-auto\config.json` |
| Build script | `vbe-auto\build.ps1` |
| Verify script | `vbe-auto\verify.ps1` (137 checks) |
| Sweep audit | `vbe-auto\sweep-audit.ps1` |
| DSS audit | `milestone_13_2\tests\dss-audit.ps1` |
| Thesis build | `Thesis_Surgical_Edit\build-thesis.ps1` |
| English paper build | `Thesis_Surgical_Edit\build-english-paper-pdf.ps1` |
| CrossFlow | `.crossflow\` |
| Handoff | `.crossflow\HANDOFF.md` |
| Status | `.crossflow\STATUS.md` |
| Session log | `.crossflow\SESSION_LOG.md` |
| Bootstrap | `.opencode\bootstrap\MASTER_BOOTSTRAP.xml` |
| Compact context | `.opencode\erp-context-compact.md` |
| Git remote | `https://github.com/kamelmh/logistics-public-sector-refactor` |
| Launcher | `Desktop\OpenCode.bat` (v3.6, 26 modes) |

## GROUND TRUTH (LOCKED — DO NOT MODIFY)
| Constant | Value | Meaning |
|----------|-------|---------|
| D (ART-002) | 33 unit/year | Annual demand for Toner G030 from ACTUAL MOUVEMENTS (5 OUT × 250/38 days) |
| Q* (EOQ) | 15 units | Wilson EOQ (PU=1200, S=801.45, I=20%) |
| ROP | 200 units | SS + (D/250) × LT = 200 + (33/250)×2 |
| SS | 200 units | Safety stock (case study value) |
| LT | 2 days | Lead time |
| S | 801.45 DZD | Order cost (field-refined) |
| PU (ART-002) | 1,200 DZD/unit | Unit price Toner G030 compatible (v7 Data Lake, regular toner for public sector) |
| I | 20% | Holding rate |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection password |
| VERSION | v13.4 | Current release |
| Case study | ART-002 Toner G030 (HP LaserJet) | Primary case study in Ch4 |
| Note | ART-001 = Papier A4 (D=2007, PU=400, Q*=50, ROP=416, SS=400). Codes were swapped in thesis v13.3; corrected in v13.4. PU=1200 reflects compatible toner price. | |

### Module & Sheet Counts (v13.4)
| Metric | Value |
|--------|-------|
| VBA modules | 44 (43 .bas + 1 .frm + MAIN_MACROS.bas + ThisWorkbook.cls) |
| Code lines | ~11,500 |
| Worksheets | 26 |
| Dead code removed | 7 (Module1, Module2, mod_Config_Test, mod_StockEntry_Logic_Enhanced, mod_TestHarness, frmSystemLog, frmStockEntry_Enhanced) |

### Key Article Data (v13.4 Calibrated from v7 Historical)
| Article | Code | Description | D (annual) | PU | S | SS | LT | Q* | ROP | ABC-XYZ |
|---------|------|-------------|------------|-----|-----|-----|-----|-----|-----|---------|
| Case Study | ART-002 | Toner G030 | 33 | 1,200 | 801.45 | 200 | 2 | 15 | 200 | AX |
| High Volume | ART-001 | Papier A4 | 2,007 | 400 | 50 | 400 | 2 | 50 | 416 | AX |
| Medium | ART-003 | Papier A3 | 645 | 600 | 50 | 30 | 2 | 23 | 35 | BX |
| Low | ART-004 | Archives | 329 | 150 | 50 | 20 | 1 | 33 | 21 | BY |
| Low | ART-005 | Agrafeuse | 13 | 800 | 50 | 2 | 2 | 3 | 2 | CX |

## VERIFICATION STATE (as of 2026-06-23 — Calibration Phase)
| Check | Result | Timestamp |
|-------|--------|-----------|
| ERP verify | **114/114 PASS** | 2026-06-08 01:45:23 |
| ERP GOLDEN | Promoted | 718.2 KB |
| Thesis verify | **29/29 PASS** | 2026-06-08 |
| Thesis PDF | 1,380 KB (91 pages) | 2026-06-08 |
| English paper PDF | 69 KB (9 pages) | 2026-06-09 |
| CI/CD | 2/2 latest push runs passed | 2026-06-09 |
| Git | In sync with origin/master (0 ahead, 0 behind) | 2026-06-09 |
| **Calibration** | **Phase 1: Config files updated** | 2026-06-23 |

## FORBIDDEN TERMS (CNEPD COMPLIANCE)
> The following terms are FORBIDDEN in the thesis and must be replaced:
- "Database" → **"السجل الرقمي" (Digital Ledger)**
- "Python/Backend" → **"وحدات المعالجة VBA" (VBA Processing Units)**
- "Hybrid System" → **"نظام إلكتروني متكامل" (Integrated Electronic System)**
- "XLOOKUP" → Forbidden (Excel 2010 compatibility required)

### ART Code Short Reference
| Code | French | Arabic | Class |
|------|--------|--------|-------|
| ART-001 | Toner G030 | حبر الطابعة Toner G030 | A |
| ART-002 | Rame papier A4 | رزم الورق A4 | A |
| ART-003 | Rame papier A3 | رزم الورق A3 | B |
| ART-004 | Boite archives | صندوق أرشيف كرتوني | B |
| ART-005 | Agrafeuse de bureau | أغرف الأغراض (دباسة) | C |
| ART-006-012 | (various C items) | (per full table) | C |

## THESIS STRUCTURE
| Chapter | Title | Status |
|---------|-------|--------|
| الفصل الأول | الإطار النظري للتسيير اللوجيستي (Theoretical Framework) | Complete |
| الفصل الثاني | الإطار العملي والتشخيص الميداني (Field Diagnosis) | Complete |
| الفصل الثالث | تصميم وإنجاز نظام دعم القرار (DSS Design) | Complete |
| الفصل الرابع | التجريب والتحقق من النتائج (Testing & Validation) | Complete |
| Front matter | Intro, abstract AR+FR, glossary, dedication, TOC | Complete |

### English Paper (CCA'2026)
- Source: `Thesis_Surgical_Edit\English_Research_Paper.md`
- Output: `English_Research_Paper_IEEE.pdf` (69 KB, 9 pages)
- Deadline: 2026-08-15

## MULTI-WINDOW ORCHESTRATION
> Core invention: coordinating multiple AI windows/sessions, each with a specialized model,
> around a shared CrossFlow context. This allows parallel work at zero token cost
> across sessions — each window owns its domain but syncs via CrossFlow.

### Active Windows
| Window | Identity | Launch Command | Model | Domain | Status |
|--------|----------|---------------|-------|--------|--------|
| **A** | Scout | `opencode` | Gemini 2.5 Flash | Audit, verify, orchestrate, threshold fixes | Complete |
| **B** | Surgeon | `opencode gemini` | Gemini 2.5 Flash | Build pipeline, thesis edits, dedup fix | Complete |
| **C** | Architect | `opencode gemma` | Gemma 4 26B (256K ctx) | Deep reasoning, quality review, thesis polish | Complete |
| **D** | Master Reviewer | Claude Desktop | Claude 4 Sonnet | Final expert review, master prompt recipient | Active |

### Window Handoff Protocol
1. **A (Scout) -> C (Architect)**: Reports findings, discrepancies, audit results
2. **C (Architect) -> B (Surgeon)**: Dispatches tasks based on A's report
3. **B (Surgeon) -> A (Scout)**: Signals completion, A runs verification
4. **Any -> D (Master)**: Deliverables for Claude Desktop final review
5. **All -> HANDOFF.md**: Update after each milestone

## SYNC PROTOCOL
1. OpenCode big-pickle (main-hub) writes `.bas` -> `build.ps1` -> `verify.ps1` (ERP pipeline)
2. OpenCode Gemini (gemini-thesis) writes `.md` -> thesis polish -> DOCX generation
3. Claude Desktop (claude-project) discusses + reviews -> writes HANDOFF entries
4. Any tool can write `HANDOFF.md` -> all tools read it on start
5. Any tool can append to `SESSION_LOG.md` -> archived to `OVERFLOW/` at 50KB
6. MASTER_CONTEXT.md is read-only for tools (edit only via explicit command)

### CrossFlow Auto-Skill
Load the `crossflow-orchestrator` skill in any OpenCode session to activate:
- Multi-window awareness (reads HANDOFF.md on start)
- Cross-session action routing (determines which window owns each task type)
- Handoff generation (formats handoff messages for other windows)
- Context freshness check (compares local state vs MASTER_CONTEXT.md timestamp)

## CODING CONVENTIONS
- Pure VBA only — NO Python, NO Flask, NO databases, NO XLOOKUP (Excel 2010 compat)
- PascalCase modules, French comments & column headers, tab names in French
- Special chars: Chr(233) for e, Chr(201) for E
- RTL: Arabic right-aligned, French left-aligned
- FormState struct pattern: form owns UI, logic owns business rules
- Fix .bas source files, NEVER modify .xlsm directly
- Never modify mod_Config constants or CANON_* values
- Always rebuild from .bas sources (stale p-code cache is the #1 silent killer)

## LATEST SESSION STATE (2026-06-23 — Calibration Phase)
| Metric | Status | Details |
|--------|--------|---------|
| ERP Build | GOLDEN — 114/114 PASS | 718.2 KB, 44 modules, 26 sheets |
| Thesis Verify | 29/29 PASS | 1,380 KB PDF, 91 pages |
| English Paper | Complete | 69 KB PDF (9 pages), 34 KB DOCX |
| Git | In sync | 96640de on master, 0 ahead/0 behind |
| CI/CD | Green | 2/2 latest push runs passed |
| Ground Truth | **Calibrated** | D=33, Q*=15, ROP=200, SS=200, PU=1200 (ART-002 Toner) |
| Calibration | Phase 1 Complete | Config files updated; ERP & Thesis pending |
| Next | Phase 2 | Update ERP workbook source (VBA + Sheets) |

---
*Updated by Academix agent at 2026-06-09. Sources: MASTER_BOOTSTRAP.xml, erp-context-compact.md, STATUS.md, HANDOFF.md, notepad.md.*
