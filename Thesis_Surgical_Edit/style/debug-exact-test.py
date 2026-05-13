"""Exact test matching the manual approach that worked."""
import os, shutil, zipfile, subprocess
from lxml import etree
from copy import deepcopy

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
cover_path = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\cover-page.docx'
thesis_path = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\test-exact-match.docx'

subprocess.run(['pandoc',
    r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md',
    '--from', 'gfm', '--to', 'docx',
    '--reference-doc', r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\reference.docx',
    '--metadata-file', r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\thesis-metadata.yaml',
    '--output', thesis_path, '--wrap', 'preserve', '--eol', 'lf'], check=True)

with zipfile.ZipFile(cover_path) as z:
    cover_xml = z.read('word/document.xml')
with zipfile.ZipFile(thesis_path) as z:
    thesis_xml = z.read('word/document.xml')

cover_doc = etree.fromstring(cover_xml)
thesis_doc = etree.fromstring(thesis_xml)
cover_body = cover_doc.find(f'{W}body')
thesis_body = thesis_doc.find(f'{W}body')
cover_paras = [c for c in list(cover_body) if c.tag != f'{W}sectPr']
insert_before = list(thesis_body)[0]

for para in cover_paras:
    clone = deepcopy(para)
    for p in clone.iter(f'{W}p'):
        pPr = p.find(f'{W}pPr')
        if pPr is not None:
            pStyle = pPr.find(f'{W}pStyle')
            if pStyle is not None:
                pPr.remove(pStyle)
            numPr = pPr.find(f'{W}numPr')
            if numPr is not None:
                pPr.remove(numPr)
    for rPr in clone.iter(f'{W}rPr'):
        for rf in rPr.findall(f'{W}rFonts'):
            for attr in list(rf.attrib.keys()):
                del rf.attrib[attr]
        for col in rPr.findall(f'{W}color'):
            for attr in list(col.attrib.keys()):
                if 'theme' in attr.lower():
                    del col.attrib[attr]
        for shd in rPr.findall(f'{W}shd'):
            for attr in list(shd.attrib.keys()):
                if 'theme' in attr.lower():
                    del shd.attrib[attr]
    thesis_body.insert(list(thesis_body).index(insert_before), clone)

idx = list(thesis_body).index(insert_before) - 1
last_para = list(thesis_body)[idx]
run = etree.SubElement(last_para, f'{W}r')
br = etree.SubElement(run, f'{W}br')
br.set(f'{W}type', 'page')

tmp = thesis_path + '.tmp'
with zipfile.ZipFile(thesis_path, 'r') as z_in:
    with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as z_out:
        for item in z_in.infolist():
            if item.filename == 'word/document.xml':
                z_out.writestr(item, etree.tostring(thesis_doc, xml_declaration=True, encoding='UTF-8', standalone=True))
            else:
                z_out.writestr(item, z_in.read(item.filename))
os.replace(tmp, thesis_path)
print(f"Done: {os.path.getsize(thesis_path)} bytes")
