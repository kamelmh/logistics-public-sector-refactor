"""Analyze archive DOCX cover formatting for exact replication."""
from docx import Document
from docx.oxml.ns import qn

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
doc = Document(r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\archive\Memoire_Academix_v13_2_Final.docx')

count = 0
for p in doc.paragraphs:
    if 'المقدمة العامة' in p.text.strip():
        break
    txt = p.text.strip()
    align_map = {0:'left', 1:'center', 2:'right', 3:'both', 4:'distribute', None:'inherit'}
    align = p.alignment
    
    for r in p.runs:
        rPr = r._r.find(f'{W}rPr')
        bold = False
        sz = None
        color = None
        theme_color = None
        font = None
        font_east = None
        if rPr is not None:
            b = rPr.find(f'{W}b')
            if b is not None:
                bold = (b.get(f'{W}val', 'true') != 'false')
            sz_e = rPr.find(f'{W}sz')
            if sz_e is not None:
                sz = sz_e.get(f'{W}val')
            col_e = rPr.find(f'{W}color')
            if col_e is not None:
                color = col_e.get(f'{W}val')
                theme_color = col_e.get(f'{W}themeColor')
            rFonts = rPr.find(f'{W}rFonts')
            if rFonts is not None:
                font = rFonts.get(f'{W}ascii') or rFonts.get(f'{W}hAnsi') or ''
                font_east = rFonts.get(f'{W}eastAsia') or ''
    
    if txt:
        tc = ''
        if theme_color:
            tc = f' (theme:{theme_color})'
        print(f'P{count:2d} align={align_map.get(align,"?"):7s} bold={str(bold):5s} sz={str(sz):4s} color={str(color)+tc:25s} font={font or "":15s} east={font_east or ""} | {txt[:70]}')
    else:
        print(f'P{count:2d} [empty]')
    count += 1
