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
- **Input**: .crossflow/temp-chapter3.md
- **Prompt**: |
  Read Chapter 3 (Chapitre 3: Diagnostic de terrain) of this French BTS thesis.
  The chapter starts with "Chapitre 3" or "Chapitre III" and covers field diagnosis.
  Review for:
  1. Academic tone consistency (formal French)
  2. Formula correctness: Wilson EOQ (Q*=37), ROP (206), CMUP
  3. Ground truth alignment: D=789, S=801.45, PU=4500, I=20%, SS=200, LT=2
  4. Table formatting and data presentation
  5. Missing citations or weak arguments
  Output: chapter review with specific paragraph references.
- **Token Budget**: ~15K input, ~5K output
- **Priority**: HIGH
- **Status: PENDING

### [TASK-003] Refactoring Plan — mod_StockEntry_Logic.bas
- **Type**: refactor-plan
- **Input**: Software_Surgical_Edit/VBA_Modules/mod_StockEntry_Logic.bas
- **Prompt**: |
  Review this Arabic thesis chapter (الفصل الثالث: تصميم وإنجاز نظام دعم القرار).
  The thesis is a French BTS but written in Arabic with French technical terms.
  Review in ENGLISH, covering:
  1. Technical accuracy of formulas (EOQ, ROP, CMUP) — verify against ground truth:
     D=789, Q*=37, ROP=206, SS=200, LT=2, S=801.45 DZD, PU=4500 DZD, I=20%
  2. VBA implementation completeness — check if all 42 modules are referenced
  3. Table formatting and data presentation
  4. Missing sections or weak arguments
  5. Code architecture assessment (monolithic vs modular)
  Format: numbered findings with severity (CRITICAL/HIGH/MED/LOW) and specific line refs.
- **Token Budget**: ~25K input, ~8K output
- **Priority**: HIGH
- **Status**: DONE

### [TASK-006] VBA Module Inventory — All 37 Modules
- **Type**: custom
- **Input**: Software_Surgical_Edit/VBA_Modules/ (directory listing)
- **Prompt**: |
  Read all 37 .bas files in the VBA_Modules directory.
  For each module, extract:
  1. Module name and type (bas/frm/cls)
  2. Public functions/subs (API surface)
  3. Dependencies (what other modules it calls)
  4. Line count
  5. Any TODO/FIXME/HACK comments
  Output as a JSON array for machine consumption.
- **Token Budget**: ~40K input, ~15K output
- **Priority**: MED
- **Status**: PENDING

---

## Active Task
<!-- Only ONE task runs at a time. Opus picks up the first PENDING task. -->
(none)

## Completed Tasks
<!-- Moved here after execution -->
(none)
















