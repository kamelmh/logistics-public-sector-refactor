"""fix_heading_alignment.py — Fix Arabic heading alignment and RTL.

Arabic thesis headings should be:
- H1: CENTERED
- H2: RIGHT-aligned
- H3: RIGHT-aligned
- All: RTL direction via <w:bidi/> in paragraph properties

Usage: python fix_heading_alignment.py <path/to.docx> [--save]
"""
import sys
import shutil
import zipfile
from lxml import etree

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W_NS = f'{{{W}}}'


def fix_heading_alignment(docx_path, save=False):
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc_xml = z.read('word/document.xml')

    root = etree.fromstring(doc_xml)
    body = root.find(f'.//{W_NS}body')
    children = list(body)

    fixed = 0
    for child in children:
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag != 'p':
            continue

        pStyle = child.find(f'.//{{{W}}}pStyle')
        if pStyle is None:
            continue

        style_val = pStyle.get(f'{{{W}}}val', '')
        if style_val not in ('Heading1', 'Heading2', 'Heading3'):
            continue

        pPr = child.find(f'{{{W}}}pPr')
        if pPr is None:
            pPr = etree.SubElement(child, f'{W_NS}pPr')
            # Move pPr to first position
            child.remove(pPr)
            child.insert(0, pPr)

        # Set alignment based on heading level
        jc = pPr.find(f'{{{W}}}jc')
        if jc is None:
            jc = etree.SubElement(pPr, f'{W_NS}jc')

        if style_val == 'Heading1':
            jc.set(f'{{{W}}}val', 'center')
        else:  # Heading2, Heading3
            jc.set(f'{{{W}}}val', 'right')  # right-aligned

        # Add RTL bidi if not present
        bidi = pPr.find(f'{{{W}}}bidi')
        if bidi is None:
            etree.SubElement(pPr, f'{W_NS}bidi')

        fixed += 1

    print(f'[HEADING_FIX] Fixed alignment on {fixed} headings')

    if save:
        new_xml = etree.tostring(root, xml_declaration=True, encoding='UTF-8', standalone=True)
        temp = docx_path + '.tmp'
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(temp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    if item.filename == 'word/document.xml':
                        zout.writestr(item, new_xml)
                    else:
                        zout.writestr(item, zin.read(item.filename))
        shutil.move(temp, docx_path)
        print(f'[HEADING_FIX] Saved: {docx_path}')

    return fixed


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python fix_heading_alignment.py <path/to.docx> [--save]')
        sys.exit(1)
    path = sys.argv[1]
    save = '--save' in sys.argv
    fix_heading_alignment(path, save)
