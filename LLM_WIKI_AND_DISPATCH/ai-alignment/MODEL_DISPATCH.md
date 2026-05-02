---
title: Model Dispatch Matrix
type: dispatch-rules
models: [haiku, sonnet, opus, gemini]
last_updated: 2026-05-02
---

# Model Dispatch Matrix

## Routing Rules

| Task Type | Recommended Model | Alert If Using Wrong |
|-----------|-------------------|---------------------|
| Quick lookup, simple queries | **haiku** | opus (overkill), gemini (context loss) |
| Standard coding, refactoring | **sonnet** | haiku (insufficient capability) |
| Architecture, deep analysis | **opus** | haiku (too weak for complexity) |
| NotebookLM alignment, research | **gemini** | claude (lacks NotebookLM context) |
| VBA DSS refactoring | **sonnet** | haiku (complexity too high) |
| Thesis writing (Arabic RTL) | **sonnet/opus** | haiku (language complexity) |
| Security audit, vulnerability detection | **opus** | sonnet (depth required) |
| Agent orchestration (team/planner) | **opus** | haiku (planning complexity) |
| Context compression, optimization | **sonnet** | haiku (may lose nuance) |
| Testing, verification | **sonnet** | haiku (test coverage needs) |

---

## Model Capabilities

### Haiku
- **Context Window:** ~200K tokens
- **Best For:** Quick lookups, simple edits, status checks
- **Limitations:** May struggle with complex VBA refactoring or deep architectural analysis
- **Cost:** Low

### Sonnet
- **Context Window:** ~200K tokens
- **Best For:** Standard coding tasks, VBA refactoring, thesis writing, testing
- **Limitations:** May need opus for deepest architectural decisions
- **Cost:** Medium

### Opus
- **Context Window:** ~200K tokens
- **Best For:** Architecture design, deep analysis, security audits, orchestration
- **Limitations:** Overkill for simple tasks (context waste)
- **Cost:** High

### Gemini
- **Context Window:** ~1M tokens (Gemini 1.5 Pro)
- **Best For:** NotebookLM exports, large document analysis, research synthesis
- **Limitations:** Less suited for VBA code generation (use Claude for that)
- **Cost:** Medium

---

## Alert Logic

Agents must self-check before executing:

```
IF task = "VBA refactoring" AND model = "haiku" 
   → WARN: "Use sonnet for complex VBA work (haiku insufficient)"

IF task = "NotebookLM" AND model = "claude" 
   → WARN: "Use Gemini for NotebookLM alignment (Claude lacks NotebookLM context)"

IF task = "Architecture design" AND model = "haiku" 
   → WARN: "Use opus for architecture (haiku too weak for deep analysis)"

IF task = "Quick lookup" AND model = "opus" 
   → WARN: "Use haiku for quick lookup (opus is overkill)"

IF task = "Thesis Arabic RTL" AND model = "haiku" 
   → WARN: "Use sonnet/opus for Arabic thesis (language complexity)"
```

---

## Automatic Model Selection

When dispatching agents, use this decision tree:

1. **Is this a NotebookLM/Research task?** → Gemini
2. **Is this quick/simple (< 1hr work)?** → Haiku
3. **Is this architecture/deep analysis?** → Opus
4. **Is this VBA coding/thesis writing?** → Sonnet
5. **Default (when unsure):** → Sonnet

---

## Integration with OMC

When using Oh-My-Claudecode (OMC):

- **haiku tasks:** Direct execution (no delegation needed)
- **sonnet tasks:** Standard delegation to `executor` (model=sonnet)
- **opus tasks:** Delegate to `architect` or `planner` (model=opus)
- **gemini tasks:** Use `/oh-my-claudecode:research` skill, then align with Gemini externally

---

*End of Model Dispatch Matrix*
