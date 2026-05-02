---
title: Dispatch Alerts
type: alert-system
last_updated: 2026-05-02
tags: [alerts, dispatch, wrong-agent, mismatch]
---

# Dispatch Alert System

## Wrong Agent Detection

Agents must self-check before executing any task.

---

## Self-Check Protocol

### Step 1: Agent Identifies Task Type
```
Task: [user request]
Type: [quick-lookup / standard-coding / architecture / research / vba-refactoring / thesis-writing]
```

### Step 2: Agent Checks `MODEL_DISPATCH.md`
```
Recommended Model: [from matrix]
Current Model: [self-identify]
Match: [YES/NO]
```

### Step 3: Agent Warns if Mismatch Detected
Use alert templates below.

---

## Alert Templates

### Model Mismatch Alerts

#### Too Weak (Haiku doing complex work)
```
⚠️ MODEL MISMATCH: Task requires {sonnet/opus}, you are using {haiku}
→ Use /model sonnet or /model opus for this task
→ Reason: {task} exceeds haiku capabilities (complex VBA/thesis structure)
```

#### Overkill (Opus doing simple work)
```
⚠️ MODEL MISMATCH: Task requires {haiku/sonnet}, you are using {opus}
→ Use /model sonnet for standard efficiency
→ Reason: {task} is simple lookup/edit, opus wastes context window
```

#### Wrong Tool (Claude doing Gemini task)
```
⚠️ TOOL MISMATCH: Task requires Gemini/NotebookLM, you are Claude/OpenCode
→ Export to Gemini: Use Gemini Exporter (https://www.ai-chat-exporter.com)
→ Paste result in: ai-alignment/GEMINI_ALIGNMENT.md
→ Reason: NotebookLM context only available in Gemini
```

---

## Context Window Alerts

### Approaching Limit
```
⚠️ CONTEXT WARNING: Task may exceed {model} context window ({limit} tokens)
→ Strategy: Use Repomix to isolate context
→ Repomix Location: Logistics.Public.Sector.Refactor/Repomix_Outputs/
→ Alternative: Use /model opus for larger context (200K tokens)
```

### Rate Limit Warning
```
⚠️ RATE LIMIT: Approaching {model} rate limit
→ Strategy: Switch to haiku for simple tasks
→ Wait: {seconds} seconds before retry
→ Alternative: Use Gemini for research (separate quota)
```

---

## Constraint Violation Alerts

### Python/External Dependency Detected
```
🚫 CONSTRAINT VIOLATION: Manifesto Rule 1 (Zero External Dependencies)
→ Detected: {Python/Flask/JSON/API} reference
→ Action: Rewrite using pure VBA
→ Reference: MANIFESTO.md Rule 1
→ Workspace: Software_Surgical_Edit (VBA only)
```

### Wrong Terminology (Thesis)
```
🚫 TERMINOLOGY VIOLATION: Administrative terminology required
→ Detected: {Database/Algorithm/Hybrid System}
→ Correct: {السجل الرقمي/النموذج الرياضي/نظام دعم القرار}
→ Reference: TERMINOLOGY_MAPPING.md
→ Workspace: Thesis_Surgical_Edit (Arabic RTL)
```

### Structural Hierarchy Violation
```
🚫 STRUCTURE VIOLATION: CNEPD hierarchy required
→ Detected: {فرع/Branch} in structure
→ Correct: فصل → مبحث → مطلب → أولاً، ثانياً
→ Reference: MANIFESTO.md Rule 2
```

---

## Workspace Confusion Alerts

### Wrong Directory
```
⚠️ WORKSPACE MISMATCH: You are in {current}, task requires {correct}
→ Thesis tasks → Thesis_Surgical_Edit
→ VBA tasks → Software_Surgical_Edit
→ Context isolation → Repomix_Outputs
→ Action: Switch workspace before proceeding
```

---

## Automated Alert Triggers

Agents should automatically trigger alerts when:

| Condition | Alert Type |
|-----------|------------|
| Task = "VBA refactoring" AND model = "haiku" | MODEL MISMATCH |
| Task = "NotebookLM" AND model = "claude" | TOOL MISMATCH |
| Task = "Architecture" AND model = "haiku" | MODEL MISMATCH (too weak) |
| Task = "Quick lookup" AND model = "opus" | MODEL MISMATCH (overkill) |
| Reference to "Python" in VBA context | CONSTRAINT VIOLATION |
| Reference to "Database" in thesis | TERMINOLOGY VIOLATION |
| Word "فرع" detected in thesis | STRUCTURE VIOLATION |
| Context > 150K tokens (sonnet) | CONTEXT WARNING |

---

## Alert Response Actions

### When Agent Sees Its Own Mismatch
1. **Stop** current execution
2. **Warn** user with appropriate template
3. **Suggest** correct model/agent
4. **Wait** for user confirmation to proceed

### When User Ignores Alert
1. **Proceed** with explicit warning logged
2. **Log** to `logs/ALIGNMENT_LOG.md`
3. **Note** potential quality/safety issues

---

## Alert Log Format

All alerts should be logged to `logs/ALIGNMENT_LOG.md`:

```markdown
## Alert - [timestamp]
- **Type:** [MODEL MISMATCH / TOOL MISMATCH / CONSTRAINT VIOLATION]
- **Task:** [description]
- **Detected:** [what was wrong]
- **Suggested:** [correction]
- **Action:** [user confirmed / user ignored / auto-corrected]
```

---

*End of Dispatch Alerts*
