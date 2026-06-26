from docx import Document
doc = Document('Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx')

# Fix specific paragraph
for p in doc.paragraphs:
    for run in p.runs:
        text = run.text
        # Fix the inconsistent calculation
        text = text.replace('1,546 × 400 = 3,550,500', '789 × 4,500 = 3,550,500')
        text = text.replace('1546 × 400 = 3550500', '789 × 4500 = 3550500')
        run.text = text

doc.save('Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx')
print('Golden source paragraph 342 fixed!')