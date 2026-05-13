"""Debug exactly what in prepend-cover.py breaks Word compatibility."""
import sys, os, subprocess
from docx import Document
from docx.oxml import OxmlElement
from copy import deepcopy

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
COVER_PATH = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\cover-page.docx'
THESIS_PATH = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\test-debug.docx'

# Fresh pandoc output
subprocess.run(['pandoc',
    r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md',
    '--from', 'gfm', '--to', 'docx',
    '--reference-doc', r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\reference.docx',
    '--metadata-file', r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\thesis-metadata.yaml',
    '--output', THESIS_PATH, '--wrap', 'preserve', '--eol', 'lf'], check=True)

cover = Document(COVER_PATH)
thesis = Document(THESIS_PATH)
cover_body = cover.element.body
thesis_body = thesis.element.body
cover_paras = [c for c in list(cover_body) if c.tag != f'{W}sectPr']
insert_before = thesis_body[0] if len(thesis_body) > 0 else None

print(f"Cover paras: {len(cover_paras)}")
if insert_before is not None:
    print(f"Insert before index: {list(thesis_body).index(insert_before)}")

# Approach A: also strip rPr theme fonts from cover paragraphs
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
        # Also strip rPr elements with themeFont references
        for rPr in p.iter(f'{W}rPr'):
            # Remove theme font references
            for rFonts in rPr.findall(f'{W}rFonts'):
                for attr in list(rFonts.attrib.keys()):
                    if 'theme' in attr.lower():
                        del rFonts.attrib[attr]
            # Remove scheme color references  
            for color in rPr.findall(f'{W}color'):
                for attr in list(color.attrib.keys()):
                    if 'theme' in attr.lower() or 'theme' in attr.lower():
                        del color.attrib[attr]
            for shade in rPr.findall(f'{W}shd'):
                for attr in list(shade.attrib.keys()):
                    if 'theme' in attr.lower():
                        del shade.attrib[attr]
    
    thesis_body.insert(
        0 if insert_before is None else list(thesis_body).index(insert_before),
        clone
    )

thesis.save(THESIS_PATH)
print("Saved. Now open the DOCX and try to open it.")
print(f"Path: {THESIS_PATH}")
