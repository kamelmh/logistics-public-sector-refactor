"""customize-reference.py -- Academix v13.2
Uses user's original complete DOCX as style source.
Copies all paragraph styles, document defaults, and section properties.
"""

import docx
from docx.shared import Pt, Cm, Emu, RGBColor
from docx.oxml.ns import qn
from lxml import etree
import zipfile, os, sys, copy

USER_DOC = r"D:\_MERGED\Software and System Tools\Dropbox\Logistics.and.Thesis.Hub\Z_ARCHIVE\03_Thesis_and_Internship\Drafts_AR_Memoire_Final_Complet.docx"
REF_IN = os.path.join(os.path.dirname(__file__), "reference-in.docx")
REF_OUT = os.path.join(os.path.dirname(__file__), "reference.docx")
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'

def load_user_styles():
    with zipfile.ZipFile(USER_DOC) as z:
        sx = z.read('word/styles.xml')
        dx = z.read('word/document.xml')
    sroot = etree.fromstring(sx)
    droot = etree.fromstring(dx)
    dde = sroot.find(f'{W}docDefaults')
    return sroot, droot, dde

def get_style(sroot, sid):
    for sty in sroot.findall(f'{W}style'):
        if sty.get(f'{W}styleId') == sid:
            return sty
    return None

def copy_props(src_style, ref_style):
    src_rpr = src_style.find(f'{W}rPr') if src_style is not None else None
    ref_rpr = ref_style.element.find(qn('w:rPr'))
    if ref_rpr is None:
        ref_rpr = docx.oxml.OxmlElement('w:rPr')
        ref_style.element.append(ref_rpr)
    
    if src_rpr is not None:
        for tag in ['w:rFonts', 'w:b', 'w:bCs', 'w:i', 'w:iCs', 'w:color', 'w:sz', 'w:szCs']:
            src_el = src_rpr.find(tag, {'w': W.replace('{', '').replace('}', '')})
            if src_el is None:
                src_el = src_rpr.find(f'{W}{tag[2:]}')
            if src_el is not None:
                existing = ref_rpr.find(qn(tag))
                if existing is not None:
                    for attr in src_el.attrib:
                        existing.set(attr, src_el.get(attr))
                else:
                    ref_rpr.append(copy.deepcopy(src_el))

def main():
    if not os.path.exists(USER_DOC):
        print(f"[ERROR] User DOC not found: {USER_DOC}")
        sys.exit(1)
    if not os.path.exists(REF_IN):
        print(f"[ERROR] reference-in.docx not found")
        sys.exit(1)
    
    print("Academix v13.2 -- Reference Style Builder")
    print(f"Source: {USER_DOC}")
    
    sroot, droot, dde = load_user_styles()
    doc = docx.Document(REF_IN)
    styles_elem = doc.styles.element
    
    # Copy ALL styles from user doc
    copied = 0
    for sty in sroot.findall(f'{W}style'):
        sid = sty.get(f'{W}styleId')
        stype = sty.get(f'{W}type')
        try:
            ref_style = doc.styles[sid]
        except KeyError:
            continue
        
        copy_props(sty, ref_style)
        
        # Copy paragraph properties (alignment, spacing)
        src_ppr = sty.find(f'{W}pPr')
        if src_ppr is not None:
            ref_ppr = ref_style.element.find(qn('w:pPr'))
            if ref_ppr is None:
                ref_ppr = docx.oxml.OxmlElement('w:pPr')
                ref_style.element.insert(0, ref_ppr)
            for tag in ['w:jc', 'w:spacing', 'w:outlineLvl']:
                src_el = src_ppr.find(f'{W}{tag[2:]}')
                if src_el is not None:
                    existing = ref_ppr.find(qn(tag))
                    if existing is not None:
                        for attr in src_el.attrib:
                            existing.set(attr, src_el.get(attr))
                    else:
                        ref_ppr.append(copy.deepcopy(src_el))
        
        # Unhide headings
        for hide_tag in ['w:semiHidden', 'w:unhideWhenUsed']:
            el = ref_style.element.find(qn(hide_tag))
            if el is not None:
                ref_style.element.remove(el)
        
        copied += 1
    
    print(f"Styles copied: {copied}")
    
    # Copy docDefaults
    existing_dd = styles_elem.find(qn('w:docDefaults'))
    if existing_dd is not None:
        styles_elem.remove(existing_dd)
    
    if dde is not None:
        styles_elem.insert(0, copy.deepcopy(dde))
        print("docDefaults: copied from user DOC")
    
    # Copy page setup from user DOC
    body = droot.find(f'{W}body')
    user_sectPr = body.find(f'{W}sectPr')
    if user_sectPr is not None:
        for section in doc.sections:
            pgSz = user_sectPr.find(f'{W}pgSz')
            if pgSz is not None:
                section.page_width = Emu(int(int(pgSz.get(f'{W}w', '11906')) * 914400 / 1440))
                section.page_height = Emu(int(int(pgSz.get(f'{W}h', '16838')) * 914400 / 1440))
            pgMar = user_sectPr.find(f'{W}pgMar')
            if pgMar is not None:
                for margin, attr in [('top_margin', 'top'), ('bottom_margin', 'bottom'), ('left_margin', 'left'), ('right_margin', 'right')]:
                    val = pgMar.get(f'{W}{attr}', '2275')
                    setattr(section, margin, Emu(int(int(val) * 914400 / 1440)))
        print("Page setup: A4, 4cm margins")
    
    doc.save(REF_OUT)
    print(f"Saved: {REF_OUT}")
    print("OK -- Reference styled from user's original DOCX")

if __name__ == '__main__':
    main()
