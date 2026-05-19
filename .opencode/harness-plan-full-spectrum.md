# Autonomous Engineering Harness — Full Spectrum Plan
# Academix v13.2 | Generated: 2026-05-19

## EXECUTIVE SUMMARY

Complete autonomous multi-agent harness deployment for the Academix v13.2 ERP + Thesis project.
Maps all 12 LCC harness layers (s01-s12) onto the existing VBA/OpenCode engineering pipeline.
Expands workzone to 8 agent zones with parallel development lanes, background pipelines,
and autonomous task claim cycles.

**Status:** Infrastructure deployed, tasks created, ready for execution.

---

## 1. PROJECT STATE SNAPSHOT

### ERP (Golden)
- Build: 174/174 PASS | Tests: 20/20 PASS | Audit: 16/16 PASS
- 37 .bas + 1 .frm modules | 25 worksheets | ~12,538 code lines
- Ground Truth: D=1546 | Q*=176 | ROP=212.4 | SS=200 | S=801.45 | I=20%

### Thesis (Print-Ready)
- Source: 993 lines | 4 chapters | 56 bibliography entries | 8 footnotes (CNEPD)
- DOCX: 102 KB | PDF: rebuild pending (timed out at step 5/10)
- Compliance: ≥93% (5/6 audit fixes complete, M-03 pending)

### CrossFlow (Synchronized)
- 4 windows: A(Scout/Gemini) B(Surgeon/Gemini) C(Architect/Gemma) D(Master/Claude)
- HANDOFF.md: 269+ lines | MASTER_CONTEXT.md: 141 lines
- Session exports: 5 archived sessions tracked

---

## 2. HARNESS LAYER DEPLOYMENT STATUS

