"""prepend-cover.py -- Academix v13.2
Prepends cover-page.docx to the generated thesis DOCX at zip level.
"""
import sys, os, shutil, tempfile
import zipfile
from lxml import etree
from copy import deepcopy

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
COVER_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "output", "cover-page.docx")

def strip_foreign_refs(element):
    for p in element.iter(f'{W}p'):
        pPr = p.find(f'{W}pPr')
        if pPr is not None:
            pStyle = pPr.find(f'{W}pStyle')
            if pStyle is not None:
                pPr.remove(pStyle)
            numPr = pPr.find(f'{W}numPr')
            if numPr is not None:
                pPr.remove(numPr)
    for rPr in element.iter(f'{W}rPr'):
        for rFonts in rPr.findall(f'{W}rFonts'):
            for attr in list(rFonts.attrib.keys()):
                del rFonts.attrib[attr]
        for color in rPr.findall(f'{W}color'):
            for attr in list(color.attrib.keys()):
                if 'theme' in attr.lower():
                    del color.attrib[attr]
        for shd in rPr.findall(f'{W}shd'):
            for attr in list(shd.attrib.keys()):
                if 'theme' in attr.lower():
                    del shd.attrib[attr]

def add_page_break_to_last_cover_para(thesis_body, insert_before):
    idx = list(thesis_body).index(insert_before) - 1
    last_para = list(thesis_body)[idx]
    run = etree.SubElement(last_para, f'{W}r')
    br = etree.SubElement(run, f'{W}br')
    br.set(f'{W}type', 'page')

def prepend_cover(thesis_path):
    if not os.path.exists(COVER_PATH):
        print(f"  [WARN] cover-page.docx not found at {COVER_PATH}")
        return False

    with zipfile.ZipFile(COVER_PATH) as z_cover:
        cover_xml = z_cover.read('word/document.xml')
    with zipfile.ZipFile(thesis_path) as z_thesis:
        thesis_xml = z_thesis.read('word/document.xml')

    cover_doc = etree.fromstring(cover_xml)
    thesis_doc = etree.fromstring(thesis_xml)

    cover_body = cover_doc.find(f'{W}body')
    thesis_body = thesis_doc.find(f'{W}body')

    cover_elements = [c for c in list(cover_body) if c.tag != f'{W}sectPr']
    insert_before = list(thesis_body)[0] if len(thesis_body) > 0 else None

    for elem in cover_elements:
        clone = deepcopy(elem)
        strip_foreign_refs(clone)
        thesis_body.insert(list(thesis_body).index(insert_before), clone)

    if insert_before is not None:
        add_page_break_to_last_cover_para(thesis_body, insert_before)

    tmp = tempfile.NamedTemporaryFile(suffix='.docx', delete=False)
    tmp.close()
    with zipfile.ZipFile(thesis_path, 'r') as z_in:
        with zipfile.ZipFile(tmp.name, 'w', zipfile.ZIP_DEFLATED) as z_out:
            for item in z_in.infolist():
                if item.filename == 'word/document.xml':
                    z_out.writestr(item,
                        etree.tostring(thesis_doc, xml_declaration=True, encoding='UTF-8', standalone=True))
                else:
                    z_out.writestr(item, z_in.read(item.filename))
    shutil.move(tmp.name, thesis_path)
    print(f"  Cover prepended: {len(cover_elements)} paragraphs, page break after cover")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python prepend-cover.py <docx_path>")
        sys.exit(1)
    prepend_cover(sys.argv[1])
