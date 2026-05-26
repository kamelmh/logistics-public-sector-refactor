"""fix_thesis_all.py — Comprehensive thesis DOCX fixer
Part of Academix v13.2 build pipeline
Usage: python fix_thesis_all.py <path/to.docx> --save

Fixes applied:
1. Page numbering: Cover→none, Front→lowerRoman, Body→decimal
2. Table column widths: proportionally sized to content (no gaps)
3. Table borders: simple gridlines on all tables
4. Body formatting: Traditional Arabic 14pt, RTL, 1.5 spacing
5. Empty paragraph cleanup
6. Footnote RTL alignment

Run without --save for a dry-run report of changes needed.
"""

import sys, os, json, copy, zipfile
from xml.etree import ElementTree as ET
from docx import Document
from docx.shared import Cm, Pt, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml

NS = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
W = NS

GOLDEN = {
    'bodyFont': 'Traditional Arabic',
    'bodySize': 14,
    'heading1Size': 22,
    'heading2Size': 18,
    'heading3Size': 16,
    'marginsCm': 2.5,
    'lineSpacing': 1.5,
    'pageWidthCm': 21.0,
    'pageHeightCm': 29.7,
}


def emu_to_cm(emu):
    return round(emu / 914400 * 2.54, 2) if emu else 0


def fix_page_numbering(doc, changes):
    """Set proper page number format per section."""
    for i, sec in enumerate(doc.sections):
        sect_pr = sec._sectPr
        existing = sect_pr.find(qn('w:pgNumType'))
        if existing is not None:
            sect_pr.remove(existing)
        
        if i == 0:
            # Cover: no page number
            pg = parse_xml('<w:pgNumType %s w:fmt="none"/>' % nsdecls('w'))
            changes['page_num_cover'] = 'fmt=none'
        elif i == 1:
            # Front matter (TOC, abstract): Roman numerals
            pg = parse_xml('<w:pgNumType %s w:fmt="lowerRoman"/>' % nsdecls('w'))
            changes['page_num_front'] = 'fmt=lowerRoman'
        else:
            # Body + back matter: decimal
            pg = parse_xml('<w:pgNumType %s w:fmt="decimal"/>' % nsdecls('w'))
            changes['page_num_body'] = 'fmt=decimal'
        
        # Insert at the beginning of sectPr
        first = sect_pr.find(qn('w:type'))
        if first is not None:
            sect_pr.insert(list(sect_pr).index(first) + 1, pg)
        else:
            sect_pr.insert(0, pg)
    
    return changes


def fix_table_column_widths(doc, changes):
    """Set proportional column widths based on content to eliminate gaps."""
    avail_width = (GOLDEN['pageWidthCm'] - 2 * GOLDEN['marginsCm']) * 914400 / 2.54  # Total available in EMU
    
    for ti, t in enumerate(doc.tables):
        cols = len(t.columns)
        if cols == 0:
            continue
        
        # Calculate content-based proportional widths
        max_chars = []
        for ci in range(cols):
            mc = 0
            for row in t.rows:
                if ci < len(row.cells):
                    text = row.cells[ci].text.strip()
                    # Estimate visual width: Arabic chars are wider
                    arabic_count = sum(1 for c in text if '\u0600' <= c <= '\u06ff' or '\ufe80' <= c <= '\ufeff')
                    latin_count = len(text) - arabic_count
                    est_width = arabic_count * 0.9 + latin_count * 0.55
                    mc = max(mc, est_width)
            max_chars.append(max(1, mc))
        
        total_chars = sum(max_chars)
        if total_chars == 0:
            continue
        
        # Calculate EMU widths: proportionally fit available width
        # Reserve a bit for padding
        padding = 150000  # ~4mm per column padding
        usable = avail_width - (cols * padding)
        
        col_widths = []
        for mc in max_chars:
            w = int(usable * mc / total_chars)
            col_widths.append(max(w, 500000))  # Minimum 500K EMU (~0.7cm)
        
        # Normalize to available width
        total = sum(col_widths)
        if total > 0:
            col_widths = [int(w * usable / total) for w in col_widths]
        
        # Apply widths to all rows
        for row in t.rows:
            for ci in range(min(cols, len(row.cells))):
                cell = row.cells[ci]
                tc = cell._tc
                tcPr = tc.find(qn('w:tcPr'))
                if tcPr is None:
                    tcPr = ET.SubElement(tc, qn('w:tcPr'))
                    # Move to front
                    tc.remove(tcPr)
                    tc.insert(0, tcPr)
                
                # Set width (use oxml to avoid lxml/etree mismatch)
                tcW = tcPr.find(qn('w:tcW'))
                if tcW is None:
                    tcW = parse_xml('<w:tcW %s w:w="%d" w:type="dxa"/>' % (nsdecls('w'), col_widths[ci]))
                    tcPr.append(tcW)
                else:
                    tcW.set(qn('w:w'), str(col_widths[ci]))
                    tcW.set(qn('w:type'), 'dxa')
        
        changes['table_widths_set'].append(ti)
    
    return changes


