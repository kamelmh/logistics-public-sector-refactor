"""
customize-reference.py -- Academix v13.2
Copies ALL style settings from v13.1 Memoire DOCX to Pandoc reference.docx
Preserves RTL alignment and Arabic font settings.

Reads v13.1 styles.xml directly for accurate XML-level style copying.
"""

import docx
from docx.shared import Pt, Cm, Emu, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from lxml import etree
import zipfile
import os, sys, copy, shutil

V13_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Final_Delivery_Layout\01_Memoire_Final\Memoire_Academix_v13_1_Final.docx"
REF_IN = os.path.join(os.path.dirname(__file__), "reference-in.docx")
REF_OUT = os.path.join(os.path.dirname(__file__), "reference.docx")

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
NSMAP = {"w": W}


def halfpt_to_pt(halfpt_str):
    """Convert half-points string to Pt value."""
    if halfpt_str is None:
        return None
    try:
        return int(halfpt_str) / 2
    except (ValueError, TypeError):
        return None


def twips_to_cm(twips_str):
    """Convert twips to Cm."""
    if twips_str is None:
        return None
    try:
        return int(twips_str) * 0.0017639  # 1 twip = 0.0017639 cm
    except (ValueError, TypeError):
        return None


def load_v13_styles():
    """Load v13.1 styles.xml and return (styles_elem, doc_elem, docDefaults_elem)."""
    with zipfile.ZipFile(V13_PATH) as z:
        styles_xml = z.read("word/styles.xml")
        doc_xml = z.read("word/document.xml")
    styles_root = etree.fromstring(styles_xml)
    doc_root = etree.fromstring(doc_xml)
    dde = styles_root.find(".//w:docDefaults", NSMAP)
    return styles_root, doc_root, dde


def get_v13_style(styles_root, style_id):
    """Get a w:style element from v13.1 styles by styleId."""
    for sty in styles_root.findall(".//w:style", NSMAP):
        sid = sty.get(qn("w:styleId"))
        if sid == style_id:
            return sty
    return None


def get_rpr_from_style(style_elem):
    """Get the w:rPr element from a style element (returns None if not found)."""
    if style_elem is None:
        return None
    return style_elem.find("w:rPr", NSMAP)


def get_ppr_from_style(style_elem):
    """Get the w:pPr element from a style element."""
    if style_elem is None:
        return None
    return style_elem.find("w:pPr", NSMAP)


