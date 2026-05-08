# Engineering Harness — Multi-Agent System for Academix v13.2
# Agent: explore | plan | build | debug | audit | test
# Framework: OpenCode + OMC v4.9.3

## Agent Registry

| Agent | Mode | Skill | Model | Purpose |
|-------|------|-------|-------|---------|
| **explore** | explore | `general` | qwen3-32b | Codebase recon — map, grep, trace deps |
| **plan** | plan | `general` | qwen3-32b | Architecture — document plans in `.opencode/plans/` |
| **build** | build | `vba-build` + `vba-importer` | qwen3-32b | Write VBA, rebuild via build.ps1 |
| **debug** | debug | `vba-debug` | qwen3-32b | Handoff-based VBA error diagnosis |
| **audit** | audit | `security-audit` | qwen3-32b | 5-phase DSS audit via dss-audit.ps1 |
| **test** | test | `test-runner` | qwen3-32b | Macro test suite via test-macros.ps1 |

## Agent Workflows

### explore → plan → build (Feature Pipeline)
```
User request
  → explore: map affected files, grep references, trace call graph
  → plan: document architecture decision in .opencode/plans/
  → build: write/edit .bas, run build.ps1, commit
```

### debug → build → test (Fix Pipeline)
```
VBA error (handoffN.txt)
  → debug: diagnose error type, fix .bas
  → build: run build.ps1 → verify.ps1
  → test: run test-macros.ps1 → confirm pass
```

### audit (Quality Gate)
```
Before release/commit
  → dss-audit.ps1 (5-phase)
  → If 0 CRITICAL → proceed
  → If CRITICAL found → route to debug → fix → re-audit
```

## Engineering Harness Commands

```powershell
# Agent dispatch via orchestrator
.\Software_Surgical_Edit\orchestrator.ps1 status      # Show all tasks
.\Software_Surgical_Edit\orchestrator.ps1 next         # Next task
.\Software_Surgical_Edit\orchestrator.ps1 run T003     # Run specific task
.\Software_Surgical_Edit\orchestrator.ps1 build        # Rebuild workbook
.\Software_Surgical_Edit\orchestrator.ps1 audit        # Run DSS audit
.\Software_Surgical_Edit\orchestrator.ps1 test         # Run tests
.\Software_Surgical_Edit\orchestrator.ps1 sync         # Sync personal → public

# Direct tool access
.\Software_Surgical_Edit\build.ps1                     # Rebuild from source
.\Software_Surgical_Edit\verify.ps1                    # 97-point verification
.\Software_Surgical_Edit\milestone_13_2\tests\dss-audit.ps1  # Full audit
.\Software_Surgical_Edit\test-macros.ps1               # Macro test suite
```

## Agent Routing Rules (from agent-routing.xml)

1. Never modify .xlsm directly — always fix source files then rebuild
2. Personal project stays in Dropbox/private; only generic LSM goes to GitHub
3. Strip all sensitive data before public release
4. Private declarations before Public procedures in modules
5. UDT arrays cannot be Variant — use ByRef Sub pattern
6. Runtime controls use Controls(name) syntax

## Mode Switching in OpenCode

In the OpenCode CLI, switch modes:
```
/mode explore    → Codebase exploration agent
/mode plan       → Architecture planner
/mode build      → VBA builder (default)
/mode debug      → VBA debugger
/mode audit      → DSS auditor
/mode auto       → Default mode
```

Or dispatch tasks via task tool with `subagent_type` parameter.
