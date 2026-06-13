import zipfile
import re

docx_path = r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"

with zipfile.ZipFile(docx_path, 'r') as z:
    # Check relationships
    rels_raw = z.read('word/_rels/document.xml.rels').decode('utf-8')
    print("=== Relationships ===")
    for line in rels_raw.split('>'):
        if 'footer' in line.lower():
            print(f"  {line}>")
    print()
    
    # Check document.xml for all sectPr with footerReference
    doc_raw = z.read('word/document.xml').decode('utf-8')
    sectprs = re.findall(r'<w:sectPr\b[^>]*>.*?</w:sectPr>', doc_raw, re.DOTALL)
    print(f"=== Found {len(sectprs)} sectPr elements ===")
    for i, sectpr in enumerate(sectprs):
        footer_refs = re.findall(r'<w:footerReference[^>]*>', sectpr)
        pgNumType = re.search(r'<w:pgNumType[^>]*>', sectpr)
        print(f"  Section {i}: footerRefs={footer_refs}, pgNumType={pgNumType.group(0) if pgNumType else 'none'}")
    print()
    
    # Check footer3.xml and footer4.xml full content for cached '1'
    for fname in ['word/footer3.xml', 'word/footer4.xml']:
        raw = z.read(fname).decode('utf-8')
        # Find all w:t elements
        wts = re.findall(r'<w:t[^>]*>(.*?)</w:t>', raw)
        print(f"=== {fname} w:t elements ===")
        for wt in wts:
            print(f"  '{wt}'")
        print()
