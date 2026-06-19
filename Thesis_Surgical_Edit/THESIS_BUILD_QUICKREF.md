# Thesis Build — Quick Reference

## One-Command Build
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1"
```

## Full Pipeline (what build-thesis.ps1 does)
```
1. Copy desktop golden (v2) → output DOCX
2. fix_docx_sections.py — insert section breaks
3. surgical_polish.py — RTL footnotes, remove GitHub links, scrub CNEPD compliance proof
4. fix_thesis_all.py — 8 fixes (steps 9-10 SKIPPED)
5. verify_docx_checks.py — 32 checks
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
| Paragraphs | ~705 |
| Tables | 25 |
| Footnotes | 46 |
| Sections | 1 |
| Verify | 32/32 PASS |
| Audit | PASSED |
| PDF | ~1,380 KB |

## Page Numbering Scheme
- Single section with continuous decimal numbering starting at 1 (continuous from cover, with cover page number hidden).

## Surgical Polish Tool (`surgical_polish.py`)
This tool is executed automatically during the build process to apply precise, academic-grade refinements to the generated DOCX:
- **Footnote RTL Alignment**: Programmatically forces Right-to-Left (RTL) alignment and bidi support on all footnotes, ensuring Arabic text is correctly formatted.
- **GitHub Link Removal**: Automatically strips references to the GitHub repository to keep the thesis focused strictly on academic content.
- **CNEPD Compliance Scrubbing**: Removes sections and tables that explicitly attempt to "prove" compliance with CNEPD standards (e.g., "التوثيق الذكي المتقاطع", "التوافق مع معايير تقييم لجنة CNEPD"), ensuring a professional, objective tone.

## DO NOT
1. Remove cached text from PAGE fields
2. Overwrite section 0's footer refs
3. Use raw PAGE fields without SDT wrapper
4. Use Roman numerals
