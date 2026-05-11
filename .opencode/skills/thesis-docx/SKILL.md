# Thesis DOCX Skill — Academix v13.2

## Purpose
Manage the thesis DOCX document: styles, heading structure, formatting, and build pipeline. Covers the master generation DOCX, cover page, and all post-processing.

## Document Architecture

### Key Files
| File | Path | Purpose |
|------|------|---------|
| Master DOCX | `Thesis_Surgical_Edit\Memoire_Academix_v13_2_Final_Master_Generation.docx` | Primary editable DOCX (168 KB, 305 paragraphs, 15 tables) |
| Cover page | `Thesis_Surgical_Edit\cover-page.docx` | Standalone cover (64 KB) |
| Source markdown | `Thesis_Surgical_Edit\Final_Thesis_Academix_v13_2_FIXED.md` | Pandoc source (142 KB) |
| Build script | `Thesis_Surgical_Edit\build-thesis.ps1` | Legacy pipeline |
| Style tools | `Thesis_Surgical_Edit\style\*.py` | Python post-processing tools |

### Style Specification
| Style | Font | Size | Color | Align | Bold |
|-------|------|------|-------|-------|------|
| docDefaults | Traditional Arabic | 14pt | — | RIGHT | — |
| Normal | Traditional Arabic | 14pt | — | RIGHT | — |
| Heading 1 | Traditional Arabic | 22pt | #1B2631 | RIGHT | Yes |
| Heading 2 | Traditional Arabic | 18pt | #0C447C | RIGHT | Yes |
| Heading 3 | Traditional Arabic | 16pt | #0C447C | RIGHT | Yes |
| Heading 4 | Traditional Arabic | 14pt | #0C447C | RIGHT | Yes |
| Title | Traditional Arabic | 28pt | #1A1A1A | CENTER | Yes |
| Header/Footer | Traditional Arabic | 10pt | — | CENTER | — |
| Table header | — | — | #0C447C fill, white text | — | Bold |
| Table body | Traditional Arabic | 11pt | #EBF5FB alternating | RIGHT | — |
| Cover title (AR) | Traditional Arabic | 18pt | #1A1A1A | CENTER | Bold |
| Cover English title | Times New Roman | 12pt | #1F6B2E | CENTER | Bold |
| Cover date | Traditional Arabic | 16pt | #806000 | CENTER | Bold |

### Line Spacing: 1.5 (360 twips)

## Document Structure (305 paragraphs)
| Section | Heading 1 | Heading 2 | Heading 3 | Normal |
|---------|-----------|-----------|-----------|--------|
| Front matter (dedication, thanks, abstracts, TOC) | 6 | 0 | 0 | body |
| Introduction (السياق العام — هيكل المذكرة) | 0 | 0 | 6 | body |
| Chapter 1 (الفصل الأول — theoretical) | 1 | 0 | 15 | body |
| Chapter 2 (الفصل الثاني — field diagnosis) | 1 | 0 | 9 | body |
| Chapter 3 (الفصل الثالث — system design) | 1 | 4 | 15 | body |
| Chapter 4 (الفصل الرابع — implementation) | 1 | 3 | 10 | body |
| Conclusion (الخاتمة) | 1 | 0 | 0 | body |

Total: 10 H1, 7 H2, 55 H3, 233 Normal + 15 tables

## Color Palette
| Use | Hex | Description |
|-----|-----|-------------|
| Cover title | #1A1A1A | Near-black |
| Cover English | #1F6B2E | Green |
| Cover date | #806000 | Gold |
| Cover subtitle | #555555 | Gray |
| Heading 1 | #1B2631 | Dark slate |
| Heading 2/3 | #0C447C | Dark blue |
| Table header fill | #0C447C | Dark blue |
| Table header text | #FFFFFF | White |
| Table alt row | #EBF5FB | Light blue |

## Heading Detection Patterns
Arabic headings detected by regex:
- `الفصل (الأول|الثاني|...)` → Heading 1
- `المبحث (الأول|الثاني|...)` → Heading 2
- `المطلب (الأول|الثاني|...)` → Heading 3
- `الفرع (الأول|الثاني|...)` → Heading 3
- `المقدمة`, `الخاتمة`, `الإهداء`, `شكر وتقدير`, `ملخص`, `Résumé`, `Abstract`, `قائمة الجداول` → Heading 1
- `N.N`, `N.N.N` numbered sections → Heading 3
- `N.` single-numbered items → Heading 3
- `أولاً:`, `ثانياً:` → Heading 3

## Commands
```powershell
# Full build from markdown
python style\docx-master-build.py --source Final_Thesis_Academix_v13_2_FIXED.md

# Fix existing DOCX (style-fix + style-apply)
python style\docx-master-build.py --from-docx "Memoire_Academix_v13_2_Final_Master_Generation.docx"

# Analyze only
python style\docx-analyze.py "Memoire_Academix_v13_2_Final_Master_Generation.docx"

# Build from old pipeline
& ".\build-thesis.ps1"
```
