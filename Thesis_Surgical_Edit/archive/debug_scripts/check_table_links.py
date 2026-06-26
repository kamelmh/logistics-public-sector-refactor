import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Find table of figures entries (List of Tables)
        table_entries = re.findall(r'<w:p[^>]*>.*?table of figures.*?</w:p>', raw, re.DOTALL)
        print(f'Table of figures entries: {len(table_entries)}')
        for entry in table_entries[:5]:
            hyperlinks = re.findall(r'w:anchor="_Toc\d+"', entry)
            print(f'  Hyperlinks: {len(hyperlinks)}')
            if hyperlinks:
                print(f'    First anchor: {hyperlinks[0]}')
            style_match = re.search(r'w:val="([^"]*)"', entry)
            if style_match:
                print(f'    Style: {style_match.group(1)}')
            # Get text
            text_match = re.search(r'<w:t[^>]*>([^<]*)</w:t>', entry)
            if text_match:
                print(f'    Text: {text_match.group(1)[:80]}')
