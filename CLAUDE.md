# Academix v13.4 — Unified Project Context
# Used by: Claude Desktop GUI, Claude CLI, and OpenCode

## PROJECT IDENTITY
- **System**: VBA/Excel DSS for inventory management
- **Organization**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Ground Truth**: D=33 (ART-002 Toner), Q*=15, ROP=201, SS=200, LT=7 days, S=801.45 DZD (ART-002)/50 DZD (others), PU=1200/400 DZD, I=20%
- **Master Password**: erp_secure_pwd_2026

## CURRENT STATUS (Session 50 — 2026-07-04)
- **Thesis Output**: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx (153 KB, 34/36 PASS) ✅
- **Build Pipeline**: `uv run` (no venv), build-v2.ps1, ~45 sec build time
- **Knowledge Base**: 30 files in `.claude/knowledge/` (comprehensive reference)
- **Tools Installed**: 6 repositories in `.claude/tools/` (iFixAi, learn-claude-code, mempalace, ruflo, skills_spectrum, thesis-tools)
- **Test Suite**: 28 tests in `tests/test_fixers.py` (all passing)
- **Skills**: 17 skills in `.opencode/skills/` (algerian-thesis, research/, etc.)
- **Git**: All changes committed and pushed (commit `4600649`)

## PROJECT STRUCTURE (Post-Cleanup)
```
Logistics.Public.Sector.Refactor/       629 MB total
├── bin/                                136 MB   OpenCode binary
├── Thesis_Surgical_Edit/                76 MB   Thesis source, build, style fixes
├── Academic_References/                5.8 MB   Reference PDFs & courses
├── superpowers/                        4.4 MB   Git submodule
├── milestone_13_2/                     1.5 MB   Git submodule (public-lsm)
├── archive/                            1.5 MB   Project archive
├── external/                           1.1 MB   Git submodule (lsm-vba-core)
├── Software_Surgical_Edit/             871 KB   ERP VBA modules
├── vbe-auto/                            56 KB   Build/verify automation
├── scripts/                             32 KB   Utility scripts
├── bot/                                 24 KB   Telegram bot
├── tools/                               16 KB   GH model tools
├── tests/                                8 KB   Tests
├── docs/                               256 KB   Documentation
├── .claude/                                      Claude settings
├── .github/                                      GitHub config
├── .opencode/                                    OpenCode config
├── CLAUDE.md                                    Project context (this file)
├── README.md                                    Readme
├── requirements.txt                             Python deps
└── opencode.jsonc                               OpenCode config
```

