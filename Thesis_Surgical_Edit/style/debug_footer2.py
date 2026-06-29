import zipfile

docx_path = r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"

with zipfile.ZipFile(docx_path, 'r') as z:
    names = z.namelist()
    
    # Check each footer fully
    for fname in names:
        if 'footer' in fname.lower():
            raw = z.read(fname).decode('utf-8')
            print(f"=== {fname} ===")
            # Look for PAGE field related content
            import re
            # Find fldChar, fldSimple, instrText
            fldchars = re.findall(r'<w:fldChar[^>]*>', raw)
            fldsimples = re.findall(r'<w:fldSimple[^>]*>.*?</w:fldSimple>', raw)
            instrtexts = re.findall(r'<w:instrText[^>]*>.*?</w:instrText>', raw)
            
            print(f"  fldChar: {fldchars}")
            print(f"  fldSimple: {fldsimples}")
            print(f"  instrText: {instrtexts}")
            
            # Also check for cached "page1" or "1" text
            if 'page1' in raw.lower() or 'page 1' in raw.lower():
                print("  [!!] CONTAINS 'page1' TEXT!")
            if '<w:t>1</w:t>' in raw or '<w:t> 1 </w:t>' in raw:
                print("  [!!] CONTAINS cached '1' in w:t!")
            print()
