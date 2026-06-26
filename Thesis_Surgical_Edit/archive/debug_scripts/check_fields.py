import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/recent-source-1-Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Find LISTOFTABLES field
        listof_fields = re.findall(r'<w:instrText[^>]*>.*?LISTOF.*?</w:instrText>', raw)
        print(f'LISTOF fields: {len(listof_fields)}')
        for f in listof_fields:
            print(f'  {f}')
        # Find TOC field
        toc_fields = re.findall(r'<w:instrText[^>]*>.*?TOC.*?</w:instrText>', raw)
        print(f'TOC fields: {len(toc_fields)}')
        for f in toc_fields:
            print(f'  {f}')
