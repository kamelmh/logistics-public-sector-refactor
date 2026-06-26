from docx import Document
doc = Document(r'D:\New folder\19-06\Memoire_DSS_Logistique_ElBayadh.docx')

# Fix specific paragraph
for p in doc.paragraphs:
    for run in p.runs:
        text = run.text
        # Fix the inconsistent calculation
        text = text.replace('618,000 دج (789 × 4,500 = 3,550,500)', '3,550,500 دج (789 × 4,500 = 3,550,500)')
        text = text.replace('618000 دج (789 × 4500 = 3550500)', '3550500 دج (789 × 4500 = 3550500)')
        run.text = text

doc.save(r'D:\New folder\19-06\Memoire_DSS_Logistique_ElBayadh.docx')
print('Fixed paragraph 336!')