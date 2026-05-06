# Skills Configuration — ERP Académie v13.2
# AI Skills Hub for Agentic Collaboration
# Generated: 2026-05-06

## Active Skills

### Core Skills (Always Available)
- `context-injection` — Structured context templates for Groq
- `context-optimization` — Deduplicate, filter, reorder, score context
- `context-ranking` — Rank context chunks by relevance
- `context-retrieval` — RAG-based context retrieval
- `version-control` — Git workflow, branching, conflict resolution

### Development Skills
- `refactoring` — Code quality improvement patterns
- `testing` — Test generation and coverage
- `security-audit` — Security vulnerability scanning
- `code-review` — Code review against conventions
- `technical-writing` — Technical documentation
- `report-generation` — Professional report generation

### OMC Skills (OpenCode Multi-Agent)
- `omc-reference` — OMC agent catalog, team pipeline, commit protocol
- `team` — Coordinated team orchestration
- `ccg` — Codex + Gemini + Claude synthesis lane
- `ultraqa` — QA cycle: test, verify, fix, repeat
- `deepinit` — Hierarchical AGENTS.md generation

### Workflow Triggers
| Trigger | Skill | Description |
|---------|-------|-------------|
| `"autopilot"` | autopilot | Full autonomous execution from idea to working code |
| `"ralph"` | ralph | Persistence loop until completion with verification |
| `"ulw"` | ultrawork | High-throughput parallel execution |
| `"ccg"` | ccg | Codex + Gemini + Claude synthesis lane |
| `"deslop"` | ai-slop-cleaner | Regression-safe cleanup workflow |
| `"deep-analyze"` | analysis mode | Deep analysis mode |
| `"tdd"` | TDD mode | Test-driven development mode |
| `"deepsearch"` | codebase search | Deep codebase search |
| `"ultrathink"` | deep reasoning | Deep reasoning mode |

## Skills Enablement Protocol

1. **On Session Start:** All skills are available via `/skill <name>`
2. **Context-Aware:** Skills activate based on trigger words in conversation
3. **Token-Efficient:** Skills load only when needed — never all at once
4. **Cross-Agent:** OMC skills enable multi-model collaboration (Claude, Groq, Codex, Gemini)

## OMC Integration

### Team Pipeline
```
team-plan → team-prd → team-exec → team-verify → team-fix (loop)
```

### Agent Routing
| Task | Agent | Model |
|------|-------|-------|
| VBA code edit | `executor` | sonnet |
| Architecture design | `architect` | opus |
| Code review | `code-reviewer` | opus |
| Debug | `debugger` | sonnet |
| Testing | `test-engineer` | sonnet |
| Documentation | `writer` | haiku |
| Requirements | `analyst` | opus |
| Planning | `planner` | opus |

### Commands
- `/team N:executor "task"` — Delegate to specific agent
- `omc ask <claude|codex|gemini>` — Query external AI
- `/ccg` — Multi-model synthesis
- `state_read` / `state_write` — OMC state management

## Free Claude Code Integration

Claude Code is available at:
- Path: `C:\Users\Administrator\.claude\`
- Skills: `C:\Users\Administrator\.claude\skills\`
- Config: `C:\Users\Administrator\.claude\CLAUDE.md`

**Integration Points:**
1. Use `/oh-my-claudecode:<skill>` to activate Claude-specific workflows
2. Claude can read/write the same XML context files as Groq
3. Shared state via `erp-agent-handoff.xml`
4. Git commits preserve decision context across both AIs

## Workspace Automation

### Context Injection Pipeline
```
Session Start → Read context.md → Activate trigger → Load XML files → Ready
```

### Memory Management
1. `/memory list` — Check previous session state
2. `/memory save "Done: X | Open: Y | Next: Z"` — Save state before exit
3. Context auto-injected on next session start

### Token Optimization
1. Use `context-optimization` skill to compress context
2. Load skills only when needed (not all at once)
3. Use `/session reset` before hitting 90% tokens
4. Keep trigger words concise — they activate full context
