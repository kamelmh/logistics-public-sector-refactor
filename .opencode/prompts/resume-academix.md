# Academix v13.2 — Resume Prompt (loaded on agent start)
# This file is injected automatically when the `academix` agent launches.

## BOOTSTRAP PROTOCOL (execute on every session start)
1. Read `.opencode/bootstrap/MASTER_BOOTSTRAP.xml` — project identity, ground truth, architecture
2. Read `.opencode/erp-context-compact.md` — token-optimized snapshot (~5K tokens)
3. Read `.crossflow/HANDOFF.md` — current state, pending tasks, final sign-off (bottom first)
4. Read `C:\Users\Administrator\.opencode\notepad.md` — session memory, last-action
5. Run `/memory recall 0` — restore latest OMC checkpoint
6. Load skills: `project`, `remember`, `crossflow-sync`, `autoaudit`, `verify`
7. Check latest ERP verify result from `vbe-auto/results/`
8. Print status board and ask user: "Resume from last action?"

## GROUND TRUTH (Never Modify)
| Param | Value | Description |
|-------|-------|-------------|
| D | 789 | Annual demand (38-day observation) |
| Q* (EOQ) | 37 | Wilson EOQ for ART-001 Toner G030 |
| ROP | 206 | Reorder Point = (D/250)*LT + SS |
| SS | 200 | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4,500 DZD | Unit Price |
| I | 20% | Holding Rate |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection password |
| VERSION | v13.4 | Current |

## PROJECT ASSETS
| Asset | Path |
|-------|------|
| Thesis source (MD) | `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` |
| Thesis DOCX | `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx` |
| English paper (MD) | `Thesis_Surgical_Edit/English_Research_Paper.md` |
| English paper DOCX | `Thesis_Surgical_Edit/output/English_Research_Paper_IEEE.docx` |
| English paper PDF | `Thesis_Surgical_Edit/output/English_Research_Paper_IEEE.pdf` |
| ERP workbook | `ERP_v13.2.xlsm` |
| Build scripts | `vbe-auto/build.ps1`, `Thesis_Surgical_Edit/build-thesis.ps1`, `Thesis_Surgical_Edit/build-english-paper.ps1` |
| Verify scripts | `vbe-auto/verify.ps1`, `Thesis_Surgical_Edit/style/verify_docx_checks.py`, `Thesis_Surgical_Edit/verify-english-paper.ps1` |
| CI/CD | `.github/workflows/ci.yml` |
| CrossFlow | `.crossflow/HANDOFF.md` (single source of truth across windows) |
| Submission | `Thesis_Surgical_Edit/submission/SUBMISSION_GUIDE.md` |
| Session memory | `C:\Users\Administrator\.opencode\notepad.md` |
| OMC checkpoint | `C:\Users\Administrator\.omc\state\sessions\memory-checkpoint-latest.md` |

## KEY PATHS (Windows)
- All file operations use `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` as project root
- Python scripts: use `python` (not `python3`)
- Build: use `& "path\to\script.ps1"` syntax

## STATUS TEMPLATE
After bootstrap, print:
```
━━━ ACADEMIX v13.2 — RESUMED ━━━
ERP verify:  <latest>
Thesis verify: <latest>
Last action: <from notepad.md>
Next: <from HANDOFF.md>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
