import sys, os, zipfile, re, time as _time
import tempfile
import shutil
from xml.etree import ElementTree as ET

def diag_footnotes(docx_path):
    print(f"--- Diagnosing Footnotes in: {docx_path} ---")
    
    tmp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            z.extractall(tmp_dir)
        
        doc_xml_path = os.path.join(tmp_dir, 'word', 'document.xml')
        fn_xml_path = os.path.join(tmp_dir, 'word', 'footnotes.xml')
        
        if not os.path.exists(doc_xml_path):
            print("[ERROR] document.xml not found")
            return
        if not os.path.exists(fn_xml_path):
            print("[ERROR] footnotes.xml not found")
            return
        
        # Namespaces
        NS = {
            'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
        }
        
        # 1. Parse Footnotes to get all valid IDs
        fn_ids = set()
        tree_fn = ET.parse(fn_xml_path)
        for fn in tree_fn.findall('.//w:footnote', NS):
            fid = fn.get(f'{{{NS["w"]}}}id')
            if fid:
                fn_ids.add(fid)
        
        print(f"Found {len(fn_ids)} footnotes in footnotes.xml: {sorted(list(fn_ids), key=lambda x: int(x) if x.isdigit() else 0)}")
        
        # 2. Parse Document to find footnote references
        # Footnote references in document.xml use w:id, not r:id
        ref_ids_in_doc = []
        
        with open(doc_xml_path, 'r', encoding='utf-8') as f:
            doc_content = f.read()
        
        # Regex to find w:id in w:footnoteReference
        # Pattern: <w:footnoteReference[^>]*w:id="([^"]+)"[^>]*/>
        ref_pattern = re.compile(r'<w:footnoteReference[^>]*w:id="([^"]+)"[^>]*/>')
        matches = ref_pattern.findall(doc_content)
        ref_ids_in_doc = matches

        print(f"Found {len(ref_ids_in_doc)} footnote references in document.xml: {ref_ids_in_doc}")
        
        # 3. Check Mapping
        unreferenced_footnotes = []
        referenced_fn_ids = set()

        for fid in ref_ids_in_doc:
            if fid in fn_ids:
                referenced_fn_ids.add(fid)
            else:
                # This might be a broken reference
                pass

        unreferenced_footnotes = fn_ids - referenced_fn_ids

        print("\n--- Results ---")
        if not unreferenced_footnotes:
            print("✅ Footnote mapping is PERFECT.")
        else:
            print(f"❌ UNREFERENCED FOOTNOTES (in footnotes.xml): {len(unreferenced_footnotes)}")
            # Sort unreferenced footnotes numerically if possible
            sorted_unref = sorted(list(unreferenced_footnotes), key=lambda x: int(x) if x.isdigit() else 0)
            for f in sorted_unref:
                print(f"  - {f}")

    finally:
        shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python diag_footnotes.py <path/to.docx>")
    else:
        diag_footnotes(sys.argv[1])
