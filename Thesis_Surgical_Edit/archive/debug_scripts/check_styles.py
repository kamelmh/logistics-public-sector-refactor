import zipfile
import re
from xml.etree import ElementTree as ET

docx_path = 'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    with z.open('word/document.xml') as f:
        content = f.read().decode('utf-8')

print(f"Total length of document.xml: {len(content)}")

# Find all paragraph styles
# <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr>...
# Or <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
# Note: w:val is in the namespace

NS = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
tree = ET.fromstring(content)

styles_found = {}

for p in tree.findall('.//w:p', NS):
    pPr = p.find('.//w:pPr', NS)
    if pPr is not None:
        pStyle = pPr.find('.//w:pStyle', NS)
        if pStyle is not None:
            val = pStyle.get(f'{{{NS["w"]}}}val')
            if val:
                styles_found[val] = styles_found.get(val, 0) + 1

print("Paragraph styles found:")
for style, count in sorted(styles_found.items(), key=lambda x: x[1], reverse=True):
    print(f"  {style}: {count}")

# Also check for headings in the text
print("\nSample of text with styles:")
for p in tree.findall('.//w:p', NS):
    pPr = p.find('.//w:pPr', NS)
    style = "Normal"
    if pPr is not None:
        pStyle = pPr.find('.//w:pStyle', NS)
        if pStyle is not None:
            val = pStyle.get(f'{{{NS["w"]}}}val')
            if val:
                style = val
    
    # Get text
    text_parts = []
    for r in p.findall('.//w:r', NS):
        for t in r.findall('.//w:t', NS):
            if t.text:
                text_parts.append(t.text)
    text = "".join(text_parts).strip()
    if text:
        print(f"[{style}] {text[:50]}...")
