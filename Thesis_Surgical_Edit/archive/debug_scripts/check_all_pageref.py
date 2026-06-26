import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Find all paragraphs with PAGEREF that might be tables
        pageref_paras = re.findall(r'<w:p[^>]*>.*?PAGEREF.*?</w:p>', raw, re.DOTALL)
        print(f'Total PAGEREF paragraphs: {len(pageref_paras)}')
        for entry in pageref_paras:
            style_match = re.search(r'w:val="([^"]*)"', entry)
            style = style_match.group(1) if style_match else 'unknown'
            if 'table' in style.lower() or 'figure' in style.lower() or 'caption' in style.lower():
                hyperlinks = re.findall(r'w:anchor="_Toc\d+"', entry)
                text_match = re.search(r'<w:t[^>]*>([^<]*)</w:t>', entry)
                text = text_match.group(1)[:80] if text_match else ''
                print(f'  Style: {style}, Hyperlinks: {len(hyperlinks)}, Text: {text}')
