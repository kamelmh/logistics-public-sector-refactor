"""fixers.styles — Style-level font, size, spacing, and RTL formatting."""

from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
from docx.shared import Pt
from .constants import GOLDEN, BODY_STYLES, FOOTNOTE_STYLES, HEADING_SIZES


def _set_spacing_pPr(pPr):
    """Set 1.5 line spacing (360 twips) on a pPr element."""
    existing = pPr.find(qn('w:spacing'))
    if existing is not None:
        existing.set(qn('w:line'), '360')
        existing.set(qn('w:lineRule'), 'auto')
    else:
        pPr.append(parse_xml('<w:spacing %s w:line="360" w:lineRule="auto"/>' % nsdecls('w')))


def _set_bidi_pPr(pPr):
    """Ensure <w:bidi w:val="1"/> and <w:jc w:val="right"/> in pPr."""
    bidi = pPr.find(qn('w:bidi'))
    if bidi is None:
        pPr.insert(0, parse_xml('<w:bidi %s w:val="1"/>' % nsdecls('w')))
    else:
        bidi.set(qn('w:val'), '1')
    jc = pPr.find(qn('w:jc'))
    if jc is None:
        pPr.append(parse_xml('<w:jc %s w:val="right"/>' % nsdecls('w')))
    else:
        jc.set(qn('w:val'), 'right')


def _get_or_create_pPr(elem):
    """Get or create a <w:pPr> element as first child of elem."""
    pPr = elem.find(qn('w:pPr'))
    if pPr is None:
        pPr = parse_xml('<w:pPr %s/>' % nsdecls('w'))
        elem.insert(0, pPr)
    return pPr


def _apply_style_formatting(style, font_name, font_size_pt, line_spacing=True, rtl=True):
    """Apply font/size/spacing/RTL to a python-docx style object."""
    style.font.name = font_name
    style.font.size = Pt(font_size_pt)
    pPr = _get_or_create_pPr(style.element)
    if line_spacing:
        _set_spacing_pPr(pPr)
    if rtl:
        _set_bidi_pPr(pPr)


def fix_styles(doc, changes):
    """Apply font/size/spacing/RTL to style definitions — NEVER individual runs."""
    # Body styles
    for sname in BODY_STYLES:
        try:
            s = doc.styles[sname]
            _apply_style_formatting(s, GOLDEN['bodyFont'], GOLDEN['bodySize'])
            changes['styles_updated'] += 1
        except KeyError:
            pass

    # Footnote styles
    for sname in FOOTNOTE_STYLES:
        try:
            s = doc.styles[sname]
            _apply_style_formatting(s, GOLDEN['bodyFont'], GOLDEN['footnoteSize'])
            changes['styles_updated'] += 1
        except KeyError:
            pass

    # Heading styles
    for sname, sz in HEADING_SIZES.items():
        try:
            s = doc.styles[sname]
            _apply_style_formatting(s, GOLDEN['bodyFont'], sz, line_spacing=False)
            s.font.bold = True
            changes['styles_updated'] += 1
        except KeyError:
            pass

    return changes
