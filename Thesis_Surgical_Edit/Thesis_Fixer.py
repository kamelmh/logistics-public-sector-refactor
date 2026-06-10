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
    Surgical RTL Fix: Forces bidi=1 and rtl=1 on EVERY run containing Arabic text.
    This ensures all captions and body text are correctly aligned.
    """
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    doc_path = os.path.join(docx_dir, 'word', 'document.xml')
    
    tree = etree.parse(doc_path)
    root = tree.getroot()
    
    modified = False
    # Scan all runs in the entire document
    runs = root.xpath('.//w:r', namespaces=ns)
    
    for run in runs:
        # Get text of the run
        run_text = "".join([t.text for t in run.iter() if t.text])
        
        # If run contains Arabic characters, force RTL
        if any('\u0600' <= c <= '\u06FF' for c in run_text):
            rPr = run.find('w:rPr', ns)
            if rPr is None:
                rPr = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
            
            if rPr.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi') != '1' or \
               rPr.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl') != '1':
                rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bidi', '1')
                rPr.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rtl', '1')
                modified = True
                
    if modified:
        tree.write(doc_path, encoding='UTF-8', xml_declaration=True, standalone=True)
        print("Applied global Arabic RTL fix to all runs.")

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