### What Was Removed (Session 48 — ~2 GB reclaimed)
- **Nested duplicate folder** (1.7 GB) — full project copy inside itself
- **Pandoc installers** (77 MB) — .msi and .zip in project root
- **DELIVERY_v13.4/** (4.4 MB) — frozen delivery package with duplicates
- **backups/** (81 MB) — redundant project backup
- **Thesis_Surgical_Edit/archive/** (41 MB) — old thesis backups, grayscale PDF
- **.crossflow/** (485 KB) — abandoned orchestration system
- **oh-my-claudecode/** (113 MB) — OpenCode plugin with own .git
- **harness/** (19 MB) — separate git repo at root
- **12 stale docs/scripts** — completed plans, session logs
- **vbe-auto/results/_inject_drawing.py** — deprecated, hardcoded paths

## TOOLS INSTALLED (Session 50)
| Tool | Location | Purpose |
|------|----------|---------|
| **iFixAi** | `.claude/tools/ifixai/` | AI misalignment diagnostic (32 inspections) |
| **learn-claude-code** | `.claude/tools/learn-claude-code/` | Agent harness engineering guide |
| **mempalace** | `.claude/tools/mempalace/` | Local-first AI memory system (96.6% R@5) |
| **ruflo** | `.claude/tools/ruflo/` | Multi-agent AI orchestration (100+ agents) |
| **skills_spectrum** | `.claude/tools/skills_spectrum/` | AI OS architecture (L0-L4 layers) |
| **thesis-tools** | `.claude/tools/thesis-tools/` | Academic writing toolkit |

## KNOWLEDGE BASE (30 files)
| Category | Files |
|----------|-------|
| **Ground Truth** | GROUND_TRUTH, THESIS_GROUND_TRUTH, CERTIFICATION_MATRIX |
| **Structure** | STRUCTURE, STRUCTURE_GUIDE, TABLE_CATALOG |
| **Build** | BUILD_REFERENCE, COMMON_ISSUES, VERIFICATION_CHECKLIST |
| **Formatting** | FORMAT_GUIDE, FORMATTING_HISTORY, ALGERIAN_THESIS_SKILL |
| **Defense** | DEFENSE_CHECKLISTS, MASTER_PROMPT, POLISH_HANDOFF |
| **Reference** | GLOSSARY_AND_ABBREVIATIONS, CONTEXT_INDEX, PROJECT_SYNC |
| **Tools** | TEST_SUITE, IFIXAI_REFERENCE, LEARN_CLAUDE_CODE, MEMPALACE_REFERENCE, RUFLO_REFERENCE, SKILLS_SPECTRUM, THESIS_TOOLS |
| **Advanced** | BAYESIAN_NETWORKS_CRASH_COURSE, CORE_KNOWLEDGE_SYSTEM, SPECTRUM_REGISTRY |

## TEST SUITE
- **Location**: `tests/test_fixers.py`
- **Framework**: pytest
- **Tests**: 28 (all passing)
- **Coverage**: Table width, heading alignment, caption RTL, TOC/TOF, compatibility, golden values, Arabic detection, zip operations, ground truth, table borders/padding, footnote styles, namespaces

## TRIPLE-SYNC CONFIGURATION
All three tools share the same MCP servers and project context:

### Tools Connected
| Tool | Type | MCP Access | Status |
|------|------|------------|--------|
| **Claude Desktop GUI** | Visual review, deep analysis | filesystem + github + microsoft-learn + context7 | ✅ |
| **Claude CLI (Code)** | Terminal, OMC plugin, agent teams | filesystem + github + context7 + omc-bridge | ✅ |
| **OpenCode** | VBA dev, build, verify | filesystem + github + memory + sequential-thinking + omc-bridge | ✅ |

### Shared MCP Servers
| Server | Purpose | Token/Limits |
|--------|---------|--------------|
| **filesystem** | Read/write project files | Local MSIX path |
| **github** | Git operations, PRs, issues | `$env:GH_TOKEN` (never commit; see SECURITY.md) |
| **microsoft-learn** | Documentation lookup | Public endpoint |
| **context7** | Library documentation (React, Next.js, etc.) | Free tier |

### Shared File Paths (All Relative)
- **Project Root**: project root directory (where this file lives)
- **ERP Workbook**: `../ERP_v13.4.xlsm` (parent of project root — Dropbox level)
- **Thesis Source**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Thesis Golden Source**: `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx`
- **Session Memory**: `.opencode/notepad.md`
- **Thesis Output**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`
- **Pipeline Script**: `Thesis_Surgical_Edit/build-v2.ps1`
- **Python**: `uv run --with lxml --with python-docx --with pypandoc python`
- **Persist Script**: `.opencode/memory/persist.ps1`

## RATE LIMIT AWARENESS

### API Limits by Provider
| Provider | Model | Rate Limit | Strategy |
|----------|-------|------------|----------|
| **Anthropic** | Claude Opus 4 | 40 req/min, 400K tokens/min | Use for deep analysis |
| **Anthropic** | Claude Sonnet 4 | 80 req/min, 800K tokens/min | Primary workhorse |
| **Anthropic** | Claude Haiku 3.5 | 150 req/min, 1.5M tokens/min | Quick tasks, exploration |
| **Groq** | Llama 3.3 70B | 30 req/min | Fast explore/debug |
| **Google** | Gemini 2.5 Flash | 15 req/min, 1M context | Large context tasks |
| **OpenRouter** | Nemotron 120B | FREE, 1M context | Backup for large tasks |

### Rate Limit Best Practices
1. **Batch operations** — Combine multiple file reads into single requests
2. **Use Haiku for exploration** — Save Sonnet/Opus for actual work
3. **Cache results** — Don't re-read files you've already seen
4. **Phase-based work** — Complete phases before hitting limits
5. **Resume prompts** — Use saved context to avoid re-explaining

### Token Budget per Session
- **Claude Desktop**: ~200K tokens/session (before compaction)
- **Claude CLI**: ~200K tokens/session (before compaction)
- **OpenCode**: Varies by model (32K-1M context)

## SKILLS INVENTORY

### OpenCode Skills (112 skills)
| Category | Key Skills | Purpose |
|----------|------------|---------|
| **VBA Development** | vba-build, vba-debug, vba-deployer, vbe-auto | Excel/VBA work |
| **Thesis** | thesis-pipeline, thesis-build, thesis-docx, thesis-to-docx | Thesis building |
| **Agent Orchestration** | autopilot, ralph, ultrawork, team, orchestrate | Multi-agent workflows |
| **Code Quality** | code-reviewer, verify, naming-cheatsheet, humanizer | Code review |
| **Planning** | plan, planning-and-task-breakdown, idea-refine | Architecture |
| **Debug** | debug, debugging-wizard, trace | Error diagnosis |
| **Research** | external-context, context7-docs, web-to-markdown | Documentation |

### When to Use Which Tool
| Task | Best Tool | Why |
|------|-----------|-----|
| **VBA debugging** | OpenCode | Specialized VBA skills |
| **Thesis review** | Claude Desktop GUI | Visual inspection, deep analysis |
| **Code review** | Claude CLI | OMC plugin, agent teams |
| **Quick questions** | Claude CLI | Fast, terminal-based |
| **Large file analysis** | OpenCode (Gemini 1M) | 1M context window |
| **Documentation** | Any tool with context7 | Library docs lookup |

## RESUME PROMPT SYSTEM

### Quick Resume (Copy this to any new session)
```
Project: Academix v13.4 — VBA/Excel DSS for Direction de l'Education El Bayadh
Thesis: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
Ground Truth (LOCKED): D=33 (ART-002 Toner), Q*=15, ROP=201, SS=200, LT=7 days, S=801.45 DZD (ART-002)/50 DZD (others), PU=1200/400 DZD, I=20%

Current State (Session 49):
- Thesis: 34/36 PASS (2 expected: hyperlinks/PAGEREF via Ctrl+A F9) ✅
- Build: uv run, build-v2.ps1, ~45 sec ✅
- Knowledge: 14 files + algerian-thesis skill ✅

Next: Open DOCX in Word, Ctrl+A → F9 to update fields
```

### Full Resume Prompt
See: `.opencode/resume-prompt.md`

## THESIS FILE PATHS
- **Source Markdown**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Output DOCX**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`
- **Cover Page Shell**: `Thesis_Surgical_Edit/output/cover_page_and_post_chapters_contents_only.docx`
- **Build Script**: `Thesis_Surgical_Edit/build-v2.ps1`
- **Python**: `uv run --with lxml --with python-docx --with pypandoc python`

## KEY SCRIPTS
- **Build Pipeline**: `Thesis_Surgical_Edit/build-v2.ps1` (5 phases: Pandoc → Stitch → Format → Word COM → Verify)
- **Heading Alignment**: `Thesis_Surgical_Edit/style/fix_heading_alignment.py` (H1=center, H2/H3=right, all RTL)
- **TOC/TOF Injection**: `Thesis_Surgical_Edit/style/inject_toc_tof_fields.py` (dynamic fields)
- **Table Captions**: `Thesis_Surgical_Edit/style/inject_table_captions.py` (SEQ + titles)
- **RTL Fixer**: `Thesis_Surgical_Edit/style/fixers/rtl.py` (bidi on all non-skip styles)
- **Table Width Fix**: `Thesis_Surgical_Edit/style/fixers/tables.py` (dxa units, 100% width)
- **Verification**: `Thesis_Surgical_Edit/style/verify_docx_checks.py` (36-point check)
- **Sync Golden**: `Thesis_Surgical_Edit/style/sync_golden_from_md.py` (MD → shell sync)
- **CNEPD Checker**: `Thesis_Surgical_Edit/style/cnepd-thesis-checker.py` (compliance)
- **Metrics**: `Thesis_Surgical_Edit/style/measure-thesis.py` (20+ metrics, JSON output)
- **Comparison**: `Thesis_Surgical_Edit/style/compare-thesis.py` (build diff)

## PAGE NUMBERING CONFIGURATION
- **Single section** with `titlePg` (different first page enabled)
- **Cover page**: No page number displayed (uses blank footer1.xml)
- **Page numbering**: Continuous decimal from cover (page 1 hidden, TOC=page 2, body continues)
- **Footer**: `footer2.xml` contains PAGE field (no cached value)

## GIT HISTORY (Session 48 Commits)
```
94122d2  chore: remove deprecated vbe-auto/results/_inject_drawing.py
23da534  chore: update .gitignore to prevent large installers and nested dirs
06289d7  fix: correct path in check_pgnum.py
b2959da  fix: replace hardcoded Dropbox paths with relative paths across 18 files
d38baaf  chore: cleanup stale docs, old backups, DELIVERY_v13.4, and .crossflow
```

### Phase Handoff Template
```markdown
## Phase [N] Complete — [Date]
### What Was Done
- [ ] Task 1
- [ ] Task 2

### What Was Verified
- [ ] Test 1 passed
- [ ] Test 2 passed

### What's Next
- Phase [N+1]: [Description]

### Context for Next Phase
- Files modified: [list]
- Key decisions: [list]
- Blockers: [list]
```

## NEXT STEPS
1. Open DOCX in Word, Ctrl+A → F9 to update fields
2. Verify page numbers, RTL, table layout
3. Final review and submission

## HOW TO HELP
- Review thesis content for accuracy
- Check formatting and structure
- Verify academic standards
- Assist with final polish before submission

## KNOWLEDGE BASE
Read `.claude/knowledge/` for detailed reference:
- **GROUND_TRUTH.md** — All locked numerical values, formulas, calculations
- **STRUCTURE.md** — Heading hierarchy (9 H1, 40 H2, 56 H3, 18 H4), chapter map
- **TABLE_CATALOG.md** — All 23 tables with expected values
- **BUILD_REFERENCE.md** — Pipeline internals, phase-by-phase explanation
- **COMMON_ISSUES.md** — 13 known problems and fixes
- **VERIFICATION_CHECKLIST.md** — 36-point check definitions
- **ALGERIAN_THESIS_SKILL.md** — CNEPD formatting standard (cover, typography, bibliography)
- **DEFENSE_CHECKLISTS.md** — Demo flow, talking points, Q&A prep, backup plan
- **AUDIT_PRIME_PACK.md** — Certification matrix, forbidden terms, architecture map
- **PROJECT_SYNC.md** — Absolute ground truth, "Deadly Sins", structural hierarchy
- **MASTER_PROMPT.md** — Thesis final polish system prompt (3-wrapper strategy)
- **STRUCTURE_GUIDE.md** — Chapter hierarchy with mermaid maps
- **FORMAT_GUIDE.md** — Fonts, colors, cover integration, table formatting
- **CONTEXT_INDEX.md** — Navigation hub, loading order, token-saving strategy
- **SPECTRUM_REGISTRY.md** — AI OS architecture (L0-L4 layers)
- **CORE_KNOWLEDGE_SYSTEM.md** — Personal knowledge system design
- **CERTIFICATION_MATRIX.md** — Mathematical proof of thesis-VBA consistency
- **FORMATTING_HISTORY.md** — Earlier formatting decisions and workflow (383 lines)
- **POLISH_HANDOFF.md** — Polish scope, known issues, pipeline commands
- **GLOSSARY_AND_ABBREVIATIONS.md** — 60+ terms, abbreviations, glossary
- **PROJECT_ASSESSMENT.md** — Agentic project mapping and DSS architecture insights
- **pdf-mapping.json** — 30 reference PDFs organized by semester
- **skill-registry.json** — 13 skills categorized by domain

## SKILLS
- **algerian-thesis**: `.opencode/skills/algerian-thesis.skill` — CNEPD thesis formatting, audit, and reformatting workflow
- **karpathy-guidelines**: `.claude/plugins/andrej-karpathy-skills/skills/karpathy-guidelines/SKILL.md` — Code quality guidelines (think before coding, simplicity first, surgical changes, goal-driven execution)
- **path-orchestrator**: `.opencode/skills/path-orchestrator.skill` — File system intelligence, structural integrity, proactive push protocol
- **workspace-setup**: `.opencode/skills/workspace-setup.skill` — Workspace detection, drive routing, session load
- **ssd-health-tools**: `.opencode/skills/ssd-health-tools.skill` — Drive health check, benchmark, deployment

## KARPATHY GUIDELINES (Merged)
**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"
- For multi-step tasks, state a brief plan with verification checks.

