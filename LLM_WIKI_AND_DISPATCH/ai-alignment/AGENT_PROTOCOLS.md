---
title: Agent Protocols
type: protocols
last_updated: 2026-05-02
tags: [agents, omc, opencode, claude, protocols]
---

# Agent Protocols (OMC/OpenCode)

## Available Agent Types

### OpenCode Agents (29+ available)

| Agent Type | Purpose | When to Use |
|------------|---------|--------------|
| **explorer** | Fast codebase exploration | Finding files, searching code patterns |
| **general** | Multi-step research & execution | Complex tasks requiring multiple steps |
| **recon** | Project language/framework detection | Initial project setup |
| **robustness-audit** | Edge cases, leaks, race conditions | Code quality checks |
| **security-audit** | OWASP Top 10, CWE mapping | Security reviews |
| **test-runner** | Discover tests, verify build | Testing & coverage |
| **web-search** | Internet research | Debugging, technical solutions |

### Oh-My-Claudecode Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **team-plan** | opus | High-level planning (4-chapter thesis) |
| **architect** | opus | System design, VBA processing units mapping |
| **executor** | sonnet | Implementation (standard coding tasks) |
| **planner** | opus | Task decomposition |
| **debugger** | sonnet | Root-cause analysis |
| **code-reviewer** | sonnet | Post-implementation review |

### Claude-Mem Agents (Persistent Memory)

- **Memory Management:** `claude-mem` plugin for vector memory
- **State Recovery:** `opencode/state/` or Claude-Mem viewer
- **Session Context:** Persistent across sessions

---

## Agent Selection Protocol

### Step 1: Identify Task Type
```
Is this a codebase exploration? → explorer
Is this implementation? → executor (sonnet) or architect (opus)
Is this security/audit? → security-audit or robustness-audit
Is this planning? → team-plan or planner (opus)
Is this testing? → test-runner
```

### Step 2: Check Model Dispatch
Cross-reference with `MODEL_DISPATCH.md`:
- Quick task → haiku
- Standard → sonnet
- Deep analysis → opus
- Research → gemini

### Step 3: Verify Agent Availability
Check `.omc/` or `AI-Hubs/plugins/` for agent definitions.

---

## OMC Integration

### Using `/oh-my-claudecode:` Commands

| Command | Agent Dispatched | Model |
|---------|------------------|-------|
| `/team 3:executor "fix errors"` | executor | sonnet |
| `/orchestrate` | team-plan + architect | opus |
| `/ultrawork` | Multiple agents | Mixed |
| `/ralph` | ralph agent | sonnet |

### Agentic Workflow (from Gemini export)

> "We have your `.agentic-hub` mounted as the single source of truth."

1. **OpenCode Subsystems:** 29 agents available
2. **Claude Code Operations:** Everything Claude Code (28 agents) + OMC (32 agents)
3. **Security & Auditing:** `claude-harden-plugin` (6 agents)
4. **Persistent State:** Session context via `claude-mem` plugin

---

## Agent Self-Check Protocol

Before executing, agents must:

1. **Read `MANIFESTO.md`** - Confirm "Clean Room" constraints
2. **Check `MODEL_DISPATCH.md`** - Verify correct model
3. **Identify Workspace** - Thesis (`Thesis_Surgical_Edit`) or Software (`Software_Surgical_Edit`)
4. **Warn if Mismatch** - Use templates from `DISPATCH_ALERTS.md`

---

## Specialized Agent Rules

### For VBA DSS Refactoring
- **Use:** `executor` (sonnet) or `architect` (opus)
- **No:** Python bridges, JSON APIs, external dependencies
- **Yes:** Pure VBA arrays, local Sheet storage, UserForms

### For Thesis Writing (Arabic RTL)
- **Use:** `team-plan` (opus) for structure, `executor` (sonnet) for drafting
- **No:** Technical terminology (Database, Python, Algorithm)
- **Yes:** Administrative vocabulary (السجل الرقمي, وحدات المعالجة VBA)

### For NotebookLM Alignment
- **Use:** Gemini (external), then align with Claude/OpenCode
- **No:** Direct NotebookLM access in Claude/OpenCode
- **Yes:** Export → Paste in `GEMINI_ALIGNMENT.md` → Execute

---

## Agent Communication Protocol

### Task Delegation Format
```
Task: [description]
Model: [haiku/sonnet/opus/gemini]
Agent: [agent-type]
Workspace: [Thesis_Surgical_Edit / Software_Surgical_Edit]
Constraints: [Manifesto rules apply]
Context: [Repomix file if needed]
```

### Status Updates
- ✅ Complete
- 🔄 In Progress
- ⏳ Pending
- ⚠️ Warning (model mismatch, constraint violation)

---

*End of Agent Protocols*
