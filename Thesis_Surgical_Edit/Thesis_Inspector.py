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
                
                # Scan for text boxes
                text_boxes = root.findall('.//w:txbxContent', ns)
                for i, box in enumerate(text_boxes):
                    text = "".join([t.text for t in box.iter() if t.text])
                    if text.strip():
                        findings.append({
                            'type': 'text_box',
                            'index': i,
                            'content': text.strip()
                        })
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def scan_captions_alignment(docx_path):
    """
    Scans document.xml for captions and checks bidi/rtl alignment.
    Excludes TOC entries and raw field codes.
    """
    findings = []
    # More specific patterns to avoid flagging normal body text
    caption_patterns = ['Figure ', 'Table ', 'Tableau ', 'شكل ', 'جدول رقم']
    
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
                        
                    # Only check paragraphs that actually look like captions
                    if any(p_text.startswith(pat) or f" {pat}" in p_text for pat in caption_patterns):
                        # 1. Check paragraph-level properties (pPr)
                        p_props = p.find('w:pPr', ns)
                        p_bidi = None
                        p_rtl = None
                        if p_props is not None:
                            p_bidi = p_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi')
                            p_rtl = p_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl')
                        
                        # If paragraph is already RTL, it's fine
                        if p_bidi == '1' and p_rtl == '1':
                            continue

                        # 2. Check individual runs
                        runs = p.findall('.//w:r', ns)
                        has_arabic_text = False
                        all_arabic_runs_fixed = True
                        
                        for run in runs:
                            run_text = "".join([t.text for t in run.iter() if t.text])
                            # Simple check for Arabic characters
                            if any('\u0600' <= c <= '\u06FF' for c in run_text):
                                has_arabic_text = True
                                run_props = run.find('w:rPr', ns)
                                if run_props is None:
                                    all_arabic_runs_fixed = False
                                else:
                                    bidi = run_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi')
                                    rtl = run_props.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl')
                                    if bidi != '1' or rtl != '1':
                                        all_arabic_runs_fixed = False
                                        break
                        
                        if has_arabic_text and not all_arabic_runs_fixed:
                            if any(pat in p_text for pat in ['شكل ', 'جدول رقم']):
                                # Debug: find the first problematic run to see its attributes
                                for run in runs:
                                    run_text = "".join([t.text for t in run.iter() if t.text])
                                    if any('\u0600' <= c <= '\u06FF' for c in run_text):
                                        rp = run.find('w:rPr', ns)
                                        rb = rp.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi') if rp is not None else 'None'
                                        rr = rp.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl') if rp is not None else 'None'
                                        print(f"DEBUG: Problematic run in {p_text[:30]}... RunBidi={rb}, RunRtl={rr}, PBidi={p_bidi}, PRtl={p_rtl}")
                                        break
                                findings.append({
                                    'type': 'alignment_error',
                                    'text': p_text[:50],
                                    'issue': 'Arabic caption missing bidi=1 or rtl=1',
                                    'bidi': p_bidi,
                                    'rtl': p_rtl
                                })
                            elif any(pat in p_text for pat in ['Figure ', 'Table ', 'Tableau ']):
                                pass
    except Exception as e:
        findings.append({'error': str(e)})
        
    return findings

def perform_visual_audit(docx_path):
    """
    Uses COM to verify rendered footer text on sample pages.
    """
    findings = []
    try:
        pages_to_check = [2, 10, 20]
        for pg in pages_to_check:
            text = verify_footer_text(docx_path, pg)
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
    
    for scan_name, results in report['scans'].items():
        if results:
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
