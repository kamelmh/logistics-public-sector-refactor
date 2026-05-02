---
title: Routing Logic
type: logic
last_updated: 2026-05-02
tags: [routing, logic, flow, task-to-agent]
---

# Routing Logic (Task → Model → Agent Flow)

## Complete Routing Table

| Task | Model | Agent | Workspace | Alert If Wrong |
|------|-------|--------|-----------|-------------------|
| **Quick lookup** | haiku | explorer | Any | sonnet/opus (overkill) |
| **Simple edit** | haiku | general | Current | sonnet (overkill) |
| **VBA refactoring** | sonnet | executor | Software_Surgical_Edit | haiku (too weak) |
| **VBA module creation** | sonnet | executor | Software_Surgical_Edit | haiku (too weak) |
| **Thesis writing (Arabic)** | sonnet/opus | team-plan + executor | Thesis_Surgical_Edit | haiku (too weak) |
| **Architecture design** | opus | architect | Software_Surgical_Edit | haiku (too weak) |
| **Deep analysis** | opus | planner | Any | sonnet (insufficient) |
| **NotebookLM/Research** | gemini | (external) | N/A | claude (no context) |
| **Security audit** | opus | security-audit | Software_Surgical_Edit | sonnet (misses issues) |
| **Testing/Verification** | sonnet | test-runner | Software_Surgical_Edit | haiku (insufficient) |
| **Context compression** | sonnet | (context-compression skill) | Any | haiku (limited) |
| **Agent orchestration** | opus | team/ralph | Any | sonnet (limited) |
| **GitHub operations** | sonnet | (version-control skill) | Root | haiku (too slow) |
| **Repomix generation** | haiku | general | Repomix_Outputs | opus (overkill) |

---

## Routing Decision Tree

```
USER REQUEST
    ↓
[1] IS THIS NOTEBOOKLM/RESEARCH?
    ├── YES → Route to GEMINI (external)
    │           ↓
    │   1. Export via Gemini Exporter
    │   2. Paste to: ai-alignment/GEMINI_ALIGNMENT.md
    │   3. Cross-reference with MANIFESTO.md
    │   4. Execute with Claude (sonnet/opus) if needed
    └── NO ↓
            ↓
[2] IS THIS QUICK/SIMPLE (< 1hr)?
    ├── YES → Route to HAIKU + explorer/general
    │           ↓
    │   - Direct execution (no delegation)
    │   - Examples: "What is EOQ?", "Check VBA syntax"
    └── NO ↓
            ↓
[3] IS THIS VBA/CODING TASK?
    ├── YES → Route to SONNET + executor
    │           ↓
    │   - Workspace: Software_Surgical_Edit
    │   - Read MANIFESTO.md first (Clean Room)
    │   - Use Repomix-software.xml for context
    │   - Examples: "Refactor mod_StockEngine.bas"
    └── NO ↓
            ↓
[4] IS THIS THESIS WRITING?
    ├── YES → Route to SONNET/OPUS + team-plan/executor
    │           ↓
    │   - Workspace: Thesis_Surgical_Edit
    │   - Check TERMINOLOGY_MAPPING.md
    │   - Use Repomix-thesis.xml for context
    │   - Examples: "Draft Chapter 3 in Arabic RTL"
    └── NO ↓
            ↓
[5] IS THIS ARCHITECTURE/DEEP ANALYSIS?
    ├── YES → Route to OPUS + architect/planner
    │           ↓
    │   - Delegat to OMC: /orchestrate or /team 3:architect
    │   - Examples: "Design VBA DSS architecture"
    └── NO ↓
            ↓
[6] IS THIS SECURITY AUDIT?
    ├── YES → Route to OPUS + security-audit
    │           ↓
    │   - Use claude-harden-plugin (6 agents)
    │   - Examples: "Audit VBA code for vulnerabilities"
    └── NO ↓
            ↓
[7] DEFAULT → Route to SONNET + executor
```

---

## Workspace Routing

### Workspace Selection Rules

| Workspace | Used For | Repomix File | Alert If Wrong |
|-----------|----------|---------------|-------------------|
| **Thesis_Surgical_Edit** | Thesis writing, Arabic RTL | repomix-thesis.xml | Software context (cross-contamination) |
| **Software_Surgical_Edit** | VBA coding, refactoring | repomix-software.xml | Thesis context (cross-contamination) |
| **Repomix_Outputs** | Context isolation, Repomix generation | N/A | Wrong (use specific workspace) |
| **Root (Logistics.Public.Sector.Refactor)** | Full project queries | repomix-project.xml | Too broad (use isolation) |

---

## OMC Command Routing

### Command → Model → Agent Mapping

| Command | Model | Agent(s) | Task Type |
|---------|-------|------------|----------|
| `/team 3:executor "fix errors"` | sonnet | executor | VBA coding |
| `/orchestrate` | opus | team-plan + architect | Planning + Design |
| `/ultrawork` | Mixed | Multiple agents | Complex tasks |
| `/ralph` | sonnet | ralph | Specialized tasks |
| `/oh-my-claudecode:research` | sonnet | research | Research |
| `/oh-my-claudecode:claude-review` | sonnet | claude-review | Code review |

---

## Multi-Agent Routing

### When to Spawn Multiple Agents

| Scenario | Agent 1 | Agent 2 | Agent 3 |
|----------|---------|---------|---------|
| **Thesis Drafting** | team-plan (opus) - structure | executor (sonnet) - drafting | code-reviewer (sonnet) - review |
| **VBA Refactoring** | explorer (haiku) - find files | executor (sonnet) - refactor | test-runner (sonnet) - verify |
| **Full Project Analysis** | architect (opus) - design | security-audit (opus) - audit | planner (opus) - plan next steps |

**Rule:** Only use parallel agents for INDEPENDENT tasks (no cross-agent dependencies).

---

## Context Routing

### Context Isolation Rules

```
Task Type?
├── Thesis → Load: repomix-thesis.xml
│               ↓
│   Workspace: Thesis_Surgical_Edit
│   Model: sonnet/opus
│   Agent: team-plan + executor
│
├── VBA/Software → Load: repomix-software.xml
│               ↓
│   Workspace: Software_Surgical_Edit
│   Model: sonnet
│   Agent: executor
│
├── Full Project → Load: repomix-project.xml
│               ↓
│   Workspace: Root
│   Model: sonnet/opus
│   Agent: general/explorer
│
└── Research → Load: (Gemini external)
                ↓
    Export: Gemini Exporter
    Paste: GEMINI_ALIGNMENT.md
    Execute: sonnet/opus (if needed)
```

---

## Alert Integration

### When Routing Detects Issue

1. **Agent Self-Check:** Read `ALERT_RULES.md`
2. **Warn User:** Use alert template from `DISPATCH_ALERTS.md`
3. **Log:** Write to `logs/ALIGNMENT_LOG.md`
4. **Wait:** For user confirmation
5. **Execute:** Or abort if critical violation

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `dispatch-system/MODEL_MATRIX.md` | Model selection table |
| `dispatch-system/ALERT_RULES.md` | Alert triggers |
| `ai-alignment/AGENT_PROTOCOLS.md` | Agent protocols |
| `project-understanding/WORKFLOW_INTEGRATION.md` | Tool pipeline |

---

*End of Routing Logic*
