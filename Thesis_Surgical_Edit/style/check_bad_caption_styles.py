from docx import Document

doc = Document(r"Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx")
indices = [68, 69, 111]
for idx in indices:
    p = doc.paragraphs[idx]
    print(f"Index {idx}: Text='{p.text[:50]}', Style='{p.style.name if p.style else 'None'}'")
