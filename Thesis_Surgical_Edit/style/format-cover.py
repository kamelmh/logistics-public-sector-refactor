"""format-cover.py -- Academix v13.2
Post-processes the cover page of the generated DOCX
to match the exact formatting of the reference DOCX:
- Near-black (#1A1A1A) bold centered Arabic titles
- Green (#1F6B2E) English title in Times New Roman
- Gold (#806000) date
- Gray (#555555) subtitle
- 18pt (228600 EMU) for main headings, 12pt (152400 EMU) for body
"""

import sys, os, re
from docx import Document
from docx.shared import Pt, Emu, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

# Color constants from the reference DOCX
C_NEAR_BLACK = RGBColor(0x1A, 0x1A, 0x1A)
C_GREEN = RGBColor(0x1F, 0x6B, 0x2E)
C_GOLD = RGBColor(0x80, 0x60, 0x00)
C_GRAY = RGBColor(0x55, 0x55, 0x55)
SZ_18PT = Pt(18)
SZ_16PT = Pt(16)
SZ_14PT = Pt(14)
SZ_12PT = Pt(12)
SZ_11PT = Pt(11)

def apply_run_format(run, bold=None, italic=None, size=None, color=None, font_name=None):
    if bold is not None:
        run.bold = bold
    if italic is not None:
        run.italic = italic
    if size is not None:
        run.font.size = size
    if color is not None:
        run.font.color.rgb = color
    if font_name is not None:
        run.font.name = font_name

def format_cover(doc):
    paras = doc.paragraphs
    i = 0
    
    while i < len(paras):
        text = paras[i].text.strip()
        
        # P0: الجمهورية الجزائرية
        if text == "الجمهورية الجزائرية الديمقراطية الشعبية":
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # P1: وزارة التكوين...
        if text.startswith("وزارة التكوين"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # مذكرة تخرج / مذكرة نهاية التربص
        if text in ("مذكرة تخرج", "مذكرة نهاية التربص"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_18PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # لنيل شهادة...
        if text.startswith("لنيل شهادة"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=False, size=SZ_12PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # Title: بناء نظام دعم قرار
        if "بناء نظام دعم قرار" in text or "بناء نظام لإتمام" in text:
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_16PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # Subtitle: دراسة حالة في ظل محدودية
        if "محدودية الموارد" in text or "دراسة حالة:" in text:
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_18PT, color=C_GRAY)
            i += 1
            continue
        
        # English title
        if text.startswith("Designing a Decision"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_12PT, color=C_GREEN, font_name="Times New Roman")
            i += 1
            continue
        
        # Student/supervisor line
        if "إعداد الطالب" in text or "ماحي" in text:
            paras[i].alignment = WD_ALIGN_PARAGRAPH.LEFT
            # Negative indent for horizontal rule effect
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_12PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # Date
        if "أكتوبر 2025" in text or "2025" in text:
            if paras[i].alignment is None:
                paras[i].alignment = WD_ALIGN_PARAGRAPH.LEFT
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_16PT, color=C_GOLD)
            i += 1
            continue
        
        # بسم الله
        if "بسم الله" in text:
            paras[i].alignment = WD_ALIGN_PARAGRAPH.RIGHT
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_14PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # Section headings (إهداء, شكر وتقدير, ملخص, Résumé, Abstract)
        if text in ("إهداء", "شكر وتقدير", "ملخص", "Résumé", "Abstract"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paras[i].runs:
                apply_run_format(run, bold=True, size=SZ_18PT, color=C_NEAR_BLACK)
            i += 1
            continue
        
        # Body text - right aligned
        if len(text) > 20 and not text.startswith("***"):
            paras[i].alignment = WD_ALIGN_PARAGRAPH.RIGHT
            for run in paras[i].runs:
                if run.font.size is None:
                    run.font.size = SZ_12PT
            i += 1
            continue
        
        i += 1
    
    return doc


def main():
    if len(sys.argv) < 2:
        print("Usage: python format-cover.py <docx_path>")
        sys.exit(1)
    
    docx_path = sys.argv[1]
    doc = Document(docx_path)
    doc = format_cover(doc)
    doc.save(docx_path)
    print(f"Cover formatted: {docx_path}")


if __name__ == "__main__":
    main()
