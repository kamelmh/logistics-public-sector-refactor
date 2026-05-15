# Thesis Format Guide — Academix v13.2

## Page Setup
- **Size**: A4 (210mm × 297mm)
- **Margins**: 4cm top, bottom, left, right
- **Direction**: RTL (Right-to-Left)
- **Line spacing**: 1.5

## Fonts
| Element | Font | Size | Color | Weight |
|---------|------|------|-------|--------|
| Body | Traditional Arabic | 14pt | #000000 | Normal |
| H1 (Chapter) | Traditional Arabic | 22pt | #1B2631 | Bold |
| H2 (مبحث) | Traditional Arabic | 18pt | #0C447C | Bold |
| H3 (مطلب) | Traditional Arabic | 16pt | #0C447C | Bold |
| English title (cover) | Times New Roman | 12pt | #1F6B2E | Bold |

## Cover Page Formatting
The file `cover-page.docx` is the USER'S CUSTOM DESIGN — treat as immutable template.

### Cover elements (do NOT modify):
1. **الجمهورية الجزائرية الديمقراطية الشعبية** — Bold, near-black, centered
2. **وزارة التكوين والتعليم المهنيين** + institute + location — Centered
3. **مذكرة تخرج** — Bold, 18pt, centered
4. **لنيل شهادة تقني سامي في تسيير المخزونات واللوجستيك** — 12pt
5. **بناء نظام دعم قرار لإتمام دورة الشراء والتخزين** — Bold, 16pt, centered
6. **دراسة حالة: مديرية التربية – البيض -** — Bold, 18pt, gray
7. **English title** — Times New Roman, 12pt, #1F6B2E green, centered
8. **إعداد الطالب / إشراف الأستاذة** — Bold, 12pt, left-aligned with tab separation
9. **دورة أكتوبر 2025** — Bold, 16pt, #806000 gold

### Cover integration for DOCX output:
```
Method: Clone → Insert
1. python-docx: load cover-page.docx
2. Insert thesis body content after last cover paragraph
3. Preserve ALL original cover formatting
4. Apply body formatting per table above
5. Save as new file
```

## Table Formatting
| Property | Value |
|----------|-------|
| Header fill | #0C447C |
| Header text | White (#FFFFFF), Bold |
| Body alternating rows | #EBF5FB |
| Body font | Traditional Arabic |
| Border | Thin, #0C447C |

## Colors Palette
```
Primary:    #0C447C (dark blue — headings, table headers)
Dark:       #1B2631 (near-black — chapter titles)
Green:      #1F6B2E (English title on cover)
Gold:       #806000 (date)
Gray:       #555555 (subtitle)
Accent bg:  #EBF5FB (alternating table rows)
```

## Page Numbering (CNEPD Standard)
- **Pre-chapters** (cover → إهداء → شكر → ملخص/Abstract/Résumé → قائمة المحتويات → قائمة الجداول → قائمة المصطلحات → قائمة الاختصارات): أ، ب، ج، د، هـ، و، ز، ح، ط (Arabic Abjad letters)
- **Main body** (الفصل الأول through الملاحق): 1, 2, 3, ... (Arabic numerals)
- **Implementation**: Insert section break between pre-chapters and الفصل الأول, set different page number formats per section in Word/python-docx

## Footnotes
- Format: `[^n]: Full citation per CNEPD standard`
- Arabic books: Full name, **Title**, Publisher, Year, p.X.
- French books: Prénom Nom, *Title*, Éditeur, Year, p.X.
- Immediate repeat: المرجع نفسه، ص.XX.
- Later repeat: اسم المؤلف، المرجع السابق، ص.XX.

## 7. Linguistic & Academic Tone
- **Sovereign Register:** Use Traditional Academic Arabic. Avoid any "translated" phrasing.
- **The Surgical Bracketing Rule:** Use technical terms in brackets ONLY on their first occurrence in a section to establish the academic anchor.
- **The Flow Rule:** All subsequent mentions must use the Arabic term alone.
- **Visual Clarity:** Eliminate redundant technical terms to ensure the prose flows naturally and professionally.
