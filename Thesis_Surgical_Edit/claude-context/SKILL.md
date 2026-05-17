---
name: algerian-thesis
description: >
  Format, audit, and structure academic theses following Algerian CFPA / Technicien Supérieur
  standards. Use this skill whenever the user mentions 'thesis', 'مذكرة', 'soutenance', 'defense',
  'mémoire', uploads a .docx thesis file, or asks for Algerian academic formatting rules.
  Apply this skill even when the user only asks about one section (e.g., cover page, table of
  contents, bibliography) — always treat the request in the context of the full thesis standard.
  Handles bilingual AR + FR theses. Produces reformatted .docx and/or PDF output, or a blank
  compliant template.
---

# Algerian Thesis Skill — Technicien Supérieur (CFPA / Formation Professionnelle)

## Scope

This skill applies to **Technicien Supérieur** مذكرات produced within the Algerian
**formation professionnelle** system (CFPA, INSFP, and equivalent institutes).
It handles **bilingual Arabic + French** theses and enforces the structural and formatting
standards expected at سoutenance.

---

## Mandatory Section Order

Enforce this exact sequence. Each section must begin on a new page.

| # | Section (FR) | Section (AR) | Notes |
|---|---|---|---|
| 1 | Page de garde | صفحة الغلاف | See cover page spec below |
| 2 | Remerciements | شكر وعرفان | Optional but conventional |
| 3 | Résumé (AR + FR) | ملخص | Both languages on same or facing pages |
| 4 | Table des matières | فهرس المحتويات | Auto-generated preferred |
| 5 | Liste des tableaux | قائمة الجداول | Numbered Table 01, 02… |
| 6 | Liste des figures | قائمة الأشكال | Numbered Figure 01, 02… |
| 7 | Introduction générale | المقدمة العامة | |
| 8 | Chapitre(s) | الفصول | Each chapter: new page, title page |
| 9 | Conclusion générale | الخاتمة العامة | |
| 10 | Bibliographie / Références | المراجع | See citation format below |
| 11 | Annexes | الملاحق | Labeled Annexe A, B… / ملحق أ، ب… |

**Sections NOT required by this standard:**
- Dédicace (إهداء) — omit unless user explicitly requests it
- Glossaire — optional, insert after Liste des figures if present

---

## Page de Garde — Cover Page Spec

The cover page must contain, top to bottom:

1. **Republic header** — الجمهورية الجزائرية الديمقراطية الشعبية (centered, AR, bold)
2. **Ministry line** — وزارة التكوين والتعليم المهنيين (centered, AR)
3. **Institute name** — full name of the CFPA/INSFP (FR + AR)
4. **Specialty** — Spécialité / التخصص
5. **Document type** — مذكرة تخرج لنيل شهادة تقني سامي / Mémoire de fin de formation pour l'obtention du diplôme de Technicien Supérieur
6. **Theme / Title** — centered, large, bold (both languages if bilingual)
7. **Presented by** — Présenté par / من إعداد الطالب(ة): [Name]
8. **Supervisor** — Encadré par / تحت إشراف: [Name + Title]
9. **Academic year** — السنة الدراسية / Année de formation: XXXX–XXXX
10. **Institute logo** — top center if available

---

## Formatting Rules

### Page Setup
- **Paper:** A4
- **Margins:** Left 3 cm · Right 2.5 cm · Top 3 cm · Bottom 2.5 cm
  *(For Arabic RTL sections: mirror — Right 3 cm · Left 2.5 cm)*
- **Binding side always gets the 3 cm margin**

### Typography

| Context | Font | Size | Style |
|---|---|---|---|
| French body text | Times New Roman | 12 pt | Regular |
| Arabic body text | Traditional Arabic | 14 pt | Regular |
| Chapter titles (H1) | Times New Roman / Traditional Arabic | 16 pt | Bold |
| Section titles (H2) | Times New Roman / Traditional Arabic | 14 pt | Bold |
| Sub-section titles (H3) | Times New Roman / Traditional Arabic | 12 pt | Bold Italic |
| Captions (tables/figures) | Times New Roman / Traditional Arabic | 11 pt | Italic |
| Page numbers | Times New Roman | 10 pt | Regular |
| Cover page title | Times New Roman / Traditional Arabic | 18 pt | Bold |

### Spacing
- **Line spacing:** 1.5 throughout body text
- **Paragraph spacing:** 6 pt after each paragraph
- **No extra blank lines** between paragraphs (use spacing, not Enter)
- **Chapter title page:** title vertically centered or placed at 1/3 from top

### Heading Hierarchy
Apply Word Styles consistently:

```
Heading 1 → Chapter title       (H1: 16pt Bold, centered, new page)
Heading 2 → Section / مبحث     (H2: 14pt Bold, left/right aligned)
Heading 3 → Sub-section / مطلب (H3: 12pt Bold Italic)
Normal     → Body text
Caption    → Table/Figure labels
```

