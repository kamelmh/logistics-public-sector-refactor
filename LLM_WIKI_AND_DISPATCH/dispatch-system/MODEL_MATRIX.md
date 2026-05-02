---
title: Model Matrix
type: matrix
last_updated: 2026-05-02
tags: [model, matrix, haiku, sonnet, opus, gemini]
---

# Model Matrix

## Complete Model Selection Table

| Task Type | Haiku | Sonnet | Opus | Gemini | Alert If Wrong |
|-----------|-------|--------|------|--------|-------------------|
| **Quick lookup** | ✅ Best | ⚠️ Overkill | ⚠️ Waste | ❌ No context | "Use haiku for quick lookup" |
| **Simple edits** | ✅ Best | ⚠️ Overkill | ⚠️ Waste | ❌ No context | "Use haiku for simple edits" |
| **Standard coding** | ❌ Too weak | ✅ Best | ⚠️ Overkill | ❌ No VBA | "Use sonnet for VBA coding" |
| **VBA refactoring** | ❌ Too weak | ✅ Best | ⚠️ Overkill | ❌ No VBA | "Use sonnet for VBA work" |
| **Thesis writing (Arabic)** | ❌ Too weak | ✅ Best | ✅ Good | ❌ No Arabic | "Use sonnet/opus for thesis" |
| **Architecture design** | ❌ Too weak | ⚠️ Might struggle | ✅ Best | ❌ No VBA | "Use opus for architecture" |
| **Deep analysis** | ❌ Too weak | ❌ Insufficient | ✅ Best | ⚠️ Large docs | "Use opus for deep analysis" |
| **NotebookLM/Research** | ❌ No context | ❌ No context | ❌ No context | ✅ Best | "Use Gemini for NotebookLM" |
| **Security audit** | ❌ Too weak | ⚠️ Might miss | ✅ Best | ❌ No VBA | "Use opus for security audit" |
| **Agent orchestration** | ❌ Too weak | ⚠️ Limited | ✅ Best | ❌ No orchestration | "Use opus for orchestration" |
| **Context compression** | ❌ Limited | ✅ Best | ⚠️ Overkill | ⚠️ Large context | "Use sonnet for compression" |
| **Testing/Verification** | ❌ Too weak | ✅ Best | ⚠️ Overkill | ❌ No VBA | "Use sonnet for testing" |

---

## Model Capabilities Comparison

### Haiku

| Aspect | Detail |
|--------|---------|
| **Context Window** | ~200K tokens |
| **Best For** | Quick lookups, simple edits, status checks |
| **Limitations** | May struggle with complex VBA refactoring or deep architectural analysis |
| **Cost** | Low |
| **Speed** | Fast |
| **When to Use** | < 1 hour tasks, simple queries, status updates |

### Sonnet

| Aspect | Detail |
|--------|---------|
| **Context Window** | ~200K tokens |
| **Best For** | Standard coding tasks, VBA refactoring, thesis writing, testing |
| **Limitations** | May need opus for deepest architectural decisions |
| **Cost** | Medium |
| **Speed** | Medium |
| **When to Use** | Standard tasks (1-4 hours), VBA coding, thesis drafting |

### Opus

| Aspect | Detail |
|--------|---------|
| **Context Window** | ~200K tokens |
| **Best For** | Architecture design, deep analysis, security audits, orchestration |
| **Limitations** | Overkill for simple tasks (context waste) |
| **Cost** | High |
| **Speed** | Slower |
| **When to Use** | Complex tasks (> 4 hours), architecture, deep analysis |

### Gemini 1.5 Pro

| Aspect | Detail |
|--------|---------|
| **Context Window** | ~1M tokens (largest) |
| **Best For** | NotebookLM exports, large document analysis, research synthesis |
| **Limitations** | Less suited for VBA code generation (use Claude) |
| **Cost** | Medium |
| **Speed** | Medium |
| **When to Use** | NotebookLM context, research, large document analysis |

---

## Decision Tree

```
User Request
    ↓
Is this NotebookLM/Research?
    ├── YES → Gemini (export via Gemini Exporter)
    └── NO ↓
Is this quick/simple (< 1hr)?
    ├── YES → Haiku (direct execution)
    └── NO ↓
Is this architecture/deep analysis?
    ├── YES → Opus (delegat to architect/planner)
    └── NO ↓
Is this VBA coding/thesis writing?
    ├── YES → Sonnet (delegat to executor)
    └── NO ↓
Default: Sonnet
```

---

## Integration with OMC

### Model Parameter in OMC Commands

| Command | Model | Agent |
|---------|-------|--------|
| `/team 3:executor "fix errors"` | sonnet | executor |
| `/orchestrate` | opus | team-plan + architect |
| `/ultrawork` | Mixed | Multiple agents |
| `/ralph` | sonnet | ralph |

### Agentic Workflow (from Gemini export)

> "We have your `.agentic-hub` mounted as the single source of truth."

- **OpenCode Subsystems:** 29 agents available
  - Use **haiku** for explorer tasks
  - Use **sonnet** for executor tasks
  - Use **opus** for architect tasks

- **Claude Code Operations:** 28 agents (Everything Claude Code) + 32 agents (OMC)
  - Use **opus** for team-plan, orchestrate
  - Use **sonnet** for executor, debugger

---

## Alert Logic

### Automatic Alerts

| Condition | Alert Type | Message |
|-----------|------------|---------|
| Task = "VBA refactoring" AND model = "haiku" | MODEL MISMATCH | "Use sonnet for complex VBA work (haiku insufficient)" |
| Task = "NotebookLM" AND model = "claude" | TOOL MISMATCH | "Use Gemini for NotebookLM alignment" |
| Task = "Architecture design" AND model = "haiku" | MODEL MISMATCH | "Use opus for architecture (haiku too weak)" |
| Task = "Quick lookup" AND model = "opus" | MODEL MISMATCH | "Use haiku for quick lookup (opus is overkill)" |
| Task = "Thesis Arabic RTL" AND model = "haiku" | MODEL MISMATCH | "Use sonnet/opus for Arabic thesis (language complexity)" |
| Context > 150K tokens (sonnet) | CONTEXT WARNING | "Use Repomix isolation or upgrade to opus/Gemini" |

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `ai-alignment/MODEL_DISPATCH.md` | Detailed dispatch rules |
| `ai-alignment/DISPATCH_ALERTS.md` | Alert templates |
| `context-management/CONTEXT_WINDOW_STRATEGY.md` | Token limits |
| `project-understanding/WORKFLOW_INTEGRATION.md` | Tool pipeline |

---

*End of Model Matrix*
