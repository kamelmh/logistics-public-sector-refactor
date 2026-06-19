# Thesis Build — Quick Reference

## One-Command Build
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1"
```

## Full Pipeline (what build-thesis.ps1 does)
```
1. Copy golden desktop DOCX (v7c_FIXED) → output DOCX
2. fix_docx_sections.py — insert section breaks
3. surgical_polish.py — RTL footnotes, link removal, CNEPD scrubbing
4. fix_thesis_all.py — 8 fixes (steps 9-10 SKIPPED)
5. verify_docx_checks.py — 32 checks
6. audit_thesis_comprehensive.py — 10 categories
```

## Advanced Commands
### No Rebuild (Use Golden Source directly)
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1" -NoRebuild
```

### Restore Golden Source from latest backup
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1" -Restore
```

### Rebuild from Markdown
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1" -FromMD
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
| Paragraphs | ~705 |
| Tables | 25 |
| Footnotes | 46 |
| Sections | 1 |
| Verify | 32/32 PASS |
| Audit | PASSED |
| PDF | ~1,380 KB |

## Page Numbering Scheme
- Single section with continuous decimal numbering starting at 1 (continuous from cover, with cover page number hidden).

## DO NOT
1. Remove cached text from PAGE fields
2. Overwrite section 0's footer refs
3. Use raw PAGE fields without SDT wrapper
4. Use Roman numerals
