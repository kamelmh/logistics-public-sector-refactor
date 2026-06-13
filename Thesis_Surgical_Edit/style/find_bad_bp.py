import sys
from docx import Document

doc = Document(r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx")
body_styles = ['Normal', 'Compact', 'Body Text', 'List Paragraph', 'No Spacing']
bp = [p for p in doc.paragraphs if p.style and p.style.name in body_styles]
sample_len = min(len(bp), 80)

print(f"Sample length: {sample_len}")
for i, p in enumerate(bp[:sample_len]):
    if p.runs:
        first_run = p.runs[0]
        fs = first_run.font.size
        fs_pt = fs.pt if fs else None
        if fs_pt is not None and fs_pt != 14:
            print(f"Index {i}: Text='{p.text[:40]}', Style='{p.style.name}', Font Size={fs_pt}")
