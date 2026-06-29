"""Check pgNumType in thesis DOCX"""
import zipfile
from pathlib import Path
from lxml import etree

PROJECT_ROOT = Path(__file__).resolve().parent
docx = str(PROJECT_ROOT / "output" / "Memoire_DSS_Logistique_ElBayadh.docx")
NSMAP = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

with zipfile.ZipFile(docx) as z:
    doc_xml = z.read('word/document.xml')

root = etree.fromstring(doc_xml)
sectprs = root.findall('.//w:sectPr', NSMAP)
for i, sp in enumerate(sectprs):
    pnt = sp.find('w:pgNumType', NSMAP)
    if pnt is not None:
        fmt = pnt.get('{%s}fmt' % NSMAP['w'])
        start = pnt.get('{%s}start' % NSMAP['w'])
        print(f"sectPr[{i}]: fmt={fmt} start={start}")
    else:
        print(f"sectPr[{i}]: no pgNumType")
