# Academix v13.4 — Unified Project Context
# Used by: Claude Desktop GUI, Claude CLI, and OpenCode

## PROJECT IDENTITY
- **System**: VBA/Excel DSS for inventory management
- **Organization**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Ground Truth**: D=1546, Q*=176, ROP=212.4, SS=200, LT=2 days, S=801.45 DZD, PU=400 DZD, I=20%
- **Master Password**: erp_secure_pwd_2026

## CURRENT STATUS (Session 47e — 2026-06-15)
- **ERP Workbook**: ERP_v13.4.xlsm (718.2 KB, 114/114 PASS) ✅
- **Thesis Golden Source**: Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx (146 KB, 32/32 PASS) ✅
- **Thesis PDF**: Memoire_DSS_Logistique_ElBayadh.pdf (1,380 KB) ✅
- **English Paper**: English_Research_Paper_IEEE.pdf (69 KB, 9 pages) ✅
- **Git**: Synced with remote (fcbb9f5) ✅
- **Workspace**: Cleaned and structured (Session 47e) ✅

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
| **github** | Git operations, PRs, issues | github_pat_11APRYXRQ0TVeTcHzbdqRG |
| **microsoft-learn** | Documentation lookup | Public endpoint |
| **context7** | Library documentation (React, Next.js, etc.) | Free tier |

### Shared File Paths
- **Project Root**: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
- **Google Drive**: `C:\Users\Administrator\My Drive`
- **Thesis Source**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Thesis Golden Source**: `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx`
- **ERP Workbook**: `ERP_v13.4.xlsm`
- **Handoff**: `.crossflow/HANDOFF.md`
- **Session Memory**: `C:\Users\Administrator\.opencode\notepad.md`
- **Resume Prompt**: `C:\Users\Administrator\.opencode\resume-prompt.md`

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

### Claude Skills (87 skills)
| Category | Key Skills | Purpose |
|----------|------------|---------|
| **Research** | deep-research, literature-review, research-report | Academic work |
| **Writing** | technical-writing, blog-post-writing, copywriting | Content creation |
| **Analysis** | data-analysis, data-visualization, exploratory-data-analysis | Data work |
| **Security** | security-audit, threat-modeling, dependency-scanning | Security review |
| **DevOps** | ci-cd, docker-compose-setup, kubernetes-deployment | Infrastructure |

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
Ground Truth (LOCKED): D=1546, Q*=176, ROP=212.4, SS=200, LT=2 days, S=801.45 DZD, PU=400 DZD, I=20%, MASTER_PWD=erp_secure_pwd_2026

Current State (Session 47e):
- ERP: 114/114 PASS ✅
- Thesis: 32/32 PASS ✅
- Git: Synced (fcbb9f5) ✅
- Workspace: Cleaned and structured ✅

Next: Launch Claude Desktop GUI for deep verification
Read: .crossflow/HANDOFF.md for full context
```

### Full Resume Prompt (For comprehensive context)
See: `C:\Users\Administrator\.opencode\resume-prompt.md`

## PHASE-BASED WORKFLOW

### Phase Structure
| Phase | Description | Deliverable | Verification |
|-------|-------------|-------------|--------------|
| **Phase 1** | Planning & Research | Implementation plan | Plan review |
| **Phase 2** | Implementation | Working code | Unit tests |
| **Phase 3** | Integration | Combined system | Integration tests |
| **Phase 4** | Verification | Tested system | All tests pass |
| **Phase 5** | Documentation | Updated docs | Doc review |
| **Phase 6** | Deployment | Production ready | Final sign-off |

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

## THESIS FILE PATHS
- **Source Markdown**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Golden Source (FIXED)**: `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx`
- **Output PDF**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf`
- **Build Script**: `Thesis_Surgical_Edit/build-thesis.ps1`
- **Verification**: `Thesis_Surgical_Edit/style/verify_docx_checks.py`
- **Handoff Plan**: `ClaudeDesktop_HANDOFF_PLAN.md`

## KEY SCRIPTS
- **Pipeline**: `Thesis_Surgical_Edit/run-thesis-pipeline.ps1` (orchestrates build → fixes → verification)
- **Section Fix**: `Thesis_Surgical_Edit/style/fix_docx_sections.py` (single-section layout)
- **Comprehensive Fix**: `Thesis_Surgical_Edit/style/fix_thesis_all.py` (tables, RTL, footers, etc.)
- **Backup**: `scripts/backup-project.ps1` (unified backup)
- **Cleanup**: `scripts/cleanup-workspace.ps1` (workspace cleanup)

## PAGE NUMBERING CONFIGURATION
- **Single section** with `titlePg` (different first page enabled)
- **Cover page**: No page number displayed (uses blank footer1.xml)
- **Page numbering**: Continuous decimal from cover (page 1 hidden, TOC=page 2, body continues)
- **Footer**: `footer2.xml` contains PAGE field (no cached value)

## WHAT WAS ACCOMPLISHED (Session 47e)
1. Workspace cleanup and structure improvements
2. Removed Dropbox conflicts and duplicates
3. Archived stale repos (hermes-agent, quant-mind)
4. Deleted dead code and old backups
5. Created unified backup and cleanup scripts
6. Added context7 MCP for documentation lookup
7. Updated HANDOFF.md with new structure

## NEXT STEPS
1. Launch Claude Desktop GUI for deep verification
2. Follow 7-phase handoff plan in `ClaudeDesktop_HANDOFF_PLAN.md`
3. Open DOCX in Word, Ctrl+A → F9 to update fields
4. Verify page numbers, RTL, table layout
5. Final review and submission

## DEEP VERIFICATION SESSION (Claude Desktop GUI)
1. Launch Claude Desktop GUI (desktop application, not CLI)
2. Read `ClaudeDesktop_DEEP_VERIFICATION.md` for full strategy
3. Follow the 7-step verification process
4. Provide final assessment and sign-off

## HOW TO HELP
- Review thesis content for accuracy
- Check formatting and structure
- Verify academic standards
- Assist with final polish before submission

## ADDITIONAL CONTEXT FILES
- **THESIS_CONTEXT.md**: Detailed thesis information and verification results
- **CrossFlow HANDOFF.md**: Current project status and handoff information
- **MASTER_BOOTSTRAP.xml**: Complete system context and configuration
- **Resume Prompt**: `C:\Users\Administrator\.opencode\resume-prompt.md`
