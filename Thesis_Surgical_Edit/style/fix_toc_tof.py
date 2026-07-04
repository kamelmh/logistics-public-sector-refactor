"""fix_toc_tof.py — Remove corrupted static TOC/TOF, let word_automation rebuild.

The shell's TOC has 104 static paragraphs with broken PAGEREF bookmarks.
This script removes them so word_automation.py can insert proper dynamic fields.

Usage: python fix_toc_tof.py <path/to.docx> [--save]
"""
import sys
import shutil
import zipfile
from lxml import etree

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W_NS = f'{{{W}}}'
W_URI = W


def get_text(elem):
    """Get text content of an XML element."""
    texts = elem.findall(f'.//{W_NS}t')
    return ''.join(t.text or '' for t in texts)


def fix_toc_tof(docx_path, save=False):
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc_xml = z.read('word/document.xml')

    root = etree.fromstring(doc_xml)
    body = root.find(f'.//{W_NS}body')
    children = list(body)

    removed = 0

    # Find and remove static TOC paragraphs (TOC1/TOC2/TOC3 styles)
    # Also remove any paragraph containing the raw TOC field code text
    to_remove = []
    for i, child in enumerate(children):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            pStyle = child.find(f'.//{{{W_URI}}}pStyle')
            if pStyle is not None:
                style_val = pStyle.get(f'{{{W_URI}}}val', '')
                # Remove ALL TOC1/TOC2/TOC3 paragraphs (they are static entries)
                if style_val in ('TOC1', 'TOC2', 'TOC3', 'TableofFigures'):
                    to_remove.append(child)
                    removed += 1
                    continue

            # Also check for raw TOC field code text
            text = get_text(child)
            if 'TOC \\o "1-3"' in text or 'TOC \\c "جدول"' in text:
                to_remove.append(child)
                removed += 1
                continue

    # Remove the identified paragraphs
    for child in to_remove:
        body.remove(child)

    print(f'[TOC_FIX] Removed {removed} static TOC/TOF paragraphs')

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
        print(f'[TOC_FIX] Saved: {docx_path}')

    return removed


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python fix_toc_tof.py <path/to.docx> [--save]')
        sys.exit(1)
    path = sys.argv[1]
    save = '--save' in sys.argv
    fix_toc_tof(path, save)
