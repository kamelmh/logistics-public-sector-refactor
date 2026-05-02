---
title: Plugins Inventory
type: inventory
last_updated: 2026-05-02
tags: [plugins, inventory, ai-hubs, opencode, claude]
---

# Plugins Inventory (AI-Hubs)

## Location: `C:\Users\Administrator\AI-Hubs\plugins\`

---

## 1. claude-harden-plugin

**Path:** `AI-Hubs/plugins/claude-harden-plugin/`  
**Agents:** 6 security-focused agents  
**Purpose:** Vulnerability detection, robustness audits, code hardening

### Structure
```
claude-harden-plugin/
├── CLAUDE.md              # Plugin instructions
├── README.md              # Documentation
├── SKILL.md               # Skill definition
├── LICENSE
├── .claude-plugin/
├── agents/                # 6 security agents
├── commands/
└── opencode/
```

### Agents Available
- Vulnerability detection agent
- Robustness audit agent (resource leaks)
- Code hardening agent
- And 3 more specialized security agents

---

## 2. claude-mem

**Path:** `AI-Hubs/plugins/claude-mem/`  
**Purpose:** Persistent vector memory for Claude/OpenCode sessions  
**Agents:** Memory management & state recovery

### Structure
```
claude-mem/
├── CLAUDE.md
├── README.md
├── CHANGELOG.md
├── package.json
├── .claude/
├── .claude-plugin/
├── .github/
├── .plan/
├── cursor-hooks/
├── docs/
├── install/
├── installer/
├── openclaw/
├── plugin/
├── ragtime/
├── scripts/
├── src/
└── tests/
```

### Features
- **Vector Memory:** Persistent across sessions
- **State Recovery:** `opencode/state/` access
- **Session Context:** Maintains project memory
- **Claude-Mem Viewer:** Visual state inspection

---

## 3. everything-claude-code

**Path:** `AI-Hubs/plugins/everything-claude-code/`  
**Agents:** 28 Claude Code agents + 32 OMC agents  
**Purpose:** Comprehensive Claude Code & OMC integration

### Structure
```
everything-claude-code/
├── AGENTS.md              # 28 agents catalog
├── CLAUDE.md
├── README.md
├── CONTRIBUTING.md
├── package.json
├── .agents/
├── .claude/
├── .claude-plugin/
├── .codex/
├── .cursor/
├── .github/
├── .opencode/
├── agents/
├── assets/
├── commands/
├── contexts/
├── docs/
├── examples/
├── hooks/
├── manifests/
├── mcp-configs/
├── plugins/
├── rules/
├── schemas/
├── scripts/
├── skills/
└── tests/
```

### Key Files
- **AGENTS.md:** Complete 28-agent catalog
- **CLAUDE.md:** Project instructions
- **README.md:** Documentation (multi-language)

---

## 4. oh-my-claudecode

**Path:** `AI-Hubs/plugins/oh-my-claudecode/`  
**Purpose:** Multi-agent orchestration layer for Claude Code  
**Version:** 4.9.3

### Structure
```
oh-my-claudecode/
├── AGENTS.md              # OMC agent catalog (32 agents)
├── CLAUDE.md             # OMC instructions
├── README.md             # Documentation (multi-language)
├── package.json
├── .claude-plugin/
├── .github/
├── agents/               # OMC agents
├── assets/
├── benchmark/
├── benchmarks/
├── bridge/
├── dist/
├── docs/
├── examples/
├── hooks/
├── missions/
├── research/
├── scripts/
├── seminar/
├── shellmark/
├── skills/
├── src/
├── templates/
└── tests/
```

### OMC Features
- **32 Agents:** team-plan, architect, executor, planner, etc.
- **Skills Registry:** Available via `omc-reference` skill
- **Team Pipeline:** Multi-agent orchestration
- **Commit Protocol:** Structured commit workflow

---

## Plugin Integration with OpenCode

### OpenCode Skills Location
`C:\Users\Administrator\.opencode\skills\`

| Skill | Path |
|-------|------|
| **claude-review** | `.opencode/skills/claude-review/` |
| **research-codex-en** | `.opencode/skills/research-codex-en/` |
| **research-codex-zh** | `.opencode/skills/research-codex-zh/` |
| **research-en** | `.opencode/skills/research-en/` |
| **research-zh** | `.opencode/skills/research-zh/` |

---

## Plugin Loading Order

### For VBA DSS Project

1. **Load Manifesto:** `MANIFESTO.md` (Clean Room rules)
2. **Load OMC:** `oh-my-claudecode` (multi-agent orchestration)
3. **Load Security:** `claude-harden-plugin` (6 security agents)
4. **Load Memory:** `claude-mem` (persistent state)
5. **Load Skills:** `everything-claude-code` (28 + 32 agents)

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `ai-hub/AGENTS_REGISTRY.md` | Agent catalog (29+ OpenCode, 28 Claude, 32 OMC) |
| `ai-hub/SKILLS_CATALOG.md` | 50+ skills inventory |
| `AI-Hubs/plugins/` | Plugin source files |
| `.opencode/skills/` | OpenCode skills |
| `.claude/skills/` | Claude skills |

---

*End of Plugins Inventory*
