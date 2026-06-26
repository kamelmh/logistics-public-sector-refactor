import zipfile, re
with zipfile.ZipFile(r'Thesis_Surgical_Edit/output/recent-source-1-Memoire_DSS_Logistique_ElBayadh.docx', 'r') as z:
    if 'word/document.xml' in z.namelist():
        raw = z.read('word/document.xml').decode('utf-8')
        # Check for LISTOFTABLES
        listof = re.findall(r'LISTOF', raw)
        print('LISTOF occurrences:', len(listof))
        # Check for TC fields with table identifier
        tc_all = re.findall(r'<w:instrText[^>]*>.*?TC\s+.*?</w:instrText>', raw)
        print('TC fields:', len(tc_all))
        for m in tc_all[:5]:
            print('  ', m[:300])
        # Check for table captions with TC
        tc_table = re.findall(r'TC\s+.*?\\f\s+[tT]', raw)
        print('TC \\f t (table):', len(tc_table))
