"""inspect_xlsm.py — ERP workbook structure explorer"""
import zipfile, os, re
from pathlib import Path
from xml.etree import ElementTree as ET

PROJECT_ROOT = Path(__file__).resolve().parent.parent
xlsm = str(PROJECT_ROOT / 'ERP_v13.4.xlsm')
ns_x = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'

with zipfile.ZipFile(xlsm, 'r') as z:
    # Sheet names
    wb = ET.fromstring(z.read('xl/workbook.xml'))
    sheets = wb.findall(f'.//{{{ns_x}}}sheet')
    print('=== SHEETS (25) ===')
    for s in sheets:
        print(f'  {s.get("name", "?")}')
    
    # Styles
    styles = ET.fromstring(z.read('xl/styles.xml'))
    fonts = styles.find(f'.//{{{ns_x}}}fonts')
    fills = styles.find(f'.//{{{ns_x}}}fills')
    borders = styles.find(f'.//{{{ns_x}}}borders')
    cellxfs = styles.find(f'.//{{{ns_x}}}cellXfs')
    print(f'\n=== FORMATTING ===')
    print(f'  Fonts: {len(fonts)}' if fonts is not None else '  No fonts')
    print(f'  Fills: {len(fills)}' if fills is not None else '  No fills')
    print(f'  Cell formats: {len(cellxfs)}' if cellxfs is not None else '  No cellxfs')
    
    # Largest sheets
    print(f'\n=== SHEET SIZES ===')
    sheets_xml = {}
    for name in z.namelist():
        if name.startswith('xl/worksheets/sheet') and name.endswith('.xml'):
            idx = int(name.split('sheet')[-1].split('.')[0])
            sheets_xml[idx] = z.getinfo(name).file_size
    
    for idx in sorted(sheets_xml):
        size = sheets_xml[idx]
        name = sheets[idx-1].get('name', f'Sheet{idx}') if idx <= len(sheets) else f'Sheet{idx}'
        bar = '#' * (size // 1000)
        print(f'  {name:30s} {size:>6}B {bar}')
    
    # VBA binary analysis
    print(f'\n=== VBA MODULES ===')
    vba = z.read('xl/vbaProject.bin')
    
    # Find module names in VBA binary
    # OLE compound document format - look for PROJECT strings
    text = vba.decode('latin-1', errors='replace')
    modules = re.findall(r'Module=([^\r\n]+)', text)
    for m in modules:
        print(f'  {m.strip()}')
    
    # Find user forms
    forms = re.findall(r'Document=([^\r\n]+/[^\r\n]*)', text)
    for f in forms:
        print(f'  [Form] {f.strip()}')
    
    # VBA size
    print(f'\n  Total VBA size: {len(vba)//1024}KB')
    print(f'  XLSM total size: {os.path.getsize(xlsm)//1024}KB')
