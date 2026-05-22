"""format-tables-advanced.py — Academix v13.2
Post-processes DOCX tables:
- Center each table on the page
- Set width to 100% (auto-fit columns)
- Prevent rows from splitting across pages (cantSplit)
- Keep heading paragraph before table with table (keepNext)
"""

import sys
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'


def center_table(tbl):
    tblPr = tbl.find(f'{W}tblPr')
    if tblPr is None:
        tblPr = OxmlElement('w:tblPr')
        tbl.insert(0, tblPr)
    existing = tblPr.find(f'{W}jc')
    if existing is not None:
        tblPr.remove(existing)
    jc = OxmlElement('w:jc')
    jc.set(f'{W}val', 'center')
    tblPr.append(jc)


def set_full_width(tbl):
    tblPr = tbl.find(f'{W}tblPr')
    if tblPr is None:
        tblPr = OxmlElement('w:tblPr')
        tbl.insert(0, tblPr)
    existing = tblPr.find(f'{W}tblW')
    if existing is not None:
        tblPr.remove(existing)
    tw = OxmlElement('w:tblW')
    tw.set(f'{W}w', '5000')
    tw.set(f'{W}type', 'pct')
    tblPr.append(tw)
    # Set layout to autofit
    existing_layout = tblPr.find(f'{W}tblLayout')
    if existing_layout is not None:
        tblPr.remove(existing_layout)
    layout = OxmlElement('w:tblLayout')
    layout.set(f'{W}type', 'autofit')
    tblPr.append(layout)


def set_row_cant_split(tr):
    trPr = tr.find(f'{W}trPr')
    if trPr is None:
        trPr = OxmlElement('w:trPr')
        tr.insert(0, trPr)
    cant = trPr.find(f'{W}cantSplit')
    if cant is None:
        cant = OxmlElement('w:cantSplit')
        trPr.append(cant)


def set_cell_width_auto(cell):
    tcPr = cell.find(f'{W}tcPr')
    if tcPr is not None:
        tcW = tcPr.find(f'{W}tcW')
        if tcW is not None:
            tcW.set(f'{W}w', '0')
            tcW.set(f'{W}type', 'dxa')


def main():
    if len(sys.argv) < 2:
        print("Usage: python format-tables-advanced.py <docx_path>")
        sys.exit(1)

    path = sys.argv[1]
    print(f"Formatting tables (advanced) in: {path}")

    doc = Document(path)

    tables = doc.element.findall('.//' + qn('w:tbl'))
    print(f"Found {len(tables)} tables")

    for ti, tbl in enumerate(tables):
        rows = tbl.findall(f'{W}tr')
        if not rows:
            continue

        # Center + full width
        center_table(tbl)
        set_full_width(tbl)

        # CantSplit on every row
        for tr in rows:
            set_row_cant_split(tr)

        # Auto-width on every cell (remove explicit widths)
        for tr in rows:
            for cell in tr.findall(f'{W}tc'):
                set_cell_width_auto(cell)

    # Keep heading paragraphs before tables with the table
    prev_was_non_table = False
    last_para = None
    for el in doc.element.body:
        tag = el.tag.split('}')[-1] if '}' in el.tag else el.tag
        if tag == 'p':
            last_para = el
            prev_was_non_table = True
        elif tag == 'tbl' and prev_was_non_table and last_para is not None:
            # Check if this paragraph already has keepNext
            pPr = last_para.find(f'{W}pPr')
            if pPr is None:
                pPr = OxmlElement('w:pPr')
                last_para.insert(0, pPr)
            existing = pPr.find(f'{W}keepNext')
            if existing is None:
                kn = OxmlElement('w:keepNext')
                pPr.append(kn)
            prev_was_non_table = False
        else:
            prev_was_non_table = False

    doc.save(path)
    print(f"Tables formatted: centered, full-width, no splits, keep-with-next")
    print(f"Saved: {path}")


if __name__ == '__main__':
    main()
