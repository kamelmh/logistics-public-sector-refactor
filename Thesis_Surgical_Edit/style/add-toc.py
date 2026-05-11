"""add-toc.py — Academix v13.2
Inserts TOC and ListOfTables field codes into the DOCX:
- After paragraph containing "فهرس المحتويات" → TOC field (levels 1-3)
- After paragraph containing "قائمة الجداول" → List of Tables field
Also upgrades both headings to Heading 3 style.
The fields are updated when opened in Word (or via COM in build step).
"""

import sys
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'


def make_run_element(text='', bold=False, sz_pt=None):
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    if bold:
        b = OxmlElement('w:b')
        rPr.append(b)
    if sz_pt is not None:
        sz = OxmlElement('w:sz')
        sz.set(f'{W}val', str(int(sz_pt * 2)))
        rPr.append(sz)
        szCs = OxmlElement('w:szCs')
        szCs.set(f'{W}val', str(int(sz_pt * 2)))
        rPr.append(szCs)
    r.append(rPr)
    t = OxmlElement('w:t')
    t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t.text = text
    r.append(t)
    return r


def make_field_paragraph(instr_text, placeholder_text=''):
    """Create a paragraph containing a Word field code."""
    p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    p.append(pPr)

    # Begin field char
    r1 = OxmlElement('w:r')
    fld1 = OxmlElement('w:fldChar')
    fld1.set(f'{W}fldCharType', 'begin')
    r1.append(fld1)
    p.append(r1)

    # Instruction text
    r2 = OxmlElement('w:r')
    instr = OxmlElement('w:instrText')
    instr.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    instr.text = instr_text
    r2.append(instr)
    p.append(r2)

    # Separate field char
    r3 = OxmlElement('w:r')
    fld2 = OxmlElement('w:fldChar')
    fld2.set(f'{W}fldCharType', 'separate')
    r3.append(fld2)
    p.append(r3)

    # Placeholder text (shown before update)
    r4 = OxmlElement('w:r')
    t = OxmlElement('w:t')
    t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t.text = placeholder_text or '[اضغط F9 لتحديث جدول المحتويات]'
    r4.append(t)
    p.append(r4)

    # End field char
    r5 = OxmlElement('w:r')
    fld3 = OxmlElement('w:fldChar')
    fld3.set(f'{W}fldCharType', 'end')
    r5.append(fld3)
    p.append(r5)

    return p


def find_paragraph_by_text(body, text_fragment):
    for i, child in enumerate(body):
        if child.tag == f'{W}p':
            para_text = ''.join(
                t.text or '' for t in child.iter(f'{W}t')
            )
            if text_fragment in para_text:
                return i, child
    return None, None


def upgrade_to_heading(p, heading_id='3'):
    """Upgrade a paragraph to heading style."""
    pPr = p.find(f'{W}pPr')
    if pPr is None:
        pPr = OxmlElement('w:pPr')
        p.insert(0, pPr)
    pStyle = pPr.find(f'{W}pStyle')
    if pStyle is None:
        pStyle = OxmlElement('w:pStyle')
        pPr.insert(0, pStyle)
    pStyle.set(f'{W}val', f'Heading{heading_id}')


def main():
    if len(sys.argv) < 2:
        print("Usage: python add-toc.py <docx_path>")
        sys.exit(1)

    path = sys.argv[1]
    print(f"Adding TOC/LOT fields in: {path}")

    doc = Document(path)
    body = doc.element.body

    # 1. Insert TOC after "فهرس المحتويات"
    idx1, p1 = find_paragraph_by_text(body, 'فهرس المحتويات')
    if idx1 is not None:
        upgrade_to_heading(p1, '3')
        toc_p = make_field_paragraph(
            'TOC \\o "1-3" \\h \\z \\u',
            '[جدول المحتويات — سيُحدَّث تلقائياً عند الفتح في Word]'
        )
        body.insert(idx1 + 1, toc_p)
        print(f"  TOC field inserted after فهرس المحتويات (P{idx1})")
        # Adjust index since we inserted
        if idx1 + 1 < len(list(body)):
            idx2_inner = idx1 + 2  # because TOC was inserted
        else:
            idx2_inner = idx1 + 1
    else:
        print("  [WARN] فهرس المحتويات not found")
        idx2_inner = None

    # 2. Insert List of Tables after "قائمة الجداول"
    search_start = idx2_inner if idx2_inner else 0
    idx2, p2 = find_paragraph_by_text(body, 'قائمة الجداول')
    if idx2 is not None:
        upgrade_to_heading(p2, '3')
        lot_p = make_field_paragraph(
            'TOC \\c "جدول"',
            '[قائمة الجداول — سيُحدَّث تلقائياً]'
        )
        body.insert(idx2 + 1, lot_p)
        print(f"  LOT field inserted after قائمة الجداول (P{idx2})")
    else:
        print("  [WARN] قائمة الجداول not found")

    doc.save(path)
    print(f"Saved: {path}")


if __name__ == '__main__':
    main()
