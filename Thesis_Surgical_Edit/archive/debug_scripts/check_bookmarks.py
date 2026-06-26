import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Check bookmark starts for TOC anchors
        bookmarks = re.findall(r'<w:bookmarkStart[^>]*w:name="(_Toc\d+)"', raw)
        print(f'Bookmark anchors (_Toc): {len(bookmarks)}')
        # Check hyperlink anchors
        hyperlinks = re.findall(r'w:anchor="(_Toc\d+)"', raw)
        print(f'Hyperlink anchors (_Toc): {len(hyperlinks)}')
        # Match them
        bookmark_set = set(bookmarks)
        hyperlink_set = set(hyperlinks)
        matched = bookmark_set & hyperlink_set
        print(f'Matched anchors: {len(matched)}')
        unmatched_hyperlinks = hyperlink_set - bookmark_set
        print(f'Unmatched hyperlinks: {len(unmatched_hyperlinks)}')
        if unmatched_hyperlinks:
            print(f'  Examples: {list(unmatched_hyperlinks)[:5]}')
