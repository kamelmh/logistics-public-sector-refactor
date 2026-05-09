"""customize-reference.py -- Academix v13.2
Creates a styled reference DOCX for pandoc by:
1. Copying styles from user's original complete DOCX
2. Adding Heading 1/2/3 styles with proper Arabic formatting
3. Setting page setup to A4 with 4cm margins (from old DOCX)
4. Setting docDefaults to Traditional Arabic 14pt with 1.5 line spacing
"""

import docx
from docx.shared import Pt, Cm, Emu, RGBColor
from docx.oxml.ns import qn
from lxml import etree
import zipfile, os, sys, copy
import inspect

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'

USER_DOC = r"D:\_MERGED\Software and System Tools\Dropbox\Logistics.and.Thesis.Hub\Z_ARCHIVE\03_Thesis_and_Internship\Drafts_AR_Memoire_Final_Complet.docx"
REF_IN = os.path.join(os.path.dirname(__file__), "reference-in.docx")
REF_OUT = os.path.join(os.path.dirname(__file__), "reference.docx")

# Color palette matching old Memoire_Academix_v13_2_Final.docx
C_NEAR_BLACK = "1A1A1A"
C_DARK_BLUE = "0C447C"
C_HEADING_1 = "1B2631"
C_HEADING_2 = "0C447C"


def load_user_styles():
    with zipfile.ZipFile(USER_DOC) as z:
        sx = z.read('word/styles.xml')
        dx = z.read('word/document.xml')
    return etree.fromstring(sx), etree.fromstring(dx)


def get_style(sroot, sid):
    for sty in sroot.findall(f'{W}style'):
        if sty.get(f'{W}styleId') == sid:
            return sty
    return None


def copy_props(src_style, ref_style, doc):
    src_rpr = src_style.find(f'{W}rPr') if src_style is not None else None
    ref_rpr = ref_style.element.find(qn('w:rPr'))
    if ref_rpr is None:
        ref_rpr = docx.oxml.OxmlElement('w:rPr')
        ref_style.element.append(ref_rpr)
    
    if src_rpr is not None:
        for tag in ['w:rFonts', 'w:b', 'w:bCs', 'w:i', 'w:iCs', 'w:color', 'w:sz', 'w:szCs']:
            src_el = src_rpr.find(f'{W}{tag[2:]}')
            if src_el is not None:
                existing = ref_rpr.find(qn(tag))
                if existing is not None:
                    for attr in src_el.attrib:
                        existing.set(attr, src_el.get(attr))
                else:
                    ref_rpr.append(copy.deepcopy(src_el))


def ensure_heading_style(doc, style_name, style_id, font_size_pt, color_hex, bold=True, outline_lvl="0"):
    """Create or update a heading style with proper Arabic formatting."""
    try:
        hs = doc.styles[style_name]
    except KeyError:
        hs = doc.styles.add_style(style_name, docx.enum.style.WD_STYLE_TYPE.PARAGRAPH)
    
    hs.font.size = Pt(font_size_pt)
    hs.font.bold = bold
    hs.font.color.rgb = RGBColor(*[int(color_hex[i:i+2], 16) for i in (0, 2, 4)])
    hs.font.name = "Traditional Arabic"
    hs.paragraph_format.alignment = docx.enum.text.WD_ALIGN_PARAGRAPH.RIGHT
    
    # Set outline level in XML
    pPr = hs.element.find(qn('w:pPr'))
    if pPr is None:
        pPr = docx.oxml.OxmlElement('w:pPr')
        hs.element.insert(0, pPr)
    outline = pPr.find(qn('w:outlineLvl'))
    if outline is None:
        outline = docx.oxml.OxmlElement('w:outlineLvl')
        pPr.append(outline)
    outline.set(qn('w:val'), outline_lvl)
    
    # Set keep-with-next and keep-lines
    pPr = hs.element.find(qn('w:pPr'))
    if pPr is None:
        pPr = docx.oxml.OxmlElement('w:pPr')
        hs.element.insert(0, pPr)
    for tag in ['w:keepNext', 'w:keepLines']:
        el = docx.oxml.OxmlElement(tag)
        pPr.append(el)
    
    return hs


