import docx
from docx.shared import Pt, Cm, Inches, Emu
from docx.oxml.ns import qn
import os

V13_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Final_Delivery_Layout\01_Memoire_Final\Memoire_Academix_v13_1_Final.docx"
REF_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\reference.docx"
OUT_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\style-comparison.txt"

STYLE_NAMES = ["Normal", "Title", "Subtitle", "Heading 1", "Heading 2", "Heading 3", "Heading 4",
               "Table", "Footer", "Header", "Footnote Text"]


def get_rpr_fonts(rpr):
    if rpr is None:
        return {}
    rFonts = rpr.find(qn("w:rFonts"))
    if rFonts is None:
        return {}
    return {
        "ascii": rFonts.get(qn("w:ascii"), ""),
        "hAnsi": rFonts.get(qn("w:hAnsi"), ""),
        "eastAsia": rFonts.get(qn("w:eastAsia"), ""),
        "cs": rFonts.get(qn("w:cs"), ""),
    }


def get_bidi(rpr):
    if rpr is None:
        return False
    bidi = rpr.find(qn("w:bidi"))
    return bidi is not None


def get_alignment(pf):
    if pf is None or pf.alignment is None:
        return "N/A"
    m = {
        0: "LEFT",
        1: "CENTER",
        2: "RIGHT",
        3: "BOTH",
        4: "MEDIUMKASHIDA",
        5: "DISTRIBUTE",
        6: "NUMTAB",
        7: "HIGHLOWKASHIDA",
        8: "LOWKASHIDA",
        9: "THAIDISTRIBUTE",
    }
    return m.get(pf.alignment, str(pf.alignment))


def get_line_spacing(pf):
    if pf is None:
        return "N/A"
    ls = pf.line_spacing
    lsr = pf.line_spacing_rule
    if ls is None and lsr is None:
        return "N/A"
    if lsr is not None:
        return f"{lsr} ({ls})"
    return str(ls)


def extract_style_info(doc, label):
    info = {}
    for sn in STYLE_NAMES:
        if sn not in doc.styles:
            info[sn] = None
            continue
        sty = doc.styles[sn]
        si = {}
        si["name"] = sty.name
        si["type"] = str(sty.type) if sty.type else "N/A"
        si["font_name"] = sty.font.name
        si["font_size"] = str(int(sty.font.size.pt)) if sty.font.size and sty.font.size.pt else "N/A"
        si["bold"] = str(sty.font.bold) if sty.font.bold is not None else "N/A"
        si["italic"] = str(sty.font.italic) if sty.font.italic is not None else "N/A"
        if sty.font.color and sty.font.color.rgb:
            si["color"] = str(sty.font.color.rgb)
        elif sty.font.color and sty.font.color.theme_color:
            si["color"] = f"theme:{sty.font.color.theme_color}"
        else:
            si["color"] = "N/A"

        rpr = sty.element.find(qn("w:rPr"))
        si["rfonts"] = get_rpr_fonts(rpr)
        si["bidi"] = get_bidi(rpr)

        pf = sty.paragraph_format
        si["alignment"] = get_alignment(pf)
        si["space_before"] = str(int(pf.space_before.pt)) if pf.space_before and pf.space_before.pt else "0"
        si["space_after"] = str(int(pf.space_after.pt)) if pf.space_after and pf.space_after.pt else "0"
        si["line_spacing"] = get_line_spacing(pf)
        si["first_line_indent"] = str(int(pf.first_line_indent.pt)) if pf.first_line_indent and pf.first_line_indent.pt else "0"

        info[sn] = si
    return info


def extract_section_info(doc):
    sections_info = []
    for i, section in enumerate(doc.sections):
        si = {}
        si["page_width"] = str(int(section.page_width.pt)) if section.page_width else "N/A"
        si["page_height"] = str(int(section.page_height.pt)) if section.page_height else "N/A"
        si["top_margin"] = str(int(section.top_margin.pt)) if section.top_margin else "N/A"
        si["bottom_margin"] = str(int(section.bottom_margin.pt)) if section.bottom_margin else "N/A"
        si["left_margin"] = str(int(section.left_margin.pt)) if section.left_margin else "N/A"
        si["right_margin"] = str(int(section.right_margin.pt)) if section.right_margin else "N/A"
        si["orientation"] = str(section.orientation) if section.orientation else "N/A"
        sections_info.append(si)
    return sections_info


def fmt_val(v):
    if v is None or v == "N/A" or v == "":
        return "N/A"
    return v


def val_str(si, key):
    if si is None:
        return "---"
    return fmt_val(si.get(key, "N/A"))


def bool_diff(a, b):
    a = fmt_val(val_str_from_si(a)) if a is not None else "---"
    b = fmt_val(val_str_from_si(b)) if b is not None else "---"
    return a, b


def val_str_from_si(si):
    return "|"  # placeholder


