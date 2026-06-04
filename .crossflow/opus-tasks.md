# CrossFlow-Opus Task Board
# Queue: opus-tasks.md | Results: opus-results.md | Worker: Claude Opus via CLI
# Protocol: OpenCode writes tasks → git commit → Opus picks up → git commit results

## Pending Tasks

<!-- FORMAT:
### [TASK-XXX] Title
- **Type**: audit-module | review-thesis | review-paper | refactor-plan | defense-qa | custom
- **Input**: file path(s) relative to project root
- **Prompt**: focused instruction (max 500 words)
- **Token Budget**: estimated input tokens
- **Priority**: HIGH | MED | LOW
- **Status**: PENDING | RUNNING | DONE | FAILED
-->

### [TASK-001] Security Audit — mod_Config.bas
- **Type**: audit-module
- **Input**: Software_Surgical_Edit/VBA_Modules/mod_Config.bas
- **Prompt**: |
  You are auditing a VBA configuration module for a public-sector ERP system.
  Read the file and produce a security audit report covering:
  1. Hardcoded secrets (MASTER_PWD, API keys)
  2. Exposed constants that should be private
  3. Missing access controls
  4. Injection vectors (SQL, command, cell injection)
  5. Input validation gaps
  Output format: markdown table with columns: Severity | Finding | File:Line | Recommendation
  Keep findings concise — max 2 lines per finding.
- **Token Budget**: ~8K input, ~4K output
- **Priority**: HIGH
- **Status: PENDING

### [TASK-002] Thesis Chapter 3 Review — Field Diagnosis
- **Type**: review-thesis
- **Input**: Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md (Chapter 3 only)
- **Prompt**: |
  Read Chapter 3 (Chapitre 3: Diagnostic de terrain) of this French BTS thesis.
  Review for:
  1. Academic tone consistency (formal French)
  2. Formula correctness: Wilson EOQ (Q*=37), ROP (206), CMUP
  3. Ground truth alignment: D=789, S=801.45, PU=4500, I=20%, SS=200, LT=2
  4. Table formatting and data presentation
  5. Missing citations or weak arguments
  Output: chapter review with specific paragraph references.
- **Token Budget**: ~15K input, ~5K output
- **Priority**: HIGH
- **Status**: DONE

### [TASK-003] Refactoring Plan — mod_StockEntry_Logic.bas
- **Type**: refactor-plan
- **Input**: Software_Surgical_Edit/VBA_Modules/mod_StockEntry_Logic.bas
- **Prompt**: |
  Read this VBA module (1063 lines, heaviest consumer in the ERP).
  Analyze and propose a refactoring plan:
  1. Identify functions that can be extracted into new modules
  2. Map dependencies (what calls what)
  3. Propose new module boundaries (max ~300 lines each)
  4. Estimate before/after line counts
  5. List risks and migration steps
  Do NOT modify any files. Output a structured refactoring plan.
- **Token Budget**: ~12K input, ~6K output
- **Priority**: MED
- **Status**: PENDING

### [TASK-004] Defense Q&A Generation
- **Type**: defense-qa
- **Input**: Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md, .opencode/erp-context-compact.md
- **Prompt**: |
  Based on the thesis and ERP system context, generate 20 likely jury questions
  for a BTS defense in Algeria. Cover:
  - Wilson EOQ formula derivation and application (5 questions)
  - ABC/XYZ classification methodology (3 questions)
  - VBA architecture decisions (4 questions)
  - Data integrity and security (3 questions)
  - Practical impact and field results (3 questions)
  - Limitations and future work (2 questions)
  Format: Q&A pairs in French. Each answer: 2-3 sentences max.
- **Token Budget**: ~20K input, ~8K output
- **Priority**: MED
- **Status**: PENDING

---

## Active Task
<!-- Only ONE task runs at a time. Opus picks up the first PENDING task. -->
(none)

## Completed Tasks
<!-- Moved here after execution -->
(none)




