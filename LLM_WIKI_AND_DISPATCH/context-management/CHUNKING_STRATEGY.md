---
title: Chunking Strategy
type: strategy
last_updated: 2026-05-02
tags: [chunking, splitting, large-documents]
---

# Chunking Strategy

## When to Chunk Documents

### Thresholds

| Document Size | Action |
|---------------|--------|
| < 50K tokens | ✅ Process as single unit |
| 50K-150K tokens | ⚠️ Consider chunking for complex tasks |
| > 150K tokens | 🔴 MUST chunk (prevent context overflow) |

---

## Chunking Methods

### Method 1: By Chapter (Thesis)

**For `Final_Thesis_Academix_v13_2.md` (~128K tokens):**

```
Chunk 1: Chapter 1 + Chapter 2
  - Theory & Concepts (EOQ, ROP, SS)
  - Field Diagnosis (El Bayadh context)
  → Process: terminology check, Arabic RTL validation

Chunk 2: Chapter 3
  - Design & Methodology (VBA DSS)
  → Process: technical accuracy, VBA code review

Chunk 3: Chapter 4
  - Results & Evaluation (Toner G030 case study)
  → Process: data verification, performance metrics
```

### Method 2: By VBA Module (Software)

**For VBA_Modules/ (~50K tokens total):**

```
Chunk 1: Core Engine Modules
  - mod_StockEngine.bas
  - mod_ExportEngine.bas
  → Process: EOQ/ROP calculations verification

Chunk 2: UI & Forms
  - frmStockEntry.frm
  - mod_UI_Setup.bas
  → Process: UserForm functionality check

Chunk 3: Utilities & Config
  - mod_Utilities.bas
  - mod_Config.bas
  - mod_Database.bas
  → Process: helper functions review
```

### Method 3: By Topic (Research)

**For NotebookLM exports (~500K tokens in Gemini):**

```
Chunk 1: Strategic Pivot (Export 1)
  - Thesis Project Strategic Pivot
  → Process: align with Manifesto

Chunk 2: Compliance (Export 2)
  - Refactoring for Public Sector
  → Process: verify Clean Room rules

Chunk 3: Workflow (Export 3)
  - Project Status & Workflow Integration
  → Process: agent dispatch alignment
```

---

## Chunk Processing Workflow

### Sequential Processing

```
1. LOAD CHUNK 1
   → Process task
   → Save output
   → Clear context (or use fresh session)

2. LOAD CHUNK 2
   → Process task
   → Save output
   → Clear context

3. MERGE RESULTS
   → Combine outputs manually
   → Verify consistency across chunks
```

### Parallel Processing (Independent Chunks Only)

```
1. SPAWN AGENT 1 → Process Chunk 1 (Thesis Ch 1-2)
2. SPAWN AGENT 2 → Process Chunk 2 (Thesis Ch 3)
3. SPAWN AGENT 3 → Process Chunk 3 (Thesis Ch 4)

→ Wait for all agents to complete
→ Merge results
```

**Warning:** Only use parallel for independent tasks (no cross-chunk dependencies).

---

## Chunk Size Recommendations

### For Different Models

| Model | Recommended Chunk Size | Max Chunk Size |
|-------|------------------------|----------------|
| Haiku | 10K-30K tokens | 50K tokens |
| Sonnet | 30K-80K tokens | 120K tokens |
| Opus | 50K-120K tokens | 180K tokens |
| Gemini 1.5 Pro | 100K-500K tokens | 900K tokens |

---

## Practical Examples

### Example 1: Thesis Chapter Drafting (Opus, Chunked)

```
Task: "Draft all 4 chapters in Formal Arabic RTL"

Chunk 1: Chapter 1 (Theory)
  - Load: repomix-thesis.xml (filtered to Ch 1)
  - Model: Opus
  - Output: CHAPTER_1.md

Chunk 2: Chapter 2 (Field Diagnosis)
  - Load: repomix-thesis.xml (filtered to Ch 2)
  - Model: Opus
  - Output: CHAPTER_2.md

... (repeat for Ch 3, Ch 4)

Merge: Combine into Final_Thesis_Academix_v13_3.md
```

### Example 2: VBA Module Refactoring (Sonnet, Chunked)

```
Task: "Refactor all VBA modules to pure VBA (no Python)"

Chunk 1: Core Modules (mod_StockEngine, mod_ExportEngine)
  - Model: Sonnet
  - Check: No Python bridges, use VBA arrays only

Chunk 2: UI Modules (frmStockEntry, mod_UI_Setup)
  - Model: Sonnet
  - Check: UserForm functionality, Digital Ledger updates

... (repeat for utilities)

Verify: Run VBA tests (if available)
```

---

## Chunking Tools

### Using Repomix for Chunking

```powershell
# Chunk 1: Thesis Chapter 1-2
repomix --include "Thesis_Surgical_Edit/CHAPTER_1.md" --include "Thesis_Surgical_Edit/CHAPTER_2.md" --output Repomix_Outputs/chunk1-thesis-12.xml

# Chunk 2: Thesis Chapter 3
repomix --include "Thesis_Surgical_Edit/CHAPTER_3.md" --output Repomix_Outputs/chunk2-thesis-3.xml

# Chunk 3: Thesis Chapter 4
repomix --include "Thesis_Surgical_Edit/CHAPTER_4.md" --output Repomix_Outputs/chunk3-thesis-4.xml
```

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `context-management/CONTEXT_WINDOW_STRATEGY.md` | Token limits |
| `context-management/REPOMIX_WORKFLOW.md` | Context isolation |
| `dispatch-system/ALERT_RULES.md` | Chunk size warnings |
| `project-understanding/WORKFLOW_INTEGRATION.md` | Sequential processing |

---

*End of Chunking Strategy*
