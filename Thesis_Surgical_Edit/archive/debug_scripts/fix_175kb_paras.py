from docx import Document
doc = Document(r'D:\New folder\19-06\Memoire_DSS_Logistique_ElBayadh.docx')

# Fix paragraphs
for p in doc.paragraphs:
    for run in p.runs:
        text = run.text
        # Fix values
        text = text.replace('1,546 وحدة', '789 وحدة')
        text = text.replace('1546 وحدة', '789 وحدة')
        text = text.replace('D = 1,546', 'D = 789')
        text = text.replace('D=1,546', 'D=789')
        text = text.replace('6.184 وحدة', '3.156 وحدة')
        text = text.replace('6.184', '3.156')
        text = text.replace('618,400 دج', '3,550,500 دج')
        text = text.replace('618,400', '3,550,500')
        text = text.replace('1,546 × 400 = 618,000', '789 × 4,500 = 3,550,500')
        text = text.replace('1546 × 400 = 618000', '789 × 4500 = 3550500')
        text = text.replace('400 دج', '4,500 دج')
        text = text.replace('400دج', '4,500 دج')
        text = text.replace('400 DA', '4,500 DA')
        text = text.replace('400 د.ج', '4,500 د.ج')
        text = text.replace('400 دينار', '4,500 دينار')
        text = text.replace('176', '37')
        text = text.replace('212.4', '206')
        run.text = text

doc.save(r'D:\New folder\19-06\Memoire_DSS_Logistique_ElBayadh.docx')
print('Fixed paragraphs!')