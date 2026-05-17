<!-- CROSSFLOW:START -->
<!-- ACADEMIX v13.2 — Cross-Platform Agent Context -->
<!-- Project root CLAUDE.md — auto-read by Claude Code when in project dir -->
<!-- Full payload at: .crossflow/MASTER_CONTEXT.md -->

## PROJECT: Academix v13.2
- VBA/Excel DSS for inventory management | El Bayadh Education Directorate
- Thesis: BTS CNEPD — 4 chapters, 16 مباحث, 52 مطالب, **36/36 PASS**
- Source: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` (907 lines)
- الفصل الرابع: `Thesis_Surgical_Edit/الفصل_الرابع_التجريب_والتحقق_من_النتائج.md` (75 lines, separate file)
- Output DOCX: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx` (107 KB)
- Output PDF: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf` (949 KB)
- Context pack: `Thesis_Surgical_Edit/claude-context/`
- CrossFlow: `.crossflow/HANDOFF.md` (sync state) | `.crossflow/MASTER_CONTEXT.md` (uber-context)

## MULTI-WINDOW TOPOLOGY (براءة اختراع)
Four parallel specialized sessions coordinated via CrossFlow:

| Window | Launch | Model | Role |
|--------|--------|-------|------|
| **main-hub/A** | `opencode` | DeepSeek V4 Flash | Scout — audit, verify, orchestrate |
| **gemini-thesis/B** | `opencode gemini` | Gemini 2.5 Flash (1M ctx) | Surgeon — thesis edits, build pipeline |
| **claude-project/C** | Claude Desktop | Claude 4 Sonnet | Architect — deep reasoning, thesis review |
| **D** (you) | Claude Desktop | Claude 4 Sonnet | **Master prompt** — full context recipient, final review, expert analysis |

## CROSS-REFERENCE
| Tool | Path | Role |
|------|------|------|
| OpenCode (JOC) | `~/.config/opencode/instructions.md` | VBA dev, build, verify (Window A) |
| OpenCode Gemini | `~/.config/opencode/instructions.md` | Thesis analysis (Window B) |
| Claude Desktop | Desktop app | Discussion, review, deep analysis (Windows C/D) |
| Claude Code | `~/.claude/CLAUDE.md` | Thesis polish, deep analysis |
| CrossFlow | `.crossflow/` | Shared context + handoff |

## SKILLS
- Load `crossflow-orchestrator` for multi-window orchestration context
- `.opencode/skills/crossflow-orchestrator/SKILL.md`

## CURRENT STATE (2026-05-17)
### Thesis — ✅ 36/36 PASS (ALL CHECKS PASSED)
- Chapter 1: ✅ الإطار النظري (5 مباحث, 14 مطالب) — polished
- Chapter 2: ✅ الإطار العملي والتشخيص الميداني (3 مباحث, 9 مطالب) — polished by Windows B+C
- Chapter 3: ✅ تصميم وإنجاز نظام دعم القرار (4 مباحث, 15 مطالب) — complete
- Chapter 4: ✅ التجريب والتحقق من النتائج (2 مباحث, 75 lines, separate file) — complete
- Bibliography: 56 entries | Tables: 21 | Footnotes: 5 | References: 30 PDFs linked

### ERP — GOLDEN
- Build: ✅ 174/174 PASS (38 modules, 833 KB)
- Tests: ✅ 20/20 PASS
- Audit: ✅ 16 PASS (DSS 5-phase)
- VBA Modules: 37 .bas + 1 .frm | Sheets: 25 | Code lines: ~12,538

## GROUND TRUTH (locked — never modify)
| Param | Value | Param | Value |
|-------|-------|-------|-------|
| D (ART-001) | 1,546 | Q* | 176 |
| ROP | 212.4 | SS | 200 |
| LT | 2 days | S | 801.45 DZD |
| I | 20% | PU | 400 DZD |
| Performance | 99.7% | Modules | 37 .bas + 1 .frm |
| Sheets | 25 | Articles | 12 (ART-001→ART-012) |
| Dead removed | 7 modules | | |

## HANDOFF
- Read: `.crossflow/HANDOFF.md`
- Write: Edit HANDOFF.md with `## Handoff: <src> → <tgt>` format
- Sync: `.crossflow/MASTER_CONTEXT.md`

### Your Role as Window D (Master Reviewer)
You are the **final expert reviewer** for Academix v13.2. You receive the fully-completed thesis (36/36 PASS) and ERP (GOLDEN) from Windows A/B/C. Your task is:
1. **Read** `.crossflow/HANDOFF.md` for latest state
2. **Read** `.crossflow/MASTER_CONTEXT.md` for full project context
3. **Review** thesis source: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
4. **Review** الفصل الرابع: `Thesis_Surgical_Edit/الفصل_الرابع_التجريب_والتحقق_من_النتائج.md`
5. **Deliver** final expert analysis, suggestions, or sign-off
<!-- CROSSFLOW:END -->

