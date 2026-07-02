# Academix v13.4 — Resume Prompt (loaded on agent start)
# This file is injected automatically when the `academix` agent launches.

## BOOTSTRAP PROTOCOL (execute on every session start)
1. Read `.opencode/bootstrap/MASTER_BOOTSTRAP.xml` — project identity, ground truth, architecture
2. Read `.opencode/notepad.md` — session memory, last-action, next-steps
3. Read `.opencode/memory/session.json` — structured session state
4. Read `C:\Users\Admin\.opencode\notepad.md` — user-home session memory mirror
5. Read `C:\Users\Admin\.omc\state\sessions\memory-checkpoint-latest.md` — OMC checkpoint
6. Read `Thesis_Surgical_Edit/pipeline_v12.py` — current pipeline script
7. Print status board and ask user: "Resume from last action?"

## BOOTSTRAP CHECKS
```
[BOOT] Notepad:      <project>/.opencode/notepad.md
[BOOT] Session JSON: <project>/.opencode/memory/session.json
[BOOT] Checkpoint:   C:\Users\Admin\.omc\state\sessions\memory-checkpoint-latest.md
[BOOT] Pipeline:     Thesis_Surgical_Edit/pipeline_v12.py
[BOOT] Python venv:  C:\Users\Admin\AppData\Local\Temp\thesis-venv\Scripts\python.exe
```

## GROUND TRUTH (Never Modify)
| Param | Value | Description |
|-------|-------|-------------|
| D | 33 | Annual demand (ART-002 Toner) |
| Q* (EOQ) | 15 | Wilson EOQ |
| ROP | 200 | Reorder Point = (D/250)*LT + SS |
| SS | 200 | Safety Stock (policy decision) |
| LT | 7 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 1,200 DZD | Unit Price |
| I | 20% | Holding Rate |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection password |
| VERSION | v13.4 | Current |

## PROJECT ASSETS
| Asset | Path |
|-------|------|
| Thesis source (MD) | `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` |
| Golden source (DOCX) | `Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx` |
| Pipeline output (DOCX) | `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx` |
| Pipeline script | `Thesis_Surgical_Edit/pipeline_v12.py` |
| Build scripts | `Thesis_Surgical_Edit/build-thesis.ps1`, `Thesis_Surgical_Edit/run-thesis-pipeline.ps1` |
| Verify script | `Thesis_Surgical_Edit/style/verify_docx_checks.py` |
| Fix scripts | `Thesis_Surgical_Edit/style/fix_thesis_all.py`, `fix_docx_sections.py`, `surgical_polish.py` |
| Word COM scripts | `Thesis_Surgical_Edit/style/update_fields.py`, `word_automation.py` |
| Persistence | `.opencode/memory/persist.ps1` — run with `-Action save` or `-Action load` |
| Session memory (project) | `.opencode/notepad.md` |
| Session memory (user home) | `C:\Users\Admin\.opencode\notepad.md` |
| OMC checkpoint | `C:\Users\Admin\.omc\state\sessions\memory-checkpoint-latest.md` |

## KEY PATHS (Windows)
- Project root: `C:\Users\Admin\Logistics.Public.Sector.Refactor`
- Python venv: `C:\Users\Admin\AppData\Local\Temp\thesis-venv\Scripts\python.exe` (has python-docx + pywin32)
- Golden source: `Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx`
- Output: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`

## PIPELINE CURRENT APPROACH (Refactored v12)
- **Fresh pandoc (NO --toc)**: Build DOCX from MD source with no TOC field (avoids duplicate SDT TOC)
- **fix_docx_sections.py**: Set A4, decimal page numbering, margins
- **fix_thesis_all.py**: RTL, footnote RTL, styles, footer, compat fixes
- **update_fields.py (Word COM)**: Update all document fields (headers, footers)
- **word_automation.py (Word COM)**: INSERT TOC/TOF fields via Selection.Find, then doc.Fields.Update() resolves hyperlinks + PAGEREFs
- **Post-COM polish**: Re-apply fix scripts (Word COM may shift styles)
- **verify_docx_checks.py**: 36 automated checks (expects 36/36 PASS)
- **No zipfile string manipulation**: Breaks Word COM
- **Job**: 36/36 PASS | Word COM opens clean | ~102 KB output

## ROOT CAUSE FINDINGS (Why earlier approaches failed)
1. `para.text = '...'` destroys `w:instrText` field codes on paragraphs with TOC/PAGEREF/field instructions
2. `python-docx save()` is actually SAFE — preserves all XML elements including instrText
3. Pandoc `--toc` creates SDT-wrapped TOC with English heading "Table of Contents" → Word COM's word_automation.py finds Arabic heading "فهرس المحتويات" in body and inserts SECOND TOC → duplicate TOCs
4. Golden source text replacement is fragile: sequential paragraph alignment shifts when cover/dedication spacer paragraphs differ in count
5. Word COM field update AFTER TOC insertion produces correct hyperlinks, PAGEREFs, bookmarks

## STATUS TEMPLATE
After bootstrap, print:
```
━━━ ACADEMIX v13.4 — RESUMED ━━━
Last verify: <from session.json>
Word COM:    <opens? />
Last action: <from notepad.md>
Next:        <from notepad.md or session.json>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
