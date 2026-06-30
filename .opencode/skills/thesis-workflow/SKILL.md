---
name: thesis-workflow
description: Automate thesis formatting, citation checks, and pre-submission readiness using the quzhiii/thesis-skills CLI workflow system.
license: MIT
compatibility: opencode
metadata:
  audience: thesis-author
  workflow: academic-submission
---
## Overview
This skill provides access to the `quzhiii/thesis-skills` CLI workflow system, cloned into `thesis-skills-workflow/` in your project root. It helps automate various aspects of thesis preparation, including:
- Citation integrity checks
- Formatting and language consistency checks
- Pre-submission readiness reports
- Optional auto-fixes for common issues
- External verification of references (e.g., CrossRef, OpenAlex)

## How to Use
To use this skill, you will typically invoke its Python scripts directly via the `bash` tool. The main entry point for checks is `run_check_once.py`.

**Example: Run a basic check (without LaTeX compile)**
```bash
python thesis-skills-workflow/run_check_once.py \
  --project-root Thesis_Surgical_Edit \
  --ruleset el-bayadh-thesis \
  --skip-compile
```

**Example: Run a full check (requires LaTeX installed and configured)**
```bash
python thesis-skills-workflow/run_check_once.py \
  --project-root Thesis_Surgical_Edit \
  --ruleset el-bayadh-thesis
```

**Example: Run final delivery workflow (generates evidence, reports, and bundle)**
```bash
python thesis-skills-workflow/33-final-delivery/run_final_delivery.py \
  --project-root Thesis_Surgical_Edit \
  --ruleset el-bayadh-thesis
```

**Important Notes:**
- Replace `Thesis_Surgical_Edit` with the actual path to your thesis source files (e.g., where your main `.tex` or `.md` file is).
- You may need to install Python dependencies for `thesis-skills-workflow` (e.g., `pip install -r thesis-skills-workflow/requirements.txt`).
- Refer to the `thesis-skills-workflow/README.md` for full documentation on all available scripts, rule packs, and scenarios.
