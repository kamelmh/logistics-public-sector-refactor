---
title: Validation Scripts
type: validation
last_updated: 2026-05-02
tags: [validation, scripts, checklists, verification]
---

# Validation Scripts

## Pre-Task Validation Checklist

### Before Starting ANY Task

```markdown
## Pre-Task Checklist

### 1. Model Selection ✅
- [ ] Read `dispatch-system/MODEL_MATRIX.md`
- [ ] Verify model matches task type
- [ ] Check: Not using haiku for complex VBA/thesis
- [ ] Check: Not using opus for simple lookups

### 2. Workspace Verification ✅
- [ ] Identify correct workspace:
  - Thesis → Thesis_Surgical_Edit/
  - VBA → Software_Surgical_Edit/
  - Context → Repomix_Outputs/
- [ ] Confirm no cross-contamination risk

### 3. Manifesto Compliance ✅
- [ ] Read `ai-alignment/MANIFESTO.md`
- [ ] Confirm: Zero Python/Flask/JSON/APIs
- [ ] Confirm: Pure VBA only
- [ ] Confirm: Administrative terminology (not technical)

### 4. Context Management ✅
- [ ] Load appropriate Repomix file:
  - Thesis → repomix-thesis.xml
  - Software → repomix-software.xml
  - Full → repomix-project.xml
- [ ] Check token count (< 150K for sonnet)

### 5. Ground Truth Verification ✅
- [ ] Read `project-understanding/EL_BAYADH_DATASET.md`
- [ ] Confirm constants:
  - D = 1,546 units
  - Q* = 176 units
  - ROP = 205.6 units
  - SS = 200 units
  - LT = 2 days
```

---

## VBA Code Validation Script

### After VBA Refactoring

```markdown
## VBA Code Validation

### Clean Room Compliance ✅
- [ ] NO Python imports/bridges
- [ ] NO Flask/API calls
- [ ] NO JSON parsing (use VBA arrays)
- [ ] ALL code runs in Excel VBA only

### VBA Syntax ✅
- [ ] All subs/functions properly declared
- [ ] Error handling (On Error) added
- [ ] Variables declared (Option Explicit)
- [ ] No external DLL references

### Ground Truth Alignment ✅
- [ ] EOQ calculation uses D=1546, result=176
- [ ] ROP calculation uses d=4.24, LT=2, SS=200, result=205.6
- [ ] All test cases use Toner G030 (ART-001)

### Digital Ledger (السجل الرقمي) ✅
- [ ] NO "Database" term in comments
- [ ] Sheets treated as Digital Ledger
- [ ] VBA Processing Units (وحدات المعالجة VBA) terminology used

### Save & Test ✅
- [ ] Module saved as .bas or .frm
- [ ] Imported to ERP_Academie_v13_Master.xlsm
- [ ] Tested with El Bayadh data
```

---

## Thesis Validation Script

### After Thesis Chapter Draft

```markdown
## Thesis Validation

### CNEPD Structure ✅
- [ ] 4 chapters ONLY (not 6)
- [ ] Hierarchy: فصل → مبحث → مطلب → أولاً، ثانياً
- [ ] NO "فرع" (Branch) anywhere
- [ ] Formal Academic Arabic (RTL)

### Terminology Mapping ✅
- [ ] NO "Database" → Use السجل الرقمي
- [ ] NO "Python/Algorithm" → Use النموذج الرياضي
- [ ] NO "Hybrid System" → Use نظام دعم القرار
- [ ] NO "UserForms" → Use استمارات العمل

### Administrative Tone ✅
- [ ] Narrative: "The system verifies..." NOT "The system calculates..."
- [ ] Emphasis on "Zero Cost", "Standard Tools", "Accountability"
- [ ] Citations: CNEPD footnotes (تهميش) at page bottom

### Ground Truth Integration ✅
- [ ] Chapter 1: EOQ formula with D=1546, Q*=176
- [ ] Chapter 2: El Bayadh Directorate context
- [ ] Chapter 3: VBA DSS design (pure VBA)
- [ ] Chapter 4: Toner G030 case study results

### Pedagogical Ladder ✅
- [ ] Ch 1: Manual science (prove competence)
- [ ] Ch 2: Semi-automated (Excel basics)
- [ ] Ch 3: VBA automation (pure VBA DSS)
- [ ] Ch 4: Evaluation (performance metrics)
```

