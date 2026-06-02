"""Quick script to verify PAGE field fix in output DOCX."""
import zipfile
import sys

path = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
TARGETS = ['word/footer1.xml', 'word/footer2.xml', 'word/footer3.xml',
           'word/header1.xml', 'word/header2.xml', 'word/header3.xml']

all_ok = True
with zipfile.ZipFile(path, 'r') as z:
    for t in TARGETS:
        if t not in z.namelist():
            print(f"  {t}: NOT FOUND")
            continue
        raw = z.read(t).decode('utf-8', errors='replace')
        sep_pos = raw.find('w:fldCharType="separate"')
        end_pos = raw.find('w:fldCharType="end"', sep_pos if sep_pos >= 0 else 0)
        
        if sep_pos < 0:
            print(f"  {t}: NO SEPARATE (no PAGE field)")
            continue
        
        between = raw[sep_pos:end_pos] if end_pos > 0 else raw[sep_pos:]
        has_text_after = '<w:t>' in between and '</w:t>' in between
        
        if has_text_after:
            print(f"  {t}: ISSUE - has <w:t> after separate (cached PAGE result)")
            all_ok = False
        else:
            print(f"  {t}: OK - no cached PAGE result")

if all_ok:
    print("\nAll footers/headers OK - no cached PAGE results!")
    sys.exit(0)
else:
    print("\nSome files still have cached PAGE results!")
    sys.exit(1)
