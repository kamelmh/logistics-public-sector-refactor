# Academix v13.4 — Unified Project Context
# Used by: Claude Desktop GUI, Claude CLI, and OpenCode

## PROJECT IDENTITY
- **System**: VBA/Excel DSS for inventory management
- **Organization**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Ground Truth**: D=33 (ART-002 Toner), Q*=15, ROP=200, SS=200, LT=2 days, S=801.45 DZD, PU=1200 DZD, I=20%
- **Master Password**: erp_secure_pwd_2026

## CURRENT STATUS (Session 48 — 2026-06-29)
- **ERP Workbook**: ERP_v13.4.xlsm (718.2 KB, 114/114 PASS) ✅
- **Thesis Golden Source**: Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx (146 KB, 32/32 PASS) ✅
- **Thesis PDF**: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf (1,380 KB) ✅
- **English Paper**: English_Research_Paper_IEEE.pdf (69 KB, 9 pages) ✅
- **Git**: Synced with remote (94122d2) ✅
- **Workspace**: Cleaned — 629 MB, 7,885 files ✅

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
- **Pipeline Script**: `Thesis_Surgical_Edit/pipeline_v12.py`
- **Python Venv**: `C:\Users\Admin\AppData\Local\Temp\thesis-venv\Scripts\python.exe`
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
Ground Truth (LOCKED): D=33 (ART-002 Toner), Q*=15, ROP=200, SS=200, LT=2 days, S=801.45 DZD, PU=1200 DZD, I=20%, MASTER_PWD=erp_secure_pwd_2026

Current State (Session 48):
- ERP: 114/114 PASS ✅
- Thesis: 32/32 PASS ✅
- Git: Synced (94122d2) ✅
- Workspace: 629 MB, 7885 files, cleaned ✅

Next: Open DOCX in Word, Ctrl+A → F9 to update fields
```

### Full Resume Prompt
See: `.opencode/resume-prompt.md`

## THESIS FILE PATHS
- **Source Markdown**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Golden Source**: `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx`
- **Output PDF**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf`
- **Build Script**: `Thesis_Surgical_Edit/build-thesis.ps1`
- **Pipeline**: `Thesis_Surgical_Edit/run-thesis-pipeline.ps1`
- **Verification**: `Thesis_Surgical_Edit/style/verify_docx_checks.py`

## KEY SCRIPTS
- **Pipeline**: `Thesis_Surgical_Edit/run-thesis-pipeline.ps1` (orchestrates build → fixes → verification)
- **Section Fix**: `Thesis_Surgical_Edit/style/fix_docx_sections.py` (single-section layout)
- **Comprehensive Fix**: `Thesis_Surgical_Edit/style/fix_thesis_all.py` (tables, RTL, footers, etc.)
- **Backup**: `scripts/backup-project.ps1` (unified backup)
- **Cleanup**: `scripts/cleanup-workspace.ps1` (workspace cleanup)
- **Harness**: `scripts/harness.ps1` (task DAG, background runner, worktree isolation)

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

## ADDITIONAL CONTEXT FILES
- **THESIS_CONTEXT.md**: Detailed thesis information and verification results
