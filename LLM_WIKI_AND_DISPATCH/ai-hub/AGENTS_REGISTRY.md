---
title: Agents Registry
type: registry
last_updated: 2026-05-02
tags: [agents, registry, opencode, claude, omc]
---

# Agents Registry

## OpenCode Agents (29+ Available)

### Exploration & Research

| Agent | Purpose | Model | Use Case |
|-------|---------|-------|----------|
| **explorer** | Fast codebase exploration | haiku/sonnet | Find files, search patterns |
| **general** | Multi-step research & execution | sonnet | Complex tasks, multiple steps |
| **recon** | Project detection (lang, framework) | haiku | Initial project setup |
| **web-search** | Internet research | sonnet | Debugging, technical solutions |
| **web-search-modules/github-debug** | GitHub-specific search | sonnet | Debug GitHub issues |
| **web-search-modules/stackoverflow** | StackOverflow search | sonnet | Programming solutions |

### Code Quality & Security

| Agent | Purpose | Model | Use Case |
|-------|---------|-------|----------|
| **debug-audit** | Error handling, logging, observability | sonnet | Debugging infrastructure |
| **robustness-audit** | Edge cases, leaks, race conditions | sonnet | Code quality checks |
| **security-audit** | OWASP Top 10, CWE mapping | opus | Security reviews |
| **static-application-security-testing** | SAST analysis | opus | Static security scanning |
| **accessibility-audit** | WCAG 2.2 Level A/AA audit | sonnet | Web accessibility |

### Testing & Execution

| Agent | Purpose | Model | Use Case |
|-------|---------|-------|----------|
| **test-runner** | Discover tests, verify build | sonnet | Testing & coverage |
| **executor** | Implementation (standard coding) | sonnet | VBA refactoring, standard tasks |

### Specialized

| Agent | Purpose | Model | Use Case |
|-------|---------|-------|----------|
| **web-search-modules/academic-papers** | Academic research | sonnet | Research papers |
| **web-search-modules/chinese-tech** | Chinese tech sources | sonnet | Localized tech info |
| **web-search-modules/general-web** | General web search | sonnet | Broad research |

---

## Oh-My-Claudecode (OMC) Agents

### Planning & Architecture

| Agent | Model | Purpose |
|--------|-------|---------|
| **team-plan** | opus | High-level planning (4-chapter thesis) |
| **planner** | opus | Task decomposition |
| **architect** | opus | System design, VBA processing units mapping |

### Execution

| Agent | Model | Purpose |
|--------|-------|---------|
| **executor** | sonnet | Implementation (standard coding tasks) |
| **debugger** | sonnet | Root-cause analysis |

### Orchestration

| Agent | Model | Purpose |
|--------|-------|---------|
| **ralph** | sonnet | Specialized tasks |
| **team** | Mixed | Multi-agent orchestration |

---

## Claude Code Agents (28 Available via Everything Claude Code)

Reference: `AI-Hubs/plugins/everything-claude-code/AGENTS.md`

### Available Agents
- **architect** (opus) - System design
- **executor** (sonnet) - Implementation
- **planner** (opus) - Planning
- **code-reviewer** (sonnet) - Post-implementation review
- **debugger** (sonnet) - Bug diagnosis
- **tester** (sonnet) - Test generation & execution
- And 22 more agents...

---

## Claude-Mem Agents (Persistent Memory)

### Memory Management
- **claude-mem plugin** - Vector memory management
- **State Recovery:** `opencode/state/` or Claude-Mem viewer
- **Session Context:** Persistent across sessions

---

## Agent Selection Protocol

### Decision Tree

```
Task Type?
├── Exploration → explorer (haiku/sonnet)
├── Research → general (sonnet) or web-search (sonnet)
├── Implementation → executor (sonnet) or architect (opus)
├── Planning → team-plan (opus) or planner (opus)
├── Security → security-audit (opus) or robustness-audit (sonnet)
├── Testing → test-runner (sonnet)
├── Debugging → debugger (sonnet) or debug-audit (sonnet)
└── Orchestration → team (mixed) or ralph (sonnet)
```

### Model Selection

| Task Complexity | Model | Agent Example |
|-----------------|-------|----------------|
| Simple (< 1hr) | haiku | explorer (quick lookup) |
| Standard | sonnet | executor (VBA coding) |
| Deep analysis | opus | architect (system design) |
| Research | gemini | (external, via NotebookLM) |

---

## Agentic Workflow (from Gemini Export)

> "We have your `.agentic-hub` mounted as the single source of truth."

### Available Deployment Capabilities

1. **OpenCode Subsystems:** 29 agents available
   - **architect** for system design
   - **executor** for implementation
   - **debugger** for root-cause analysis

2. **Claude Code Operations:** 28 agents (Everything Claude Code) + 32 agents (OMC)
   - Commands: `/team 3:executor "fix all errors"`
   - Commands: `/orchestrate`

3. **Security & Auditing:** `claude-harden-plugin` (6 agents)
   - Vulnerability detection
   - Robustness audits (resource leaks)
   - Code hardening

4. **Persistent State:** Session context via `claude-mem` plugin
   - State recovery: `opencode/state/`
   - Claude-Mem viewer

---

## OMC Commands Quick Reference

| Command | Agent Dispatched | Model |
|---------|------------------|-------|
| `/team 3:executor "fix errors"` | executor | sonnet |
| `/orchestrate` | team-plan + architect | opus |
| `/ultrawork` | Multiple agents | Mixed |
| `/ralph` | ralph | sonnet |
| `/oh-my-claudecode:research` | research | sonnet |
| `/claude-review` | claude-review | sonnet |

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `ai-alignment/MODEL_DISPATCH.md` | Model selection matrix |
| `ai-alignment/AGENT_PROTOCOLS.md` | Agent protocols |
| `ai-alignment/DISPATCH_ALERTS.md` | Wrong agent detection |
| `ai-hub/SKILLS_CATALOG.md` | 50+ skills inventory |
| `AI-Hubs/plugins/` | Plugin definitions |

---

*End of Agents Registry*
