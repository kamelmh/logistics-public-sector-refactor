"""vba_module_map.py — Map VBA module sizes and procedures"""
import zipfile, re

xlsm = r'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.2.xlsm'
with zipfile.ZipFile(xlsm, 'r') as z:
    vba = z.read('xl/vbaProject.bin')
    text = vba.decode('latin-1', errors='replace')

modules = re.findall(r'Module=([^\r\n]+)', text)
results = []
for m in modules:
    m = m.strip()
    if not m:
        continue
    idx = text.find(f'Attribute VB_Name = "{m}"')
    if idx == -1:
        continue
    end_idx = text.find('Attribute VB_Name = "', idx + 50)
    if end_idx == -1:
        end_idx = len(text)
    body = text[idx:end_idx]
    lines = len(body.split('\n'))
    subs = len(re.findall(r'\b(Sub|Function|Property Get|Property Let|Property Set)\s+\w+', body))

    # Classify module
    if m.startswith('mod_'):
        cat = 'Standard'
    elif m == 'MAIN_MACROS':
        cat = 'EntryPoint'
    elif m == 'ThisWorkbook':
        cat = 'Workbook'
    else:
        cat = 'Sheet'

    results.append((cat, m, lines, subs))

# Sort by category then size
results.sort(key=lambda r: (r[0], -r[2]))

print(f'{"Category":15s} {"Module":30s} {"Lines":>5s} {"Procs":>4s}')
print('-' * 60)
total_lines = 0
total_procs = 0
for cat, m, lines, subs in results:
    total_lines += lines
    total_procs += subs
    print(f'{cat:15s} {m:30s} {lines:5d} {subs:4d}')

print('-' * 60)
print(f'{"TOTAL":46s} {total_lines:5d} {total_procs:4d}')
print(f'Estimated code lines (no attributes): ~{total_lines - len(results) * 10}')
