"""format-tables.py -- Academix v13.2
Post-processes DOCX to apply user's table formatting:
- Header row: dark blue fill (#0C447C), white bold text
- Body: alternating light blue (#EBF5FB) / white rows
"""

import sys, copy
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

HEADER_FILL = '0C447C'
ALT_FILL = 'EBF5FB'

def set_shading(cell_elem, fill_hex):
    tc_pr = cell_elem.find(qn('w:tcPr'))
    if tc_pr is None:
        tc_pr = OxmlElement('w:tcPr')
        cell_elem.insert(0, tc_pr)
    existing = tc_pr.find(qn('w:shd'))
    if existing is not None:
        tc_pr.remove(existing)
    shd = OxmlElement('w:shd')
    shd.set(qn('w:fill'), fill_hex)
    shd.set(qn('w:val'), 'clear')
    tc_pr.append(shd)

def set_run_props(run_elem, color_hex, bold=False):
    rPr = run_elem.find(qn('w:rPr'))
    if rPr is None:
        rPr = OxmlElement('w:rPr')
        run_elem.insert(0, rPr)
    # Color
    existing = rPr.find(qn('w:color'))
    if existing is not None:
        rPr.remove(existing)
    c = OxmlElement('w:color')
    c.set(qn('w:val'), color_hex)
    rPr.append(c)
    # Bold (only for header)
    if bold:
        existing_b = rPr.find(qn('w:b'))
        if existing_b is None:
            b = OxmlElement('w:b')
            rPr.append(b)
    else:
        existing_b = rPr.find(qn('w:b'))
        if existing_b is not None:
            rPr.remove(existing_b)

def format_table(tbl_elem):
    rows = tbl_elem.findall(qn('w:tr'))
    if not rows:
        return
    for ri, row in enumerate(rows):
        cells = row.findall(qn('w:tc'))
        if ri == 0:
            # Header row: dark fill, white bold text
            for cell in cells:
                set_shading(cell, HEADER_FILL)
                for run in cell.findall('.//' + qn('w:r')):
                    set_run_props(run, 'FFFFFF', bold=True)
        elif ri % 2 == 1:
            # Odd rows: alternating fill
            for cell in cells:
                set_shading(cell, ALT_FILL)
                for run in cell.findall('.//' + qn('w:r')):
                    rPr = run.find(qn('w:rPr'))
                    keep_color = False
                    if rPr is not None:
                        c = rPr.find(qn('w:color'))
                        if c is not None:
                            val = c.get(qn('w:val'), '').upper()
                            if val not in ('', '000000', 'AUTO'):
                                keep_color = True
                    if not keep_color:
                        set_run_props(run, '000000')
        else:
            # Even body rows: white bg, black text
            for cell in cells:
                for run in cell.findall('.//' + qn('w:r')):
                    set_run_props(run, '000000')

def main():
    if len(sys.argv) < 2:
        print("Usage: format-tables.py <docx_path>")
        sys.exit(1)
    
    path = sys.argv[1]
    print(f"Formatting tables in: {path}")
    
    doc = Document(path)
    tables = doc.element.findall('.//' + qn('w:tbl'))
    print(f"Found {len(tables)} tables")
    
    for ti, tbl in enumerate(tables):
        format_table(tbl)
        if ti < 3 or ti == len(tables) - 1:
            print(f"  Table {ti+1}: formatted")
    
    if len(tables) > 4:
        print(f"  ... and {len(tables)-4} more tables formatted")
    
    doc.save(path)
    print(f"Saved: {path}")

if __name__ == '__main__':
    main()
