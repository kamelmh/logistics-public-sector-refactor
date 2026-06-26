"""
Minimal COM test — replicate the EXACT code that worked the first time.
"""
import win32com.client
import os
import sys

docx_path = os.path.abspath(sys.argv[1])
logo1_path = os.path.abspath(sys.argv[2])
logo2_path = os.path.abspath(sys.argv[3])

print(f"DOCX: {docx_path}", flush=True)

word = win32com.client.Dispatch("Word.Application")
word.Visible = False
word.DisplayAlerts = False

doc = word.Documents.Open(docx_path, ReadOnly=False)
print(f"Opened: {doc.Paragraphs.Count} paras", flush=True)

# --- TOC: find heading, insert field (EXACT v2 code) ---
toc_heading_found = False
for i in range(1, doc.Paragraphs.Count + 1):
    p = doc.Paragraphs(i)
    if "فهرس المحتويات" in p.Range.Text and p.Style.NameLocal == "Heading 2":
        toc_heading_found = True
        print(f"TOC heading found at para {i}", flush=True)
        p.Range.InsertParagraphAfter()
        print("  InsertParagraphAfter done", flush=True)
        new_range = doc.Paragraphs(i + 1).Range
        new_range.Fields.Add(new_range, -1, r'TOC \o "1-3" \h \z \u', True)
        print("  TOC field added", flush=True)
        break

if not toc_heading_found:
    print("WARNING: TOC heading not found", flush=True)

# --- TOF: find heading, insert field ---
tof_heading_found = False
for i in range(1, doc.Paragraphs.Count + 1):
    p = doc.Paragraphs(i)
    if "قائمة الجداول" in p.Range.Text and p.Style.NameLocal == "Heading 2":
        tof_heading_found = True
        print(f"TOF heading found at para {i}", flush=True)
        p.Range.InsertParagraphAfter()
        print("  InsertParagraphAfter done", flush=True)
        new_range = doc.Paragraphs(i + 1).Range
        new_range.Fields.Add(new_range, -1, r'TOC \h \z \c "جدول"', True)
        print("  TOF field added", flush=True)
        break

if not tof_heading_found:
    print("WARNING: TOF heading not found", flush=True)

# --- Logos ---
for label, path, left in [("Logo1", logo1_path, 36), ("Logo2", logo2_path, 432)]:
    if os.path.exists(path):
        try:
            shape = doc.Shapes.AddPicture(
                FileName=os.path.abspath(path),
                LinkToFile=False, SaveWithDocument=True,
                Left=left, Top=36, Width=108, Height=108
            )
            shape.WrapFormat.Type = 3
            print(f"{label} placed", flush=True)
        except Exception as e:
            print(f"{label} FAILED: {e}", flush=True)
    else:
        print(f"SKIP: {label}", flush=True)

# --- Update fields ---
print("Updating fields...", flush=True)
word.Selection.WholeStory()
word.Selection.Fields.Update()
print("Fields updated", flush=True)

# --- Save ---
doc.Save()
print("SAVED", flush=True)

doc.Close(SaveChanges=False)
word.Quit()
print("DONE", flush=True)
