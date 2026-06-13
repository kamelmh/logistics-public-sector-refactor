import sys
from docx import Document

W_NS = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

doc = Document(r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx")
bad_captions = []
total_captions = 0

for i, p in enumerate(doc.paragraphs):
    text = p.text or ""
    if "جدول" in text or "شكل" in text:
        total_captions += 1
        pPr = p._element.find(f'{{{W_NS["w"]}}}pPr')
        if pPr is not None:
            bidi = pPr.find(f'{{{W_NS["w"]}}}bidi')
            if bidi is None:
                bad_captions.append((i, text[:60], "No bidi element"))
        else:
            bad_captions.append((i, text[:60], "No pPr element"))

print(f"Total captions: {total_captions}")
print(f"Bad captions: {len(bad_captions)}")
for item in bad_captions:
    print(item)