def add_table_borders(doc, changes):
    """Add simple gridlines to all tables."""
    # Simple thin border XML
    border_attrs = {
        'w:val': 'single',
        'w:sz': '4',      # 0.5pt
        'w:space': '0',
        'w:color': '000000',
    }
    
    border_xml = (
        '<w:tblBorders %s>'
        '  <w:top %s/>'
        '  <w:left %s/>'
        '  <w:bottom %s/>'
        '  <w:right %s/>'
        '  <w:insideH %s/>'
        '  <w:insideV %s/>'
        '</w:tblBorders>' % (
            nsdecls('w'),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
            ' '.join('%s="%s"' % (k, v) for k, v in border_attrs.items()),
        )
    )
    
    for ti, t in enumerate(doc.tables):
        tbl = t._tbl
        tblPr = tbl.find(qn('w:tblPr'))
        if tblPr is None:
            tblPr = ET.SubElement(tbl, qn('w:tblPr'))
            tbl.insert(0, tblPr)
        
        existing = tblPr.find(qn('w:tblBorders'))
        if existing is not None:
            tblPr.remove(existing)
        
        borders = parse_xml(border_xml)
        tblPr.append(borders)
        changes['table_borders_added'].append(ti)
    
    return changes


def fix_body_formatting(doc, changes):
    """Fix body text: Traditional Arabic 14pt, RTL, 1.5 spacing."""
    SKIP_STYLES = {'Heading 1', 'Heading 2', 'Heading 3', 'Heading 4', 'Heading 5',
                   'Titre 1', 'Titre 2', 'Titre 3',
                   'toc 1', 'toc 2', 'toc 3', 'TOC',
                   'Header', 'Footer', 'Footnote Text', 'Footnote Reference',
                   'Endnote Text', 'Endnote Reference'}
    
    for i, p in enumerate(doc.paragraphs):
        sname = p.style.name if p.style else ''
        if sname in SKIP_STYLES:
            continue
        if any(k in sname for k in ('Header', 'Footer', 'Footnote', 'Endnote', 'toc')):
            continue
        if not p.text.strip():
            continue
        
        # Font name and size on runs
        for r in p.runs:
            if r.font.name != GOLDEN['bodyFont']:
                r.font.name = GOLDEN['bodyFont']
                changes['font_fixes'] += 1
            if r.font.size is None or abs(r.font.size.pt - GOLDEN['bodySize']) >= 0.5:
                r.font.size = Pt(GOLDEN['bodySize'])
                changes['size_fixes'] += 1
        
        # RTL alignment
        if p.alignment != WD_ALIGN_PARAGRAPH.RIGHT:
            p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            changes['rtl_fixes'] += 1
        
        # Line spacing
        if p.paragraph_format.line_spacing != GOLDEN['lineSpacing']:
            p.paragraph_format.line_spacing = GOLDEN['lineSpacing']
            changes['spacing_fixes'] += 1
    
    return changes


