import zipfile
import re

docx_path = r'Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    print("=== DETAILED FOOTER ANALYSIS ===")
    for i in range(1, 5):
        name = f'word/footer{i}.xml'
        if name in z.namelist():
            content = z.read(name).decode('utf-8')
            print(f'\n--- {name} ---')
            
            # Pretty print the XML to see structure
            # Look for all w:p elements
            p_matches = re.findall(r'<w:p[^>]*>.*?</w:p>', content, re.DOTALL)
            for j, p in enumerate(p_matches):
                print(f'Paragraph {j+1}:')
                # Clean up for readability
                clean_p = re.sub(r'\s+', ' ', p)
                print(f'  {clean_p[:200]}...')
                
                # Check for fldChar types
                fldchars = re.findall(r'<w:fldChar[^>]*w:fldCharType="([^"]*)"[^>]*/>', p)
                if fldchars:
                    print(f'    fldChar types: {fldchars}')
                
                # Check for instrText
                instrtexts = re.findall(r'<w:instrText[^>]*>(.*?)</w:instrText>', p)
                if instrtexts:
                    print(f'    instrText: {instrtexts}')
                
                # Check for any text elements
                texts = re.findall(r'<w:t[^>]*>(.*?)</w:t>', p)
                if texts:
                    print(f'    text elements: {texts}')
                    
                # Check for fldSimple (the problematic one)
                if 'fldSimple' in p:
                    print('    *** CONTAINS FldSimple ***')
                    simples = re.findall(r'<w:fldSimple[^>]*>(.*?)</w:fldSimple>', p, re.DOTALL)
                    for simple in simples:
                        print(f'      fldSimple content: {simple[:100]}...')
                        
    print("\n=== CHECKING FOR ANY PAGE1 REFERENCES IN ENTIRE DOC ===")
    # Get all XML content and search for page1
    all_content = ""
    for filename in z.namelist():
        if filename.endswith('.xml'):
            try:
                content = z.read(filename).decode('utf-8')
                all_content += content + "\n"
            except:
                pass  # Skip binary files
                
    if 'page1' in all_content.lower():
        print("FOUND 'page1' somewhere in the document XML!")
        # Show context
        import re
        matches = re.findall(r'.{0,50}page1.{0,50}', all_content, re.IGNORECASE)
        for match in matches[:10]:
            print(f'  ...{match}...')
    else:
        print("No 'page1' found in any XML content")
        
    print("\n=== CHECKING FOR FIELD RESULTS THAT MIGHT SHOW AS 1 ===")
    # Look for any field results that might be displaying as 1
    # These would be in w:t elements that contain just numbers
    if '<w:t>' in all_content:
        t_matches = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', all_content)
        numeric_ts = [t for t in t_matches if t.strip().isdigit() and len(t.strip()) <= 4]
        if numeric_ts:
            print(f"Found {len(numeric_ts)} numeric text elements: {numeric_ts[:10]}")
        else:
            print("No small numeric text elements found")