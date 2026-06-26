import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Check TOC entries for hyperlinks
        toc_entries = re.findall(r'<w:p[^>]*>.*?toc 3.*?</w:p>', raw, re.DOTALL)
        print(f'TOC entries (toc 3 style): {len(toc_entries)}')
        for entry in toc_entries[:3]:
            hyperlinks = re.findall(r'w:anchor="_Toc\d+"', entry)
            print(f'  Hyperlinks in entry: {len(hyperlinks)}')
            if hyperlinks:
                print(f'    First anchor: {hyperlinks[0]}')
