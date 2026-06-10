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
            
            # Find fldSimple with PAGE instruction
            # Use XPath to find fldSimple elements
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
            # Find all txbxContent elements
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
    """
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    doc_path = os.path.join(docx_dir, 'word', 'document.xml')
    
    tree = etree.parse(doc_path)
    root = tree.getroot()
    
    modified = False
    paragraphs = root.xpath('.//w:p', namespaces=ns)
    
    for p in paragraphs:
        p_text = etree.tostring(p, method='text', encoding='unicode')
        
        # Check for Arabic keywords
        if any(kw in p_text for kw in ['شكل', 'جدول']):
            # Find all runs and ensure they have bidi=1, rtl=1
            runs = p.xpath('.//w:r', namespaces=ns)
            if not runs:
                continue
                
            for run in runs:
                rPr = run.find('w:rPr', ns)
                if rPr is None:
                    rPr = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
                
                if rPr.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi') != '1' or \
                   rPr.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl') != '1':
                    rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi', '1')
                    rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl', '1')
                    modified = True
        
        # Check for French/English keywords
        elif any(kw in p_text for kw in ['Figure', 'Table', 'Tableau']):
            runs = p.xpath('.//w:r', namespaces=ns)
            if not runs:
                continue
            for run in runs:
                rPr = run.find('w:rPr', ns)
                if rPr is None:
                    rPr = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
                
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
    
    # Create a temporary directory to unpack the DOCX
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            z.extractall(temp_dir)
            
        # Apply fixes
        clear_page_field_cache(temp_dir)
        remove_ghost_text(temp_dir, report_json)
        fix_caption_alignment(temp_dir, report_json)
        
        # Pack it back up
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
