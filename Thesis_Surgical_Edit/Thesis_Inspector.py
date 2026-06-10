import os
import zipfile
import xml.etree.ElementTree as ET
import json
from Thesis_COM_Control import verify_footer_text

def scan_xml_for_page1_bug(docx_path):
    """
    Scans footer XML files for cached PAGE field values.
    """
    findings = []
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            footer_files = [f for f in z.namelist() if f.startswith('word/footer')]
            for f_file in footer_files:
                with z.open(f_file) as f:
                    tree = ET.parse(f)
                    root = tree.getroot()
                    
                    # Namespace for word processing
                    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
                    
                    # Check for fldSimple with PAGE instruction and cached text
                    for fld in root.findall('.//w:fldSimple', ns):
                        instr = fld.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}instr', '')
                        if 'PAGE' in instr and fld.text and fld.text.strip():
                            findings.append({
                                'file': f_file,
                                'type': 'cached_page_field',
                                'value': fld.text.strip(),
                                'instruction': instr
                            })
                            
                    # Check for instrText containing PAGE with surrounding text
                    for instr_text in root.findall('.//w:instrText', ns):
                        if 'PAGE' in instr_text.text and instr_text.text:
                            # This is more common for complex fields, but we look for surrounding text
                            # In a real scenario, we'd check the parent/siblings for text
                            pass 
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def scan_for_ghost_text(docx_path):
    """
    Scans document.xml for stray text boxes or paragraphs that might be 'ghost text'.
    """
    findings = []
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            with z.open('word/document.xml') as f:
                tree = ET.parse(f)
                root = tree.getroot()
                ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
                
                # Scan for text boxes (often used for 'ghost' labels or stray notes)
                text_boxes = root.findall('.//w:txbxContent', ns)
                for i, box in enumerate(text_boxes):
                    text = "".join([t.text for t in box.iter() if t.text])
                    if text.strip():
                        findings.append({
                            'type': 'text_box',
                            'index': i,
                            'content': text.strip()
                        })
                
                # Scan for paragraphs with very high spacing or odd properties 
                # (Simplification: look for empty paragraphs with specific formatting if known)
                # For now, we focus on text boxes as they are common 'ghosts'.
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def scan_captions_alignment(docx_path):
    """
    Scans document.xml for captions and checks bidi/rtl alignment.
    Excludes TOC entries and raw field codes.
    """
    findings = []
    # Keywords for captions in English, French, and Arabic
    caption_keywords = ['Figure', 'Table', 'Tableau', 'شكل', 'جدول']
    
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            with z.open('word/document.xml') as f:
                tree = ET.parse(f)
                root = tree.getroot()
                ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
                
                def is_in_toc(p_elem, p_text):
                    """Check if paragraph is a TOC entry."""
                    if 'TOC' in p_text.upper() or 'PAGEREF' in p_text.upper():
                        return True
                        
                    parent_map = {c: p for p in root.iter() for c in p}
                    current = p_elem
                    while current in parent_map:
                        parent = parent_map[current]
                        if parent.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sdt':
                            sdt_pr = parent.find('w:sdtPr', ns)
                            if sdt_pr is not None:
                                alias = sdt_pr.find('w:alias', ns)
                                tag = sdt_pr.find('w:tag', ns)
                                if alias is not None and 'TOC' in alias.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '').upper():
                                    return True
                                if tag is not None and 'TOC' in tag.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '').upper():
                                    return True
                                if sdt_pr.find('w:toc', ns) is not None:
                                    return True
                        current = parent
                    return False
                
                for p in root.findall('.//w:p', ns):
                    p_text = "".join([t.text for t in p.iter() if t.text])
                    
                    # Skip TOC entries and raw field codes (SEQ, PAGEREF)
                    if is_in_toc(p, p_text) or 'SEQ ' in p_text or 'PAGEREF' in p_text:
                        continue
                        
                    if any(kw in p_text for kw in caption_keywords):
                        # Find properties
                        p_props = p.find('w:pPr', ns)
                        if p_props is not None:
                            runs = p.findall('.//w:r', ns)
                            for run in runs:
                                run_props = run.find('w:rPr', ns)
                                if run_props is not None:
                                    bidi = run_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi')
                                    rtl = run_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl')
                                    
                                    # Check Arabic
                                    if any(kw in p_text for kw in ['شكل', 'جدول']):
                                        if bidi != '1' or rtl != '1':
                                            findings.append({
                                                'type': 'alignment_error',
                                                'text': p_text[:50],
                                                'issue': 'Arabic caption missing bidi=1 or rtl=1',
                                                'bidi': bidi,
                                                'rtl': rtl
                                            })
                                    # Check French/English
                                    elif any(kw in p_text for kw in ['Figure', 'Table', 'Tableau']):
                                        if bidi == '1':
                                            findings.append({
                                                'type': 'alignment_error',
                                                'text': p_text[:50],
                                                'issue': 'French/English caption has bidi=1',
                                                'bidi': bidi,
                                                'rtl': rtl
                                            })
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def perform_visual_audit(docx_path):
    """
    Uses COM to verify rendered footer text on sample pages.
    """
    findings = []
    try:
        # Sample pages
        pages_to_check = [2, 10, 20]
        # Get last page
        # We can't easily get last page without opening it, 
        # but we can try a high number or just use a few.
        # For the purpose of this tool, we'll stick to a few and a final check.
        
        for pg in pages_to_check:
            text = verify_footer_text(docx_path, pg)
            # Check if text is just "1" or similar when it should be the page number
            # If page 2 has "1", it's a bug.
            if text == "1" and pg != 1:
                findings.append({
                    'page': pg,
                    'issue': 'Footer rendered as "1" on non-page-1',
                    'text': text
                })
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def generate_audit_report(docx_path, report_path):
    """
    Combines all scans into a JSON report.
    """
    print(f"Starting deep scan of {docx_path}...")
    
    report = {
        'document': docx_path,
        'scans': {
            'page1_bug': scan_xml_for_page1_bug(docx_path),
            'ghost_text': scan_for_ghost_text(docx_path),
            'captions_alignment': scan_captions_alignment(docx_path),
            'visual_audit': perform_visual_audit(docx_path)
        },
        'status': 'PASS'
    }
    
    # Determine overall status
    for scan_name, results in report['scans'].items():
        if results:
            # If any results were found, it's a FAIL (since these are anomalies)
            report['status'] = 'FAIL'
            break
            
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=4, ensure_ascii=False)
        
    return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python Thesis_Inspector.py <doc_path>")
    else:
        doc_path = sys.argv[1]
        report_path = "thesis_audit_report.json"
        result = generate_audit_report(doc_path, report_path)
        print(f"Audit complete. Status: {result['status']}")
        print(f"Report saved to {report_path}")
