# AGENTS.md — Academix v13.2
# Mahi Kamel Abdelghani | Direction de l'Education El Bayadh
# Full context: instructions.md (auto-loaded), .opencode/bootstrap/MASTER_BOOTSTRAP.xml

## GROUND TRUTH (locked — never modify)
D=1546 | Q*=176 | ROP=205.6 | SS=200 | LT=2 days | S=801.45 DZD | I=20%
MASTER_PWD=erp_secure_pwd_2026 | VERSION=v13.2

## CRITICAL RULES
- Pure VBA only — NO Python, NO Flask, NO databases, NO XLOOKUP (Excel 2010 compat)
- Column headers & tab names stay in French
- Fix .bas source files, NOT .xlsm directly (stale p-code cache)
- Never commit without user approval
- Dead code removed: Module1, Module2, mod_Config_Test, mod_StockEntry_Logic_Enhanced, mod_TestHarness, frmSystemLog, frmStockEntry_Enhanced (7 total)

## BUILD & VERIFY
```powershell
# ERP Workbook (uses vbe-auto toolkit)
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"
# Thesis PDF
& "Thesis_Surgical_Edit\build-thesis.ps1"
# Verify (137 checks)
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"
```

## BOOTSTRAP SYSTEM (auto-load on every session start)
Location: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.opencode\bootstrap\`
Contains 4 files:
- `MASTER_BOOTSTRAP.xml` — **READ FIRST** Uber-context: project, paths, agents, skills-map, pipelines, known issues, session persistence, RAG, Ralph map (~180 lines, token-optimized)
- `SKILL_INDEX.md` — All 71 skills categorized by agent type
- `AGENT_BOOTSTRAP.md` — Full model routing, skill mappings, self-hosted guide
- `VBA_BUILDER.md` — VBA-specific build pipeline and rules

### BOOTSTRAP PROTOCOL (every agent, every session)
```
Step 1: Read MASTER_BOOTSTRAP.xml — complete system context
Step 2: Call `skill` tool to load agent-type skills (table below)
Step 3: Read notepad.md — session memory and last actions
Step 4: Run `/memory list` — OMC checkpoint recall
Step 5: Begin work. Save before closing: `/memory save "Done: X | Next: Y"`
```

> Note: `.opencode/erp-context-compact.md` (9.6KB) is a token-optimized snapshot of all 4 XML context files. Read it after MASTER_BOOTSTRAP.xml for a faster, smaller alternative to the raw XMLs.

### SESSION PERSISTENCE (survives disconnects)
When you reconnect after disconnect:
1. instructions.md auto-loads → see BOOTSTRAP PROTOCOL section
2. Read MASTER_BOOTSTRAP.xml → full context restored
3. Read notepad.md → see last-action, resume there
4. Run `/memory recall 0` → restore OMC checkpoint
5. Memory files: notepad.md + project-memory.json + `\.omc\state\sessions\`
6. Auto-save: Update notepad.md `last-action` line on every task completion

### MULTI-SESSION SUPPORT
- `OpenCode <mode> <session-name>` launches named sessions in parallel
- Each session has unique window title: `OpenCode [mode] - name`
- Session log: `\.opencode\memory\last-session-<name>.txt`
- Named sessions don't interfere — separate windows, separate context
- Recommended: `OpenCode groq thesis` and `OpenCode ollama debug` in separate windows

## PROVIDERS & MODELS CONFIGURED

### Cloud — Fast (Free)
| Provider | Model | Context | Speed | Role |
|----------|-------|---------|-------|------|
| **Groq** | Qwen 3 32B | 32K | ~1s | Explore/debug/audit |
| **Google** | Gemini 2.5 Flash | 1M | ~2s | Large context reasoning |
| **Google** | Gemma 4 26B (A4B) | 256K | ~2s | Multimodal, vision, open-weight (Apache 2.0) |
| **Google** | Gemma 4 31B | 32K | ~2s | Stronger reasoning, dense model |



### Working Free 1M Context Alternatives (balance exhausted replacements)
| Model | Context | Provider | Cost | Role | Replaces |
|-------|---------|----------|------|------|----------|
| **Nemotron 120B** | 1M | OpenRouter | FREE | Primary 1M ctx driver | DeepSeek V4-Pro, Quasar Alpha |
| **Ring 2.6 1T (Kimi free)** | 262K | OpenRouter | FREE | Fast explore, agentic coding | DeepSeek V4-Flash |

### Completions.me (26 models, free, unlimited, data logged)
| Tier | Models | Role |
|------|--------|------|
| Claude | Opus 4.6, Opus 4.6-fast, Opus 4.5, Sonnet 4.6, Sonnet 4.5, Sonnet 4, Haiku 4.5 | Primary free unlimited driver |
| GPT | 5.4, 5.3-codex, 5.2, 5.2-codex, 5.1-codex, 5.1, 5-mini, 4o, 4.1, 4o-mini | GPT alternatives, codex variants |
| Gemini | 3.1 Pro (1M ctx), 3 Pro, 3 Flash, 2.5 Pro | 1M context via completions |
| Other | Grok Code Fast 1, OSWE VSCode Prime/Secondary | Specialized coding |

### Local Gateway — FreeLLM (localhost:3000, 8 providers aggregated)
| Route | Backend | Model | Limits | Status |
|-------|---------|-------|--------|--------|
| `free` | auto | Auto-route (max uptime) | ~150 req/min | ✅ Active |
| `free-fast` | auto | Lowest latency (Groq→Cerebras→Gemini→NIM) | ~150 req/min | ✅ Active |
| `free-smart` | auto | Best reasoning (Gemini→NIM→Groq) | ~150 req/min | ✅ Active |
| `nim/nemotron-70b` | **NVIDIA NIM** | Nemotron 70B | ~40 req/min | ❌ Skipped (SMS) |
| `cerebras/gpt-oss-120b` | **Cerebras** | GPT-OSS 120B | ~30 req/min | ✅ Active |
| `cerebras/qwen3-235b` | **Cerebras** | Qwen3 235B | ~30 req/min | ✅ Active |
| `cf/kimi-k2` | **Cloudflare** | Kimi K2 (Ring 2.6) | ~20 req/min | ❌ Not in FreeLLM models |
| `gh/phi-4` | **GitHub Models** | Phi-4, GPT-4o-mini | ~15 req/min | ✅ Active |

### Local — Self-Hosted (Ollama, CPU-only)
| Model | Params | Speed | RAM | Role |
|-------|--------|-------|-----|------|
| Qwen 2.5 Coder 7B | 7B | ~30s/req | ~7GB | Offline moderate |
| Qwen 2.5 Coder 1.5B | 1.5B | ~95s/req | ~3GB | Offline slow fallback |
| Phi4-mini 3.8B | 3.8B | ~25s/req | ~2.5GB | CPU coding (best quality) |
| Qwen3 1.7B | 1.7B | ~40s/req | ~1.4GB | CPU reasoning |
| Gemma 4 e2b | 2B (eff.) | ~40-60s/req | ~3GB | Offline Gemma 4 (128K, image+text) |


## DEFAULT MODEL RULE OF THUMB
- `oc` / `ol` → **Gemini 2.5 Flash** — fast VBA edits, prose, daily driving (zero rate limits, ~2s)
- `og` → **Qwen3 32B** — fastest explore/debug/audit (~1s)
- `ogg` → **Gemma 4 26B** — 256K context, multimodal, own Google AI Studio key
- `oggl` → **Gemma 4 e2b (local)** — 128K context, offline fallback (Ollama)
- `ogm` → **Gemini 2.5 Flash** — 1M context, thesis-wide analysis, vision/PDF, deep reasoning
- `on` → **Nemotron 120B** — 1M context, OpenRouter free (replaces DeepSeek V4-Pro)
- `ophi4` → **Phi4-mini 3.8B** — offline CPU coding (best quality local)
- `oo` → **Qwen 1.5B** — offline fallback (slow)
- `opicker` → **Model picker TUI** — interactive grid with live Ollama status
- `on` → **Nemotron 120B** — 1M context, OpenRouter free (replaces DeepSeek V4-Pro)

## AGENT ROUTING

*Note: VBA-specific skills (vba-build, vba-debug) exist on disk at `.opencode/skills/` but aren't in OpenCode's global skill catalog. VBA domain knowledge is loaded via instructions.md + XML context files instead.*

| Agent | Model | Skills to Load | Purpose |
|-------|-------|---------------|---------|
| `build` | Gemini 2.5 Flash | naming-cheatsheet, humanizer, github-workflow.skill, mcp-builder.skill | VBA code writing & fixes |
| `(mode) crossflow` | CrossFlow sync | crossflow-orchestrator | Multi-window sync + handoff |
| `plan` | Gemini 2.5 Flash | plan, planning-and-task-breakdown, idea-refine, main-brain.skill, doc-coauthoring.skill | Architecture planning |
| `explore` | Groq Qwen 32B | (read-only), web-artifacts-builder.skill | Codebase search |
| `debug` | Groq Qwen 32B | verify | VBA error diagnosis |
| `audit` | Groq Qwen 32B | verify, algerian-thesis.skill | 5-phase DSS audit |
| `test` | Groq Qwen 32B | project, verify | Macro test suite |
| `or-free` | FreeLLM `free` route | naming-cheatsheet, humanizer | Auto-routed via FreeLLM gateway |
| `or-oss` | FreeLLM `free-smart` route | (instructions.md context) | Auto-routed via FreeLLM gateway |
| `or-ring` | FreeLLM `cf/kimi-k2` (when key set) | (all skills) | Cloudflare Kimi K2 via FreeLLM |
| `or-coder` | FreeLLM `cerebras/qwen3-235b` (when key set) | naming-cheatsheet | Cerebras Qwen3 235B via FreeLLM |
| (mode) `gemini-flash` | Gemini 2.5 Flash | external-context | Large context (1M) |
| (mode) `gemma-4` | Gemma 4 26B | naming-cheatsheet | Hosted free (Google AI Studio) |
| (mode) `gemma-4-local` | Gemma 4 e2b | naming-cheatsheet | Offline fallback (Ollama, 128K) |
| (mode) `ollama-local` | Qwen 1.5B CPU | (slow) | Offline fallback |

## DESKTOP LAUNCHERS (Portable — v3.4)
### Project Root (`Logistics.Public.Sector.Refactor/`)
- `OpenCode.bat` — Single portable entry point with 23 modes (`%~dp0`-relative, finds opencode.exe via search: self dir > bin/ > Desktop baseline > PATH)
- `Academix_Launch.bat` — Standalone dashboard launcher (`%~dp0`-relative to academix-launcher.ps1)

### Desktop Shortcut
- `OpenCode.lnk` → `Project Root\OpenCode.bat` (opens in project root)

### Baseline Folder (`Desktop\opencode-windows-x64-baseline\`)
- `opencode.exe` only — pure binary, no scripts

### OpenCode.bat Modes:
  - `OpenCode` — CLI default (big-pickle)
  - `OpenCode gui` — Desktop GUI (v1.14.42)
  - `OpenCode groq` — Groq Qwen3 32B (fast explore/debug)
  - `OpenCode nemotron` / `on` — Nemotron 120B (1M ctx, OpenRouter free)
  - `OpenCode fcc` — CLI via free-claude-code proxy (Nemotron 120B, auto-start)
  - `OpenCode gemini` — Google Gemini 2.5 Flash (1M ctx)
  - `OpenCode gemma` / `ogg` — Google Gemma 4 26B (256K, multimodal)
  - `OpenCode gemma-local` / `ogg-local` — Ollama Gemma 4 e2b (128K, offline)
  - `OpenCode phi4` — Ollama Phi4-mini 3.8B (CPU coding)
  - `OpenCode qwen3` — Ollama Qwen3 1.7B (CPU reasoning)
  - `OpenCode ollama` — Ollama server + interactive model picker (4 models)
  - `OpenCode proxy` — Start FCC proxy only (background)
  - `OpenCode academix` — Interactive project dashboard
  - `OpenCode restore` — Restore last session
  - `OpenCode picker` / `op` — Interactive model picker (TUI, arrow-key nav, live Ollama status)
  - `OpenCode completions` — Completions.me (free, 26 models, incl. Claude Opus 4.6)
  - `OpenCode <mode> <name>` — Named multi-session (e.g. `OpenCode groq thesis`)
  - Pipeline modes: autobuild, autoverify, autotest, autoaudit, autothesis, autocheck, autofix, autoplan, autolog, automenu, autoclean, status

AUTO Pipeline modes (`OpenCode autobuild`, `autoverify`, `autotest`, `autoaudit`, `autothesis`, `autocheck`, `autofix`, `autoplan`):
Run pipeline scripts in the terminal window. `autofix` runs the full chain end-to-end.

Logging mode: `OpenCode autolog <mode>` captures output to `logs/` directory.
Menu mode: `OpenCode automenu` shows interactive mode selector.

## AUTO COMMANDS (slash commands in chat)
9 commands in `.opencode/commands/` — Tab-completable in chat:
- `/auto build|verify|test|audit|thesis|check|plan|fix` — Multi-purpose AUTO command
- `/autobuild` — Build + verify
- `/autoverify` — 137 verification checks
- `/autotest` — Macro test suite
- `/autoaudit` — 5-phase DSS audit
- `/autofix` — Full pipeline
- `/autoplan` — Planning workflow
- `/autocheck` — System health + git status
- `/autothesis` — Build thesis PDF

PowerShell profile also has corresponding functions: `autobuild`, `autoverify`, `autotest`, `autoaudit`, `autocheck`, `autofix`.

## HANDOFF PROTOCOLS
1. **VBA Debug**: Read `.crossflow\HANDOFF.md` → diagnose → fix .bas → build.ps1 → verify.ps1 → report
2. **Multi-Agent Sync**: `.crossflow\HANDOFF.md` is the single source of truth across all agents (main-hub, gemini-thesis, gemma-4, claude-project). All agents read/write here.
3. **Thesis**: `Thesis_Surgical_Edit/SESSION_HANDOFF.md` — resume any session

## LOST-SESSION RECOVERY WORKFLOW
How to resume after computer shutdown or session loss:

1. **Launch**: `OpenCode` (or `OpenCode.bat`) from Desktop
   - Default model: `opencode/big-pickle` (CLI mode)
   - For large context: `OpenCode gemini` (1M ctx)
   - For offline: `OpenCode phi4`

2. **Auto-loads**: instructions.md → MASTER_BOOTSTRAP.xml → notepad.md

 3. **Manual recall** (if context is stale):
    - `C:\Users\Administrator\.config\opencode\AGENTS.md` — config & routing
    - `C:\Users\Administrator\.omc\state\sessions\memory-checkpoint-latest.md` — OMC checkpoint
    - `.crossflow\HANDOFF.md` — multi-agent sync state (all agents read/write here)

4. **Verify paths** (PowerShell):
   ```powershell
   Test-Path "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm"         # Active workbook
    Test-Path "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.2.xlsm"  # Default workbook
   ```

5. **Build check**: `build` (rebuilds .xlsm from .bas), then `verify` (137 checks)

6. **Resume**: Read notepad.md `last-action` line, continue from there

### Memory Hierarchy (most recent first)
1. `C:\Users\Administrator\.opencode\notepad.md` — Session memory (last activity)
2. `C:\Users\Administrator\.config\opencode\instructions.md` — Full project context (auto-loaded)
3. `C:\Users\Administrator\.config\opencode\AGENTS.md` — Agent config & model routing
4. `C:\Users\Administrator\.omc\state\sessions\memory-checkpoint-latest.md` — OMC checkpoint
5. `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.opencode\bootstrap\MASTER_BOOTSTRAP.xml` — Uber-context (read first)
6. `.crossflow\HANDOFF.md` — multi-agent sync state (all agents read/write here)
6. `Dropbox/Logistics.Public.Sector.Refactor/.opencode/erp-context-compact.md` — Token-optimized snapshot (9.6KB, all 4 XMLs)
7. `Dropbox/Logistics.Public.Sector.Refactor/Thesis_Surgical_Edit/SESSION_HANDOFF.md` — Thesis state
8. XML files in `Software_Surgical_Edit/*.xml` — ERP context files

## HOSTED SKILLS (72 in `.opencode/skills/`)
| Category | Skills | Purpose |
|----------|--------|---------|
| VBA Development (6) | (disk-only — not in global catalog; load via XML context) | VBA coding, debugging, workbook management |
| Agent Orchestration (10) | crossflow-orchestrator (NEW) + existing 9 | Multi-window session coordination (براءة اختراع) |
| Git/Version (3) | conventional-commit, changelog-generator, github-ops | Git workflow, PRs, changelogs |
| Code Quality (5) | naming-cheatsheet, humanizer, ai-slop-cleaner, verify, claude-review | Code review, naming, text quality |
| Planning (7) | plan, planning-and-task-breakdown, idea-refine, deep-dive, deep-interview, ralplan, ideation | Architecture, task breakdown, research |
| Agent Orchestration (9) | team, orchestrate, ultrawork, autopilot, ralph, self-improve, sciomc, ccg, ultraqa | Multi-agent, parallel execution, QA cycles |
| Debug/Trace (2) | debug, trace | Session/repo diagnostics |
| Research (9) | external-context, context7-docs, web-to-markdown, wiki, harvest-context, context-injection, context-optimization, context-ranking, context-retrieval | Web search, doc fetch, RAG |
| Testing (2) | project, visual-verdict | Test generation, visual QA |
| Setup/MCP (5) | mcp-setup, init-project, joc-setup, joc-doctor, joc-reference | Infrastructure, MCP servers |
| Utility (5) | remember, skill-creator, skillify, writer-memory, learner | Knowledge management, skill creation |
| Other (17) | ui/mui, design-system-starter, icon-generator, professional-communication, deliberate-practice, graph-thinking, agent-md-refactor, opencode-agent-creator, opencode-command-creator, cancel, hud, ask, project-session-manager, dependency-updater, file-organizer, release, craft-ef-readme | Specialized tools |

## XML CONTEXT FILES (35KB total, token-optimized)
All in `Software_Surgical_Edit/`:
- `erp-project-context.xml` (17KB) — Architecture, modules, sheets, call graph, config params
- `erp-admin-paths.xml` (14KB) — All file paths, AI backends, desktop launchers
- `erp-agent-handoff.xml` (6KB) — Agent routing, ground truth, task queue, session state
- `erp-skills-projection.xml` (5KB) — Skills mapped to code regions, security/testing targets

Plus `.opencode/bootstrap/MASTER_BOOTSTRAP.xml` — **READ FIRST** (~5KB, 180 lines, uber-context)

## KNOWN VBA ISSUES (FIXED)
- UTF-8 em dashes in .bas → VBA syntax errors (replace with -)
- Public Const after procedures → syntax error (move before)
- Public Const MASTER_PWD cross-module → use Property Get
- Stale p-code cache → always rebuild from scratch
- Comments between _ continuations → VBA parser breaks

## SELF-HOSTED FALLBACK (Ollama-only offline mode)
For fully offline operation (no cloud APIs):
```powershell
opencode --model ollama/qwen2.5-coder:1.5b
```
Or use desktop launcher: `OpenCode.bat ollama` (or `OpenCode ollama` via shortcut). Available models:
- `phi4` — Phi4-mini 3.8B (~25s/req, 2.5GB, best CPU coding)
- `qwen3` — Qwen3 1.7B (~40s/req, 1.4GB, CPU reasoning)
- `ollama` — Interactive model picker (all 4 local models)
- `gemma-local` — Gemma 4 e2b (~40-60s/req, 7.2GB, 128K ctx, text+image)
- Default ollama: Qwen 2.5 1.5B (~95s/req, 0.58 t/s)

## ENV VARS
GEMINI_API_KEY | ANTHROPIC_API_KEY_BACKUP | VERCEL_AI_API_KEY
OPENAI_API_KEY | OPENAI_API_KEY_BACKUP | OPENROUTER_API_KEY
DEEPSEEK_API_KEY
