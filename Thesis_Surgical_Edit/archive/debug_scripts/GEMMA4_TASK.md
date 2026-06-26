# Gemma 4 31B Task — Amelioration Mission

## Your Role
You are Gemma 4 31B, running on OpenCode CLI for the Academix v13.4 project.

## Project Context
- **ERP DSS** for Direction de l'Education El Bayadh, Algeria
- **Student**: Mahi Kamel Abdelghani
- **Thesis**: Memoire_DSS_Logistique_ElBayadh (78 pages, 28/29 verify PASS)
- **ERP**: v13.4, 114/114 PASS, Pure VBA, Excel 2010 compat
- **Ground Truth**: D=789, Q*=37, ROP=206, SS=200, LT=2, S=801.45, PU=4500, I=20%

## What's Been Built Today
1. **Academix Command Center v2.0** — Unified launcher with model routing
2. **Smart Model Router** — Auto-selects best model for task type
3. **Context Loader** — Auto-injects ground truth into prompts
4. **Quick ERP Calculator** — One-click EOQ/ROP/alerts
5. **Quick Code Review** — VBA bug finder
6. **Model Testing** — Qwen3 32B (96%), Llama 3.3 70B (90%), GPT-OSS 120B (50%)

## AMELIORATION TASK

Pick ONE of the following and complete it:

### Option A: Improve the Command Center
Read `Desktop\Academix-CommandCenter.ps1` and enhance it:
- Add a "Thesis Status" checker (verify DOCX exists, check size, run verify script)
- Add a "Git Status" quick view (commits ahead, branch, last commit)
- Add a "Model Speed Test" (ping all models, show latency ranking)
- Improve error handling (try/catch around API calls)

### Option B: Create Submission Checklist
Create `Thesis_Surgical_Edit\submission\SUBMISSION_CHECKLIST.md`:
- Thesis defense checklist (PDF, DOCX, presentation, printed copies)
- CCA'2026 paper submission checklist (format, deadline, co-authors)
- File inventory (all outputs, sizes, verification status)
- Timeline to defense date

### Option C: Improve verify_docx_checks.py
Read `Thesis_Surgical_Edit\style\verify_docx_checks.py` and add:
- Table style comparison check (current vs backup v7c)
- Caption RTL verification (w:bidi attribute)
- Page numbering validation (decimal, start=4 on TOC)
- Output a clean PASS/FAIL summary with emoji

### Option D: Create Defense Presentation Outline
Create `Thesis_Surgical_Edit\defense\DEFENSE_OUTLINE.md`:
- Slide-by-slide outline for 15-minute defense
- Key points per chapter
- Anticipated questions and answers
- Demo script (ERP workbook walkthrough)

## Instructions
1. Read the relevant files first
2. Pick the option you think adds most value
3. Implement it fully (write the code/docs)
4. Test if possible
5. Report what you did

## Key Files
| File | Path |
|------|------|
| Command Center | Desktop\Academix-CommandCenter.ps1 |
| Model Router | Desktop\model-router.ps1 |
| Context Loader | Desktop\context-loader.ps1 |
| Verify Script | Thesis_Surgical_Edit\style\verify_docx_checks.py |
| Build Script | Thesis_Surgical_Edit\build-thesis.ps1 |
| HANDOFF | .crossflow\HANDOFF.md |
| Notepad | C:\Users\Administrator\.opencode\notepad.md |
