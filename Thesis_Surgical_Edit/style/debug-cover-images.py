"""Check cover DOCX for embedded images, shapes, or OLE objects."""
import zipfile, re

cover_path = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\cover-page.docx'

with zipfile.ZipFile(cover_path) as z:
    for f in z.namelist():
        info = z.getinfo(f)
        print(f"{f:60s} {info.file_size:>8} bytes")

    doc_xml = z.read('word/document.xml').decode('utf-8')
    embeds = re.findall(r'r:embed="([^"]+)"', doc_xml)
    imagedata = re.findall(r'r:id="([^"]+)"', doc_xml)
    pics = ['<drawing>' if '<w:drawing' in doc_xml or '<wp:' in doc_xml else 'no']
    shapes = re.findall(r'w:(shape|object|ole)', doc_xml)
    
    print(f"\nEmbed references (r:embed): {embeds}")
    print(f"All r:id refs: {imagedata}")
    print(f"Drawings present: {'yes' if '<w:drawing' in doc_xml else 'no'}, {'yes' if '<wp:' in doc_xml else 'no'}")
    print(f"Shapes/OLE: {shapes}")
    
    # Check rels
    if 'word/_rels/document.xml.rels' in z.namelist():
        rels = z.read('word/_rels/document.xml.rels').decode('utf-8')
        print(f"\nRelationships:")
        for line in rels.split('\n'):
            line = line.strip()
            if line and 'Relationship' in line:
                target_m = re.search(r'Target="([^"]+)"', line)
                type_m = re.search(r'Type="([^"]+)"', line)
                id_m = re.search(r'Id="([^"]+)"', line)
                if id_m and type_m and target_m:
                    t = type_m.group(1).split('/')[-1]
                    print(f"  {id_m.group(1):10s} {t:30s} -> {target_m.group(1)}")
    
    # Check for images in media folder
    media_files = [f for f in z.namelist() if 'media' in f.lower() or 'image' in f.lower()]
    print(f"\nMedia files: {media_files}")
    
    # Also check if there's a header or footer in cover
    header_files = [f for f in z.namelist() if 'header' in f.lower()]
    print(f"Header files: {header_files}")
