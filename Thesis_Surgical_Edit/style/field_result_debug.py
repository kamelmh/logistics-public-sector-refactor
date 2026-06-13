import zipfile
import re

docx_path = r'Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    print("=== CHECKING FOR NUMERIC TEXT IN FOOTERS ===")
    for i in range(1, 5):
        name = f'word/footer{i}.xml'
        if name in z.namelist():
            content = z.read(name).decode('utf-8')
            print(f'\n--- {name} ---')
            
            # Find all w:t elements and their context
            # We'll look for w:t elements that contain numbers
            t_pattern = r'(<w:[^>]*t[^>]*>)(.*?)(</w:[^>]*t>)'
            matches = re.findall(t_pattern, content, re.DOTALL)
            
            numeric_found = False
            for full_open, text, full_close in matches:
                if text.strip().isdigit():
                    print(f'  Found numeric text: "{text}"')
                    # Show more context around this
                    start_pos = content.find(full_open + text + full_close)
                    if start_pos != -1:
                        context_start = max(0, start_pos - 100)
                        context_end = min(len(content), start_pos + len(full_open + text + full_close) + 100)
                        context = content[context_start:context_end]
                        print(f'    Context: {context}')
                        numeric_found = True
            
            if not numeric_found:
                print('  No numeric text elements found in this footer')
                
    print("\n=== CHECKING FOR FIELD RESULT CACHING ===")
    # Look for any evidence of cached field results
    # These would typically be w:t elements that are direct children of w:r 
    # that are inside w:p elements that contain field chars
    
    # Let's look at the document.xml for any suspicious patterns
    doc_content = z.read('word/document.xml').decode('utf-8')
    
    # Look for patterns that might indicate cached results
    # Look for fldChar followed by instrText and then fldChar with text in between
    field_pattern = r'(<w:p[^>]*>.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:instrText[^>]*>.*?</w:instrText>.*?</w:r>.*?<w:r[^>]*>.*?<w:t[^>]*>)(.*?)(</w:t>.*?</w:r>.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="end"[^>]*/>.*?</w:r>.*?</w:p>)'
    
    field_matches = re.findall(field_pattern, doc_content, re.DOTALL)
    if field_matches:
        print(f'Found {len(field_matches)} field patterns with potential result text')
        for i, (prefix, result_text, suffix) in enumerate(field_matches[:5]):
            print(f'  Field {i+1} result text: "{result_text}"')
            if result_text.strip():
                print(f'    *** NON-EMPTY RESULT TEXT FOUND: "{result_text}" ***')
    else:
        print('No standard field patterns found with result text')
        
    # Also check for any w:t that might be field results (not inside instrText)
    # Look for w:t elements that are siblings of fldChar elements
    print("\n=== CHECKING FOR SUSPICIOUS TEXT ELEMENTS ===")
    # Find all w:t elements
    t_elements = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', doc_content)
    suspicious = []
    for t in t_elements:
        t_clean = t.strip()
        # Check if it's a small number that could be a page number
        if t_clean.isdigit() and 1 <= int(t_clean) <= 999:
            suspicious.append(t_clean)
        # Also check for any text that looks like it could be a page result
        elif t_clean.lower() in ['page', 'p', 'pg'] or 'page' in t_clean.lower():
            suspicious.append(t_clean)
    
    if suspicious:
        print(f'Found {len(suspicious)} suspicious text elements: {suspicious[:20]}')
    else:
        print('No suspicious text elements found')