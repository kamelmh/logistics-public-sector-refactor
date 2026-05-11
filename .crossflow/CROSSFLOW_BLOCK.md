<!-- CROSSFLOW:START -->
<!-- ACADEMIX v13.2 — Cross-Platform Agent Context -->
<!-- Sync target: all CLAUDE.md files. Edit MASTER_CONTEXT.md then re-copy this block. -->

## PROJECT: Academix v13.2
- VBA/Excel DSS for inventory management | El Bayadh Education Directorate
- Thesis: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- Source: `Dropbox/Logistics.Public.Sector.Refactor/Thesis_Surgical_Edit/Final_Thesis_Academix_v13_2_FIXED.md`
- Context pack: `Dropbox/.../Thesis_Surgical_Edit/claude-context/`

## CROSS-REFERENCE
| Tool | Path | Role |
|------|------|------|
| OpenCode (JOC) | `~/.config/opencode/instructions.md` | VBA dev, build, verify |
| Claude Code | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis |
| OMC | `~/.claude/CLAUDE.md` (omc block) | Agent orchestration |
| FCC Proxy | `project/.opencode/plugins/fcc-proxy/` | AI backend proxy |
| CrossFlow | `project/.crossflow/` | Shared context + handoff |

## GROUND TRUTH (locked)
- ART-001 = Toner G030 (NOT رزم الورق A4)
- ART-005 = Agrafeuse (NOT Toner)
- Q*=176, ROP=205.6, SS=200, 99.7%
- 37 modules, ~8,100 lines, 25 sheets

## HANDOFF
- Read: `.crossflow/HANDOFF.md` (current state)
- Write: `/crossflow handoff "message"` (after completing work)
- Sync: `.crossflow/MASTER_CONTEXT.md` (full payload)
<!-- CROSSFLOW:END -->
