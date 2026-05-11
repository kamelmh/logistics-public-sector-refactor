# CrossFlow Master Context — Academix v13.2
> Unified context payload shared across OpenCode, Claude Code, OMC, ECC, FCC.
> Auto-loaded by all agents via CROSSFLOW block in their CLAUDE.md files.
> Last updated: 2026-05-11

## PROJECT IDENTITY
- **Project**: Logistics Public Sector Refactor — Academix v13.2
- **Author**: ماحي كمال عبد الغني
- **Supervisor**: د. دهيني ميمونة
- **Institution**: المعهد الوطني المتخصص في التكوين المهني — بن سعيدي عبد العاطي، البيض
- **Host**: مديرية التربية لولاية البيض
- **Scope**: VBA/Excel DSS for inventory management (offline-first, pure VBA)

## TOOL CROSS-REFERENCE
| Tool | Config Path | Role | Entry Point |
|------|------------|------|-------------|
| OpenCode (JOC) | `~/.config/opencode/AGENTS.md` | VBA dev, build, verify | `~/.config/opencode/instructions.md` |
| Claude Code | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis | `~/.agentic-hub/CLAUDE.md` |
| OMC (oh-my-claudecode) | `~/.claude/CLAUDE.md` | Agent orchestration | Embedded in Claude Code |
| ECC (everything-claude-code) | `~/.agentic-hub/plugins/everything-claude-code/` | 28 agents, 116 skills | Plugin index |
| FCC (free-claude-code proxy) | `project/.opencode/plugins/fcc-proxy/` | AI backend proxy | `scripts/profile-common.ps1` |

## PROJECT PATHS
| Resource | Path |
|----------|------|
| Project root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\` |
| Thesis source | `...\Thesis_Surgical_Edit\Final_Thesis_Academix_v13_2_FIXED.md` |
| Thesis PDF | `...\Thesis_Surgical_Edit\output\Memoire_Academix_v13_2_Final.pdf` |
| Thesis DOCX | `...\Thesis_Surgical_Edit\output\Memoire_Academix_v13_2_Final.docx` |
| Cover page | `...\Thesis_Surgical_Edit\cover-page.docx` |
| Claude context | `...\Thesis_Surgical_Edit\claude-context\` |
| ERP workbook | `...\Software_Surgical_Edit\ERP_Academie_v13_2.xlsm` |
| VBA modules | `...\Software_Surgical_Edit\VBA_Modules\` (37 .bas + 1 .frm) |
| Build config | `...\vbe-auto\config.json` |
| Build script | `...\vbe-auto\build.ps1` |
| Verify script | `...\vbe-auto\verify.ps1` |
| CrossFlow | `...\.crossflow\` |
| Handoff | `...\.crossflow\HANDOFF.md` |
| Session log | `...\.crossflow\SESSION_LOG.md` |
| Overflow | `...\.crossflow\OVERFLOW\` |

## GROUND TRUTH (LOCKED — DO NOT MODIFY)
| Constant | Value | Meaning |
|----------|-------|---------|
| D (ART-001) | 1,546 unit/year | Annual demand for Toner G030 |
| Q* (EOQ) | 176 units | Optimal order quantity |
| ROP | 205.6 units | Reorder point |
| SS | 200 units | Safety stock |
| LT | 2 days | Lead time |
| S | 500 DZD | Order cost |
| I | 20% | Holding rate |
| PU (ART-001) | 400 DZD/unit | Unit price |
| Modules | 37 .bas + 1 .frm | Active |
| Dead removed | 7 | Module1, Module2, etc. |
| Worksheets | 25 | Active sheets |
| Code lines | ~8,100 | Verified |
| Performance | 99.7% | NOT 97% |

### ART Code Short Reference
| Code | French | Arabic | Class |
|------|--------|--------|-------|
| ART-001 | Toner G030 | حبر الطابعة Toner G030 | A |
| ART-002 | Rame papier A4 | رزم الورق A4 | A |
| ART-003 | Rame papier A3 | رزم الورق A3 | B |
| ART-004 | Boîte archives | صندوق أرشيف كرتوني | B |
| ART-005 | Agrafeuse de bureau | أغرف الأغراض (دباسة) | C |
| ART-006–012 | (various C items) | (per full table) | C |

## THESIS STRUCTURE
| Chapter | Title | مباحث | مطالب |
|---------|-------|-------|-------|
| الفصل الأول | الإطار النظري للتسيير اللوجيستي | 5 | 14 |
| الفصل الثاني | الإطار العملي للتشخيص الميداني | 3 | 9 |
| الفصل الثالث | تصميم وإنجاز نظام دعم القرار | 4 | 15 |
| الفصل الرابع | التجريب والتحقق من النتائج | 6 | 14 |

## SYNC PROTOCOL
1. OpenCode writes `.bas` → `build.ps1` → `verify.ps1` (ERP pipeline)
2. Claude Code writes `.md` → thesis polish → DOCX generation
3. Any tool can write `HANDOFF.md` → all tools read it on start
4. Any tool can append to `SESSION_LOG.md` → archived to `OVERFLOW/` at 50KB
5. MASTER_CONTEXT.md is read-only for tools (edit only via explicit command)