def main():
    if not os.path.exists(USER_DOC):
        print(f"[ERROR] User DOC not found: {USER_DOC}")
        sys.exit(1)
    if not os.path.exists(REF_IN):
        print(f"[ERROR] reference-in.docx not found")
        sys.exit(1)
    
    print("Academix v13.2 -- Reference Style Builder")
    print(f"Source: {USER_DOC}")
    
    sroot, droot = load_user_styles()
    doc = docx.Document(REF_IN)
    styles_elem = doc.styles.element
    
    # Copy ALL paragraph styles from user doc
    copied = 0
    for sty in sroot.findall(f'{W}style'):
        if sty.get(f'{W}type') != 'paragraph' and sty.get(f'{W}type') != '1':
            continue
        sid = sty.get(f'{W}styleId')
        ref_style = None
        for s in doc.styles:
            if s.style_id == sid:
                ref_style = s
                break
        if ref_style is None:
            continue
        
        copy_props(sty, ref_style, doc)
        
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
    
    # Copy docDefaults from user DOC
    dde = sroot.find(f'{W}docDefaults')
    existing_dd = styles_elem.find(qn('w:docDefaults'))
    if existing_dd is not None:
        styles_elem.remove(existing_dd)
    if dde is not None:
        styles_elem.insert(0, copy.deepcopy(dde))
        print("docDefaults: copied from user DOC")
    
    # Override docDefaults line spacing to 1.5
    existing_dd = styles_elem.find(qn('w:docDefaults'))
    if existing_dd is not None:
        pPrDefault = existing_dd.find(f'{W}pPrDefault')
    else:
        # Create docDefaults
        dd = docx.oxml.OxmlElement('w:docDefaults')
        styles_elem.insert(0, dd)
        pPrDef = docx.oxml.OxmlElement('w:pPrDefault')
        pPr = docx.oxml.OxmlElement('w:pPr')
        pPrDef.append(pPr)
        dd.append(pPrDef)
        line = docx.oxml.OxmlElement('w:spacing')
        line.set(qn('w:line'), '360')
        line.set(qn('w:lineRule'), 'auto')
        pPr.append(line)
        rPrDef = docx.oxml.OxmlElement('w:rPrDefault')
        rPr = docx.oxml.OxmlElement('w:rPr')
        rPrDef.append(rPr)
        dd.append(rPrDef)
        print("docDefaults: created with 1.5 line spacing")
    
    # Add Heading styles with proper Arabic formatting
    headings = [
        ("Heading 1", 22, C_HEADING_1, "0"),    # Chapter titles
        ("Heading 2", 18, C_HEADING_2, "1"),    # Section titles
        ("Heading 3", 16, C_HEADING_2, "2"),    # Subsection titles
    ]
    for hname, sz, clr, lvl in headings:
        ensure_heading_style(doc, hname, hname, sz, clr, bold=True, outline_lvl=lvl)
        print(f"  Added {hname}: {sz}pt, #{clr}")
    
    # Copy page setup from user DOC (A4, 4cm margins)
    body = droot.find(f'{W}body')
    user_sectPr = body.find(f'{W}sectPr')
    if user_sectPr is not None:
        for section in doc.sections:
            pgSz = user_sectPr.find(f'{W}pgSz')
            if pgSz is not None:
                section.page_width = Emu(
                    int(int(pgSz.get(f'{W}w', '11906')) * 914400 / 1440)
                )
                section.page_height = Emu(
                    int(int(pgSz.get(f'{W}h', '16838')) * 914400 / 1440)
                )
            pgMar = user_sectPr.find(f'{W}pgMar')
            if pgMar is not None:
                for margin, attr in [
                    ('top_margin', 'top'), ('bottom_margin', 'bottom'),
                    ('left_margin', 'left'), ('right_margin', 'right')
                ]:
                    val = pgMar.get(f'{W}{attr}', '2275')
                    setattr(section, margin, Emu(int(int(val) * 914400 / 1440)))
        print("Page setup: A4, 4cm margins")
    
    doc.save(REF_OUT)
    print(f"Saved: {REF_OUT}")
    print("OK -- Reference styled from user's original DOCX")


if __name__ == '__main__':
    main()
