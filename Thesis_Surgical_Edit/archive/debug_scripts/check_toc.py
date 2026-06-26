import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/recent-source-1-Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        hyperlinks = re.findall(r'w:anchor="_Toc\d+"', raw)
        print('TOC hyperlinks:', len(hyperlinks))
        bookmarks = re.findall(r'<w:bookmarkStart[^>]*w:name="_Toc\d+"', raw)
        print('Bookmarks (_Toc):', len(bookmarks))
