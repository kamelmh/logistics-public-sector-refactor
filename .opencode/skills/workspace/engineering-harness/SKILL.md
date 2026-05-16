---
name: engineering-harness
description: |
  Full-spectrum agent harness for Academix v13.2 ERP — maps all 12 LCC harness layers
  (s01-s12) onto the existing VBA/OpenCode engineering pipeline.
  Load this skill for multi-agent orchestration, task isolation, context management,
  autonomous team coordination, and worktree-based parallel development.
---

# Engineering Harness — Full Agent Spectrum

## LCC s01-s12 Cross-Reference Map

```
                        LEARN-CLAUDE-CODE HARNESS SPECTRUM
                        ==================================
 s01  s02   s03   s04   s05   s06   |   s07    s08    s09    s10    s11    s12
 Loop Tools Plan  Sub   Skill Ctx   |   Tasks  BgRun  Teams  Proto  Auto   WrkTr
  |    |     |    |     |     |     |    |      |      |      |      |      |
  v    v     v    v     v     v     v    v      v      v      v      v      v
                          ACADEMIX v13.2 ERP
```

## Layer Mapping: LCC → Academix

| Layer | LCC Pattern | Academix Equivalent | Status | Deploy Action |
|-------|-------------|---------------------|--------|---------------|
| **s01** | Agent Loop | OpenCode native loop | ✅ Built-in | — |
| **s02** | Tool Dispatch | OpenCode tool system + build.ps1/verify.ps1/audit | ✅ Built-in | — |
| **s03** | TodoWrite | `/memory save` + notepad.md | ⚠️ Partial | Use TodoWrite in agent loop |
| **s04** | Subagent | `task` tool with `subagent_type` | ✅ Built-in | — |
| **s05** | Skill Loading | `skills/` dir with SKILL.md + `load_skill` | ✅ Native | Use `skill` tool |
| **s06** | Context Compact | Not deployed | ❌ Gap | microcompact + auto-compact via OpenCode |
| **s07** | Task System | `.tasks/` JSON files with `blockedBy` DAG | ❌ Gap | Deploy file-task DAG for pipeline steps |
| **s08** | Background Tasks | Not deployed | ❌ Gap | Daemon thread for async builds/audits |
| **s09** | Agent Teams | 6 agents via `/mode` switching | ⚠️ Partial | JSONL inboxes for persistent teammates |
| **s10** | Team Protocols | orchestrator.ps1 chaining | ⚠️ Partial | request_id handshake for shutdown/plan |
| **s11** | Autonomous Agents | AUTO pipeline commands | ⚠️ Partial | idle/claim cycle + identity re-injection |
| **s12** | Worktree Isolation | Not deployed | ❌ Gap | git worktree per task for parallel lanes |

## Ruflo-Lite Orchestration (Symmetry Logic)

The project uses a Ruflo-inspired orchestration layer to coordinate the CrossFlow Trio (Architect, Surgeon, Scout).

### Core Commands:
- `/ruflo-swarm-init`: Establish the coordination topology (e.g., `hierarchical-mesh`).
- `/ruflo-agent-spawn`: Assign roles (Scout, Surgeon, Architect) to synchronize behavior.
- `/ruflo-memory-store`: Save successful reasoning patterns to `.opencode/memory/patterns.json` (Self-Learning).
- `/ruflo-memory-search`: Retrieve past successful patterns to avoid repeated errors.

### The reporting rule:
Whenever any window completes a meaningful step, it MUST broadcast using:
`pwsh -NoProfile -File scripts/harness.ps1 sync "Message"`

