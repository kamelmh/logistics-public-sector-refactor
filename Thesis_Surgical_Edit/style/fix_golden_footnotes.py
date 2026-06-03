"""fix_golden_footnotes.py — Fix namespace declarations in golden source DOCX"""
import zipfile, shutil, os, sys

MISSING_NS = [
    ('w14', 'http://schemas.microsoft.com/office/word/2010/wordml'),
    ('w15', 'http://schemas.microsoft.com/office/word/2012/wordml'),
    ('w16se', 'http://schemas.microsoft.com/office/word/2015/wordml/symex'),
    ('w16cid', 'http://schemas.microsoft.com/office/word/2016/wordml/cid'),
    ('wp14', 'http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing'),
]

def fix_xml(content_str):
    """Add missing namespace declarations to root element."""
    added = 0
    for prefix, uri in MISSING_NS:
        attr = f'xmlns:{prefix}="'
        if attr not in content_str:
            # Insert before the closing > of the root opening tag
            # Find first >
            idx = content_str.find('>')
            if idx > 0:
                content_str = content_str[:idx] + f' xmlns:{prefix}="{uri}"' + content_str[idx:]
                added += 1
    return content_str, added


def fix_docx(docx_path):
    backup = docx_path.replace('.docx', '_pre_nsfix.docx')
    shutil.copy2(docx_path, backup)
    print(f"Backup: {backup}")

    targets = ['word/footnotes.xml', 'word/endnotes.xml']

    with zipfile.ZipFile(docx_path, 'r') as z:
        entries = {}
        for name in z.namelist():
            data = z.read(name)
            if name in targets:
                print(f"\nFixing: {name}")
                content = data.decode('utf-8')
                content, added = fix_xml(content)
                print(f"  Added {added} namespace declarations")
                data = content.encode('utf-8')
            entries[name] = data

    tmp = docx_path + '.tmp'
    with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
        for name, data in entries.items():
            zout.writestr(name, data)
    os.replace(tmp, docx_path)
    print(f"\nSaved: {docx_path} ({os.path.getsize(docx_path)} bytes)")

    from docx import Document
    doc = Document(docx_path)
    print(f"python-docx: OK, {len(doc.paragraphs)} paragraphs")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python fix_golden_footnotes.py <path/to.docx>")
        sys.exit(1)
    fix_docx(sys.argv[1])
