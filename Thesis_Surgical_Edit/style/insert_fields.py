"""insert_fields.py — Inserts real Word TOC and LISTOFTABLES fields into a DOCX.
Usage: python insert_fields.py <path/to.docx> --save
"""

import sys, os
from docx import Document
from docx.oxml import parse_xml
from docx.oxml.ns import qn

def insert_field(p, field_type):
    """
    Inserts a field into a paragraph.
    field_type: 'TOC' or 'LISTOFTABLES'
    """
    instr = "TOC \\h \\z \\u" if field_type == 'TOC' else "LISTOF TABLES \\h \\z \\u"
    # Note: LISTOF TABLES is the standard switch for List of Tables in Word.
    # Some versions use LISTOFTABLES (no space). Let's use the most compatible one.
    if field_type == 'LISTOFTABLES':
        instr = "LISTOF TABLES \\h \\z \\u"

    # We'll use the standard field structure
    p._element.append(parse_xml(
        '<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:fldChar w:fldCharType="begin"/>'
        '</w:r>'))
    
    p._element.append(parse_xml(
        f'<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        f'<w:instrText xml:space="preserve">{instr}</w:instrText>'
        '</w:r>'))
    
    p._element.append(parse_xml(
        '<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:fldChar w:fldCharType="separate"/>'
        '</w:r>'))
    
    p._element.append(parse_xml(
        '<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:fldChar w:fldCharType="end"/>'
        '</w:r>'))

def insert_fields(docx_path, save=False):
    doc = Document(docx_path)
    
    # Placeholders from MD
    toc_placeholder = "جدول المحتويات سيتم توليده تلقائياً"
    list_tables_placeholder = "قائمة الجداول سيتم توليدها تلقائياً"
    
    inserted_toc = False
    inserted_list = False

    for p in doc.paragraphs:
        # Check for TOC placeholder
        if toc_placeholder in p.text and not inserted_toc:
            # Check if it already contains a field to avoid duplicates
            if not any(child.tag.endswith('fldChar') for child in p._element.xpath('.//w:r')):
                insert_field(p, 'TOC')
                inserted_toc = True
                print(f"Successfully inserted TOC field at: '{p.text.strip()}'")
            else:
                print(f"TOC field already exists at: '{p.text.strip()}'")
                inserted_toc = True

        # Check for List of Tables placeholder
        if list_tables_placeholder in p.text and not inserted_list:
            if not any(child.tag.endswith('fldChar') for child in p._element.xpath('.//w:r')):
                insert_field(p, 'LISTOFTABLES')
                inserted_list = True
                print(f"Successfully inserted LISTOFTABLES field at: '{p.text.strip()}'")
            else:
                print(f"LISTOFTABLES field already exists at: '{p.text.strip()}'")
                inserted_list = True

    if inserted_toc or inserted_list:
        if save:
            doc.save(docx_path)
            print(f"Saved changes to {docx_path}")
        else:
            print("Dry run: No changes saved. Use --save to apply.")
    else:
        print("No placeholders found or fields already inserted.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python insert_fields.py <path/to.docx> [--save]")
        sys.exit(1)
    
    path = sys.argv[1]
    save = '--save' in sys.argv
    insert_fields(path, save)
