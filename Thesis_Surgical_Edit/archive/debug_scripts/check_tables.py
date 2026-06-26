from docx import Document
doc = Document(r'D:\New folder\19-06\Memoire_DSS_Logistique_ElBayadh.docx')
for i in [1, 4]:
    print('=== Table', i, '===')
    for row_idx, row in enumerate(doc.tables[i].rows):
        row_text = [cell.text.strip() for cell in row.cells]
        print('Row', row_idx, ':', ' | '.join(row_text))