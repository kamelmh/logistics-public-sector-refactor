# Thesis-to-DOCX — Markdown → Formatted Thesis Document Pipeline

## Purpose
Convert a markdown thesis/academic document to professionally formatted DOCX and PDF,
with RTL/Arabic support, styled tables, and cover page formatting.

## Pattern Source
Academix v13.2 `Thesis_Surgical_Edit/` pipeline. Generalized for any academic project.

## Pipeline

```
Source .md (Arabic/French/English)
        │
        ▼
1. Customize reference template (styles: heading, body, table)
2. Pandoc MD → DOCX conversion (with reference-docx)
3. Format tables (header color, alternating rows, fonts)
4. Format cover page (title, subtitle, author, colors)
5. Export to PDF via Word COM
6. Verify output (file size, page count)
```

## Project Structure Convention
```
thesis-project/
├── build-thesis.ps1            ← Full pipeline script
├── Final_Thesis.md              ← Source document (markdown)
├── style/
│   ├── customize-reference.py   ← Style copier from template
│   ├── format-tables.py         ← Table styling (header, rows, fonts)
│   ├── format-cover.py          ← Cover page formatting
│   └── thesis-metadata.yaml     ← Pandoc YAML metadata
├── images/                      ← Embedded images
└── output/                      ← Generated DOCX + PDF
```

## Pandoc Command
```powershell
pandoc "$sourceMd" `
  --reference-doc="$referenceDocx" `
  --metadata-file="style/thesis-metadata.yaml" `
  --from markdown+grid_tables+raw_tex `
  --to docx `
  --lua-filter="style/arabic-fix.lua" `  # if RTL
  -o "$outputDocx"
```

## Key Formatting Patterns

### Table Formatting (Python)
```python
# Header row: #0C447C background, white bold text
for cell in table.rows[0].cells:
    cell._tc.get_or_add_tcPr()
    shading = OxmlElement('w:shd')
    shading.set(qn('w:fill'), '0C447C')
    cell._tc.tcPr.append(shading)
    for p in cell.paragraphs:
        for r in p.runs:
            r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

# Alternating rows: #EBF5FB / white
for i, row in enumerate(table.rows[1:], 1):
    if i % 2 == 0:
        # apply #EBF5FB shading
```

### Cover Page Formatting
```python
# Title: #1A1A1A, 22pt, center
# Subtitle: #555555, 14pt, center
# EN title: #1F6B2E, 12pt, center
# Date: #806000, 10pt, center
```

## Verification
- File size check (DOCX: 100KB+, PDF: 500KB+)
- Table count check
- Image embed check
- Page count (PDF via COM)

## Usage
```powershell
.\build-thesis.ps1
.\build-thesis.ps1 -SourceMD "My_Chapter.md" -OutputName "Custom_Name"
```