| Layer | LCC Pattern | Academix Equivalent | Before | After | Files |
|-------|-------------|---------------------|--------|-------|-------|
| s01 | Agent Loop | OpenCode native loop | ✅ | ✅ | — |
| s02 | Tool Dispatch | OpenCode tools + PS scripts | ✅ | ✅ | — |
| s03 | TodoWrite | /memory save + notepad.md | ⚠️ | ⚠️ | — |
| s04 | Subagent | task tool with subagent_type | ✅ | ✅ | — |
| s05 | Skill Loading | skills/ dir + skill tool | ✅ | ✅ | — |
| s06 | Context Compact | transcripts + auto-compact | ⚠️ | ⚠️ | transcripts/*.jsonl |
| s07 | Task System | .tasks/ JSON DAG | ⚠️ | ✅ | 21 task files |
| s08 | Background Tasks | bg-worker.ps1 daemon | ❌ | ✅ | scripts/bg-worker.ps1 |
| s09 | Agent Teams | 6 agents + JSONL inboxes | ⚠️ | ✅ | .team/inbox/*.jsonl |
| s10 | Team Protocols | orchestrator.ps1 + handoff | ⚠️ | ⚠️ | .crossflow/HANDOFF.md |
| s11 | Autonomous Agents | idle/claim + AUTO commands | ⚠️ | ✅ | task_16, task_101 |
| s12 | Worktree Isolation | git worktrees + index | ❌ | ✅ | .worktrees/index.json |

---

## 3. 8 AGENT ZONES

### Zone 1: ERP VBA Core
- **Agents:** build, debug
- **Path:** Software_Surgical_Edit/VBA_Modules/
- **Pipeline:** build.ps1 → verify.ps1 → test-macros.ps1
- **Goal:** Maintain GOLDEN state (174/174 PASS)
- **Priority:** MAINTAIN

### Zone 2: Thesis Academic
- **Agents:** plan, build
- **Path:** Thesis_Surgical_Edit/
- **Pipeline:** build-thesis.ps1 → verify-thesis.ps1
- **Pending:** PDF rebuild, M-03 table caption verification
- **Next:** Phase B — English Research Paper (6-8pp IEEE/Springer)
- **Priority:** HIGH

### Zone 3: CrossFlow Coordination
- **Agents:** orchestrator
- **Path:** .crossflow/
- **Components:** HANDOFF.md, MASTER_CONTEXT.md, SESSION_LOG.md
- **Protocol:** Read on start, write on completion
- **Priority:** ALWAYS ACTIVE

### Zone 4: Task Queue Engine
- **Agents:** autonomous
- **Path:** .tasks/
- **Tasks:** 21 total (12 completed, 9 pending)
- **DAG:** blockedBy edges for dependency ordering
- **Claim Cycle:** idle → scan → claim unblocked → execute → complete
- **Priority:** HIGH

### Zone 5: Background Pipeline Runner
- **Agents:** build, audit, test
- **Script:** scripts/bg-worker.ps1
- **Actions:** start, status, stop, drain, run
- **Pipelines:** build, verify, audit, test, thesis
- **Notifications:** drained before each LLM call
- **Priority:** HIGH

### Zone 6: Worktree Parallel Lanes
- **Agents:** autonomous, build
- **Path:** .worktrees/
- **Index:** index.json (tracks active worktrees)
- **Lifecycle:** events.jsonl (create → bind → execute → merge → remove)
- **Target:** One worktree per parallel task
- **Priority:** MEDIUM

### Zone 7: Agent Team Inboxes
- **Agents:** all 6 (explore, plan, build, debug, audit, test)
- **Path:** .team/inbox/*.jsonl
- **Protocol:** send → poll → acknowledge → execute → respond
- **Config:** .team/config.json (updated with inbox paths)
- **Priority:** MEDIUM

### Zone 8: Gateway & Dashboard
- **Agents:** orchestrator
- **Path:** .opencode/gateway/
- **Server:** Express :3000 (build-erp, verify-erp, build-thesis, git-status)
- **Planned:** audit, test, health endpoints + WebSocket progress
- **Canvas:** .opencode/canvas/thesis_map.mmd
- **Priority:** LOW

---

## 4. TASK DAG — DEPENDENCY GRAPH

```
                    ┌─────────────────────────────────────────┐
                    │          PHASE 1: INFRASTRUCTURE         │
                    │         (Parallel — No Dependencies)     │
                    ├─────────────────────────────────────────┤
                    │  task_13: Worktree isolation (s12)      │
                    │  task_14: Background runner (s08)       │
                    │  task_15: Team inboxes (s09)            │
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │          PHASE 2: CLAIM CYCLE            │
                    ├─────────────────────────────────────────┤
                    │  task_16: Autonomous claim loop (s11)   │
                    │    blockedBy: [13, 14]                  │
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │          PHASE 3: THESIS                 │
                    ├─────────────────────────────────────────┤
                    │  task_17: PDF rebuild + M-03 (thesis)   │
                    │    ↓                                    │
                    │  task_18: English Paper (blockedBy: 17) │
                    │  task_19: Chapter expansion (blockedBy:17)│
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │          PHASE 4: GATEWAY                │
                    ├─────────────────────────────────────────┤
                    │  task_20: Gateway endpoints (s08)       │
                    │    blockedBy: [14]                      │
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │          PHASE 5: INTEGRATION TEST       │
                    ├─────────────────────────────────────────┤
                    │  task_101: Autonomous loop test (s11)   │
                    │    blockedBy: [13, 16]                  │
                    └─────────────────────────────────────────┘
```

---

## 5. EXECUTION WORKFLOWS

### Feature Pipeline (explore → plan → build)
```
1. s07: task_create "explore affected files"
2. s04: subagent explore → returns dependency map
3. s07: task_create "plan architecture" (blockedBy: [explore])
4. s10: plan_approval → user approved
5. s07: task_create "implement" (blockedBy: [plan])
6. s05: load_skill "naming-cheatsheet" + "humanizer"
7. s02: write .bas sources
8. s08: background_run build.ps1
9. s06: microcompact replaces old results
10. s07: task_update → completed
```

### Fix Pipeline (debug → build → test)
```
1. s07: task_create "diagnose handoff" (priority: critical)
2. s04: debug subagent → diagnoses root cause
3. s07: task_update → completed
4. s07: task_create "rebuild" (blockedBy: [diagnose])
5. s08: background_run build.ps1
6. s07: task_create "verify" (blockedBy: [rebuild])
7. s06: auto-compact if threshold exceeded
```

### Parallel Pipeline (audit + test concurrent)
```
1. s12: worktree_create "audit-wt" → git isolate
2. s08: background_run dss-audit.ps1 (in audit-wt)
3. s08: background_run test-macros.ps1 (in main)
4. s06: drain notifications → inject results
5. s10: shutdown handshake on completion
```

---

## 6. BACKGROUND PIPELINE COMMANDS

```powershell
# Start a pipeline in background
pwsh -NoProfile -File scripts/bg-worker.ps1 start -Pipeline build
pwsh -NoProfile -File scripts/bg-worker.ps1 start -Pipeline verify
pwsh -NoProfile -File scripts/bg-worker.ps1 start -Pipeline audit
pwsh -NoProfile -File scripts/bg-worker.ps1 start -Pipeline test
pwsh -NoProfile -File scripts/bg-worker.ps1 start -Pipeline thesis

# Check status
pwsh -NoProfile -File scripts/bg-worker.ps1 status

# Drain completed notifications (before LLM call)
pwsh -NoProfile -File scripts/bg-worker.ps1 drain

# Stop a running pipeline
pwsh -NoProfile -File scripts/bg-worker.ps1 stop -Pipeline build
```

---

## 7. WORKTREE COMMANDS

```powershell
# Create worktree for a task
git worktree add .worktrees/task-18 origin/master
# Bind to task: update task_18.json worktree field

# List worktrees
git worktree list

# Remove worktree after merge
git worktree remove .worktrees/task-18
```

---

## 8. TEAM INBOX PROTOCOL

```
Send message:
  Append to .team/inbox/{agent}.jsonl:
  {"from": "orchestrator", "type": "task", "task_id": 18, "message": "Start English Paper", "timestamp": "..."}

Agent polls:
  Read last 10 lines of .team/inbox/{agent}.jsonl
  Filter: type=task, not acknowledged

Agent acknowledges:
  Append: {"from": "{agent}", "type": "ack", "task_id": 18, "timestamp": "..."}

Agent responds:
  Append: {"from": "{agent}", "type": "result", "task_id": 18, "status": "completed", "timestamp": "..."}
```

---

## 9. CROSSFLOW HANDOFF FORMAT

When completing any zone, append to `.crossflow/HANDOFF.md`:

```markdown
## Handoff: <source-window> → <target-window>
**Date:** YYYY-MM-DD HH:MM UTC
**Zone:** 1-8
**Tasks Completed:** <list>
**Status:** PASS/FAIL/PARTIAL
**Notes:** <any issues or follow-ups>
```

---

## 10. VERIFICATION CHECKLIST

After harness deployment:

- [x] s08: bg-worker.ps1 created and functional
- [x] s09: 6 JSONL inboxes created in .team/inbox/
- [x] s11: Task claim cycle tasks created (16, 101)
- [x] s12: Worktree index + events created
- [x] .team/config.json updated with inbox paths
- [x] .tasks/ expanded with 8 new tasks (13-20)
- [x] .crossflow/HANDOFF.md updated with harness state
- [x] .opencode/state/project-memory.md updated
- [ ] Phase 1 execution: tasks 13, 14, 15
- [ ] Phase 2 execution: task 16 (claim cycle)
- [ ] Phase 3 execution: tasks 17, 18, 19 (thesis)
- [ ] Phase 5 execution: task 101 (integration test)

---

## 11. GROUND TRUTH (LOCKED — NEVER MODIFY)

| Constant | Value | Verified In |
|----------|-------|-------------|
| D (ART-001) | 1,546 units/year | Ch1, Ch2, Ch4, VBA |
| Q* (EOQ) | 176 units | All chapters, VBA |
| ROP | 212.4 units | Ch2 Table 04, Ch4 |
| SS | 200 units | All chapters |
| LT | 2 days | Ch2, Ch4 |
| S | 801.45 DZD | Ch1, VBA (updated 2026-05-12) |
| I | 20% | All chapters |
| PU (ART-001) | 400 DZD | Ch1, Ch2 |
| Performance | 99.7% | Abstract, Ch4, Conclusion |
| TC(176) | 14,080 DZD | Ch1 (7,040 + 7,080 balanced) |

---

## 12. ART CODE REFERENCE (12 Articles)

| Code | French | Arabic | Class | D |
|------|--------|--------|-------|---|
| ART-001 | Toner G030 | حبر الطابعة Toner G030 | A | 1,546 |
| ART-002 | Rame papier A4 | رزم الورق A4 | A | 1,200 |
| ART-003 | Rame papier A3 | رزم الورق A3 | B | 800 |
| ART-004 | Boîte archives | صندوق أرشيف كرتوني | B | 400 |
| ART-005 | Agrafeuse | دباسة | C | 300 |
| ART-006 | Stylos boîte/50 | أقلام حبر علبة/50 | C | 450 |
| ART-007 | Registre 5m | سجل كبير | C | 350 |
| ART-008 | Encre tampon | حبر أختام | C | 200 |
| ART-009 | Sous-chemise | مغلف كرتوني | C | 250 |
| ART-010 | Chemise cartonnée | مجلد كرتوني | C | - |
| ART-011 | Rouleau fax | لفافة فاكس | C | - |
| ART-012 | Marqueur | قلم دائم | C | - |

---

*Generated: 2026-05-19 | Layers: s01-s12 | Tasks: 21 | Zones: 8 | Agents: 6+2*
