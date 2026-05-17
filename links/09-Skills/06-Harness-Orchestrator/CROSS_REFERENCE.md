# Engineering Harness — Skill Cross-Reference Map

> This file explicitly links the **engineering-harness** skill to ALL 211 skills across 4 ecosystems.
> The harness acts as the central orchestrator, loading and coordinating skills by pipeline.

## 🎯 Harness Layer → Skill Mapping

### s01 Agent Loop
- **Skills**: `engineering-harness` (self), `autopilot`, `ralph`, `ultrawork`
- **Purpose**: Native OpenCode loop with tool dispatch

### s02 Tool Dispatch
- **Skills**: `vba-deployer`, `python-docx-tools`, `thesis-docx`, `thesis-to-docx`, `build`, `verify`
- **Purpose**: Direct tool execution (bash, read, write, edit, build.ps1, verify.ps1)

### s03 TodoWrite
- **Skills**: `project`, `task-automation`, `remember`
- **Purpose**: Session-level checklists, nag at 3+ rounds

### s04 Subagents
- **Skills**: `deepinit`, `graph-thinking`, `explore` (agent), `plan` (agent), `build` (agent), `debug` (agent), `audit` (agent), `test` (agent)
- **Purpose**: Codebase recon, architecture, VBA builds, diagnosis, DSS audit, macro tests

### s05 Skill Loading
- **Skills**: `naming-cheatsheet`, `verify`, `humanizer`, `engineering-harness` (self), `crossflow-orchestrator`
- **Purpose**: Load specialized skills via `skill` tool

### s06 Context Compact
- **Skills**: `semantic-memory`, `remember`, `harvest-context`, `context-optimization`, `context-retrieval`, `context-ranking`, `context-injection`, `context-compression`, `summarization`
- **Purpose**: microcompact + auto-compact + transcripts

### s07 Task System
- **Skills**: `deepinit`, `project`, `version-control`, `task-automation`
- **Purpose**: .tasks/ JSON DAG with blockedBy edges

### s08 Background Tasks
- **Skills**: `task-automation`, `ssd-tools`, `auto-thesis`, `autonomous-iteration`
- **Purpose**: Daemon threads for build.ps1, verify.ps1, dss-audit.ps1

### s09 Agent Teams
- **Skills**: `crossflow-orchestrator`, `crossflow`, `mcp-builder`, `internal-comms`
- **Purpose**: 6 agents + .team/config.json + JSONL inboxes

### s10 Team Protocols
- **Skills**: `crossflow-orchestrator`, `github-workflow`, `path-orchestrator`
- **Purpose**: shutdown_request/response + plan_approval

### s11 Autonomous Agents
- **Skills**: `autonomous-iteration`, `autopilot`, `ralph`, `self-improve`, `ccg`, `ultraqa`
- **Purpose**: idle/claim cycle + auto-claim from .tasks/

### s12 Worktree Isolation
- **Skills**: `version-control`, `workspace-setup`, `path-orchestrator`
- **Purpose**: git worktrees in .worktrees/{name}/

## 📋 Pipeline Skill Bundles

### ERP Pipeline (Build → Verify → Test → Audit)
```
engineering-harness (orchestrator)
├── vba-deployer (s02: write .bas, build.ps1)
├── verify (s02: 174-check validation)
├── naming-cheatsheet (s05: VBA naming conventions)
├── version-control (s07: git commits)
├── code-review (s04: quality analysis)
├── testing (s04: macro test suite)
├── security-audit (s04: vulnerability scanning)
├── task-automation (s08: build automation)
└── algerian-thesis (s05: CNEPD compliance)
```

### Thesis Pipeline (MD → DOCX → PDF → Verify)
```
engineering-harness (orchestrator)
├── auto-thesis (s08: automated build)
├── thesis-docx (s02: DOCX generation)
├── thesis-to-docx (s02: MD→DOCX conversion)
├── python-docx-tools (s02: Word automation)
├── algerian-thesis (s05: CNEPD formatting)
├── technical-writing (s04: content quality)
├── proofreading (s04: text correction)
├── context-optimization (s06: token efficiency)
└── summarization (s06: content condensation)
```

### Maintenance Pipeline (Health → Organize → Commit)
```
engineering-harness (orchestrator)
├── project (s03: operations hub)
├── version-control (s07: git workflows)
├── file-organizer (s03: file organization)
├── task-automation (s08: automation patterns)
├── deepinit (s07: AGENTS.md generation)
├── remember (s06: knowledge persistence)
├── harvest-context (s06: context extraction)
└── graph-thinking (s04: problem solving)
```

### CrossFlow Pipeline (Multi-Window Sync)
```
engineering-harness (orchestrator)
├── crossflow-orchestrator (s09: trio coordination)
├── crossflow (s09: sync protocol)
├── semantic-memory (s06: shared knowledge)
├── mcp-builder (s09: MCP servers)
├── internal-comms (s09: team communication)
├── github-workflow (s10: CI/CD integration)
└── path-orchestrator (s10: file routing)
```

## 🔗 Direct Skill Links

All skills are accessible via the symlink hub:

```
links/09-Skills/
├── 01-Project-Core/          ← 7 core skills
├── 02-Project-Workspace/     ← 5 workspace skills
├── 03-Spectrum-Drivers/      ← 12 driver skills
├── 04-Global-OpenCode/skills ← 106 global OpenCode skills
├── 05-Global-Claude/skills   ← 81 global Claude skills
└── 06-Harness-Orchestrator/  ← Central orchestrator components
```

## 🚀 Loading Order

1. **First**: `engineering-harness` (establishes orchestrator)
2. **Second**: `crossflow-orchestrator` (enables multi-window)
3. **Third**: Pipeline-specific skills (ERP, Thesis, Maintenance, or CrossFlow)
4. **Fourth**: Supporting skills (verify, naming-cheatsheet, etc.)

## 📊 Skill Count by Layer

| Layer | Skills | Category |
|-------|--------|----------|
| s01-s03 | 8 | Core infrastructure |
| s04-s06 | 45 | Analysis & context |
| s07-s09 | 32 | Tasks & teams |
| s10-s12 | 18 | Protocols & isolation |
| Global | 108 | OpenCode + Claude |
| **TOTAL** | **211** | **All ecosystems** |
