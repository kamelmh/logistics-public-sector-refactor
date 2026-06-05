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
- **Status**: DONE

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
- **Status**: DONE

### [TASK-003] Refactoring Plan — mod_StockEntry_Logic.bas
- **Type**: refactor-plan
- **Input**: Software_Surgical_Edit/VBA_Modules/mod_StockEntry_Logic.bas
- **Prompt**: |
  Analyze this 1063-line VBA module and produce a refactoring plan.
  Current state: monolithic, handles stock entry + 6 guard validations + CMUP + ABC-XYZ + alerts.
  Requirements:
  1. Identify logical sub-components (guards, CMUP calc, ABC-XYZ, UI)
  2. Propose 4-6 focused modules with clear responsibilities
  3. Define public API for each new module
  4. List dependencies between new modules
  5. Estimate effort (hours) per module
  6. Identify risks (p-code cache, breaking changes)
  Output: refactoring roadmap with phases and dependencies.
  Constraints: Pure VBA only, no Python/Flask/databases, Excel 2010 compatible.
- **Token Budget**: ~25K input, ~8K output
- **Priority**: MED
- **Status**: DONE

### [TASK-004] Defense Q&A Generation
- **Type**: defense-qa
- **Input**: Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md, .opencode/erp-context-compact.md
- **Prompt**: |
  Based on the thesis and ERP system context, generate 20 likely jury questions
  for a BTS defense in Algeria. Cover:
  - Wilson EOQ formula derivation and application (5 questions)
  - ABC/XYZ classification methodology (3 questions)
  - CMUP moving average calculation (3 questions)
  - VBA implementation architecture (4 questions)
  - Practical results and limitations (3 questions)
  - Future improvements (2 questions)
  For each question, provide:
  - The question in French (formal academic register)
  - Expected answer key points (3-5 bullet points)
  - Difficulty level (EASY/MEDIUM/HARD)
  - Related ground-truth values to cite in answer
  Format: numbered list with Q, Answer Key, Difficulty, Ground Truth refs.
- **Token Budget**: ~20K input, ~10K output
- **Priority**: HIGH
- **Status**: DONE

### [TASK-005] Loop Verification — CrossFlow Pipeline Test
- **Type**: verification
- **Input**: .crossflow/opus-tasks.md, .crossflow/opus-results.md, .crossflow/knowledge-base.json
- **Prompt**: |
  Verify the CrossFlow-Opus closed learning loop is working:
  1. Check opus-tasks.md has tasks with correct status (DONE/PENDING)
  2. Check opus-results.md has results for all DONE tasks
  3. Check knowledge-base.json has extracted knowledge items
  4. Check .crossflow/skills/ has auto-generated SKILL.md files
  5. Verify ground truth params are correct: D=789, Q*=37, ROP=206, SS=200, LT=2, S=801.45, PU=4500, I=20%
  6. Verify MASTER_PWD is NOT exposed in any file
  Output: pass/fail checklist with details.
- **Token Budget**: ~10K input, ~4K output
- **Priority**: HIGH
- **Status**: DONE

---

### [TASK-006] VBA Module Inventory — All 37 Modules
- **Type**: audit-module
- **Input**: Software_Surgical_Edit/VBA_Modules/*.bas
- **Prompt**: |
  Perform a complete inventory of all VBA modules in the ERP system.
  For each .bas file in Software_Surgical_Edit/VBA_Modules/:
  1. Module name and file size
  2. Number of Public/Private procedures (Sub/Function)
  3. Total lines of code (excluding comments and blank lines)
  4. Key responsibilities (1-2 line summary)
  5. Dependencies (which other modules it calls)
  6. Security concerns (hardcoded values, missing validation)
  7. Lines of code threshold (flag if >500 lines — needs refactoring)
  
  Output format: markdown table with columns:
  Module | Size | Procedures | LOC | Responsibilities | Dependencies | Flags
  
  Also produce a summary:
  - Total modules count
  - Total LOC across all modules
  - Modules exceeding 500 LOC (refactoring candidates)
  - Most connected modules (called by many others)
  - Dead code candidates (never called)
- **Token Budget**: ~30K input, ~10K output
- **Priority**: MED
- **Status**: DONE

---

## Active Task
<!-- Only ONE task runs at a time. Opus picks up the first PENDING task. -->
(none)

## Completed Tasks
<!-- Moved here after execution -->
(none)
























