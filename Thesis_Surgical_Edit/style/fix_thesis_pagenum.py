#!/usr/bin/env python3
"""fix_thesis_pagenum.py — Complete thesis page numbering fix.

Creates proper SDT-wrapped PAGE fields in footers and sets correct
pgNumType on each section.

Section layout:
  Sect 0 (cover):     no page number (pgNumType fmt=none)
  Sect 1 (front):     Roman numerals (pgNumType fmt=lowerRoman, start=1)
  Sect 2 (body):      Decimal (pgNumType fmt=decimal, start=1)
  Sect 3 (annexes):   Decimal (pgNumType fmt=decimal, continuing)

Usage: python fix_thesis_pagenum.py <path/to.docx> [--save]
"""
import sys, os, re, shutil, zipfile
from xml.etree import ElementTree as ET

NS = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W = '{%s}' % NS

# Proper SDT-wrapped PAGE field (what Word creates via Insert > Page Number)
SDT_PAGE_FIELD = (
    '<w:sdt xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:sdtPr>'
    '<w:docPartObj>'
    '<w:docPartGallery w:val="Page Numbers (Bottom of Page)"/>'
    '<w:docPartUnique/>'
    '</w:docPartObj>'
    '</w:sdtPr>'
    '<w:sdtContent>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="begin"/>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:instrText xml:space="preserve"> PAGE </w:instrText>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="separate"/>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:t>1</w:t>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="end"/>'
    '</w:r>'
    '</w:sdtContent>'
    '</w:sdt>'
)

# Proper SDT-wrapped PAGE field with阿拉伯语字体 (Traditional Arabic)
SDT_PAGE_FIELD_AR = (
    '<w:sdt xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:sdtPr>'
    '<w:docPartObj>'
    '<w:docPartGallery w:val="Page Numbers (Bottom of Page)"/>'
    '<w:docPartUnique/>'
    '</w:docPartObj>'
    '</w:sdtPr>'
    '<w:sdtContent>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="begin"/>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:instrText xml:space="preserve"> PAGE </w:instrText>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="separate"/>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:t>1</w:t>'
    '</w:r>'
    '<w:r>'
    '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
    '<w:fldChar w:fldCharType="end"/>'
    '</w:r>'
    '</w:sdtContent>'
    '</w:sdt>'
)


def make_footer2_content():
    """Create a proper footer2.xml with SDT-wrapped PAGE field, right-aligned."""
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:ftr xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" '
        'xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex" '
        'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
        'xmlns:o="urn:schemas-microsoft-com:office:office" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" '
        'xmlns:v="urn:schemas-microsoft-com:vml" '
        'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
        'xmlns:w10="urn:schemas-microsoft-com:office:word" '
        'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
        'xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" '
        'xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid" '
        'xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" '
        'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" '
        'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" '
        'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" '
        'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" '
        'mc:Ignorable="w14 w15 w16se w16cid wp14">'
        '<w:p>'
        '<w:pPr><w:jc w:val="center"/></w:pPr>'
        + SDT_PAGE_FIELD_AR +
        '</w:p>'
        '</w:ftr>'
    )


def fix_footer2(path, entries):
    """Replace footer2.xml with proper SDT-wrapped PAGE field."""
    new_content = make_footer2_content()
    entries['word/footer2.xml'] = new_content.encode('utf-8')
    return entries, True


def fix_footer13(path, entries):
    """Remove any PAGE fields from footer1.xml and footer3.xml (they should be empty)."""
    changed = False
    for fname in ['word/footer1.xml', 'word/footer3.xml']:
        if fname in entries:
            content = entries[fname].decode('utf-8')
            if 'PAGE' in content or '<w:sdt>' in content:
                # Replace with empty footer
                empty = (
                    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                    '<w:ftr xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" '
                    'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
                    'xmlns:o="urn:schemas-microsoft-com:office:office" '
                    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
                    'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" '
                    'xmlns:v="urn:schemas-microsoft-com:vml" '
                    'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
                    'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
                    'xmlns:w10="urn:schemas-microsoft-com:office:word" '
                    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
                    'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
                    'xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" '
                    'xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid" '
                    'xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" '
                    'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" '
                    'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" '
                    'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" '
                    'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" '
                    'mc:Ignorable="w14 w15 w16se w16cid wp14">'
                    '<w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p>'
                    '</w:ftr>'
                )
                entries[fname] = empty.encode('utf-8')
                changed = True
    return entries, changed


