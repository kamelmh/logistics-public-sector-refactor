import zipfile
import re

docx_path = r'Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    doc_content = z.read('word/document.xml').decode('utf-8')
    
    print("=== DETAILED FIELD ANALYSIS ===")
    
    # Look for complete field structures
    # Pattern: fldChar(begin) ... instrText ... fldChar(separate) ... result ... fldChar(end)
    field_pattern = r'<w:p[^>]*>.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:instrText[^>]*>(.*?)</w:instrText>.*?</w:r>.*?(?:<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="separate"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:t[^>]*>(.*?)</w:t>.*?</w:r>)?.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="end"[^>]*/>.*?</w:r>.*?</w:p>'
    
    matches = re.findall(field_pattern, doc_content, re.DOTALL)
    print(f'Found {len(matches)} complete field structures')
    
    for i, (instr_text, result_text) in enumerate(matches):
        instr_clean = instr_text.strip() if instr_text else ""
        result_clean = result_text.strip() if result_text else ""
        
        # Check for suspicious fields
        if 'page' in instr_clean.lower() or result_clean.isdigit() or result_clean in ['i', 'ii', 'iii', 'iv', 'v']:
            print(f'\nField {i+1}:')
            print(f'  InstrText: "{instr_clean}"')
            print(f'  Result: "{result_clean}"')
            if result_clean and result_clean not in ['', ' ']:
                print(f'  *** HAS RESULT TEXT: "{result_clean}" ***')
                
    # Also look for simpler patterns that might be missing separate char
    print("\n=== CHECKING FOR FIELDS WITHOUT SEPARATE CHAR ===")
    simple_pattern = r'<w:p[^>]*>.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:instrText[^>]*>(.*?)</w:instrText>.*?</w:r>.*?(?:<w:r[^>]*>.*?<w:t[^>]*>(.*?)</w:t>.*?</w:r>)?.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="end"[^>]*/>.*?</w:r>.*?</w:p>'
    
    simple_matches = re.findall(simple_pattern, doc_content, re.DOTALL)
    print(f'Found {len(simple_matches)} fields with simple pattern')
    
    for i, (instr_text, result_text) in enumerate(simple_matches):
        instr_clean = instr_text.strip() if instr_text else ""
        result_clean = result_text.strip() if result_text else ""
        
        if 'page' in instr_clean.lower():
            print(f'\nPAGE Field {i+1}:')
            print(f'  InstrText: "{instr_clean}"')
            print(f'  Result: "{result_clean}"')
            if result_clean:
                print(f'  *** HAS RESULT: "{result_clean}" ***')
                
    # Let's also check the headers and footers for any fields there
    print("\n=== CHECKING HEADERS AND FOOTERS FOR FIELDS ===")
    for part_type in ['header', 'footer']:
        part_files = [n for n in z.namelist() if part_type in n.lower()]
        for pname in part_files:
            try:
                content = z.read(pname).decode('utf-8')
                # Look for any fldSimple in headers/footers
                if 'fldSimple' in content:
                    print(f'  FOUND fldSimple in {pname}')
                    simples = re.findall(r'<w:fldSimple[^>]*>.*?</w:fldSimple>', content, re.DOTALL)
                    for simple in simples:
                        print(f'    {simple[:100]}...')
                # Look for standard fields
                if 'fldChar' in content:
                    # Count field chars
                    begin_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>', content))
                    separate_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="separate"[^>]*/>', content))
                    end_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="end"[^>]*/>', content))
                    if begin_count > 0 or separate_count > 0 or end_count > 0:
                        print(f'  {pname}: {begin_count} begin, {separate_count} separate, {end_count} end fldChar')
            except Exception as e:
                print(f'  Error reading {pname}: {e}')