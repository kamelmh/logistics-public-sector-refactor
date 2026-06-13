import zipfile
import re

docx_path = r'Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx'

with zipfile.ZipFile(docx_path, 'r') as z:
    # Check headers
    header_files = [n for n in z.namelist() if 'header' in n.lower()]
    print('Header files:', header_files)
    for hname in header_files:
        content = z.read(hname).decode('utf-8')
        if 'page1' in content.lower():
            print('FOUND page1 in header ' + hname)
        # Check for any fldSimple in headers
        if 'fldSimple' in content:
            print('FOUND fldSimple in header ' + hname)
    print()
    
    # Check document.xml for any obvious issues
    doc_content = z.read('word/document.xml').decode('utf-8')
    # Look for any text runs that might contain 'page1'
    # Find all w:t elements
    t_elements = re.findall(r'<w:t[^>]*>(.*?)</w:t>', doc_content)
    page1_matches = [t for t in t_elements if 'page1' in t.lower()]
    if page1_matches:
        print('FOUND "page1" in document text runs: ' + str(page1_matches[:5]))
    else:
        print('No "page1" found in document text runs')
        
    # Check for fldSimple in main document
    if 'fldSimple' in doc_content:
        print('FOUND fldSimple in main document')
        simples = re.findall(r'<w:fldSimple[^>]*>.*?</w:fldSimple>', doc_content, re.DOTALL)
        print('Found ' + str(len(simples)) + ' fldSimple fields')
        for simple in simples[:3]:
            print('  ' + simple[:100] + '...')
    else:
        print('No fldSimple in main document')
        
    # Also check for any other suspicious field types
    if 'fldChar' in doc_content:
        # This is normal, just count them
        fldchar_count = len(re.findall(r'<w:fldChar[^>]*/>', doc_content))
        print('Found ' + str(fldchar_count) + ' fldChar fields (normal)')
        
    # Check instrText for any suspicious content
    instrtexts = re.findall(r'<w:instrText[^>]*>.*?</w:instrText>', doc_content, re.DOTALL)
    suspicious_instr = [it for it in instrtexts if 'page' in it.lower() and 'num' in it.lower()]
    if suspicious_instr:
        print('Suspicious instrText: ' + str(suspicious_instr))
    else:
        print('No suspicious instrText found')