def copy_rpr_props(v13_style, ref_style, docDefaults_rpr):
    """Copy run properties from v13.1 style to reference style.
    
    Strategy:
    1. Get font info from docDefaults (Traditional Arabic)
    2. Apply v13.1 style-specific overrides (size, color, bold, italic)
    3. Set on the reference style
    """
    v13_rpr = get_rpr_from_style(v13_style)
    ref_rpr = ref_style.element.find(qn("w:rPr"))
    if ref_rpr is None:
        ref_rpr = docx.oxml.OxmlElement("w:rPr")
        ref_style.element.append(ref_rpr)

    # --- rFonts: always set to Traditional Arabic from v13.1 docDefaults ---
    # Remove existing rFonts
    existing_rFonts = ref_rpr.find(qn("w:rFonts"))
    if existing_rFonts is not None:
        ref_rpr.remove(existing_rFonts)

    # Create new rFonts with Traditional Arabic
    rFonts = docx.oxml.OxmlElement("w:rFonts")
    rFonts.set(qn("w:ascii"), "Traditional Arabic")
    rFonts.set(qn("w:hAnsi"), "Traditional Arabic")
    rFonts.set(qn("w:eastAsia"), "Traditional Arabic")
    rFonts.set(qn("w:cs"), "Traditional Arabic")
    ref_rpr.insert(0, rFonts)

    # --- Copy properties from v13.1 style rPr ---
    if v13_rpr is not None:
        # w:b (bold)
        v_b = v13_rpr.find("w:b", NSMAP)
        existing_b = ref_rpr.find(qn("w:b"))
        if v_b is not None:
            if existing_b is None:
                ref_rpr.append(copy.deepcopy(v_b))
        else:
            if existing_b is not None:
                ref_rpr.remove(existing_b)
        # w:bCs
        v_bCs = v13_rpr.find("w:bCs", NSMAP)
        existing_bCs = ref_rpr.find(qn("w:bCs"))
        if v_bCs is not None:
            if existing_bCs is None:
                ref_rpr.append(copy.deepcopy(v_bCs))
        else:
            if existing_bCs is not None:
                ref_rpr.remove(existing_bCs)

        # w:i (italic)
        v_i = v13_rpr.find("w:i", NSMAP)
        existing_i = ref_rpr.find(qn("w:i"))
        if v_i is not None:
            if existing_i is None:
                ref_rpr.append(copy.deepcopy(v_i))
        else:
            if existing_i is not None:
                ref_rpr.remove(existing_i)
        # w:iCs
        v_iCs = v13_rpr.find("w:iCs", NSMAP)
        existing_iCs = ref_rpr.find(qn("w:iCs"))
        if v_iCs is not None:
            if existing_iCs is None:
                ref_rpr.append(copy.deepcopy(v_iCs))
        else:
            if existing_iCs is not None:
                ref_rpr.remove(existing_iCs)

        # w:color
        v_color = v13_rpr.find("w:color", NSMAP)
        existing_color = ref_rpr.find(qn("w:color"))
        if v_color is not None:
            if existing_color is not None:
                # Copy val and any other attrs from v13
                existing_color.set(qn("w:val"), v_color.get(qn("w:val"), ""))
            else:
                ref_rpr.append(copy.deepcopy(v_color))
        else:
            if existing_color is not None:
                ref_rpr.remove(existing_color)

        # w:sz (font size)
        v_sz = v13_rpr.find("w:sz", NSMAP)
        existing_sz = ref_rpr.find(qn("w:sz"))
        if v_sz is not None:
            if existing_sz is not None:
                existing_sz.set(qn("w:val"), v_sz.get(qn("w:val"), "24"))
            else:
                ref_rpr.append(copy.deepcopy(v_sz))
        else:
            # If v13 has no sz, inherit from docDefaults (28 half-pt = 14pt)
            if existing_sz is not None and docDefaults_rpr is not None:
                dd_sz = docDefaults_rpr.find("w:sz", NSMAP)
                if dd_sz is not None:
                    existing_sz.set(qn("w:val"), dd_sz.get(qn("w:val"), "28"))

        # w:szCs
        v_szCs = v13_rpr.find("w:szCs", NSMAP)
        existing_szCs = ref_rpr.find(qn("w:szCs"))
        if v_szCs is not None:
            if existing_szCs is not None:
                existing_szCs.set(qn("w:val"), v_szCs.get(qn("w:val"), "24"))
            else:
                ref_rpr.append(copy.deepcopy(v_szCs))
        elif existing_szCs is not None and docDefaults_rpr is not None:
            dd_szCs = docDefaults_rpr.find("w:szCs", NSMAP)
            if dd_szCs is not None:
                existing_szCs.set(qn("w:val"), dd_szCs.get(qn("w:val"), "28"))
    else:
        # No rPr in v13 style -- use docDefaults
        if docDefaults_rpr is not None:
            dd_sz = docDefaults_rpr.find("w:sz", NSMAP)
            if dd_sz is not None:
                existing_sz = ref_rpr.find(qn("w:sz"))
                if existing_sz is not None:
                    existing_sz.set(qn("w:val"), dd_sz.get(qn("w:val"), "28"))
            dd_szCs = docDefaults_rpr.find("w:szCs", NSMAP)
            if dd_szCs is not None:
                existing_szCs = ref_rpr.find(qn("w:szCs"))
                if existing_szCs is not None:
                    existing_szCs.set(qn("w:val"), dd_szCs.get(qn("w:val"), "28"))

    # Ensure w:lang is set for bidi Arabic
    existing_lang = ref_rpr.find(qn("w:lang"))
    if existing_lang is not None:
        existing_lang.set(qn("w:bidi"), "ar-SA")
    else:
        lang = docx.oxml.OxmlElement("w:lang")
        lang.set(qn("w:val"), "en-US")
        lang.set(qn("w:eastAsia"), "en-US")
        lang.set(qn("w:bidi"), "ar-SA")
        ref_rpr.append(lang)


