import zipfile

docx_path = r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"

with zipfile.ZipFile(docx_path, 'r') as z:
    names = z.namelist()
    print("Footer files:", [n for n in names if 'footer' in n.lower()])
    print("Header files:", [n for n in names if 'header' in n.lower()])
    print()
    
    # Check document.xml for footer references
    doc_raw = z.read('word/document.xml').decode('utf-8')
    import re
    footer_refs = re.findall(r'<w:footerReference[^>]*>', doc_raw)
    print("Footer references in document.xml:")
    for ref in footer_refs:
        print(f"  {ref}")
    print()
    
    # Check each footer
    for fname in names:
        if 'footer' in fname.lower():
            raw = z.read(fname).decode('utf-8')
            print(f"=== {fname} ===")
            print(raw[:2000])
            print("...")
            print()
