---
title: Context Window Strategy
type: strategy
last_updated: 2026-05-02
tags: [context, token-limits, optimization]
---

# Context Window Strategy

## Model Context Limits

| Model | Context Window | Best Use |
|-------|----------------|----------|
| **Haiku** | ~200K tokens | Quick lookups, simple edits |
| **Sonnet** | ~200K tokens | Standard coding, VBA refactoring |
| **Opus** | ~200K tokens | Deep analysis, architecture |
| **Gemini 1.5 Pro** | ~1M tokens | Large document analysis, NotebookLM |

---

## Strategy 1: Repomix Isolation

**Purpose:** Prevent cross-contamination between contexts.

### Workflow
```
1. Generate Repomix for specific context:
   - Thesis: repomix-thesis.xml
   - Software: repomix-software.xml
   - Full Project: repomix-project.xml

2. Load ONLY the relevant file
3. Work in isolated workspace
4. Prevent old Python code "hallucination"
```

### Repomix Outputs Location
`C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Repomix_Outputs\`

---

## Strategy 2: Chunking Large Documents

**When context > 150K tokens:**

1. **Split Document:**
   - Chapter 1-2 (Theory + Diagnosis)
   - Chapter 3-4 (Design + Results)
   - VBA Modules (separate by functionality)

2. **Process Chunks Separately:**
   - Load chunk 1 → Process → Save
   - Load chunk 2 → Process → Save
   - Merge results manually

---

## Strategy 3: Context Compression

**Using `context-compression` Skill:**

### Techniques
- **Deduplication:** Remove repeated content
- **Filtering:** Keep only relevant sections
- **Reordering:** Prioritize recent/important context
- **Summarization:** Compress old context

### Skill Path
`.claude/skills/context-compression/SKILL.md`

---

## Strategy 4: Frontmatter Metadata

**Notion-Style Markdown (like this wiki):**

```markdown
---
title: Document Title
type: document-type
status: active|pending|complete
last_updated: YYYY-MM-DD
tags: [tag1, tag2]
---
```

**Benefits:**
- Quick metadata scanning (no full read)
- AI can prioritize recent/active docs
- Tags help with relevance filtering

---

## Strategy 5: Model Upgrade for Large Context

**When approaching limits:**

| Current Model | Upgrade To | Reason |
|---------------|------------|--------|
| Haiku (200K) | Sonnet (200K) | Better capability |
| Sonnet (200K) | Opus (200K) | Deeper analysis |
| Opus (200K) | Gemini (1M) | Massive context needed |
| Any Claude | Gemini 1.5 Pro | NotebookLM integration |

---

## Alert Thresholds

### Context Warning System

| Used Tokens | Action |
|--------------|--------|
| < 100K | ✅ Safe to continue |
| 100K-150K | ⚠️ Approaching limit - consider compression |
| 150K-180K | 🔴 Warning - use Repomix isolation |
| > 180K | 🚨 Critical - upgrade model or split task |

---

## Practical Examples

### Example 1: VBA Refactoring (Sonnet, ~50K tokens)
```
1. Load: repomix-software.xml (isolated)
2. Read: MANIFESTO.md (constraints)
3. Execute: VBA refactoring task
4. Result: Clean, no Python contamination
```

### Example 2: Thesis Writing (Opus, ~120K tokens)
```
1. Load: repomix-thesis.xml (isolated)
2. Read: TERMINOLOGY_MAPPING.md (Arabic vocab)
3. Execute: Draft Chapter 3 (Design & Methodology)
4. Result: Formal Arabic RTL, administrative terms
```

### Example 3: Gemini Alignment (Gemini, ~500K tokens)
```
1. Export: Gemini NotebookLM conversation
2. Load: Full project context (1M token window)
3. Analyze: Cross-reference with Manifesto
4. Result: Strategic alignment achieved
```

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `ai-alignment/MODEL_DISPATCH.md` | Model selection matrix |
| `project-understanding/WORKFLOW_INTEGRATION.md` | Repomix workflow |
| `dispatch-system/ALERT_RULES.md` | Context warning alerts |
| `context-management/REPOMIX_WORKFLOW.md` | Repomix usage guide |

---

*End of Context Window Strategy*