def copy_ppr_props(v13_style, ref_style):
    """Copy paragraph properties from v13.1 style to reference style.
    
    Ensures RTL alignment (right-justified) and copies spacing.
    """
    v13_ppr = get_ppr_from_style(v13_style)
    ref_ppr = ref_style.element.find(qn("w:pPr"))
    if ref_ppr is None:
        ref_ppr = docx.oxml.OxmlElement("w:pPr")
        ref_style.element.insert(0, ref_ppr)

    # Ensure right alignment for RTL
    existing_jc = ref_ppr.find(qn("w:jc"))
    if existing_jc is not None:
        existing_jc.set(qn("w:val"), "right")
    else:
        jc = docx.oxml.OxmlElement("w:jc")
        jc.set(qn("w:val"), "right")
        ref_ppr.append(jc)

    # Copy spacing from v13.1 style
    if v13_ppr is not None:
        v_spacing = v13_ppr.find("w:spacing", NSMAP)
        existing_spacing = ref_ppr.find(qn("w:spacing"))
        if v_spacing is not None:
            if existing_spacing is not None:
                for attr_name in ["w:line", "w:lineRule", "w:before", "w:after"]:
                    attr_val = v_spacing.get(qn(attr_name))
                    if attr_val is not None:
                        existing_spacing.set(qn(attr_name), attr_val)
            else:
                ref_ppr.append(copy.deepcopy(v_spacing))
        else:
            # v13 style has no spacing -- remove from reference so it inherits from Normal/docDefaults
            if existing_spacing is not None and ref_style.name != "Normal":
                ref_ppr.remove(existing_spacing)

        # Copy outlineLvl (important for headings)
        v_ol = v13_ppr.find("w:outlineLvl", NSMAP)
        existing_ol = ref_ppr.find(qn("w:outlineLvl"))
        if v_ol is not None:
            if existing_ol is not None:
                existing_ol.set(qn("w:val"), v_ol.get(qn("w:val"), "0"))
            else:
                ref_ppr.append(copy.deepcopy(v_ol))
        elif existing_ol is not None:
            pass
    else:
        # No pPr in v13 style -- remove spacing so it inherits from Normal/docDefaults
        existing_spacing = ref_ppr.find(qn("w:spacing"))
        if existing_spacing is not None:
            ref_ppr.remove(existing_spacing)


def copy_doc_defaults(v13_dde, doc):
    """Copy document defaults from v13.1 to the reference document."""
    if v13_dde is None:
        return

    styles_elem = doc.styles.element  # This is the <w:styles> root

    # Remove existing docDefaults
    existing_dd = styles_elem.find(qn("w:docDefaults"))
    if existing_dd is not None:
        styles_elem.remove(existing_dd)

    # Create new docDefaults based on v13.1
    new_dd = docx.oxml.OxmlElement("w:docDefaults")

    # rPrDefault
    rpr_default = docx.oxml.OxmlElement("w:rPrDefault")
    rpr = docx.oxml.OxmlElement("w:rPr")

    rFonts = docx.oxml.OxmlElement("w:rFonts")
    rFonts.set(qn("w:ascii"), "Traditional Arabic")
    rFonts.set(qn("w:hAnsi"), "Traditional Arabic")
    rFonts.set(qn("w:eastAsia"), "Traditional Arabic")
    rFonts.set(qn("w:cs"), "Traditional Arabic")
    rpr.append(rFonts)

    sz = docx.oxml.OxmlElement("w:sz")
    sz.set(qn("w:val"), "28")  # 14pt
    rpr.append(sz)

    szCs = docx.oxml.OxmlElement("w:szCs")
    szCs.set(qn("w:val"), "28")
    rpr.append(szCs)

    lang = docx.oxml.OxmlElement("w:lang")
    lang.set(qn("w:val"), "en-US")
    lang.set(qn("w:eastAsia"), "en-US")
    lang.set(qn("w:bidi"), "ar-SA")
    rpr.append(lang)

    rpr_default.append(rpr)
    new_dd.append(rpr_default)

    # pPrDefault
    ppr_default = docx.oxml.OxmlElement("w:pPrDefault")
    ppr = docx.oxml.OxmlElement("w:pPr")

    spacing = docx.oxml.OxmlElement("w:spacing")
    spacing.set(qn("w:line"), "360")  # 1.5 line spacing
    spacing.set(qn("w:lineRule"), "auto")
    ppr.append(spacing)

    jc = docx.oxml.OxmlElement("w:jc")
    jc.set(qn("w:val"), "right")
    ppr.append(jc)

    ppr_default.append(ppr)
    new_dd.append(ppr_default)

    # Insert at the beginning of styles (after any potential comments/processing)
    styles_elem.insert(0, new_dd)


def copy_section_props(v13_doc, doc):
    """Copy section properties from v13.1 to reference doc."""
    v13_body = v13_doc.find(".//w:body", NSMAP)
    v13_sectPr = v13_body.find("w:sectPr", NSMAP)
    if v13_sectPr is None:
        return

    v13_pgSz = v13_sectPr.find("w:pgSz", NSMAP)

    for section in doc.sections:
        section.top_margin = Emu(int(2275 * 914400 / 1440))  # twips to EMU
        section.bottom_margin = Emu(int(2275 * 914400 / 1440))
        section.left_margin = Emu(int(2275 * 914400 / 1440))
        section.right_margin = Emu(int(2275 * 914400 / 1440))

        # Set page size (A4: 11906 x 16838 twips)
        section.page_width  = Emu(int(11906 * 914400 / 1440))
        section.page_height = Emu(int(16838 * 914400 / 1440))


