"""docx-style-apply.py -- Academix v13.2
Map paragraphs to proper heading styles based on content analysis.
Detects chapter/section/subsection markers and assigns Heading 1/2/3.
Usage: python docx-style-apply.py <docx_path>
"""

import sys, os, re
from docx import Document
from docx.oxml.ns import qn

# Heading detection patterns (ordered by priority)
CHAPTER_RE = re.compile(r'^(الفصل\s+(الأول|الثاني|الثالث|الرابع|الخامس))')
MAKER_RE = re.compile(r'^(المبحث\s+(الأول|الثاني|الثالث|الرابع|الخامس))')
MATLAB_RE = re.compile(r'^(المطلب\s+(الأول|الثاني|الثالث|الرابع|الخامس))')
FAR3_RE = re.compile(r'^(الفرع\s+(الأول|الثاني|الثالث|الرابع|الخامس))')

HEAD_NAMES_H1 = [
    "المقدمة", "الخاتمة", "الإهداء", "شكر وتقدير",
    "ملخص", "Résumé", "Abstract",
    "قائمة الجداول", "قائمة الأشكال", "قائمة الملاحق",
    "جدول المحتويات",
]

SECTION_NUM_RE = re.compile(r'^(\d+\.\d+(\.\d+)?)\s')
SINGLE_NUM_RE = re.compile(r'^(\d+[\.\)])\s+')
ARABIC_LIST_RE = re.compile(r'^(أولاً|ثانياً|ثالثاً|رابعاً|خامساً|سادساً)\s*[—:]\s')


def detect_level(text):
    text = text.strip()
    if not text:
        return None
    if len(text) > 200:
        return None

    # Heading 1: الفصل + المقدمة + الخاتمة + dedication
    m = CHAPTER_RE.match(text)
    if m:
        return 1
    if any(text == h or text.startswith(h) for h in HEAD_NAMES_H1):
        return 1
    # إهداء / شكر block (first line only)
    if text in ("إهداء", "شكر وتقدير"):
        return 1

    # Heading 2: المبحث
    m = MAKER_RE.match(text)
    if m:
        return 2

    # Heading 3: المطلب
    m = MATLAB_RE.match(text)
    if m:
        return 3

    # Heading 3: الفرع
    m = FAR3_RE.match(text)
    if m:
        return 3

    # Heading 3: Numbered sections (1.1, 1.1.1, 2.1, etc.)
    m = SECTION_NUM_RE.match(text)
    if m:
        # Count depth
        num_part = m.group(1)
        dots = num_part.count('.')
        if dots == 1:
            return 3
        if dots >= 2:
            return 3

    # Heading 3: Single number (1. text, 2) text)
    m = SINGLE_NUM_RE.match(text)
    if m:
        return 3

    # Arabic list markers
    m = ARABIC_LIST_RE.match(text)
    if m:
        return 3

    # Short bold text might be a heading
    if len(text) < 60:
        return None

    return None


def get_bold_status(p):
    for r in p.runs:
        if r.bold:
            return True
    return False


def is_mostly_bold(p):
    bold_len = sum(len(r.text) for r in p.runs if r.bold)
    total_len = sum(len(r.text) for r in p.runs)
    if total_len == 0:
        return False
    return (bold_len / total_len) > 0.6


def apply_headings(doc):
    changes = []

    for i, p in enumerate(doc.paragraphs):
        text = p.text.strip()
        if not text:
            continue

        level = detect_level(text)

        # If not clearly detected, try bold heuristic
        if level is None and is_mostly_bold(p) and len(text) < 80:
            if any(kw in text for kw in ["مفهوم", "تعريف", "أهداف", "طرق", "أدوات", "تقييم",
                                          "نموذج", "دورة", "تحليل", "نظام", "إجراء",
                                          "مبدأ", "إستراتيجية", "متطلبات", "معايير",
                                          "مراقبة", "تخطيط", "تنظيم", "توجيه"]):
                level = 3

        if level is None:
            continue

        current_style = p.style.name if p.style else "None"
        wanted_style = f"Heading {level}"

        if current_style != wanted_style:
            old_style = current_style
            p.style = doc.styles[wanted_style]
            changes.append((i, old_style, wanted_style, text[:60]))

    return changes


def main():
    if len(sys.argv) < 2:
        print("Usage: python docx-style-apply.py <docx_path>")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"[ERROR] File not found: {path}")
        sys.exit(1)

    doc = Document(path)

    print(f"\nApplying heading styles to: {path}")
    print()

    changes = apply_headings(doc)

    if not changes:
        print("  ✅ No changes needed — all headings correctly styled.")
        doc.save(path)
        return

    h1 = sum(1 for _, _, s, _ in changes if s == "Heading 1")
    h2 = sum(1 for _, _, s, _ in changes if s == "Heading 2")
    h3 = sum(1 for _, _, s, _ in changes if s == "Heading 3")

    print(f"  Changes applied: {len(changes)} paragraphs")
    print(f"    H1 (chapter):   {h1}")
    print(f"    H2 (section):   {h2}")
    print(f"    H3 (subsection):{h3}")
    print()
    print(f"  {'P#':<6} {'From':<18} {'To':<18} {'Text':<50}")
    print(f"  " + "-" * 92)
    for idx, (pi, old, new, txt) in enumerate(changes):
        if idx >= 40:
            print(f"  ... and {len(changes) - 40} more")
            break
        print(f"  P{pi:<4} {old:<18} {new:<18} {txt[:50]:<50}")

    doc.save(path)

    print()
    print(f"✅ Heading styles applied. Saved: {path}")


if __name__ == "__main__":
    main()
