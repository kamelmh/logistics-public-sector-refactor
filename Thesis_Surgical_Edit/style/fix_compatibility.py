"""fix_compatibility.py — Suppress Word Compatibility Checker warnings.

Removes alt-text related settings that trigger the popup when saving.

Usage: python fix_compatibility.py <path/to.docx> [--save]
"""
import sys
import shutil
import zipfile
from lxml import etree

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W_NS = f'{{{W}}}'


def fix_compatibility(docx_path, save=False):
    with zipfile.ZipFile(docx_path, 'r') as z:
        settings_xml = z.read('word/settings.xml')

    root = etree.fromstring(settings_xml)

    # Remove compatibility settings that trigger the checker
    removed = 0

    # Remove <w:compat> elements that cause issues
    for compat in root.findall(f'.//{{{W}}}compat'):
        # Remove specific compat settings
        for child in list(compat):
            tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
            # Remove settings that trigger alt-text warnings
            if 'compat' in tag.lower() or 'setting' in tag.lower():
                compat.remove(child)
                removed += 1

    # Remove table cell alt-text warning settings
    for elem in root.findall(f'.//{{{W}}}tblCellSpacing'):
        parent = elem.getparent()
        if parent is not None:
            parent.remove(elem)
            removed += 1

    # Remove any alt-text related attributes
    for elem in root.iter():
        for attr in list(elem.attrib.keys()):
            if 'alt' in attr.lower() or 'desc' in attr.lower():
                del elem.attrib[attr]
                removed += 1

    print(f'[COMPAT] Removed {removed} compatibility settings')

    if save:
        new_xml = etree.tostring(root, xml_declaration=True, encoding='UTF-8', standalone=True)
        temp = docx_path + '.tmp'
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(temp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    if item.filename == 'word/settings.xml':
                        zout.writestr(item, new_xml)
                    else:
                        zout.writestr(item, zin.read(item.filename))
        shutil.move(temp, docx_path)
        print(f'[COMPAT] Saved: {docx_path}')

    return removed


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python fix_compatibility.py <path/to.docx> [--save]')
        sys.exit(1)
    path = sys.argv[1]
    save = '--save' in sys.argv
    fix_compatibility(path, save)