---

## Gemini Alignment Validation

### After Pasting Gemini Export

```markdown
## Gemini Alignment Validation

### Export Integrity ✅
- [ ] Exported via Gemini Exporter
- [ ] Pasted to `ai-alignment/GEMINI_ALIGNMENT.md`
- [ ] Link to original conversation included

### Cross-Reference ✅
- [ ] Checked against `MANIFESTO.md` (Clean Room rules)
- [ ] Verified against `PROJECT_MEMORY.md` (Ground truth)
- [ ] Ensured model dispatch aligns with `MODEL_DISPATCH.md`

### Compliance Check ✅
- [ ] NO Python suggestions
- [ ] NO technical terminology (Database, Algorithm)
- [ ] YES administrative vocabulary
- [ ] YES CNEPD BTS standards

### Execution Plan ✅
- [ ] Task broken into steps
- [ ] Correct model assigned (sonnet/opus)
- [ ] Correct workspace identified
- [ ] Repomix file selected (isolation)
```

---

## Model Dispatch Validation

### Before Executing Task

```markdown
## Model Dispatch Validation

### Task Identification ✅
- [ ] Task type identified (lookup/coding/thesis/architecture/research)
- [ ] Complexity assessed (< 1hr / 1-4hr / > 4hr)

### Model Selection ✅
- [ ] Consulted `MODEL_MATRIX.md`
- [ ] Model matches task type:
  - Quick → haiku
  - Standard → sonnet
  - Deep → opus
  - Research → gemini
- [ ] NO mismatches (or warned user)

### Agent Selection ✅
- [ ] Consulted `AGENT_PROTOCOLS.md`
- [ ] Agent matches model:
  - haiku → explorer/general
  - sonnet → executor
  - opus → architect/planner
  - gemini → (external)
- [ ] OMC command used if needed (/team, /orchestrate)

### Alert Check ✅
- [ ] Self-checked against `ALERT_RULES.md`
- [ ] No critical violations
- [ ] Warnings logged to `logs/ALIGNMENT_LOG.md`
```

---

## Post-Task Validation

### After Completing Task

```markdown
## Post-Task Validation

### Output Verification ✅
- [ ] Output matches request
- [ ] NO Python/Flask/JSON/APIs (if VBA task)
- [ ] NO technical terms (if thesis task)
- [ ] Ground truth data used (if calculations)

### Workspace Cleanliness ✅
- [ ] Files saved to correct workspace
- [ ] NO cross-contamination (thesis vs. software)
- [ ] Repomix file used (isolation)

### Logging ✅
- [ ] Session logged to `logs/SESSION_LOG.md`
- [ ] Alerts logged to `logs/ALIGNMENT_LOG.md`
- [ ] Status updated in `_INDEX.md` dashboard

### Next Steps ✅
- [ ] Next task identified
- [ ] Model pre-selected
- [ ] Workspace prepared
- [ ] Context (Repomix) ready
```

---

## Automated Validation (Future)

### Potential Automation Scripts

| Script | Purpose | Trigger |
|--------|---------|--------|
| `check-vba-cleanroom.ps1` | Scan for Python/JSON/API refs | After VBA edit |
| `check-thesis-terminology.ps1` | Scan for "Database"/"Algorithm" | After thesis edit |
| `check-context-tokens.ps1` | Count tokens in context | Before loading context |
| `check-el-bayadh-constants.ps1` | Verify ground truth values | Before VBA tests |

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `dispatch-system/ALERT_RULES.md` | Alert triggers |
| `dispatch-system/ROUTING_LOGIC.md` | Task → Model → Agent flow |
| `dispatch-system/MODEL_MATRIX.md` | Model selection |
| `project-understanding/WORKFLOW_INTEGRATION.md` | Tool pipeline |

---

*End of Validation Scripts*
