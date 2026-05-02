---
title: Repomix Workflow
type: workflow
last_updated: 2026-05-02
tags: [repomix, context-isolation, packing]
---

# Repomix Workflow

## What is Repomix?

Tool for generating isolated context files (.xml or .txt) for AI tools. Prevents cross-contamination between different project contexts.

---

## Repomix Outputs Location

`C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Repomix_Outputs\`

### Current Files

| File | Content | Use Case |
|------|---------|----------|
| `repomix-project.xml` | Full project context | General queries |
| `repomix-software.xml` | VBA codebase only | Software refactoring |
| `repomix-thesis.xml` | Thesis files only | Thesis writing |

---

## When to Use Repomix

### Scenario 1: VBA Refactoring (Software Context)
```
1. Generate: repomix-software.xml
   - Include: Software_Surgical_Edit/
   - Exclude: Thesis_Surgical_Edit/
   - Exclude: Python files (enforce Clean Room)

2. Load: repomix-software.xml into Claude/OpenCode
3. Task: "Refactor mod_StockEngine.bas to pure VBA"
4. Result: No Python contamination from thesis context
```

### Scenario 2: Thesis Writing (Thesis Context)
```
1. Generate: repomix-thesis.xml
   - Include: Thesis_Surgical_Edit/
   - Include: project-understanding/
   - Exclude: Software_Surgical_Edit/VBA_Modules/

2. Load: repomix-thesis.xml into Claude/OpenCode
3. Task: "Draft Chapter 3 in Formal Arabic RTL"
4. Result: No VBA code contamination in thesis
```

### Scenario 3: Full Project (General Context)
```
1. Generate: repomix-project.xml
   - Include: Entire Logistics.Public.Sector.Refactor/
   - Include: LLM_WIKI_AND_DISPATCH/

2. Load: repomix-project.xml
3. Task: "Check project alignment with Manifesto"
4. Result: Full visibility across all contexts
```

---

## Repomix Generation Commands

### Basic Command (PowerShell)
```powershell
# Navigate to project root
cd "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"

# Generate full project context
repomix --output Repomix_Outputs/repomix-project.xml

# Generate software-only context
repomix --include "Software_Surgical_Edit/**" --output Repomix_Outputs/repomix-software.xml

# Generate thesis-only context
repomix --include "Thesis_Surgical_Edit/**" --output Repomix_Outputs/repomix-thesis.xml
```

### Advanced: Exclude Python (Clean Room Enforcement)
```powershell
# Exclude any Python files (enforce zero dependency rule)
repomix --exclude "**/*.py" --exclude "**/venv/**" --output Repomix_Outputs/repomix-software.xml
```

---

## Context Isolation Rules

### DO NOT Cross-Contaminate

| Context A | Context B | Risk |
|----------|----------|------|
| Thesis (Arabic RTL) | VBA Code (English) | Mixed language confusion |
| VBA (Pure) | Python (Banned) | Hallucinated Python bridges |
| Manifesto (Rules) | Old Python Code | Rule violations |
| El Bayadh Data | Fake Datasets | Incorrect calculations |

### Solution: Separate Repomix Files

1. **Always load only the relevant Repomix file**
2. **Verify workspace** (Thesis vs. Software)
3. **Read Manifesto first** (constraints)
4. **Execute task** in isolation

---

## Workflow Integration

### Step-by-Step Process

```
1. DETERMINE CONTEXT NEEDED
   ├── Thesis writing? → repomix-thesis.xml
   ├── VBA coding? → repomix-software.xml
   └── General query? → repomix-project.xml

2. GENERATE REPOMIX (if outdated)
   → Run repomix command with appropriate filters

3. LOAD INTO AI TOOL
   → Claude/OpenCode: Load repomix-*.xml

4. READ MANIFESTO
   → ai-alignment/MANIFESTO.md (constraints)

5. EXECUTE TASK
   → In isolated workspace

6. SAVE OUTPUT
   → To appropriate directory (Thesis_Surgical_Edit/ or Software_Surgical_Edit/)

7. UPDATE LOGS
   → logs/SESSION_LOG.md
```

---

## Preventing Hallucinations

### Common Hallucination Triggers

| Trigger | Prevention |
|---------|-------------|
| Old Python code in context | Use repomix-software.xml (exclude *.py) |
| Wrong terminology | Read TERMINOLOGY_MAPPING.md first |
| Fake data | Verify EL_BAYADH_DATASET.md constants |
| Branch (فرع) in thesis | Check CNEPD_STANDARDS.md |

### Isolation Checklist

Before executing task:

- [ ] Loaded correct Repomix file (thesis vs. software)
- [ ] Read MANIFESTO.md (Clean Room rules)
- [ ] Verified workspace (Thesis_Surgical_Edit/ or Software_Surgical_Edit/)
- [ ] Checked MODEL_DISPATCH.md (correct model)
- [ ] Confirmed El Bayadh constants (if calculations)

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `project-understanding/WORKFLOW_INTEGRATION.md` | AI tools pipeline |
| `context-management/CONTEXT_WINDOW_STRATEGY.md` | Token management |
| `ai-alignment/MODEL_DISPATCH.md` | Model selection |
| `dispatch-system/ALERT_RULES.md` | Context warnings |

---

*End of Repomix Workflow*