def copy_v13_style_to_ref(style_id, v13_styles_root, ref_doc, docDefaults_rpr):
    """Copy a single style from v13.1 to reference doc."""
    v13_style = get_v13_style(v13_styles_root, style_id)
    try:
        ref_style = ref_doc.styles[style_id]
    except KeyError:
        print(f"  [SKIP] Style '{style_id}' not found in reference doc")
        return False

    copy_rpr_props(v13_style, ref_style, docDefaults_rpr)
    copy_ppr_props(v13_style, ref_style)
    return True


def main():
    if not os.path.exists(V13_PATH):
        print(f"[ERROR] v13.1 not found: {V13_PATH}")
        sys.exit(1)
    if not os.path.exists(REF_IN):
        print(f"[ERROR] {REF_IN} not found. Run: pandoc -o '{REF_IN}' --print-default-data-file reference.docx")
        sys.exit(1)

    print("=" * 60)
    print("Academix v13.2 -- Reference Style Customizer")
    print("=" * 60)

    # 1. Load v13.1 styles
    print(f"\n[1] Loading v13.1 styles from: {V13_PATH}")
    v13_styles_root, v13_doc_root, v13_dde = load_v13_styles()
    docDefaults_rpr = None
    if v13_dde is not None:
        rpr_default = v13_dde.find("w:rPrDefault", NSMAP)
        if rpr_default is not None:
            docDefaults_rpr = rpr_default.find("w:rPr", NSMAP)
        print(f"    docDefaults: Traditional Arabic, 14pt, bidi=ar-SA")

    # 2. Open reference document
    print(f"\n[2] Opening reference: {REF_IN}")
    doc = docx.Document(REF_IN)

    # 3. Copy docDefaults
    print(f"\n[3] Copying document defaults...")
    copy_doc_defaults(v13_dde, doc)
    print(f"    Font: Traditional Arabic, Size: 14pt, LineSpacing: 1.5, RTL: right-aligned")

    # 4. Copy styles
    print(f"\n[4] Copying styles from v13.1...")
    style_mapping = {
        "Normal": "Normal",
        "Title": "Title",
        "Heading1": "Heading 1",
        "Heading2": "Heading 2",
        "Heading3": "Heading 3",
        "Heading4": "Heading 4",
        "Header": "Header",
        "Footer": "Footer",
        "FootnoteText": "Footnote Text",
        "Table": "Table",
        "Subtitle": "Subtitle",
    }

    styles_copied = 0
    for v13_sid, ref_sid in style_mapping.items():
        try:
            ref_style = doc.styles[ref_sid]
        except KeyError:
            print(f"  [SKIP] {ref_sid} not found in reference doc")
            continue

        v13_style = get_v13_style(v13_styles_root, v13_sid)
        if v13_style is None:
            print(f"  [INFO] {v13_sid} not in v13.1 -- applying defaults")
        else:
            print(f"  [COPY] {v13_sid} -> {ref_sid}")

        copy_rpr_props(v13_style, ref_style, docDefaults_rpr)
        copy_ppr_props(v13_style, ref_style)

        # Special handling for Title: center alignment
        if ref_sid == "Title":
            ref_ppr = ref_style.element.find(qn("w:pPr"))
            if ref_ppr is not None:
                existing_jc = ref_ppr.find(qn("w:jc"))
                if existing_jc is not None:
                    existing_jc.set(qn("w:val"), "center")

        # Special handling for Footer/Header: keep their tab stops but apply v13 spacing
        if ref_sid in ("Header", "Footer"):
            ref_ppr = ref_style.element.find(qn("w:pPr"))
            if ref_ppr is not None:
                existing_jc = ref_ppr.find(qn("w:jc"))
                if existing_jc is not None:
                    existing_jc.set(qn("w:val"), "left")

        # Special: remove hidden/unhide from Heading2-4 so they appear
        ref_style_elem = ref_style.element
        semi = ref_style_elem.find(qn("w:semiHidden"))
        if semi is not None:
            ref_style_elem.remove(semi)
        unhide = ref_style_elem.find(qn("w:unhideWhenUsed"))
        if unhide is not None:
            ref_style_elem.remove(unhide)

        styles_copied += 1

    print(f"\n[5] {styles_copied} styles processed")

    # 5. Copy section properties
    print(f"\n[6] Setting page margins from v13.1...")
    copy_section_props(v13_doc_root, doc)
    print(f"    Margins: Top=4cm, Bottom=4cm, Left=4cm, Right=4cm")

    # 6. Save
    print(f"\n[7] Saving to: {REF_OUT}")
    doc.save(REF_OUT)
    print(f"\n{'=' * 60}")
    print(f"[OK] Reference styled successfully!")
    print(f"     Font: Traditional Arabic 14pt (inherited from docDefaults)")
    print(f"     Margins: 4cm all sides")
    print(f"     Headings: v13.1 colors+sizes, RTL alignment")
    print(f"     Line Spacing: 1.5 (auto)")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
