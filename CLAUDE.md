<!-- CROSSFLOW:START -->
<!-- ACADEMIX v13.2 — Cross-Platform Agent Context -->
<!-- Project root CLAUDE.md — auto-read by Claude Code when in project dir -->
<!-- Full payload at: .crossflow/MASTER_CONTEXT.md -->

## PROJECT: Academix v13.2
- VBA/Excel DSS for inventory management | El Bayadh Education Directorate
- Thesis: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- Source: `Thesis_Surgical_Edit/Final_Thesis_Academix_v13_2_FIXED.md`
- Context pack: `Thesis_Surgical_Edit/claude-context/`

## MULTI-WINDOW TOPOLOGY (براءة اختراع)
Parallel specialized sessions coordinated via CrossFlow:

| Window | Launch | Model | Role |
|--------|--------|-------|------|
| main-hub | `opencode` | big-pickle | VBA dev, build, verify, orchestration hub |
| gemini-thesis | `opencode gemini` | Gemini 2.5 Flash (1M ctx) | Thesis-wide analysis, deep reasoning |
| claude-project | Claude Desktop | Claude 4 Sonnet | Give-and-take on thesis + project |

## CROSS-REFERENCE
| Tool | Path | Role |
|------|------|------|
| OpenCode (JOC) | `~/.config/opencode/instructions.md` | VBA dev, build, verify (main-hub) |
| OpenCode Gemini | `~/.config/opencode/instructions.md` | Thesis analysis (gemini-thesis) |
| Claude Desktop | Desktop app | Discussion, review (claude-project) |
| Claude Code | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis |
| OMC | `~/.claude/CLAUDE.md` (omc block) | Agent orchestration |
| CrossFlow | `.crossflow/` | Shared context + handoff |

## SKILLS
- Load `crossflow-orchestrator` for multi-window orchestration context
- `.opencode/skills/crossflow-orchestrator/SKILL.md`

## GROUND TRUTH (locked)
- ART-001 = Toner G030 (NOT رزم الورق A4)
- ART-005 = Agrafeuse (NOT Toner)
- Q*=176, ROP=205.6, SS=200, 99.7%
- 37 modules, ~8,100 lines, 25 sheets
- Build: OK | Verify: 174/174 | Tests: 20/20 | Audit: 16 PASS

## HANDOFF
- Read: `.crossflow/HANDOFF.md`
- Write: Edit HANDOFF.md with `## Handoff: <src> → <tgt>` format
- Sync: `.crossflow/MASTER_CONTEXT.md`
<!-- CROSSFLOW:END -->