### Page Numbering
- **Front matter** (Remerciements → Liste des figures): Roman numerals (i, ii, iii…)
- **Body** (Introduction → Annexes): Arabic numerals (1, 2, 3…)
- Position: bottom center
- Cover page: no page number printed (but counted)

---

## Tables and Figures

### Numbering Convention
Use chapter-based numbering:
- **Tables:** Tableau 01, Tableau 02… *per chapter* → e.g., Tableau 03-01 (Ch3, Table 1)
  - Arabic: جدول 01، جدول 02…
- **Figures:** Figure 01, Figure 02… same convention

### Caption Placement
- **Tables:** Caption ABOVE the table
- **Figures:** Caption BELOW the figure
- Caption format: `Tableau XX : [Title]` / `جدول XX : [العنوان]`

### Liste des tableaux / figures
Auto-populate from captions. Format:
```
Tableau 01 : Titre du tableau ........... page X
```

---

## Bibliography / المراجع

Use **APA 7th edition** adapted for Algerian academic context.

### Book
```
Nom, P. (Année). Titre de l'ouvrage. Éditeur.
```

### Article
```
Nom, P. (Année). Titre de l'article. Nom de la revue, Volume(Numéro), pages.
```

### Arabic source
```
الاسم، الاسم. (السنة). عنوان الكتاب. دار النشر.
```

**Rules:**
- List French sources first, then Arabic sources (or separate sections)
- Alphabetical order within each language group
- No numbering — use hanging indent
- All sources cited in text must appear in bibliography and vice versa

---

## Chapter Structure Template

Each chapter follows this internal structure:

```
[New Page]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        الفصل الأول / Chapitre I
     [Chapter Title — AR + FR]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[New Page]
تمهيد / Introduction du chapitre   (½ page max)

مبحث أول / Section 1 (H2)
  مطلب أول / 1.1 (H3)
  مطلب ثاني / 1.2 (H3)

مبحث ثاني / Section 2 (H2)
  ...

خلاصة الفصل / Conclusion du chapitre  (½ page max)
[New Page → next chapter]
```

---

## Workflow: Reformatting an Existing Thesis

When the user uploads a .docx thesis file, follow these steps:

### Step 1 — Audit
Read the SKILL.md (docx skill) first. Then open the file and check:
- [ ] Section order matches mandatory sequence
- [ ] All mandatory sections present
- [ ] Heading styles applied (not just bold text)
- [ ] Fonts and sizes correct per language
- [ ] Margins set correctly
- [ ] Page numbering scheme correct
- [ ] Table/figure captions present and correctly placed
- [ ] Bibliography exists and follows APA format

Report findings as a numbered audit list with ✅ / ⚠️ / ❌ per item.

### Step 2 — Plan
Present a fix plan to the user before making changes. List what will be changed.

### Step 3 — Reformat
Read `/mnt/skills/public/docx/SKILL.md` before writing any Python/docx code.
Apply fixes programmatically using `python-docx`. Key operations:
- Set page margins via `sections[0].left_margin` etc. (in Emu: 1 cm = 360000 Emu)
- Apply paragraph styles via `paragraph.style`
- Set font per run: `run.font.name`, `run.font.size`
- Set line spacing: `paragraph.paragraph_format.line_spacing`
- Insert page breaks: `paragraph.add_run().add_break(WD_BREAK.PAGE)`
- Set RTL for Arabic paragraphs via `pPr` XML manipulation

### Step 4 — Output
- Save reformatted `.docx` to `/mnt/user-data/outputs/`
- If PDF requested: convert via LibreOffice headless
  ```bash
  libreoffice --headless --convert-to pdf file.docx --outdir /mnt/user-data/outputs/
  ```
- Present both files to user with `present_files`

---

## Workflow: Generate a Blank Template

When the user asks for a blank thesis template:

1. Read `/mnt/skills/public/docx/SKILL.md`
2. Build a `.docx` with all mandatory sections as placeholder pages
3. Apply all formatting rules from this skill
4. Include sample heading hierarchy (H1/H2/H3 with placeholder text)
5. Include sample table with caption above, sample figure caption below
6. Include blank bibliography section with format examples commented in
7. Output to `/mnt/user-data/outputs/these_template_TS_[date].docx`

---

## Common Errors to Watch For

| Error | Fix |
|---|---|
| Bold text used instead of Heading styles | Replace with proper Word Styles |
| Arabic text set to Times New Roman | Switch to Traditional Arabic 14pt |
| Single spacing throughout | Set 1.5 line spacing on all body paragraphs |
| No section breaks between chapters | Insert page break / section break |
| Table captions below table | Move above |
| Figure captions above figure | Move below |
| Mixed numbering (1.1 vs Tableau 01) | Standardize to chapter-prefixed format |
| Bibliography missing from front matter lists | Verify it is NOT in ToC (it should be) |
| Roman numerals missing on front matter | Apply separate section with different numbering |

---

## Reference Files

- `references/cover-page-example.md` — annotated cover page layout
- `references/heading-styles.md` — exact Word style definitions to apply programmatically

*Load these only when building template or doing deep formatting work.*
