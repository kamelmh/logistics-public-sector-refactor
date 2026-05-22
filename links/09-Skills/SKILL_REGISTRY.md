# 🔗 Academix v13.2 — Unified Skill Registry

> **211 skills across 4 ecosystems**, orchestrated by the Engineering Harness (s01-s12).
> All skills are symlinked through `links/09-Skills/` for unified access.

## 🏗️ Engineering Harness — Central Orchestrator

The **engineering-harness** skill is the central nervous system that connects and coordinates all other skills:

```
                    ┌─────────────────────────────────────────┐
                    │     ENGINEERING HARNESS (s01-s12)       │
                    │   links/09-Skills/06-Harness-Orchestrator│
                    └──────────────┬──────────────────────────┘
                                   │
           ┌───────────────────────┼───────────────────────┐
           │                       │                       │
    ┌──────▼──────┐         ┌──────▼──────┐         ┌──────▼──────┐
    │  CORE SKILLS │         │ WORKSPACE   │         │  SPECTRUM   │
    │  (7 skills)  │         │ (5 skills)  │         │ (12 drivers)│
    └──────┬──────┘         └──────┬──────┘         └──────┬──────┘
           │                       │                       │
           └───────────────────────┼───────────────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │    GLOBAL SKILLS (187)      │
                    │  OpenCode: 106 | Claude: 81 │
                    └─────────────────────────────┘
```

## 📂 Skill Ecosystem Map

### 01-Project-Core (7 skills)
| Skill | Purpose | Harness Layer |
|-------|---------|---------------|
| `crossflow` | Multi-window sync protocol | s09-s10 |
| `crossflow-orchestrator` | Trio coordination (Scout/Surgeon/Architect) | s09-s11 |
| `python-docx-tools` | Thesis DOCX generation pipeline | s02 |
| `semantic-memory` | Project knowledge persistence | s06 |
| `ssd-tools` | Storage optimization | s08 |
| `vba-deployer` | ERP workbook deployment | s02-s05 |
| `workspace-setup` | Project initialization | s07 |

### 02-Project-Workspace (5 skills)
| Skill | Purpose | Harness Layer |
|-------|---------|---------------|
| `auto-thesis` | Automated thesis build pipeline | s08 |
| `autonomous-iteration` | Self-improving code cycles | s11 |
| `engineering-harness` | **CENTRAL ORCHESTRATOR** | s01-s12 |
| `thesis-docx` | DOCX formatting & generation | s02 |
| `thesis-to-docx` | Markdown to DOCX conversion | s02 |

### 03-Spectrum-Drivers (12 skills)
| Skill | Purpose | Category |
|-------|---------|----------|
| `algerian-thesis` | CNEPD thesis formatting | Academic |
| `algorithmic-art` | Algorithmic visualization | Creative |
| `brand-guidelines` | Brand identity management | Design |
| `canvas-design` | Canvas-based design tools | Design |
| `doc-coauthoring` | Collaborative document editing | Writing |
| `github-workflow` | GitHub CI/CD integration | DevOps |
| `internal-comms` | Team communication patterns | Management |
| `mcp-builder` | MCP server/client creation | Integration |
| `path-orchestrator` | File path management | Utility |
| `slack-gif-creator` | Slack GIF generation | Creative |
| `theme-factory` | UI theme generation | Design |
| `web-artifacts-builder` | Web component generation | Development |

### 04-Global-OpenCode (106 skills)
Key skills for Academix v13.2:
| Skill | Purpose | Used By |
|-------|---------|---------|
| `engineering-harness` | Full agent spectrum | All agents |
| `verify` | Change verification | Build/Debug |
| `naming-cheatsheet` | Naming conventions | Build |
| `project` | Project operations | All |
| `version-control` | Git workflows | All |
| `file-organizer` | File organization | Maintenance |
| `task-automation` | Automation patterns | s08 |
| `graph-thinking` | Non-linear problem solving | Plan |
| `deepinit` | AGENTS.md generation | s07 |
| `remember` | Knowledge persistence | s06 |
| `harvest-context` | Context extraction | s06 |
| `context-optimization` | Context refinement | s06 |
| `crossflow-orchestrator` | Multi-window sync | s09 |
| `algerian-thesis` | CNEPD compliance | Thesis |

### 05-Global-Claude (81 skills)
Key skills for Academix v13.2:
| Skill | Purpose | Used By |
|-------|---------|---------|
| `context-optimization` | Context refinement | s06 |
| `context-retrieval` | RAG retrieval | s06 |
| `context-ranking` | Relevance scoring | s06 |
| `context-injection` | Context grounding | s06 |
| `code-review` | Code quality analysis | Audit |
| `testing` | Test generation | Test |
| `refactoring` | Code improvement | Build |
| `debugging` | Error diagnosis | Debug |
| `security-audit` | Vulnerability scanning | Audit |
| `technical-writing` | Documentation | Thesis |
| `proofreading` | Text correction | Thesis |
| `summarization` | Text condensation | s06 |

## 🔗 Skill Relationship Graph

### Core Dependencies
```
engineering-harness
├── crossflow-orchestrator (multi-window sync)
├── verify (change validation)
├── naming-cheatsheet (code quality)
├── project (operations hub)
├── version-control (git workflows)
├── task-automation (s08 background tasks)
├── graph-thinking (planning/architecture)
├── deepinit (s07 task documentation)
├── remember (s06 context persistence)
├── harvest-context (s06 context extraction)
└── context-optimization (s06 token efficiency)
```

### Thesis Pipeline Skills
```
auto-thesis
├── thesis-docx (DOCX generation)
├── thesis-to-docx (MD→DOCX conversion)
├── python-docx-tools (Word automation)
├── algerian-thesis (CNEPD formatting)
├── technical-writing (content quality)
├── proofreading (text correction)
└── context-optimization (token efficiency)
```

### ERP Pipeline Skills
```
vba-deployer
├── engineering-harness (orchestration)
├── verify (174-check validation)
├── naming-cheatsheet (VBA naming)
├── version-control (git commits)
├── code-review (quality analysis)
├── testing (macro test suite)
└── task-automation (build automation)
```

## 🚀 Quick Skill Loading

### Load All Core Skills (One Command)
```powershell
# In OpenCode session:
skill engineering-harness
skill crossflow-orchestrator
skill verify
skill naming-cheatsheet
skill project
skill version-control
skill task-automation
skill graph-thinking
skill deepinit
skill remember
skill harvest-context
skill context-optimization
```

### Load by Pipeline
```powershell
# ERP Pipeline
skill engineering-harness
skill vba-deployer
skill verify
skill naming-cheatsheet

# Thesis Pipeline
skill auto-thesis
skill thesis-docx
skill algerian-thesis
skill technical-writing

# Maintenance Pipeline
skill project
skill version-control
skill file-organizer
skill task-automation
```

## 📊 Skill Statistics

| Category | Count | Status |
|----------|-------|--------|
| Project Core | 7 | ✅ Active |
| Project Workspace | 5 | ✅ Active |
| Spectrum Drivers | 12 | ✅ Active |
| Global OpenCode | 106 | ✅ Available |
| Global Claude | 81 | ✅ Available |
| **TOTAL** | **211** | **✅ All Linked** |

## 🔧 Maintenance

- Symlinks auto-repair via `scripts/harness.ps1`
- New skills auto-discovered on next health check
- Registry updated via `/harvest-context codebase`
- Broken links detected by `system-health-maintenance.ps1`
