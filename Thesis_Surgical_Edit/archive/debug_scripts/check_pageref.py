import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Find all paragraphs with PAGEREF
        pageref_paras = re.findall(r'<w:p[^>]*>.*?PAGEREF.*?</w:p>', raw, re.DOTALL)
        print(f'Paragraphs with PAGEREF: {len(pageref_paras)}')
        for entry in pageref_paras[:3]:
            hyperlinks = re.findall(r'w:anchor="_Toc\d+"', entry)
            print(f'  Hyperlinks: {len(hyperlinks)}')
            if hyperlinks:
                print(f'    First anchor: {hyperlinks[0]}')
            # Get style
            style_match = re.search(r'w:val="([^"]*)"', entry)
            if style_match:
                print(f'    Style: {style_match.group(1)}')
