# Python DOCX Tools Skill — Academix v13.2

## Purpose
Python toolchain for DOCX generation, analysis, style fixing, and formatting of the thesis document.

## Tool Inventory

### Tools in `Thesis_Surgical_Edit/style/`

| Tool | File | Description |
|------|------|-------------|
| **docx-analyze.py** | `style/docx-analyze.py` | Deep audit: style inventory, heading detection, table summary, page setup, issues report |
| **docx-style-fix.py** | `style/docx-style-fix.py` | Fixes styles: unhides headings, sets Traditional Arabic font, RIGHT alignment, proper sizes/colors, 1.5 line spacing |
| **docx-style-apply.py** | `style/docx-style-apply.py` | Maps paragraphs to Heading 1/2/3 based on Arabic content patterns |
| **docx-master-build.py** | `style/docx-master-build.py` | One-command orchestrator: chains style-fix → style-apply → format-tables → format-cover |
| **format-tables.py** | `style/format-tables.py` | Post-processes tables: #0C447C header fill, white bold text, #EBF5FB alternating rows |
| **format-cover.py** | `style/format-cover.py` | Cover page styling: Arabic titles, English title, date, section headings |
| **customize-reference.py** | `style/customize-reference.py` | Builds pandoc reference.docx from user's original DOCX styles |
| **compare-styles.py** | `style/compare-styles.py` | Style diff between two DOCX files |

### Supporting Files
| File | Purpose |
|------|---------|
| `style/reference.docx` | Pandoc reference template (generated) |
| `style/reference-in.docx` | Pandoc default reference template |
| `style/thesis-metadata.yaml` | Pandoc metadata (title, author, date, lang) |
| `style/style-comparison.txt` | Last style comparison output |
| `output/` | Build output directory |

## Pipeline Flow
```
Source MD → pandoc → style-fix → style-apply → format-tables → format-cover → [Word COM → PDF]
```

## Dependencies
```
python-docx   1.2.0    DOCX read/write
PyMuPDF       1.27.2   PDF manipulation  
weasyprint    68.1     HTML/CSS → PDF
matplotlib    3.10.9   Charts/graphs
seaborn       0.13.2   Statistical charts
docxtpl       0.20.2   Jinja2 DOCX templates
reportlab     4.5.0    Professional PDF
fpdf2         2.8.7    Lightweight PDF
cairosvg      2.9.0    SVG rendering
Pillow        12.1.1   Image processing
numpy         2.4.3    Numerical computing
openpyxl      3.1.5    Excel
jinja2        3.1.6    Templating
```

## Usage

### Analyze a DOCX
```powershell
python style\docx-analyze.py "Memoire_Academix_v13_2_Final_Master_Generation.docx"
python style\docx-analyze.py "file.docx" --json
```

### Fix styles on existing DOCX
```powershell
python style\docx-master-build.py --from-docx "file.docx"
```

### Full build from markdown
```powershell
python style\docx-master-build.py --source Memoire_DSS_Logistique_ElBayadh.md
python style\docx-master-build.py --source thesis.md --output MyThesis --no-pdf
```

### Individual tools
```powershell
python style\docx-style-fix.py "file.docx"
python style\docx-style-apply.py "file.docx"
python style\format-tables.py "file.docx"
python style\format-cover.py "file.docx"
```

## Style Specification (Post-Fix State)
| Style | Font | Size | Color | Align |
|-------|------|------|-------|-------|
| Normal | Traditional Arabic | 14pt | — | RIGHT |
| Heading 1 | Traditional Arabic | 22pt | #1B2631 | RIGHT |
| Heading 2 | Traditional Arabic | 18pt | #0C447C | RIGHT |
| Heading 3 | Traditional Arabic | 16pt | #0C447C | RIGHT |
| Title | Traditional Arabic | 28pt | — | CENTER |

## Common Issues
- **Heading 2-6 hidden**: Run `docx-style-fix.py` to unhide
- **Wrong heading style**: Run `docx-style-apply.py` to auto-detect and apply
- **Font not set**: `docx-style-fix.py` sets Traditional Arabic via docDefaults and per-style
