# VBA Task Orchestrator Skill (v1.1)

## Overview
Advanced macro coordination engine with task queue, priority scheduling, dependency management, progress tracking, error retry, and automated scheduler. Enables complex workflow orchestration in pure VBA.

## Module
`mod_TaskOrchestrator.bas` in `Software_Surgical_Edit/VBA_Modules/`

## Capabilities
- **Task Queue** — FIFO with priority insertion (0=Critical, 1=High, 2=Normal, 3=Low)
- **Dependency Management** — Tasks wait for dependencies to complete before execution
- **Error Retry** — Configurable retry count and delay between attempts
- **Progress Tracking** — 0-100% with status bar updates
- **Scheduler** — Daily/weekly/monthly/on-idle timed task execution via `Application.OnTime`
- **Task Logging** — Export execution log to `TASK_LOG` sheet
- **Predefined Chains** — Data sync chain, backup chain, inventory chain
- **Pipeline Support** — Full "one-click" pipeline execution

## Entry Points (MAIN_MACROS.bas)
| Macro | Description |
|-------|-------------|
| `RunTaskSync` | Quick run: validate → sync metrics → ABC → report |
| `RunTaskBackup` | Quick run: export all data + clean logs |
| `RunTaskAll` | Run all pending tasks |
| `ShowTaskDashboard` | Display status summary |
| `StartTaskScheduler` | Start timed task scheduler |
| `StopTaskScheduler` | Stop the scheduler |
| `CreateCustomTaskChain` | Build and run a user-defined chain |
| `ExportTaskLog` | Export log to worksheet |

## Task Definition Example
```vb
Dim t1 As String, t2 As String
t1 = mod_TaskOrchestrator.DefineTask("MY-TASK", "Validate data", _
    "mod_DataValidator.ValidateAll", priority:=tpHigh, retryCount:=3)
t2 = mod_TaskOrchestrator.DefineTask("MY-SYNC", "Sync metrics", _
    "mod_StockEngine.RefreshAllCMUP", priority:=tpNormal)
mod_TaskOrchestrator.SetDependencies t2, t1
mod_TaskOrchestrator.EnqueueMultiple t1, t2
mod_TaskOrchestrator.RunQueue True
```

## Scheduling Example
```vb
' Run daily at 22:00
mod_TaskOrchestrator.SetSchedule t1, stDaily, "22:00"
' Run weekly on Monday at 08:00
mod_TaskOrchestrator.SetSchedule t2, stWeekly, "1 08:00"
' Start scheduler
mod_TaskOrchestrator.StartScheduler 60  ' Check every 60 seconds
```

## Enums
### TaskPriority
| Name | Value | Use |
|------|-------|-----|
| `tpCritical` | 0 | Must run immediately |
| `tpHigh` | 1 | High importance |
| `tpNormal` | 2 | Default |
| `tpLow` | 3 | Background/idle |

### TaskStatus
| Name | Value | Meaning |
|------|-------|---------|
| `tsPending` | 0 | Not yet queued |
| `tsQueued` | 1 | In queue |
| `tsRunning` | 2 | Currently executing |
| `tsCompleted` | 3 | Finished successfully |
| `tsFailed` | 4 | Failed after all retries |
| `tsRetrying` | 5 | Retrying after error |
| `tsSkipped` | 6 | Dependency not met |
| `tsCancelled` | 7 | Cancelled by user |

## Pre-Build Validation
This module is checked by `vba-check.py` (v1.2) which catches:
- ❌ `Name:=` in `Application.OnTime` (must be `Procedure:=`) — **fixed in v1.1**
- ❌ `Return` statement (VB.NET syntax)
- ❌ Parameter named `format` (conflicts with built-in `Format()`)
- ❌ `Const Array()` (runtime function in Const declaration)
- ❌ UTF-8 encoding issues, missing headers, broken continuations

**Known fix applied (v2026-05-29):** `Application.OnTime` named argument changed from `Name:=` to `Procedure:=` (the correct syntax in VBA for scheduling procedures).

## Dependencies
- `mod_Config.bas` — Master password
- VBA runtime `OnTime` for scheduler (use `Procedure:=`, not `Name:=`)
- No external dependencies

## Verification
Run `build.ps1` then `mod_TaskOrchestrator.QuickRunSync` to verify:
1. Task creation and queue works
2. Dependencies execute in order
3. Error retry functions correctly
4. Scheduler timer fires
5. Log export writes correctly

## History
| Version | Date | Changes |
|---------|------|---------|
| v1.1 | 2026-05-29 | Fixed `Name:=`→`Procedure:=` in `Application.OnTime`; added pre-build validation section |
| v1.0 | 2026-02-24 | Initial release — task queue, scheduler, dependency management |
