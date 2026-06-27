#!/usr/bin/env python3
"""Check section structure, page settings, and number format."""
from docx import Document
from docx.oxml.ns import qn

DOCX_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"

doc = Document(DOCX_PATH)
body = doc.element.body

# Count section-level sectPr
sect_count = 0
for child in body:
    if child.tag == qn('w:p'):
        pPr = child.find(qn('w:pPr'))
        if pPr is not None:
            sectPr = pPr.find(qn('w:sectPr'))
            if sectPr is not None:
                sect_count += 1
                for ch in sectPr:
                    if ch.tag == qn('w:type'):
                        print(f"  Body section break type: {ch.get(qn('w:val'))}")
                    if ch.tag == qn('w:titlePg'):
                        print(f"  titlePg found in body sectPr")

# Document-level sectPr
doc_sectPr = body.find(qn('w:sectPr'))
if doc_sectPr is not None:
    print("Document-level sectPr found:")
    for ch in doc_sectPr:
        tag = ch.tag.split('}')[-1] if '}' in ch.tag else ch.tag
        if tag == 'titlePg':
            print("  titlePg: YES (different first page)")
        elif tag == 'type':
            val = ch.get(qn('w:val'))
            print(f"  type: {val}")
        elif tag == 'pgSz':
            w = int(ch.get(qn('w:w'), 0))
            h = int(ch.get(qn('w:h'), 0))
            print(f"  page size: {w/567:.1f}x{h/567:.1f} cm")
        elif tag == 'pgMar':
            t = int(ch.get(qn('w:top'), 0))
            b = int(ch.get(qn('w:bottom'), 0))
            l = int(ch.get(qn('w:left'), 0))
            r = int(ch.get(qn('w:right'), 0))
            print(f"  margins: T={t/567:.1f} B={b/567:.1f} L={l/567:.1f} R={r/567:.1f} cm")

print(f"Body section breaks: {sect_count}")
print(f"Total sections: {len(doc.sections)}")

# Check number format for page numbering
print("\n=== Numbering XML ===")
from lxml import etree
W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
nsmap = {'w': W_NS}

# Check footer for number format
for part in doc.part.package.iter_parts():
    if hasattr(part, 'blob') and part.partname and 'footer' in str(part.partname):
        blob = part.blob.decode("utf-8", errors="replace")
        if 'PAGE' in blob:
            print(f"\nFooter with PAGE field ({part.partname}):")
            # Look for numFmt
            if 'numFmt' in blob:
                print("  Has numFmt setting")
            else:
                print("  No numFmt (defaults to decimal)")
            # Check for jc (alignment)
            if 'jc' in blob:
                import re
                jc_vals = re.findall(r'<w:jc[^>]*w:val="([^"]*)"', blob)
                print(f"  Alignment: {jc_vals}")

# Check sectPr for numFmt
if doc_sectPr is not None:
    # Look for pgNumType
    for ch in doc_sectPr:
        tag = ch.tag.split('}')[-1] if '}' in ch.tag else ch.tag
        if tag == 'pgNumType':
            fmt = ch.get(qn('w:fmt'))
            start = ch.get(qn('w:start'))
            print(f"\npgNumType in sectPr: fmt={fmt}, start={start}")

# Check for numbering definitions
print("\n=== Style numPr check ===")
for style in doc.styles:
    if style.name and style.name.startswith("Heading"):
        if hasattr(style, 'element'):
            pPr = style.element.find(qn('w:pPr'))
            if pPr is not None:
                numPr = pPr.find(qn('w:numPr'))
                if numPr is not None:
                    ilvl = numPr.find(qn('w:ilvl'))
                    numId = numPr.find(qn('w:numId'))
                    ilvl_val = ilvl.get(qn('w:val')) if ilvl is not None else "?"
                    numId_val = numId.get(qn('w:val')) if numId is not None else "?"
                    print(f"  {style.name}: numId={numId_val}, ilvl={ilvl_val}")
