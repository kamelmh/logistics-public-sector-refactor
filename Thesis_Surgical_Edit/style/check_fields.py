"""Investigate TOC, hyperlinks, and field structure in the DOCX."""
import zipfile
import re

docx_path = r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    doc_xml = z.read('word/document.xml').decode('utf-8')
    
    # Count fields
    field_begin = doc_xml.count('fldCharType="begin"')
    field_sep = doc_xml.count('fldCharType="separate"')
    field_end = doc_xml.count('fldCharType="end"')
    print(f'Field structure: begin={field_begin}, separate={field_sep}, end={field_end}')
    
    # Find all instrText contents
    instr_texts = re.findall(r'<w:instrText[^>]*>([^<]*)</w:instrText>', doc_xml)
    print(f'\nAll instruction texts ({len(instr_texts)}):')
    for i, txt in enumerate(instr_texts):
        print(f'  [{i}] "{txt.strip()}"')
    
    # Check for HYPERLINK
    hyperlink_count = doc_xml.count('HYPERLINK')
    print(f'\nHYPERLINK occurrences: {hyperlink_count}')
    
    # Check for TOC
    toc_matches = [t for t in instr_texts if 'TOC' in t]
    print(f'TOC instructions: {toc_matches}')
    
    # Check for w:hyperlink tags
    hyperlink_tags = re.findall(r'<w:hyperlink[^>]*>', doc_xml)
    print(f'w:hyperlink tags: {len(hyperlink_tags)}')
    
    # Check for w:bookmarkStart
    bookmark_starts = re.findall(r'<w:bookmarkStart[^>]*w:name="([^"]*)"[^>]*/>', doc_xml)
    print(f'Bookmarks: {len(bookmark_starts)} — {bookmark_starts[:10]}')
    
    # Check for w:internalHyperlink or w:externalHyperlink
    internal = len(re.findall(r'r:id="[^"]*"', doc_xml))
    print(f'r:id references: {internal}')
    
    # Check relationships
    rels_xml = z.read('word/_rels/document.xml.rels').decode('utf-8')
    rel_count = rels_xml.count('Relationship')
    hyperlink_rels = re.findall(r'Id="([^"]*)"[^>]*Target="([^"]*)"[^>]*', rels_xml)
    print(f'\nRelationships: {rel_count}')
    for rid, target in hyperlink_rels[:15]:
        print(f'  {rid} -> {target}')
    
    # Find the TOC section area
    toc_idx = doc_xml.find('فهرس المحتويات')
    if toc_idx >= 0:
        snippet = doc_xml[toc_idx:toc_idx+2000]
        print(f'\nTOC area snippet (around فهرس المحتويات):')
        # Find field chars in this area
        field_in_toc = re.findall(r'fldCharType="(\w+)"', snippet)
        instr_in_toc = re.findall(r'w:instrText[^>]*>([^<]*)</w:instrText>', snippet)
        print(f'  Field chars: {field_in_toc}')
        print(f'  InstrText: {instr_in_toc}')
    
    # Check for TOF (Table of Figures)
    tof_idx = doc_xml.find('قائمة الجداول')
    if tof_idx >= 0:
        snippet = doc_xml[tof_idx:tof_idx+2000]
        field_in_tof = re.findall(r'fldCharType="(\w+)"', snippet)
        instr_in_tof = re.findall(r'w:instrText[^>]*>([^<]*)</w:instrText>', snippet)
        print(f'\nTOF area snippet (around قائمة الجداول):')
        print(f'  Field chars: {field_in_tof}')
        print(f'  InstrText: {instr_in_tof}')
