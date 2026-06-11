"""
Surgical Fix: Caption RTL + Page Numbering
Fixes w:bidi=1 on all captions and pgNumType in sectPr
"""
import sys
import os
from lxml import etree

NSMAP = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
    'mc': 'http://schemas.openxmlformats.org/markup-compatibility/2006',
}

def fix_caption_bidi(body):
    """Add w:bidi=1 to all paragraphs containing جدول or شكل."""
    fixed = 0
    for para in body.findall('.//w:p', NSMAP):
        text = ''.join(para.itertext())
        if 'جدول' in text or 'شكل' in text:
            pPr = para.find('w:pPr', NSMAP)
            if pPr is None:
                pPr = etree.SubElement(para, '{%s}pPr' % NSMAP['w'])
                # Move pPr to first position
                para.remove(pPr)
                para.insert(0, pPr)
            
            bidi = pPr.find('w:bidi', NSMAP)
            if bidi is None:
                bidi = etree.SubElement(pPr, '{%s}bidi' % NSMAP['w'])
                fixed += 1
            elif bidi.get('{%s}val' % NSMAP['w']) != '1':
                bidi.set('{%s}val' % NSMAP['w'], '1')
                fixed += 1
    
    return fixed

def fix_page_numbering(doc_xml):
    """Ensure sectPr has pgNumType with decimal start=4."""
    body = doc_xml.find('.//w:body', NSMAP)
    if body is None:
        return False
    
    # Find all sectPr elements
    sectprs = body.findall('.//w:sectPr', NSMAP)
    if not sectprs:
        print("  [WARN] No sectPr found")
        return False
    
    fixed = False
    for i, sectPr in enumerate(sectprs):
        pgNumType = sectPr.find('w:pgNumType', NSMAP)
        if pgNumType is None:
            pgNumType = etree.SubElement(sectPr, '{%s}pgNumType' % NSMAP['w'])
        
        # First section (TOC): decimal start=4
        if i == 0:
            pgNumType.set('{%s}fmt' % NSMAP['w'], 'decimal')
            pgNumType.set('{%s}start' % NSMAP['w'], '4')
            fixed = True
            print(f"  [FIX] sectPr[{i}]: decimal start=4")
        else:
            # Other sections: decimal continue
            pgNumType.set('{%s}fmt' % NSMAP['w'], 'decimal')
            # Remove start to allow continuation
            if '{%s}start' % NSMAP['w'] in pgNumType.attrib:
                del pgNumType.attrib['{%s}start' % NSMAP['w']]
            fixed = True
            print(f"  [FIX] sectPr[{i}]: decimal continue")
    
    return fixed

def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_thesis_surgical.py <docx_path>")
        sys.exit(1)
    
    docx_path = sys.argv[1]
    
    # Check if file exists
    if not os.path.exists(docx_path):
        print(f"  [ERROR] File not found: {docx_path}")
        sys.exit(1)
    
    print(f"\n  Surgical Fix: {os.path.basename(docx_path)}")
    print(f"  Size: {os.path.getsize(docx_path) / 1024:.1f} KB")
    
    # Read the DOCX as a ZIP and modify word/document.xml
    import zipfile
    import shutil
    import tempfile
    
    # Create backup
    backup_path = docx_path + '.bak'
    shutil.copy2(docx_path, backup_path)
    print(f"  Backup: {os.path.basename(backup_path)}")
    
    # Extract, modify, repack
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as zin:
            zin.extractall(temp_dir)
        
        # Parse document.xml
        doc_xml_path = os.path.join(temp_dir, 'word', 'document.xml')
        parser = etree.XMLParser(remove_blank_text=False)
        doc_xml = etree.parse(doc_xml_path, parser)
        root = doc_xml.getroot()
        
        # Fix 1: Caption RTL
        body = root.find('.//{%s}body' % NSMAP['w'])
        bidi_fixed = fix_caption_bidi(body)
        print(f"  [FIX] Caption RTL: {bidi_fixed} paragraphs updated")
        
        # Fix 2: Page numbering
        pn_fixed = fix_page_numbering(root)
        
        # Save document.xml
        doc_xml.write(doc_xml_path, xml_declaration=True, encoding='UTF-8', standalone=True)
        
        # Repack DOCX
        with zipfile.ZipFile(docx_path, 'w', zipfile.ZIP_DEFLATED) as zout:
            for dirpath, dirnames, filenames in os.walk(temp_dir):
                for filename in filenames:
                    file_path = os.path.join(dirpath, filename)
                    arcname = os.path.relpath(file_path, temp_dir)
                    zout.write(file_path, arcname)
        
        print(f"\n  [OK] Fixed and saved: {os.path.basename(docx_path)}")
        print(f"  [OK] Size: {os.path.getsize(docx_path) / 1024:.1f} KB")
        
    finally:
        shutil.rmtree(temp_dir)

if __name__ == "__main__":
    main()
