"""debug-cover.py — Check why cover prepend breaks Word compatibility"""
import zipfile, re, sys

cover_path = sys.argv[1] if len(sys.argv) > 1 else r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\cover-page.docx'
thesis_path = sys.argv[2] if len(sys.argv) > 2 else r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\test-pandoc.docx'

def analyze(name, path):
    print(f"\n{'='*60}")
    print(f"  {name}: {path}")
    print(f"{'='*60}")
    try:
        z = zipfile.ZipFile(path)
        names = z.namelist()
        print(f"Files ({len(names)}):")
        for n in names:
            info = z.getinfo(n)
            print(f"  {n:50s} {info.file_size:>8} bytes")
        
        # Check document.xml for references
        if 'word/document.xml' in names:
            content = z.read('word/document.xml').decode('utf-8')
            rids = re.findall(r'r:id="([^"]+)"', content)
            print(f"\nr:id references: {rids}")
            
            # Check header/footer refs
            hf = re.findall(r'w:(headerReference|footerReference)\s+[^/]+/>', content)
            print(f"Header/Footer refs: {hf}")
            
            # Check footnotes
            fn = re.findall(r'w:footnoteReference\s+w:id="(\d+)"', content)
            print(f"Footnote refs: {fn}")
            
            # Check for comments
            cm = re.findall(r'w:commentReference\s+w:id="(\d+)"', content)
            print(f"Comment refs: {cm}")
        
        # Check relationships
        if 'word/_rels/document.xml.rels' in names:
            rels = z.read('word/_rels/document.xml.rels').decode('utf-8')
            print(f"\nRelationships:")
            for line in rels.split('\n'):
                line = line.strip()
                if line:
                    typem = re.search(r'Type="([^"]+)"', line)
                    targetm = re.search(r'Target="([^"]+)"', line)
                    if typem and targetm:
                        t = typem.group(1).split('/')[-1]
                        tg = targetm.group(1)
                        print(f"  {t:30s} -> {tg}")
        
        z.close()
    except Exception as e:
        print(f"ERROR: {e}")

analyze("COVER", cover_path)
analyze("THESIS (before cover)", thesis_path)

# Also check after prepend
after_path = thesis_path.replace('.docx', '-after-cover.docx')
import shutil, os
if os.path.exists(after_path):
    analyze("THESIS (after cover)", after_path)
