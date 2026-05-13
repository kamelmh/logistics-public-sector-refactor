# Academix v13.2 — Reference Library

## Structure

```
refs/
  master-references.json    # Single source of truth — 56 bib entries with linked PDFs
  pdf-mapping.json          # Maps bib item numbers to semester PDF filenames
  Archive/                  # Old-named duplicate PDFs (COURS (1-15).pdf, etc.)
  Semester_1/               # 5 course PDFs + README + references.bib
  Semester_2/               # 6 course PDFs + README + references.bib
  Semester_3/               # 9 course PDFs + README + references.bib
  Semester_4/               # 12 course PDFs + README + references.bib
```

## Master Reference JSON (`master-references.json`)

56 entries extracted from `Memoire_DSS_Logistique_ElBayadh.md` bibliography section.
Each entry contains: number, key, type, authors, year, title, section, inline_cited flag, linked_pdf path.

| Section | Arabic | Entries | PDFs |
|---------|--------|---------|------|
| academic_books | الكتب والمراجع العلمية | 1-10 | 0 |
| legal_framework | الإطار القانوني والتنظيمي الجزائري | 11-16 | 0 |
| bts_curriculum | المنهاج الدراسي BTS GSL (TAG1801) | 17-47 | 30 |
| technical_refs | المراجع التقنية | 48-49 | 0 |
| parallel_theses | مشاريع وأطروحات موازية | 50-53 | 0 |
| field_data | مصادر البيانات الميدانية | 54-55 | 0 |
| software_ref | المراجع البرمجية | 56 | 0 |

**Total**: 56 entries, 7 inline-cited, 30 linked to PDFs.

## PDF Mapping (`pdf-mapping.json`)

Links bib item numbers (17-47) to their corresponding PDFs in `Semester_1-4/`.

## Build Tool

`tools/build-master-refs.py` regenerates both JSON files from the thesis `.md`.

Usage: `python tools/build-master-refs.py`

## Semester References

Each semester folder contains course PDFs + a `references.bib` file (deprecated — use `master-references.json` instead) + a README index.

## Archive

`Archive/` contains old-named duplicate PDFs (COURS (1-15).pdf and semester-compiled PDFs) moved from `Archive/Old_Naming/`. These are redundant with the semester-organized PDFs.

The 20 `Old_Naming/` PDFs are now in `Archive/` (fallout from Phase 1 refactoring).
