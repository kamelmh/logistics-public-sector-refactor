import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        pageref_paras = re.findall(r'<w:p[^>]*>.*?PAGEREF.*?</w:p>', raw, re.DOTALL)
        styles = {}
        for entry in pageref_paras:
            style_match = re.search(r'w:val="([^"]*)"', entry)
            style = style_match.group(1) if style_match else 'unknown'
            styles[style] = styles.get(style, 0) + 1
        for style, count in sorted(styles.items()):
            print(f'{style}: {count}')
