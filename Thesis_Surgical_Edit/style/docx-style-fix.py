"""docx-style-fix.py -- Academix v13.2
Fix DOCX styles: unhide headings, set Traditional Arabic font,
RIGHT alignment, proper sizes and colors.
Usage: python docx-style-fix.py <docx_path>
"""

import sys, os, copy
from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml.ns import qn, nsdecls
from docx.oxml import OxmlElement
from lxml import etree

# Style spec: name -> (size_pt, color_hex, bold, outline_level)
HEADING_SPEC = {
    "Heading 1": (22, "1B2631", True, "0"),
    "Heading 2": (18, "0C447C", True, "1"),
    "Heading 3": (16, "0C447C", True, "2"),
    "Heading 4": (14, "0C447C", True, "3"),
}

FONT_NAME = "Traditional Arabic"
LINE_SPACING = "360"  # 1.5 line spacing in twips


def maketag(tag):
    return qn(tag)


def find_child(parent, tag):
    return parent.find(maketag(tag))


def get_or_create_child(parent, tag):
    child = find_child(parent, tag)
    if child is None:
        child = OxmlElement(tag)
        parent.append(child)
    return child


def unhide_style(style_elem):
    for tag in ['w:semiHidden', 'w:unhideWhenUsed', 'w:hidden']:
        el = find_child(style_elem, tag)
        if el is not None:
            style_elem.remove(el)


def ensure_rpr(style_elem):
    return get_or_create_child(style_elem, 'w:rPr')


def ensure_ppr(style_elem):
    return get_or_create_child(style_elem, 'w:pPr')


def set_font_name(rpr, font_name):
    rFonts = get_or_create_child(rpr, 'w:rFonts')
    for attr in ['w:ascii', 'w:hAnsi', 'w:eastAsia', 'w:cs']:
        rFonts.set(maketag(attr), font_name)


def set_bold(rpr, bold=True):
    existing = find_child(rpr, 'w:b')
    if bold:
        if existing is None:
            get_or_create_child(rpr, 'w:b')
    else:
        if existing is not None:
            rpr.remove(existing)


def set_font_size(rpr, size_half_pt):
    sz = get_or_create_child(rpr, 'w:sz')
    sz.set(maketag('w:val'), str(size_half_pt))
    szCs = get_or_create_child(rpr, 'w:szCs')
    szCs.set(maketag('w:val'), str(size_half_pt))


def set_color(rpr, color_hex):
    c = get_or_create_child(rpr, 'w:color')
    c.set(maketag('w:val'), color_hex)


def set_alignment(ppr, align_val):
    jc = get_or_create_child(ppr, 'w:jc')
    jc.set(maketag('w:val'), align_val)


def set_line_spacing(ppr, line_val):
    spacing = get_or_create_child(ppr, 'w:spacing')
    spacing.set(maketag('w:line'), line_val)
    spacing.set(maketag('w:lineRule'), 'auto')


def set_outline_level(ppr, level):
    ol = get_or_create_child(ppr, 'w:outlineLvl')
    ol.set(maketag('w:val'), level)


def fix_style_by_name(doc, style_name, font_name=FONT_NAME,
                      size_pt=None, color_hex=None, bold=None,
                      alignment=None, line_spacing=None,
                      outline_level=None, unhide=True):
    if style_name not in doc.styles:
        print(f"  Style '{style_name}' not found, skipping")
        return
    st = doc.styles[style_name]
    se = st.element

    if unhide:
        unhide_style(se)

    rpr = ensure_rpr(se)

    set_font_name(rpr, font_name)

    if size_pt is not None:
        set_font_size(rpr, int(size_pt * 2))

    if bold is not None:
        set_bold(rpr, bold)

    if color_hex is not None:
        set_color(rpr, color_hex)

    ppr = ensure_ppr(se)

    if alignment is not None:
        set_alignment(ppr, alignment)

    if line_spacing is not None:
        set_line_spacing(ppr, line_spacing)

    if outline_level is not None:
        set_outline_level(ppr, outline_level)

    print(f"  Fixed: {style_name}")


def fix_doc_defaults(doc):
    styles_elem = doc.styles.element
    dd = find_child(styles_elem, 'w:docDefaults')
    if dd is None:
        dd = OxmlElement('w:docDefaults')
        styles_elem.insert(0, dd)

    rPrDefault = get_or_create_child(dd, 'w:rPrDefault')
    rPr = get_or_create_child(rPrDefault, 'w:rPr')
    set_font_name(rPr, FONT_NAME)

    pPrDefault = get_or_create_child(dd, 'w:pPrDefault')
    pPr = get_or_create_child(pPrDefault, 'w:pPr')
    set_line_spacing(pPr, LINE_SPACING)
    set_alignment(pPr, 'right')

    print(f"  Fixed: docDefaults (font={FONT_NAME}, 1.5 spacing, right align)")


def fix_section_properties(doc):
    for section in doc.sections:
        sectPr = section._sectPr
        pgMar = find_child(sectPr, 'w:pgMar')
        if pgMar is not None:
            header = pgMar.get(maketag('w:header'))
            footer = pgMar.get(maketag('w:footer'))
            if header is None:
                pgMar.set(maketag('w:header'), '850')
            if footer is None:
                pgMar.set(maketag('w:footer'), '850')
    print("  Fixed: section header/footer margins")


def main():
    if len(sys.argv) < 2:
        print("Usage: python docx-style-fix.py <docx_path>")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"[ERROR] File not found: {path}")
        sys.exit(1)

    backup_path = path.replace('.docx', '_backup.docx')
    if not os.path.exists(backup_path):
        import shutil
        shutil.copy2(path, backup_path)
        print(f"Backup saved: {backup_path}")

    doc = Document(path)

    print(f"\nFixing styles in: {path}")
    print()

    # Fix docDefaults first
    fix_doc_defaults(doc)

    # Fix heading styles with spec
    for hname, (sz, clr, bold, lvl) in HEADING_SPEC.items():
        fix_style_by_name(doc, hname, size_pt=sz, color_hex=clr,
                          bold=bold, alignment='right',
                          outline_level=lvl, unhide=True)

    # Fix Normal
    fix_style_by_name(doc, "Normal", size_pt=14,
                      alignment='right', line_spacing=LINE_SPACING)

    # Fix Title
    fix_style_by_name(doc, "Title", size_pt=28, bold=True,
                      alignment='center', color_hex="1A1A1A")

    # Fix Subtitle
    fix_style_by_name(doc, "Subtitle", size_pt=14,
                      alignment='right', color_hex="555555")

    # Fix table-related styles
    for tn in ["Table", "Table Grid", "Grid Table 5 Dark Accent 6"]:
        fix_style_by_name(doc, tn, size_pt=11, alignment='right', unhide=True)

    # Fix Header/Footer
    fix_style_by_name(doc, "Header", size_pt=10, alignment='center')
    fix_style_by_name(doc, "Footer", size_pt=10, alignment='center')

    # Fix List Paragraph
    fix_style_by_name(doc, "List Paragraph", size_pt=14, alignment='right')

    # Fix Strong1
    fix_style_by_name(doc, "Strong1", bold=True, size_pt=14, alignment='right')

    # Unhide common styles
    for sn in ["Default Paragraph Font", "Normal Table", "No List"]:
        if sn in doc.styles:
            unhide_style(doc.styles[sn].element)
            print(f"  Unhidden: {sn}")

    fix_section_properties(doc)

    doc.save(path)

    print()
    print(f"✅ Style fixes applied. Saved: {path}")
    print(f"   Backup: {backup_path}")


if __name__ == "__main__":
    main()