def fix_document_xml(content):
    """Fix section properties and ensure all sections reference footer2.xml.
    
    - Sect 0: pgNumType fmt=none, footer=default -> footer2
    - Sect 1: pgNumType fmt=lowerRoman start=1, footer=default -> footer2
    - Sect 2: pgNumType fmt=decimal start=1, footer=default -> footer2
    - Sect 3: pgNumType fmt=decimal, footer=default -> footer2
    """
    # Find which rId maps to footer2.xml
    # We need to check _rels/document.xml.rels, but since we're working
    # on content, we find it from existing references
    footer2_rid = None
    ref_pattern = re.compile(r'<w:footerReference\s+w:type="(\w+)"\s+r:id="(rId\d+)"/>')
    all_refs = ref_pattern.findall(content)
    for ftype, rid in all_refs:
        if ftype == 'default':
            footer2_rid = rid
            break
    if not footer2_rid and all_refs:
        footer2_rid = all_refs[0][1]
    
    if not footer2_rid:
        print("  [ERROR] No footer references found")
        return content, 0
    
    print(f"  footer2.xml rId: {footer2_rid}")
    
    # Desired pgNumType per section
    # User wants: no numbers on cover, decimal starting at 4 on TOC page
    desired_pgn = [
        'none',    # Sect 0: cover (no page number shown)
        'decimal', # Sect 1: TOC onwards (starts at 4)
        'decimal', # Sect 2: body (continues from sect 1)
        'decimal', # Sect 3: annexes (continues)
    ]
    desired_start = [None, 4, None, None]  # None = no start (continues from prev)
    
    sect_pattern = re.compile(r'(<w:sectPr[^>]*>)(.*?)(</w:sectPr>)', re.DOTALL)
    fixes = 0
    sect_idx = [0]
    
    def fix_sect(m):
        nonlocal fixes
        attrs = m.group(1)
        body = m.group(2)
        close = m.group(3)
        idx = sect_idx[0]
        sect_idx[0] += 1
        
        if idx >= len(desired_pgn):
            return m.group(0)
        
        # Remove existing pgNumType
        body = re.sub(r'<w:pgNumType[^/]*/>', '', body)
        
        # Remove existing footer references
        body = re.sub(r'<w:footerReference\s+[^/]*/>', '', body)
        
        # Add correct pgNumType
        fmt = desired_pgn[idx]
        start = desired_start[idx]
        if fmt == 'none':
            pgn = '<w:pgNumType w:fmt="none"/>'
        elif start is not None:
            pgn = f'<w:pgNumType w:fmt="{fmt}" w:start="{start}"/>'
        else:
            pgn = f'<w:pgNumType w:fmt="{fmt}"/>'
        
        # Insert footer reference and pgNumType as FIRST children of sectPr
        # (must be direct children, NOT inside footnotePr or other sub-elements)
        footer_ref = f'<w:footerReference w:type="default" r:id="{footer2_rid}"/>'
        body = footer_ref + pgn + body
        
        fixes += 1
        return attrs + body + close
    
    content = sect_pattern.sub(fix_sect, content)
    return content, fixes


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_thesis_pagenum.py <path/to.docx> [--save]")
        sys.exit(1)
    
    path = sys.argv[1]
    save = '--save' in sys.argv
    
    print("=" * 60)
    print("Thesis Page Number Fix — SDT-wrapped PAGE field")
    print("=" * 60)
    print(f"File: {path}")
    print(f"Mode: {'SAVE' if save else 'DRY RUN'}")
    print()
    
    if not os.path.exists(path):
        print(f"ERROR: File not found: {path}")
        sys.exit(1)
    
    backup = path.replace('.docx', '_pre_pagenum.docx')
    
    # Read all entries
    entries = {}
    with zipfile.ZipFile(path, 'r') as z:
        for name in z.namelist():
            entries[name] = z.read(name)
    
    # Fix footer2.xml
    print("[1/3] Replacing footer2.xml with SDT-wrapped PAGE field...")
    entries, f2_changed = fix_footer2(path, entries)
    print(f"  footer2.xml: {'REPLACED' if f2_changed else 'unchanged'}")
    
    # Fix footer1.xml and footer3.xml
    print("[2/3] Cleaning footer1.xml and footer3.xml...")
    entries, f13_changed = fix_footer13(path, entries)
    print(f"  footer1/3: {'CLEANED' if f13_changed else 'unchanged'}")
    
    # Fix document.xml section properties
    print("[3/3] Fixing section pgNumType and footer references...")
    doc_content = entries['word/document.xml'].decode('utf-8')
    doc_fixed, sect_fixes = fix_document_xml(doc_content)
    entries['word/document.xml'] = doc_fixed.encode('utf-8')
    print(f"  Fixed {sect_fixes} section(s)")
    
    if save:
        shutil.copy2(path, backup)
        print(f"\nBackup: {backup}")
        
        tmp = path + '.tmp'
        with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
            for name, data in entries.items():
                zout.writestr(name, data)
        os.replace(tmp, path)
        size = os.path.getsize(path)
        print(f"Saved: {path} ({size} bytes)")
    
    # Verify
    print("\n=== VERIFICATION ===")
    with zipfile.ZipFile(path, 'r') as z:
        # Check footer2.xml
        f2 = z.read('word/footer2.xml').decode('utf-8')
        has_sdt = '<w:sdt>' in f2
        has_page = 'PAGE' in f2
        has_mergeformat = 'MERGEFORMAT' in f2 or 'xml:space' in f2
        print(f"  footer2.xml: SDT={has_sdt} PAGE={has_page} proper_instrText={has_mergeformat}")
        
        # Check sections
        doc = z.read('word/document.xml').decode('utf-8')
        sects = re.findall(r'<w:sectPr[^>]*>.*?</w:sectPr>', doc, re.DOTALL)
        for i, s in enumerate(sects):
            pgn_m = re.search(r'<w:pgNumType[^/]*/>', s)
            pgn = pgn_m.group() if pgn_m else "NONE"
            fmt_m = re.search(r'w:fmt="([^"]+)"', pgn)
            start_m = re.search(r'w:start="([^"]+)"', pgn)
            fmt = fmt_m.group(1) if fmt_m else "-"
            start = start_m.group(1) if start_m else "-"
            footer_refs = re.findall(r'<w:footerReference[^/]*/>', s)
            print(f"  Sect {i}: fmt={fmt} start={start} footers={len(footer_refs)}")
        
        # Check footer1/3 are clean
        for fname in ['word/footer1.xml', 'word/footer3.xml']:
            if fname in z.namelist():
                content = z.read(fname).decode('utf-8')
                has_page = 'PAGE' in content
                print(f"  {fname}: PAGE={has_page}")


if __name__ == '__main__':
    main()