|                    ACADEMIX ENGINEERING HARNESS                      |
+====================================================================+
|                                                                      |
|  [s01] Agent Loop  ←── OpenCode native (tool dispatch, stop_reason) |
|                                                                      |
|  [s02] Tools:  bash | read | write | edit | load_skill | task       |
|                build | verify | audit | test | run_script            |
|                                                                      |
|  [s03] Checklist: TodoWrite for session-level task tracking          |
|                                                                      |
|  [s04] Subagents: explore (ro) | plan (arch) | build (vba)          |
|                   debug (diag) | audit (dss) | test (macro)         |
|                                                                      |
|  [s05] Skills: naming-cheatsheet | verify | humanizer               |
|                engineering-harness (this skill)                      |
|                                                                      |
|  [s06] Context: microcompact (auto) → auto-compact (threshold)      |
|                ↳ transcripts saved to .opencode/memory/transcripts/ |
|                                                                      |
|  [s07] Tasks:  file-based DAG in .tasks/                            |
|                task_create / task_update / task_list / task_get      |
|                blockedBy edges for pipeline ordering                 |
|                                                                      |
|  [s08] BgRun:  daemon threads for build.ps1, verify.ps1, audit      |
|                notifications drained before each LLM call            |
|                                                                      |
|  [s09] Teams:  explore | plan | build | debug | audit | test        |
|                Persistent config in .team/config.json                |
|                JSONL inboxes at .team/inbox/{name}.jsonl             |
|                                                                      |
|  [s10] Proto:  shutdown_request/response handshake                   |
|                plan_approval submit/review with request_id           |
|                                                                      |
|  [s11] Auto:   idle phase with poll inbox + scan .tasks/            |
|                auto-claim unclaimed, unblocked tasks                 |
|                identity re-injection after compression               |
|                                                                      |
|  [s12] WrkTr:  git worktrees in .worktrees/{name}/                  |
|                bound to tasks via task["worktree"]                   |
|                events.jsonl lifecycle log                            |
|                                                                      |
+====================================================================+
```

## Agent Registry (6 + 2)

| Agent | LCC Pattern | Tools | Entry |
|-------|-------------|-------|-------|
| **explore** | s04 subagent (readonly) | bash, read, grep | `/mode explore` |
| **plan** | s07 task graph + s10 protocols | task_create/list, bash, read, write | `/mode plan` |
| **build** | s05 skill load + s02 tools | bash (build.ps1), read, write, edit | `/mode build` |
| **debug** | s06 compact + handoff pattern | bash, read, edit, verify.ps1 | `/mode debug` |
| **audit** | s08 bg_run + s10 shutdown | bash (dss-audit.ps1), read | `/mode audit` |
| **test** | s07 task + s08 bg_run | bash (test-macros.ps1) | `/mode test` |
| **orchestrator** | s09 teams + s11 auto | spawn, send, broadcast, claim | orchestrator.ps1 |
| **autonomous** | s11 idle/claim + s12 worktree | idle, claim_task, worktree_create/remove | Auto-start |

## Pipeline: LCC-Aware Workflows

### Feature Pipeline (explore → plan → build)
```
s07: task_create "explore affected files"
s04: subagent explore → returns map
s07: task_create "plan architecture" (blockedBy: [1])
s10: plan_approval → approved
s07: task_create "implement" (blockedBy: [2])
s05: load_skill "naming-cheatsheet" + "humanizer"
s02: build.ps1
s08: background_run build.ps1
s06: microcompact replaces old results
```

### Fix Pipeline (debug → build → test)
```
s07: task_create "diagnose handoff" (priority: critical)
s04: debug subagent → diagnoses root cause
s07: task_update → completed
s07: task_create "rebuild" (blockedBy: [1])
s08: background_run build.ps1
s07: task_create "verify" (blockedBy: [2])
s06: auto-compact if threshold exceeded
```

### Parallel Pipeline (audit + test in parallel)
```
s07: task_create "audit DSS" (blockedBy: [])
s07: task_create "run tests" (blockedBy: [])
s12: worktree_create "audit-wt" → git worktree isolate
s08: background_run dss-audit.ps1 (in audit-wt)
s08: background_run test-macros.ps1 (in main)
s06: drain notifications → inject results
s10: shutdown handshake on completion
```

## Project-Specific Paths

| Resource | Path |
|----------|------|
| Tasks dir | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.tasks\` |
| Team dir | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.team\` |
| Inboxes | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.team\inbox\` |
| Worktrees | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.worktrees\` |
| Transcripts | `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.opencode\memory\transcripts\` |
| VBA source | `Software_Surgical_Edit\VBA_Modules\` |
| Build script | `Software_Surgical_Edit\build.ps1` |
| Verify script | `Software_Surgical_Edit\verify.ps1` |
| Audit script | `milestone_13_2\tests\dss-audit.ps1` |
| Test script | `Software_Surgical_Edit\test-macros.ps1` |

## Deployed Commands

| Command | Layer | Action | File |
|---------|-------|--------|------|
| `/harness-compact` | s06 | Save transcript + compact | `.opencode/commands/harness-compact.md` |
| `/task-create` | s07 | Create DAG task | `.opencode/commands/task-create.md` |
| `/task-list` | s07 | List all tasks | `.opencode/commands/task-list.md` |
| `/task-update` | s07 | Update status/deps | `.opencode/commands/task-update.md` |
| `/task-get` | s07 | Get task by ID | `.opencode/commands/task-get.md` |
| `/task-claim` | s07 | Claim task | `.opencode/commands/task-claim.md` |
| `/bg-run` | s08 | Background subprocess | `.opencode/commands/bg-run.md` |
| `/bg-check` | s08 | Check bg status | `.opencode/commands/bg-check.md` |
| `/worktree-create` | s12 | Git worktree + bind | `.opencode/commands/worktree-create.md` |
| `/worktree-remove` | s12 | Remove worktree | `.opencode/commands/worktree-remove.md` |
| `/worktree-list` | s12 | List worktrees | `.opencode/commands/worktree-list.md` |

## Backend Script

`scripts/harness.ps1` — Unified PowerShell module for all four layers:

```
pwsh -NoProfile -File scripts/harness.ps1 compact save           # s06: save transcript
pwsh -NoProfile -File scripts/harness.ps1 task create "..."      # s07: create task
pwsh -NoProfile -File scripts/harness.ps1 bg run "npm install"   # s08: bg command
pwsh -NoProfile -File scripts/harness.ps1 worktree create "x" N  # s12: isolate
```

## Deployment Checklist

- [x] `.tasks/` — Task DAG directory (s07)
- [x] `.team/` + `config.json` — Team roster (s09)
- [x] `.team/inbox/` — JSONL inboxes (s09)
- [x] `.worktrees/` + `index.json` — Worktree isolation (s12)
- [x] `.opencode/memory/transcripts/` — Context compression transcripts (s06)
- [x] `.opencode/commands/` — 11 harness commands deployed
- [x] `scripts/harness.ps1` — Unified backend for s06/s07/s08/s12
- [x] Skills indexed in MASTER_BOOTSTRAP.xml skills-map
