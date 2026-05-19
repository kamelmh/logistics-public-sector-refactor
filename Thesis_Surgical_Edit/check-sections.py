from docx import Document
import zipfile
import xml.etree.ElementTree as ET

# Check the actual XML for sections
docx_path = 'output/Memoire_DSS_Logistique_ElBayadh.docx'

# Extract document.xml
with zipfile.ZipFile(docx_path, 'r') as z:
    xml_content = z.read('word/document.xml')

# Parse XML
root = ET.fromstring(xml_content)
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

# Find all sectPr elements
sectPrs = root.findall('.//w:sectPr', ns)
print(f'=== SECTPR ELEMENTS FOUND: {len(sectPrs)} ===')
for i, sectPr in enumerate(sectPrs):
    pgn = sectPr.find('w:pgNumType', ns)
    fmt = pgn.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}fmt') if pgn is not None else 'none'
    # Check if it's a body sectPr or inline
    parent = sectPr.getparent() if hasattr(sectPr, 'getparent') else None
    print(f'SectPr {i}: pgNumType={fmt}, parent={parent.tag if parent is not None else "root"}')

# Check body children for sectPr
body = root.find('w:body', ns)
body_children = list(body)
print(f'\n=== BODY CHILDREN: {len(body_children)} ===')
sectPr_indices = [i for i, child in enumerate(body_children) if child.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sectPr']
print(f'SectPr at body indices: {sectPr_indices}')

# Find الفصل الأول
for i, child in enumerate(body_children):
    if child.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p':
        texts = [t.text for t in child.findall('.//w:t', ns) if t.text]
        full_text = ''.join(texts)
        if 'الفصل الأول' in full_text:
            print(f'\nالفصل الأول found at body child index {i}')
            # Check if there's a sectPr before it
            if i > 0 and body_children[i-1].tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sectPr':
                print('  sectPr found immediately before الفصل الأول ✓')
            else:
                print('  NO sectPr before الفصل الأول ✗')
            break
