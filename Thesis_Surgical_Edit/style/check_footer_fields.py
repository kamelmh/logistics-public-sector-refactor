import zipfile
import re

docx_path = r'Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx'
with zipfile.ZipFile(docx_path, 'r') as z:
    for i in range(2, 5):  # Check footers 2,3,4 (footer1 is empty)
        name = 'word/footer' + str(i) + '.xml'
        if name in z.namelist():
            content = z.read(name).decode('utf-8')
            print('=== ' + name + ' ===')
            
            # Count all fldChar types
            begin_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>', content))
            separate_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="separate"[^>]*/>', content))
            end_count = len(re.findall(r'<w:fldChar[^>]*w:fldCharType="end"[^>]*/>', content))
            
            print('Begin: ' + str(begin_count) + ', Separate: ' + str(separate_count) + ', End: ' + str(end_count))
            
            # Show the actual field structure
            if begin_count > 0:
                # Extract the field
                field_match = re.search(r'(<w:p[^>]*>.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="begin"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:instrText[^>]*>.*?</w:instrText>.*?</w:r>.*?(?:<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="separate"[^>]*/>.*?</w:r>.*?<w:r[^>]*>.*?<w:t[^>]*>.*?</w:t>.*?</w:r>)?.*?<w:r[^>]*>.*?<w:fldChar[^>]*w:fldCharType="end"[^>]*/>.*?</w:r>.*?</w:p>)', content, re.DOTALL)
                if field_match:
                    field_xml = field_match.group(1)
                    print('Field structure:')
                    print(field_xml[:300] + ('...' if len(field_xml) > 300 else ''))
                else:
                    print('Could not extract complete field structure')
            print()