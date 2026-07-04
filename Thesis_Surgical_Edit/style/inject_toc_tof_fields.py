"""inject_toc_tof_fields.py — Inject TOC and TOF fields at XML level.

After fix_toc_tof.py removes static TOC/TOF paragraphs, this script
injects proper dynamic TOC and TOF fields after the headings.

Usage: python inject_toc_tof_fields.py <path/to.docx> [--save]
"""
import sys
import shutil
import zipfile
from lxml import etree

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W_NS = f'{{{W}}}'
XML_SPACE = '{http://www.w3.org/XML/1998/namespace}space'


def get_text(elem):
    """Get text content of an XML element."""
    texts = elem.findall(f'.//{W_NS}t')
    return ''.join(t.text or '' for t in texts)


def get_field_codes(elem):
    """Get field instruction text from an XML element."""
    instr_texts = elem.findall(f'.//{W_NS}instrText')
    return ''.join(t.text or '' for t in instr_texts)


def make_toc_field(field_code):
    """Create a paragraph with a TOC field."""
    p = etree.Element(f'{W_NS}p')
    pPr = etree.SubElement(p, f'{W_NS}pPr')

    # Field begin
    r1 = etree.SubElement(p, f'{W_NS}r')
    fldChar1 = etree.SubElement(r1, f'{W_NS}fldChar')
    fldChar1.set(f'{W_NS}fldCharType', 'begin')

    # Field instruction
    r2 = etree.SubElement(p, f'{W_NS}r')
    instrText = etree.SubElement(r2, f'{W_NS}instrText')
    instrText.set(XML_SPACE, 'preserve')
    instrText.text = f' {field_code} '

    # Field separate
    r3 = etree.SubElement(p, f'{W_NS}r')
    fldChar2 = etree.SubElement(r3, f'{W_NS}fldChar')
    fldChar2.set(f'{W_NS}fldCharType', 'separate')

    # Placeholder text
    r4 = etree.SubElement(p, f'{W_NS}r')
    t = etree.SubElement(r4, f'{W_NS}t')
    t.set(XML_SPACE, 'preserve')
    t.text = '[]'

    # Field end
    r5 = etree.SubElement(p, f'{W_NS}r')
    fldChar3 = etree.SubElement(r5, f'{W_NS}fldChar')
    fldChar3.set(f'{W_NS}fldCharType', 'end')

    return p


def inject_toc_tof_fields(docx_path, save=False):
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc_xml = z.read('word/document.xml')

    root = etree.fromstring(doc_xml)
    body = root.find(f'.//{W_NS}body')
    children = list(body)

    injected = 0

    # Find فهرس المحتويات heading (search by text)
    toc_heading_idx = None
    for i, child in enumerate(children):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            text = get_text(child)
            if 'فهرس المحتويات' in text:
                toc_heading_idx = i
                print(f'  Found فهرس المحتويات at index {i}')
                break

    # If فهرس المحتويات not found, add it before قائمة الجداول
    if toc_heading_idx is None:
        # Find قائمة الجداول to insert before it
        for i, child in enumerate(children):
            tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
            if tag == 'p':
                text = get_text(child)
                if 'قائمة الجداول' in text:
                    # Add فهرس المحتويات heading before قائمة الجداول
                    heading_p = etree.Element(f'{W_NS}p')
                    pPr = etree.SubElement(heading_p, f'{W_NS}pPr')
                    pStyle = etree.SubElement(pPr, f'{W_NS}pStyle')
                    pStyle.set(f'{W_NS}val', 'Heading3')
                    r = etree.SubElement(heading_p, f'{W_NS}r')
                    t = etree.SubElement(r, f'{W_NS}t')
                    t.set(XML_SPACE, 'preserve')
                    t.text = 'فهرس المحتويات'
                    body.insert(i, heading_p)
                    toc_heading_idx = i
                    injected += 1
                    print(f'  Added فهرس المحتويات heading at index {i}')
                    break
        
        # If still not found, add at the beginning (after cover page)
        if toc_heading_idx is None:
            heading_p = etree.Element(f'{W_NS}p')
            pPr = etree.SubElement(heading_p, f'{W_NS}pPr')
            pStyle = etree.SubElement(pPr, f'{W_NS}pStyle')
            pStyle.set(f'{W_NS}val', 'Heading3')
            r = etree.SubElement(heading_p, f'{W_NS}r')
            t = etree.SubElement(r, f'{W_NS}t')
            t.set(XML_SPACE, 'preserve')
            t.text = 'فهرس المحتويات'
            # Insert after first Heading3 or after cover page
            insert_idx = 25  # Default after cover page
            body.insert(insert_idx, heading_p)
            toc_heading_idx = insert_idx
            injected += 1
            print(f'  Added فهرس المحتويات heading at index {insert_idx}')

    # Refresh children list
    children = list(body)

    # Inject TOC field after فهرس المحتويات
    if toc_heading_idx is not None:
        # Check if next paragraph already has a TOC field
        has_toc = False
        if toc_heading_idx + 1 < len(children):
            next_child = children[toc_heading_idx + 1]
            next_field = get_field_codes(next_child)
            if 'TOC \\o' in next_field:
                has_toc = True
                print(f'  TOC field already exists')
        
        if not has_toc:
            toc_p = make_toc_field(r'TOC \o "1-3" \h \z \u')
            body.insert(toc_heading_idx + 1, toc_p)
            injected += 1
            print(f'  Injected TOC field at index {toc_heading_idx + 1}')

    # Find قائمة الجداول heading (search by text)
    children = list(body)  # Refresh after insertion
    tof_heading_idx = None
    for i, child in enumerate(children):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            text = get_text(child)
            if 'قائمة الجداول' in text:
                tof_heading_idx = i
                print(f'  Found قائمة الجداول at index {i}')
                break

    # Inject TOF field after قائمة الجداول
    if tof_heading_idx is not None:
        # Check if next paragraph already has a TOF field
        has_tof = False
        if tof_heading_idx + 1 < len(children):
            next_child = children[tof_heading_idx + 1]
            next_field = get_field_codes(next_child)
            if 'TOC \\c' in next_field:
                has_tof = True
                print(f'  TOF field already exists')
        
        if not has_tof:
            tof_p = make_toc_field(r'TOC \h \z \c "جدول"')
            body.insert(tof_heading_idx + 1, tof_p)
            injected += 1
            print(f'  Injected TOF field at index {tof_heading_idx + 1}')

    print(f'[TOC_INJECT] Injected {injected} fields')

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
        print(f'[TOC_INJECT] Saved: {docx_path}')

    return injected


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python inject_toc_tof_fields.py <path/to.docx> [--save]')
        sys.exit(1)
    path = sys.argv[1]
    save = '--save' in sys.argv
    inject_toc_tof_fields(path, save)