def main():
    print(f"Opening v13.1: {V13_PATH}")
    v13 = docx.Document(V13_PATH)
    print(f"Opening reference: {REF_PATH}")
    ref = docx.Document(REF_PATH)

    v13_styles = extract_style_info(v13, "v13.1")
    ref_styles = extract_style_info(ref, "reference")

    v13_sec = extract_section_info(v13)
    ref_sec = extract_section_info(ref)

    lines = []
    lines.append("=" * 140)
    lines.append("STYLE COMPARISON: v13.1 Memoire vs reference.docx")
    lines.append("=" * 140)
    lines.append("")

    for sn in STYLE_NAMES:
        v = v13_styles[sn]
        r = ref_styles[sn]
        lines.append("-" * 140)
        lines.append(f"STYLE: {sn}")
        lines.append("-" * 140)

        if v is None and r is None:
            lines.append("  Not found in either document.")
            lines.append("")
            continue

        hdr = f"{'Attribute':<25} {'v13.1':<45} {'Reference':<45} {'Match':<10}"
        lines.append(hdr)
        lines.append("-" * 140)

        attrs = [
            ("Font Name", "font_name"),
            ("Font Size", "font_size"),
            ("Bold", "bold"),
            ("Italic", "italic"),
            ("Color", "color"),
            ("Alignment", "alignment"),
            ("Space Before", "space_before"),
            ("Space After", "space_after"),
            ("Line Spacing", "line_spacing"),
            ("First Line Indent", "first_line_indent"),
        ]

        for aname, akey in attrs:
            vv = val_str(v, akey) if v else "---"
            rr = val_str(r, akey) if r else "---"
            match = "YES" if vv == rr else "DIFF"
            lines.append(f"{aname:<25} {vv:<45} {rr:<45} {match:<10}")

        lines.append("")
        lines.append("  --- rFonts / Bidi ---")
        if v:
            vrf = val_str(v, "rfonts")
            vb = str(v.get("bidi", False))
            lines.append(f"  v13.1   rFonts: {v.get('rfonts', {})}")
            lines.append(f"  v13.1   Bidi:   {v.get('bidi', False)}")
            lines.append(f"  v13.1   Type:   {v.get('type', 'N/A')}")
        if r:
            lines.append(f"  Ref     rFonts: {r.get('rfonts', {})}")
            lines.append(f"  Ref     Bidi:   {r.get('bidi', False)}")
            lines.append(f"  Ref     Type:   {r.get('type', 'N/A')}")
        lines.append("")

    lines.append("=" * 140)
    lines.append("SECTION / PAGE SETUP")
    lines.append("=" * 140)
    lines.append("")

    max_sec = max(len(v13_sec), len(ref_sec))
    for i in range(max_sec):
        vs = v13_sec[i] if i < len(v13_sec) else {}
        rs = ref_sec[i] if i < len(ref_sec) else {}
        lines.append(f"--- Section {i+1} ---")
        sec_attrs = [
            ("Page Width", "page_width"),
            ("Page Height", "page_height"),
            ("Top Margin", "top_margin"),
            ("Bottom Margin", "bottom_margin"),
            ("Left Margin", "left_margin"),
            ("Right Margin", "right_margin"),
            ("Orientation", "orientation"),
        ]
        hdr = f"{'Attribute':<25} {'v13.1':<20} {'Reference':<20} {'Match':<10}"
        lines.append(hdr)
        lines.append("-" * 80)
        for aname, akey in sec_attrs:
            vv = fmt_val(vs.get(akey, "N/A")) if vs else "---"
            rr = fmt_val(rs.get(akey, "N/A")) if rs else "---"
            match = "YES" if vv == rr else "DIFF"
            lines.append(f"{aname:<25} {vv:<20} {rr:<20} {match:<10}")
        lines.append("")

    lines.append("=" * 140)
    lines.append("SUMMARY OF DIFFERENCES")
    lines.append("=" * 140)
    lines.append("")

    diff_count = 0
    for sn in STYLE_NAMES:
        v = v13_styles[sn]
        r = ref_styles[sn]
        if v is None and r is None:
            continue
        attrs = ["font_name", "font_size", "bold", "italic", "color",
                 "alignment", "space_before", "space_after", "line_spacing", "first_line_indent"]
        for akey in attrs:
            vv = val_str(v, akey) if v else "---"
            rr = val_str(r, akey) if r else "---"
            if vv != rr:
                diff_count += 1
                lines.append(f"  [{sn}] {akey}: v13.1='{vv}' vs ref='{rr}'")

    if diff_count == 0:
        lines.append("  No differences found — styles match exactly!")
    else:
        lines.append(f"  Total differences: {diff_count}")

    lines.append("")
    lines.append(f"Output written to: {OUT_PATH}")

    out = "\n".join(lines)
    print(out)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(out)

    print(f"\n\nComparison saved to {OUT_PATH}")
    return diff_count


if __name__ == "__main__":
    main()
