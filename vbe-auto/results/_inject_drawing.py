"""
[DEPRECATED] Drawing injection via zip manipulation.

The button 'Actualiser le Tableau de Bord' is now added directly
to the GOLDEN_ERP_v13.2.xlsm via COM automation (Shapes.AddShape).
The golden master preserves the button across all vbe-auto builds.
Keep this script for reference only -- DO NOT USE, it corrupts zip structure.
"""

import zipfile, os, shutil

output_path = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.2.xlsm'
backup_path = output_path + '.bak3'

# Backup the clean built workbook
shutil.copy2(output_path, backup_path)
print(f'Backed up to {backup_path}')

# Read from the Dropbox version which has the drawing
dropbox_path = r'C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm'
zd = zipfile.ZipFile(dropbox_path, 'r')
drawing_xml = zd.read('xl/drawings/drawing1.xml')
zd.close()
print(f'Read drawing1.xml ({len(drawing_xml)} bytes)')

# Read built workbook
z = zipfile.ZipFile(output_path, 'r')
entries = {name: z.read(name) for name in z.namelist()}
z.close()
print(f'Read built workbook: {len(entries)} entries, {len(entries["xl/vbaProject.bin"])} bytes vba')

# 1. Add drawing XML
entries['xl/drawings/drawing1.xml'] = drawing_xml
entries['xl/drawings/_rels/drawing1.xml.rels'] = b'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>'''

# 2. Add drawing reference to sheet1.xml
s1 = entries['xl/worksheets/sheet1.xml'].decode('utf-8')
if '<drawing' not in s1:
    # Add r namespace if missing
    if 'xmlns:r=' not in s1:
        s1 = s1.replace('<worksheet ', '<worksheet xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ')
    s1 = s1.replace('</worksheet>', '  <drawing r:id="rId2"/>\n</worksheet>')
    entries['xl/worksheets/sheet1.xml'] = s1.encode('utf-8')
    print('Added drawing reference to sheet1.xml')

# 3. Add sheet1.xml.rels
rels_content = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/printerSettings" Target="../printerSettings/printerSettings1.bin"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing1.xml"/>
</Relationships>'''
entries['xl/worksheets/_rels/sheet1.xml.rels'] = rels_content.encode('utf-8')

# 4. Update Content_Types.xml
ct = entries['[Content_Types].xml'].decode('utf-8')
if '/xl/drawings/drawing1.xml' not in ct:
    ct = ct.replace('</Types>', '  <Override PartName="/xl/drawings/drawing1.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/>\n</Types>')
    entries['[Content_Types].xml'] = ct.encode('utf-8')

# Also add drawing rels content type override
if '/xl/drawings/_rels/drawing1.xml.rels' not in ct:
    ct2 = entries['[Content_Types].xml'].decode('utf-8')
    ct2 = ct2.replace('</Types>', '  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n</Types>')
    entries['[Content_Types].xml'] = ct2.encode('utf-8')

# Write new workbook
tmp = output_path + '.tmp'
with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
    for name in sorted(entries.keys()):
        zout.writestr(name, entries[name])
os.replace(tmp, output_path)
print(f'Written to {output_path}')

# Verify
zv = zipfile.ZipFile(output_path, 'r')
has_d = 'xl/drawings/drawing1.xml' in zv.namelist()
has_r = 'xl/worksheets/_rels/sheet1.xml.rels' in zv.namelist()
s1v = zv.read('xl/worksheets/sheet1.xml').decode('utf-8')
has_dr = '<drawing' in s1v
print(f'\nVerification:')
print(f'  drawing1.xml: {has_d}')
print(f'  sheet1.xml.rels: {has_r}')
print(f'  drawing ref in sheet1: {has_dr}')
print(f'  Total entries: {len(zv.namelist())}')
zv.close()
