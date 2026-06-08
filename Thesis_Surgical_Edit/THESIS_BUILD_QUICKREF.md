# Thesis Build — Quick Reference

## One-Command Build
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1"
```

## Full Pipeline (what build-thesis.ps1 does)
```
1. Copy desktop golden (v2) → output DOCX
2. fix_docx_sections.py — insert section breaks
3. fix_thesis_all.py — 8 fixes (steps 9-10 SKIPPED)
4. fix_thesis_pagenum.py — SDT-wrapped PAGE field
5. verify_docx_checks.py — 29 checks
6. audit_thesis_comprehensive.py — 10 categories
```

## After Build — PDF Generation
```powershell
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open("Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx")
$doc.SaveAs([ref]"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.pdf", [ref]17)
$doc.Close()
$word.Quit()
```

## Quick Verify
```powershell
python "Thesis_Surgical_Edit\style\verify_docx_checks.py" "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
```

## Quick Audit
```powershell
python "Thesis_Surgical_Edit\style\audit_thesis_comprehensive.py" "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
```

## Fix Page Numbering Only
```powershell
python "Thesis_Surgical_Edit\style\fix_thesis_pagenum.py" "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx" --save
```

## Expected Results
| Check | Value |
|-------|-------|
| Paragraphs | 702 |
| Tables | 26 |
| Footnotes | 46 |
| Sections | 4 |
| Verify | 29/29 PASS |
| Audit | PASSED |
| PDF | ~1,380 KB |

## Page Numbering Scheme
- Section 0 (cover): none
- Section 1 (TOC): decimal, start=4
- Section 2 (body): decimal, continue
- Section 3 (annexes): decimal, continue

## DO NOT
1. Remove cached text from PAGE fields
2. Overwrite section 0's footer refs
3. Use raw PAGE fields without SDT wrapper
4. Use Roman numerals
