# CrossFlow Master Context — Academix v13.2
> Unified context payload shared across OpenCode, Claude Code, OMC, ECC, FCC.
> Auto-loaded by all agents via CROSSFLOW block in their CLAUDE.md files.
> Last updated: 2026-05-12

## PROJECT IDENTITY
- **Project**: Logistics Public Sector Refactor — Academix v13.2
- **Author**: ماحي كمال عبد الغني
- **Supervisor**: د. دهيني ميمونة
- **Institution**: المعهد الوطني المتخصص في التكوين المهني — بن سعيدي عبد العاطي، البيض
- **Host**: مديرية التربية لولاية البيض
- **Scope**: VBA/Excel DSS for inventory management (offline-first, pure VBA)

## TOOL CROSS-REFERENCE
| Tool | Session | Config Path | Role | Entry Point |
|------|---------|------------|------|-------------|
| OpenCode big-pickle | `main-hub` | `~/.config/opencode/AGENTS.md` | VBA dev, build, verify, orchestration hub | `~/.config/opencode/instructions.md` |
| OpenCode Gemini | `gemini-thesis` | `~/.config/opencode/AGENTS.md` | Thesis-wide analysis (1M ctx) | `~/.config/opencode/instructions.md` |
| Claude Desktop | `claude-project` | `C:\Users\Administrator\AppData\Roaming\Claude\claude_desktop_config.json` | Give-and-take on thesis + project | Desktop app |
| Claude Code | `claude-code` | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis | `~/.agentic-hub/CLAUDE.md` |
| OMC | — | `~/.claude/CLAUDE.md` | Agent orchestration | Embedded in Claude Code |
| ECC | — | `~/.agentic-hub/plugins/everything-claude-code/` | 28 agents, 116 skills | Plugin index |
| FCC | — | `project/.opencode/plugins/fcc-proxy/` | AI backend proxy | `scripts/profile-common.ps1` |

## PROJECT PATHS
| Resource | Path |
|----------|------|
| Project root | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\` |
| Thesis source | `...\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md` |
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
| S | 801.45 DZD | Order cost (field-refined from initial 500; VBA updated 2026-05-12) |
| I | 20% | Holding rate |
| PU (ART-001) | 400 DZD/unit | Unit price |
| Modules | 37 .bas + 1 .frm | Active |
| Dead removed | 7 | Module1, Module2, etc. |
| Worksheets | 25 | Active sheets |
| Code lines | ~8,100 | Verified |
| Performance | 99.7% | NOT 97% |
| Test suite | 20 | All passing |

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

## MULTI-WINDOW ORCHESTRATION (براءة اختراع)
> Core invention: coordinating multiple AI windows/sessions, each with a specialized model,
> around a shared CrossFlow context. This allows parallel work at zero token cost
> across sessions — each window owns its domain but syncs via CrossFlow.

### Active Windows
| Window | Launch Command | Model | Domain | Status |
|--------|---------------|-------|--------|--------|
| main-hub | `opencode` | big-pickle (default) | VBA dev, build, verify, orchestration | 🟢 Active |
| gemini-thesis | `opencode gemini` | Gemini 2.5 Flash (1M ctx) | Thesis-wide analysis, deep reasoning | 🟢 Active |
| claude-project | Claude Desktop | Claude 4 Sonnet | Give-and-take on thesis + project | 🟢 Active |

### Window Handoff Protocol
1. **main-hub → gemini-thesis**: When VBA work triggers thesis updates (e.g., ground truth changes, new feature)
2. **main-hub → claude-project**: When architectural decisions need human discussion or thesis chapter review  
3. **gemini-thesis → main-hub**: When thesis analysis reveals VBA changes needed
4. **claude-project → main-hub**: After discussion yields action items for VBA implementation
5. **Any → all**: After completing a task, append to SESSION_LOG.md and update HANDOFF.md

## SYNC PROTOCOL
1. OpenCode big-pickle (main-hub) writes `.bas` → `build.ps1` → `verify.ps1` (ERP pipeline)
2. OpenCode Gemini (gemini-thesis) writes `.md` → thesis polish → DOCX generation
3. Claude Desktop (claude-project) discusses + reviews → writes HANDOFF entries
4. Any tool can write `HANDOFF.md` → all tools read it on start
5. Any tool can append to `SESSION_LOG.md` → archived to `OVERFLOW/` at 50KB
6. MASTER_CONTEXT.md is read-only for tools (edit only via explicit command)

### CrossFlow Auto-Skill
Load the `crossflow-orchestrator` skill in any OpenCode session to activate:
- Multi-window awareness (reads HANDOFF.md on start)
- Cross-session action routing (determines which window owns each task type)
- Handoff generation (formats handoff messages for other windows)
- Context freshness check (compares local state vs MASTER_CONTEXT.md timestamp)

## LATEST SESSION STATE (2026-05-12)
| Metric | Status |
|--------|--------|
| Build | ✅ COMPILE: OK |
| Verify | ✅ 174/174 PASS |
| Tests | ✅ 20/20 PASS |
| Audit | ✅ 16 PASS, 0 CRITICAL |
| Public LSM | ✅ Pushed v1.4.0 |
| Defense checklist | ✅ Created: `milestone_13_2\defense-demo-checklists.md` |
| Next | Thesis polish (gemini-thesis) / Feature expansion (main-hub)
