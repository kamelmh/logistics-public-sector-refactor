import os
import zipfile
import json
import shutil
import tempfile
from lxml import etree

def clear_page_field_cache(docx_dir):
    """
    Finds footer XML files and removes the cached text results from PAGE fields.
    """
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    footer_dir = os.path.join(docx_dir, 'word')
    
    for filename in os.listdir(footer_dir):
        if filename.startswith('footer') and filename.endswith('.xml'):
            filepath = os.path.join(footer_dir, filename)
            tree = etree.parse(filepath)
            root = tree.getroot()
            
            flds = root.xpath('.//w:fldSimple', namespaces=ns)
            modified = False
            for fld in flds:
                instr = fld.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}instr', '')
                if 'PAGE' in instr and fld.text:
                    fld.text = None
                    modified = True
            
            if modified:
                tree.write(filepath, encoding='UTF-8', xml_declaration=True, standalone=True)
                print(f"Cleared page field cache in {filename}")

def remove_ghost_text(docx_dir, report_json):
    """
    Removes stray text boxes or paragraphs flagged by the Inspector.
    """
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    doc_path = os.path.join(docx_dir, 'word', 'document.xml')
    
    ghosts = report_json.get('scans', {}).get('ghost_text', [])
    if not ghosts:
        return

    tree = etree.parse(doc_path)
    root = tree.getroot()
    
    modified = False
    for ghost in ghosts:
        if ghost.get('type') == 'text_box':
            text_boxes = root.xpath('.//w:txbxContent', namespaces=ns)
            idx = ghost.get('index')
            if idx is not None and 0 <= idx < len(text_boxes):
                box = text_boxes[idx]
                box.getparent().remove(box)
                modified = True
                print(f"Removed ghost text box at index {idx}")
    
    if modified:
        tree.write(doc_path, encoding='UTF-8', xml_declaration=True, standalone=True)

def fix_caption_alignment(docx_dir, report_json):
    """
    Fixes caption alignment by scanning for keywords and applying bidi/rtl.
    Excludes TOC entries.
    """
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    doc_path = os.path.join(docx_dir, 'word', 'document.xml')
    
    tree = etree.parse(doc_path)
    root = tree.getroot()
    
    def is_in_toc(p_elem):
        """Check if paragraph is inside a TOC SDT."""
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

    modified = False
    paragraphs = root.xpath('.//w:p', namespaces=ns)
    
    for p in paragraphs:
        if is_in_toc(p):
            continue
            
        p_text = etree.tostring(p, method='text', encoding='unicode')
        
        # Use the same logic as the Inspector: check for specific patterns
        caption_patterns = ['Figure ', 'Table ', 'Tableau ', 'شكل ', 'جدول رقم']
        if any(p_text.startswith(pat) or f" {pat}" in p_text for pat in caption_patterns):
            runs = p.xpath('.//w:r', namespaces=ns)
            if not runs:
                continue
                
            for run in runs:
                rPr = run.find('w:rPr', ns)
                if rPr is None:
                    rPr = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
                
                # Force RTL for all runs in an Arabic caption
                if any(pat in p_text for pat in ['شكل ', 'جدول رقم']):
                    rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi', '1')
                    rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl', '1')
                    modified = True
                elif any(pat in p_text for pat in ['Figure ', 'Table ', 'Tableau ']):
                    if rPr.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi') == '1':
                        rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi', '0')
                        modified = True
        
    if modified:
        tree.write(doc_path, encoding='UTF-8', xml_declaration=True, standalone=True)
        print("Fixed caption alignments (comprehensive scan)")

def apply_fixes_from_report(docx_path, report_json, output_path):
    """
    Orchestrates the fix process.
    """
    print(f"Applying fixes to {docx_path}...")
    
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            z.extractall(temp_dir)
            
        clear_page_field_cache(temp_dir)
        remove_ghost_text(temp_dir, report_json)
        fix_caption_alignment(temp_dir, report_json)
        
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as z:
            for root, dirs, files in os.walk(temp_dir):
                for file in files:
                    full_path = os.path.join(root, file)
                    arcname = os.path.relpath(full_path, temp_dir)
                    z.write(full_path, arcname)
        
        print(f"Fixed document saved to {output_path}")
        
    finally:
        shutil.rmtree(temp_dir)

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python Thesis_Fixer.py <doc_path> <report_json>")
    else:
        doc_path = sys.argv[1]
        report_path = sys.argv[2]
        
        with open(report_path, 'r', encoding='utf-8') as f:
            report_json = json.load(f)
            
        output_path = doc_path.replace('.docx', '_fixed.docx')
        apply_fixes_from_report(doc_path, report_json, output_path)
        print(f"Process complete. Fixed file: {output_path}")
