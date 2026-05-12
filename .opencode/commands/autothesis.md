---
description: Build thesis PDF + verify output
agent: build
---

Build pipeline + verify:
```
pwsh -NoProfile -ExecutionPolicy Bypass -File Thesis_Surgical_Edit/build-thesis.ps1
```
Auto-runs verify-thesis.ps1 as step 7 — deep structural check, old-vs-new comparison.

Quick verify only (no rebuild):
```
pwsh -NoProfile -ExecutionPolicy Bypass -File Thesis_Surgical_Edit/verify-thesis.ps1
```

Pipeline scripts in `Thesis_Surgical_Edit/style/`:
- `add-toc.py` — TOC + LOT field codes + SEQ captions
- `customize-reference.py` — reference DOCX styling
- `format-baseline.py` — fonts, margins, headings, alignment
- `format-tables.py` — #0C447C headers, #EBF5FB rows
- `add-page-numbers.py` — Abjad pre-chapters, Arabic body
- `prepend-cover.py` — cover-page.docx insertion
- `fix-fonts.py` — style-inherited font sizes
- `footnotes.py` — inline citation → footnote conversion
