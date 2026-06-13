"""Fix pgNumType in document.xml after doc.save() regenerates it"""
import zipfile, tempfile, os, re

path = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
W_NS = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

fd, tmp = tempfile.mkstemp(suffix='.tmp', dir=os.path.dirname(path))
os.close(fd)
with zipfile.ZipFile(path, 'r') as zin:
    with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.namelist():
            if item == 'word/document.xml':
                raw = zin.read(item).decode('utf-8')
                # Fix pgNumType in sectPr
                def fix_pgnum(m):
                    s = m.group(0)
                    # Remove existing pgNumType
                    s = re.sub(r'<w:pgNumType[^/]*/>', '', s)
                    s = re.sub(r'<w:pgNumType[^>]*></w:pgNumType>', '', s)
                    # Add correct pgNumType
                    pg = '<w:pgNumType xmlns:w="' + W_NS + '" w:fmt="decimal" w:start="1"/>'
                    if '<w:titlePg' in s:
                        s = s.replace('<w:titlePg', pg + '<w:titlePg')
                    else:
                        s = s.replace('<w:sectPr', '<w:sectPr' + pg)
                    return s
                raw = re.sub(r'<w:sectPr\b[^>]*>.*?</w:sectPr>', fix_pgnum, raw, flags=re.DOTALL)
                zout.writestr(item, raw.encode('utf-8'))
            else:
                zout.writestr(item, zin.read(item))
os.replace(tmp, path)
print('Fixed pgNumType in document.xml')