def fix_headings(doc, changes):
    """Fix heading sizes."""
    HEADING_MAP = {
        'Heading 1': 22, 'Titre 1': 22,
        'Heading 2': 18, 'Titre 2': 18,
        'Heading 3': 16, 'Titre 3': 16,
    }
    
    for p in doc.paragraphs:
        sname = p.style.name if p.style else ''
        if sname in HEADING_MAP:
            target = HEADING_MAP[sname]
            for r in p.runs:
                if r.font.size is None or abs(r.font.size.pt - target) >= 0.5:
                    r.font.size = Pt(target)
                    r.font.bold = True
                    changes['heading_fixes'] += 1
    
    return changes


def fix_footnotes_rtl(docx_path, changes):
    """Fix footnote RTL alignment via XML manipulation."""
    fn_file = 'word/footnotes.xml'
    modified = False
    
    with zipfile.ZipFile(docx_path, 'r') as z:
        if fn_file not in z.namelist():
            return changes
        
        tree = ET.parse(z.open(fn_file))
        root = tree.getroot()
    
    fn_ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    w_uri = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
    for fn in root.findall('.//w:footnote', fn_ns):
        fid = fn.attrib.get(w_uri + 'id', '')
        if fid in ('0', '-1'):
            continue
        for p in fn.findall('.//w:p', fn_ns):
            pPr = p.find(w_uri + 'pPr')
            if pPr is None:
                pPr = ET.SubElement(p, w_uri + 'pPr')
                p.remove(pPr)
                p.insert(0, pPr)
            jc = pPr.find(w_uri + 'jc')
            if jc is not None:
                val = jc.attrib.get(w_uri + 'val', '')
                if val != 'right':
                    jc.attrib[w_uri + 'val'] = 'right'
                    modified = True
                    changes['footnote_rtl_fixes'] += 1
            else:
                jc = ET.SubElement(pPr, w_uri + 'jc')
                jc.attrib[w_uri + 'val'] = 'right'
                modified = True
                changes['footnote_rtl_fixes'] += 1
    
    if modified:
        raw = ET.tostring(root, encoding='unicode')
        # Preserve XML declaration required by OOXML (Word rejects missing declaration)
        XML_DECL = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        if not raw.startswith('<?xml'):
            raw = XML_DECL + raw
        tmp = docx_path + '.tmp'
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.namelist():
                    if item == fn_file:
                        zout.writestr(item, raw)
                    else:
                        zout.writestr(item, zin.read(item))
        os.replace(tmp, docx_path)
    
    return changes


def clean_empty_paragraphs(doc, changes):
    """Remove consecutive empty paragraphs (keep single spacer)."""
    empty_indices = []
    for i, p in enumerate(doc.paragraphs):
        if not p.text.strip():
            empty_indices.append(i)
    
    # Mark consecutive empties (skip first in each group)
    to_remove = []
    for idx in empty_indices:
        if idx + 1 in empty_indices:
            to_remove.append(idx)
    
    # Remove in reverse
    for idx in reversed(to_remove):
        p_elem = doc.paragraphs[idx]._element
        p_elem.getparent().remove(p_elem)
        changes['empty_paras_removed'] += 1
    
    return changes


