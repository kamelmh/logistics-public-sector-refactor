from docx import Document
doc = Document('Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx')

# Fix specific paragraphs
for p in doc.paragraphs:
    for run in p.runs:
        text = run.text
        # Fix D=1,546 -> D=789
        text = text.replace('1,546 وحدة', '789 وحدة')
        text = text.replace('1546 وحدة', '789 وحدة')
        text = text.replace('D = 1,546', 'D = 789')
        text = text.replace('D=1,546', 'D=789')
        # Fix daily consumption 6.184 -> 3.156
        text = text.replace('6.184 وحدة', '3.156 وحدة')
        text = text.replace('6.184', '3.156')
        # Fix annual consumption value 618,000 -> 3,550,500
        text = text.replace('618,000 دج', '3,550,500 دج')
        text = text.replace('618,000', '3,550,500')
        # Fix the calculation 1,546 × 400 = 618,000 -> 789 × 4,500 = 3,550,500
        text = text.replace('1,546 × 400 = 618,000', '789 × 4,500 = 3,550,500')
        text = text.replace('1546 × 400 = 618000', '789 × 4500 = 3550500')
        # Fix PU=400 -> PU=4,500
        text = text.replace('400 دج', '4,500 دج')
        text = text.replace('400دج', '4,500 دج')
        run.text = text

doc.save('Thesis_Surgical_Edit/output/Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx')
print('Golden source paragraphs fixed!')