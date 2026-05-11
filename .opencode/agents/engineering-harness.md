# Engineering Harness — Full Agent Spectrum (LCC s01-s12)
# Agent: explore | plan | build | debug | audit | test | orchestrator | autonomous
# Framework: OpenCode + LCC Harness Spectrum
# Skill: engineering-harness (load with `skill` tool)

## LCC Harness Layers Deployed

```
s01 Agent Loop        →  OpenCode native (stop_reason, tool dispatch)
s02 Tool Use          →  bash | read | write | edit | load_skill | task | build | verify | audit | test
s03 TodoWrite         →  session-level checklists, nag reminder at 3+ rounds
s04 Subagents         →  explore (ro) | plan (arch) | build (vba) | debug (diag) | audit (dss) | test (macro)
s05 Skill Loading     →  engineering-harness, naming-cheatsheet, verify, humanizer, autopilot
s06 Context Compact   →  microcompact (silent, every turn) + auto-compact (token threshold) + transcripts
s07 Task System       →  .tasks/ JSON DAG with blockedBy edges (pending → in_progress → completed)
s08 Background Tasks  →  daemon threads for build.ps1, verify.ps1, dss-audit.ps1 (async notifications)
s09 Agent Teams       →  6 agents + .team/config.json + JSONL inboxes in .team/inbox/
s10 Team Protocols    →  shutdown_request/response handshake + plan_approval submit/review (request_id)
s11 Autonomous Agents →  idle/claim cycle + auto-claim from .tasks/ + identity re-injection
s12 Worktree Isolation →  git worktrees in .worktrees/{name}/ bound to task["worktree"]
```

## Agent Registry

| Agent | Layer | Tools | Purpose |
|-------|-------|-------|---------|
| **explore** | s04 | bash, read, grep | Codebase recon — map, grep, trace deps |
| **plan** | s07+s10 | task_create/list, bash, read, write | Architecture decisions, impact docs |
| **build** | s05+s02 | bash (build.ps1), read, write, edit | Write VBA, rebuild via build.ps1 |
| **debug** | s06 | bash, read, edit, verify.ps1 | Handoff-based VBA error diagnosis |
| **audit** | s08+s10 | bash (dss-audit.ps1), read | 5-phase DSS audit |
| **test** | s07+s08 | bash (test-macros.ps1) | Macro test suite |
| **orchestrator** | s09+s11 | spawn, send, broadcast, claim, shutdown, plan_approval | Task dispatch + team coordination |
| **autonomous** | s11+s12 | idle, claim_task, worktree_create/remove | Self-organizing parallel agents |

## Workflows

### Feature (explore → plan → build)
```
s07 task_create "explore" → s04 subagent explore → returns map
s07 task_create "plan" (blockedBy: 1) → s10 plan_approval
s07 task_create "build" (blockedBy: 2) → s05 load_skill + build.ps1
```

### Fix (debug → build → test)
```
s07 task_create "diagnose" → s04 debug subagent
s07 task_create "rebuild" (blockedBy: 1) → s08 bg_run build.ps1
s07 task_create "verify" (blockedBy: 2) → test-macros.ps1
```

### Parallel (audit + test concurrent)
```
s12 worktree_create "audit-wt" → git isolate
s08 bg_run dss-audit (in worktree) + test-macros (main)
s06 drain notifications → inject results
s10 shutdown on completion
```

## Commands

```powershell
# Build
.\Software_Surgical_Edit\build.ps1

# Verify (137 checks)
.\Software_Surgical_Edit\verify.ps1

# Audit (5-phase DSS)
.\milestone_13_2\tests\dss-audit.ps1

# Macro tests
.\Software_Surgical_Edit\test-macros.ps1
```

## Ground Rules

1. Never modify .xlsm directly — fix .bas sources then rebuild
2. Stale p-code cache — always rebuild from scratch
3. UTF-8 em dashes → VBA syntax error (replace with -)
4. Public Const before procedures, Property Get for cross-module
5. 6 agents via `/mode` or task tool with `subagent_type`