def fix_table_cell_padding(doc, changes):
    """Set consistent cell margins (reduce padding/gaps)."""
    for t in doc.tables:
        tbl = t._tbl
        tblPr = tbl.find(qn('w:tblPr'))
        if tblPr is None:
            tblPr = parse_xml('<w:tblPr %s/>' % nsdecls('w'))
            tbl.insert(0, tblPr)
        
        # Set default cell margin
        cell_mar_xml = (
            '<w:tblCellMar %s>'
            '  <w:top w:w="40" w:type="dxa"/>'
            '  <w:bottom w:w="40" w:type="dxa"/>'
            '  <w:left w:w="60" w:type="dxa"/>'
            '  <w:right w:w="60" w:type="dxa"/>'
            '</w:tblCellMar>' % nsdecls('w')
        )
        existing = tblPr.find(qn('w:tblCellMar'))
        if existing is not None:
            tblPr.remove(existing)
        cell_mar = parse_xml(cell_mar_xml)
        tblPr.append(cell_mar)
    
    changes['table_cell_margins_set'] = True
    return changes


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_thesis_all.py <path/to.docx> [--save]", file=sys.stderr)
        sys.exit(1)
    
    path = sys.argv[1]
    save = '--save' in sys.argv
    
    if not os.path.exists(path):
        print("[ERROR] File not found: %s" % path, file=sys.stderr)
        sys.exit(1)
    
    changes = {
        'page_num_cover': 'unchanged',
        'page_num_front': 'unchanged',
        'page_num_body': 'unchanged',
        'font_fixes': 0,
        'size_fixes': 0,
        'rtl_fixes': 0,
        'spacing_fixes': 0,
        'heading_fixes': 0,
        'table_widths_set': [],
        'table_borders_added': [],
        'table_cell_margins_set': False,
        'footnote_rtl_fixes': 0,
        'empty_paras_removed': 0,
    }
    
    print("=" * 60)
    print("ACADEMIX — Comprehensive Thesis Fixer")
    print("=" * 60)
    print("File: %s" % path)
    print("Mode: %s" % ('SAVE (modifying file)' if save else 'DRY RUN'))
    print()
    
    # 1. Fix page numbering
    print("[1/7] Page numbering...")
    doc = Document(path)
    changes = fix_page_numbering(doc, changes)
    print("  Cover: %s | Front: %s | Body: %s" % (
        changes['page_num_cover'], changes['page_num_front'], changes['page_num_body']))
    
    # 2. Fix table column widths
    print("[2/7] Table column widths (minimizing gaps)...")
    changes = fix_table_column_widths(doc, changes)
    print("  %d tables sized" % len(changes['table_widths_set']))
    
    # 3. Add table borders
    print("[3/7] Adding table borders (gridlines)...")
    changes = add_table_borders(doc, changes)
    print("  %d tables got borders" % len(changes['table_borders_added']))
    
    # 4. Fix table cell padding
    print("[4/7] Setting compact cell margins...")
    changes = fix_table_cell_padding(doc, changes)
    
    # 5. Fix body formatting
    print("[5/7] Body formatting (font=%s %dpt, RTL, 1.5 spacing)..." % (
        GOLDEN['bodyFont'], GOLDEN['bodySize']))
    changes = fix_body_formatting(doc, changes)
    changes = fix_headings(doc, changes)
    print("  Font: %d | Size: %d | RTL: %d | Spacing: %d | Headings: %d" % (
        changes['font_fixes'], changes['size_fixes'], changes['rtl_fixes'],
        changes['spacing_fixes'], changes['heading_fixes']))
    
    # 6. Clean empty paragraphs (consecutive)
    print("[6/7] Cleaning consecutive empty paragraphs...")
    changes = clean_empty_paragraphs(doc, changes)
    print("  Removed: %d" % changes['empty_paras_removed'])
    
    # Save doc-level changes
    if save:
        doc.save(path)
        print("  [Saved doc-level changes]")
    
    # 7. Fix footnotes RTL (needs zip-level manipulation)
    print("[7/7] Footnote RTL alignment...")
    if save:
        changes = fix_footnotes_rtl(path, changes)
    print("  Footnotes RTL fixes: %d" % changes['footnote_rtl_fixes'])
    
    print()
    print("=" * 60)
    print("FIX SUMMARY")
    print("=" * 60)
    for k, v in changes.items():
        print("  %s: %s" % (k, v))
    print()
    print("Mode: %s" % ('SAVED' if save else 'DRY RUN (use --save to apply)'))
    
    if not save:
        print("\nTo apply: python fix_thesis_all.py \"%s\" --save" % path)
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
