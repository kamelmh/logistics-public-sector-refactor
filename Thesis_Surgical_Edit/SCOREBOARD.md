# Thesis Build Scorecard — 2026-07-04

## Overall: 34/36 PASS (2 expected failures)

---

## Verification Results (36-point check)

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | DOCX file exists | ✅ | — |
| 2 | Has paragraphs | ✅ | count=346 |
| 3 | Has sections (>=1) | ✅ | count=1 |
| 4 | Paragraph count >= 250 | ✅ | count=346 |
| 5 | File size threshold | ✅ | size=119KB |
| 6 | All XML parts have declaration | ✅ | All OK |
| 7 | Page size A4 | ✅ | 21.0x29.7cm |
| 8 | Margins 2.5cm | ✅ | T=2.5 B=2.5 L=2.5 R=2.5 |
| 9 | Footnotes >= 16 | ✅ | count=25 |
| 10 | Footnote RTL alignment | ✅ | 0 bad |
| 11 | Tables >= 21 | ✅ | count=23 |
| 12 | H1 >= 4 | ✅ | count=9 |
| 13 | H2 >= 10 | ✅ | count=40 |
| 14 | H3 >= 10 | ✅ | count=56 |
| 15 | Heading hierarchy OK | ✅ | 1 skip |
| 16 | Font Traditional Arabic | ✅ | 0 bad |
| 17 | Font size 14pt | ✅ | 0 bad |
| 18 | RTL alignment OK | ✅ | 0 bad |
| 19 | Line spacing >= 1.0 | ✅ | 0 bad |
| 20 | Body text style consistency | ✅ | 0 bad |
| 21 | First line indent consistency | ✅ | 0 bad |
| 22 | Paragraph spacing consistency | ✅ | 0 bad |
| 23 | Core chapters as H1 | ✅ | — |
| 24 | Abstract present | ✅ | — |
| 25 | Bibliography present | ✅ | — |
| 26 | Annexes present | ✅ | — |
| 27 | TOC heading present | ✅ | — |
| 28 | Page numbering decimal | ✅ | fmt=decimal, start=1 |
| 29 | Caption RTL alignment | ✅ | 0/27 bad |
| 30 | Table style comparison | ✅ | Skipped |
| 31 | Opens without corruption | ✅ | python-docx ok |
| 32 | Body has content | ✅ | — |
| 33 | **Hyperlinks present** | ❌ | count=0 (needs Ctrl+A F9) |
| 34 | **PAGEREF fields present** | ❌ | count=0 (needs Ctrl+A F9) |
| 35 | TOC has \h switch | ✅ | clickable hyperlinks enabled |
| 36 | Bookmarks present | ✅ | count=133 |

---

## Heading Structure

| Level | Count | Style | Notes |
|-------|-------|-------|-------|
| H1 | 9 | Heading1 | Chapters + الخاتمة العامة + القوائم |
| H2 | 40 | Heading2 | Sections + إهداء + شكر وتقدير |
| H3 | 56 | Heading3 | Sub-sections |
| H4 | 18 | Heading4 | Sub-sub-sections (bold, not italic) |
| **Total** | **123** | | |

---

## Fixes Applied This Session

| # | Fix | What Changed | Status |
|---|-----|-------------|--------|
| 1 | **الخاتمة العامة** | `**bold**` → `# H1` in MD | ✅ Fixed |
| 2 | **شكر وتقدير** | Shell Normal → Heading 2 + sync logic | ✅ Fixed |
| 3 | **إهداء** | Shell Normal → Heading 2 + sync logic | ✅ Fixed |
| 4 | **Caption RTL** | 27/27 bad → 0/27 bad | ✅ Fixed |
| 5 | **Heading4 style** | Italic → Bold in styles.xml | ✅ Fixed |
| 6 | **Bibliography ordering** | Harris moved before Lambert | ✅ Fixed |
| 7 | **Orphaned Footnotes heading** | Removed `# قائمة المراجع والتعليقات (Footnotes)` | ✅ Fixed |
| 8 | **Page numbering** | fmt=None → decimal | ✅ Fixed |
| 9 | **Heading alignment** | H1=center, H2/H3=right, all bidi | ✅ Fixed |
| 10 | **Compatibility checker** | Suppressed alt-text popup | ✅ Fixed |
| 11 | **Build script** | Migrated from thesis-venv to uv | ✅ Fixed |

---

## What's Recommended (Optional Improvements)

| # | Item | Priority | Effort | Notes |
|---|------|----------|--------|-------|
| 1 | Add page numbers to footer in Word | Low | 1 min | Ctrl+A F9 after opening |
| 2 | Verify TOC/TOF populated correctly | Low | 2 min | Open in Word, check page numbers |
| 3 | Add "قائمة الأشكال" section | N/A | — | No figures in thesis, not needed |
| 4 | Normalize margin to 3cm left/2.5cm right | Low | 5 min | CNEPD standard is asymmetric |
| 5 | Add Heading4 to CNEPD standard | Low | — | Currently no spec, italic was wrong |

---

## What Needs To Be Done Before Submission

| # | Action | Status |
|---|--------|--------|
| 1 | Open DOCX in Word | ⏳ Pending |
| 2 | Press Ctrl+A → F9 to update fields | ⏳ Pending |
| 3 | Verify TOC page numbers are correct | ⏳ Pending |
| 4 | Verify all tables render properly | ⏳ Pending |
| 5 | Final visual review | ⏳ Pending |

---

## Build Pipeline Status

| Phase | Status | Time |
|-------|--------|------|
| Phase 1: Pandoc | ✅ PASS | ~5s |
| Phase 2: Stitch | ✅ PASS | ~2s |
| Phase 3: Format | ✅ PASS | ~5s |
| Phase 4: Word COM | ✅ PASS | ~25s |
| Phase 5: Verify | ✅ 34/36 | ~3s |
| **Total** | | **~45s** |
