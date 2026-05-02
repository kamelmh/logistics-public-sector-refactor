---
title: Workflow Integration
type: integration
last_updated: 2026-05-02
tags: [workflow, ai-tools, opencode, claude, gemini]
---

# Workflow Integration (AI Tools Pipeline)

## AI Tool Ecosystem

```
┌─────────────────────────────────────────────────────────┐
│                    AI WORKFLOW                         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────┐     ┌──────────┐     ┌──────────┐   │
│  │  Gemini  │────▶│ Claude/  │────▶│ OpenCode │   │
│  │(Strategy)│     │ OpenCode │     │(Executor)│   │
│  └──────────┘     └──────────┘     └──────────┘   │
│       │                   │                   │          │
│       ▼                   ▼                   ▼          │
│  NotebookLM          Implementation      Agent         │
│  Research            (VBA DSS)          Dispatch       │
└─────────────────────────────────────────────────────────┘
```

---

## Tool Roles & Responsibilities

### Gemini (Strategic Layer)

**Purpose:** Big picture strategy, NotebookLM research  
**Best For:**
- High-level project direction
- NotebookLM document analysis
- Public sector compliance strategy
- Clean Room strategy enforcement

**Limitations:**
- Less suited for VBA code generation
- No direct VBA execution environment

**Integration:**
- Export via [Gemini Exporter](https://www.ai-chat-exporter.com)
- Paste to `ai-alignment/GEMINI_ALIGNMENT.md`
- Cross-reference with Manifesto before execution

---

### Claude/OpenCode (Implementation Layer)

**Purpose:** VBA DSS implementation, thesis writing  
**Best For:**
- VBA code generation (pure, vanilla)
- Arabic RTL thesis drafting (4 chapters)
- Agent orchestration (29+ agents available)
- Model dispatch (haiku/sonnet/opus)

**Integration with Gemini:**
1. Read Gemini export from `GEMINI_ALIGNMENT.md`
2. Verify against `MANIFESTO.md` (Clean Room rules)
3. Execute with appropriate model (check `MODEL_DISPATCH.md`)

---

## Workflow Scenarios

### Scenario 1: VBA Module Refactoring

```
1. Gemini (NotebookLM): "Refactor mod_StockEngine.bas to pure VBA"
         ↓ (export)
2. Paste to: GEMINI_ALIGNMENT.md
         ↓ (verify)
3. Claude/OpenCode: Read Manifesto + Verify Clean Room
         ↓ (dispatch)
4. Model: sonnet, Agent: executor
         ↓ (execute)
5. Output: Pure VBA module (no Python bridges)
```

### Scenario 2: Thesis Chapter Writing

```
1. Gemini (NotebookLM): "Draft Chapter 1 - Theory & Concepts"
         ↓ (export)
2. Paste to: GEMINI_ALIGNMENT.md
         ↓ (verify)
3. Claude/OpenCode: Check terminology mapping
         ↓ (dispatch)
4. Model: sonnet/opus, Agent: team-plan + executor
         ↓ (execute)
5. Output: Arabic RTL thesis (formal academic)
```

### Scenario 3: Model Mismatch Detection

```
1. User: "Fix VBA error" with model=haiku
         ↓ (self-check)
2. Agent reads: MODEL_DISPATCH.md
         ↓ (detect)
3. Alert: "⚠️ MODEL MISMATCH: Use sonnet for VBA work"
         ↓ (wait)
4. User confirms: Switch to sonnet
         ↓ (execute)
5. Task completes successfully
```

---

## Context Management

### Repomix Strategy

**Purpose:** Isolate context to prevent cross-contamination

| Context | Repomix File | Workspace |
|---------|---------------|-----------|
| Thesis | `repomix-thesis.xml` | `Thesis_Surgical_Edit/` |
| Software | `repomix-software.xml` | `Software_Surgical_Edit/` |
| Full Project | `repomix-project.xml` | Root directory |

**Workflow:**
1. Generate Repomix file for specific context
2. Load into AI tool (Claude/OpenCode)
3. Work in isolated workspace
4. Prevent old Python code "hallucination"

---

## Agent Dispatch Flow

### Decision Tree

```
User Request
    ↓
Is this NotebookLM/Research? → Gemini (external)
    ↓ No
Is this quick/simple? → haiku (direct execution)
    ↓ No
Is this architecture/deep analysis? → opus (delegat to architect)
    ↓ No
Is this VBA coding/thesis? → sonnet (delegat to executor)
    ↓ No
Default: sonnet
```

### OMC Commands

| Command | Agent | Model | Task |
|---------|--------|-------|------|
| `/team 3:executor "fix errors"` | executor | sonnet | Standard coding |
| `/orchestrate` | team-plan + architect | opus | High-level planning |
| `/ultrawork` | Multiple agents | Mixed | Complex tasks |
| `/ralph` | ralph | sonnet | Specialized tasks |

---

## File Synchronization

### Key Files to Keep in Sync

| File | Purpose | Sync With |
|------|---------|----------|
| `MANIFESTO.md` | Core rules | `.omc/`, `CLAUDE.md`, `ai-alignment/` |
| `PROJECT_MEMORY.md` | Ground truth | `project-understanding/` |
| `MODEL_DISPATCH.md` | Model routing | `ai-alignment/`, `dispatch-system/` |
| `EL_BAYADH_DATASET.md` | Case study data | `project-understanding/` |
| `GEMINI_ALIGNMENT.md` | Strategy exports | `ai-alignment/` |

---

## Alert System Integration

### When Agent Detects Issue

1. **Self-Check:** Read `DISPATCH_ALERTS.md`
2. **Warn User:** Use alert template
3. **Log:** Write to `logs/ALIGNMENT_LOG.md`
4. **Wait:** For user confirmation
5. **Execute:** Or abort if critical violation

### Alert Types

| Alert | Trigger | Action |
|-------|---------|--------|
| MODEL MISMATCH | Wrong model for task | Suggest correct model |
| TOOL MISMATCH | Claude doing Gemini task | Export to Gemini |
| CONSTRAINT VIOLATION | Python/externals detected | Rewrite pure VBA |
| TERMINOLOGY VIOLATION | Tech terms in thesis | Use administrative vocab |
| CONTEXT WARNING | Approaching token limit | Use Repomix isolation |

---

## Session Continuity

### Starting New Session

1. **Read Manifesto:** `MANIFESTO.md` (Clean Room rules)
2. **Check Model:** `MODEL_DISPATCH.md` (correct model?)
3. **Load Context:** Repomix file (isolated workspace)
4. **Verify Data:** `EL_BAYADH_DATASET.md` (ground truth)
5. **Begin Task:** With correct agent dispatch

### Ending Session

1. **Save Work:** Commit to workspace
2. **Log Session:** `logs/SESSION_LOG.md`
3. **Update Status:** `_INDEX.md` dashboard
4. **Note Issues:** `logs/ALIGNMENT_LOG.md`

---

*End of Workflow Integration*
