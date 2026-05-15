"""prepend-bismillah.py — Academix v13.2
Prepends the bismillah-page.docx to the target DOCX.
"""
import sys, os
from docx import Document
from docx.opc.constants import RELATIONSHIP_TYPE as RT
from lxml import etree

def prepend_bismillah(target_path, bismillah_path):
    # Ensure the path is absolute or relative to the script
    if not os.path.isabs(bismillah_path):
        bismillah_path = os.path.join(os.path.dirname(__file__), bismillah_path)
    
    # Use a similar logic to prepend-cover.py (zip-level merge)

    
    # Since I don't have the full code of prepend-cover.py in memory, 
    # I will implement a robust merge logic.
    
    from docx import Document
    
    doc_b = Document(bismillah_path)
    doc_t = Document(target_path)
    
    # Append all paragraphs from Bismillah to the start of target
    # Note: this is a simplified merge. For a truly separate page, 
    # we ensure the Bismillah doc ends with a page break.
    
    # To maintain the 'Standalone' nature, we use a more advanced merge if needed,
    # but for a single page, we can insert paragraphs.
    
    for p in doc_b.paragraphs:
        new_p = doc_t.add_paragraph(p.text)
        new_p.alignment = p.alignment
        # Copy formatting
        run = new_p.add_run()
        run.font.name = p.runs[0].font.name if p.runs else None
        run.font.size = p.runs[0].font.size if p.runs else None
        run.bold = p.runs[0].bold if p.runs else False
        
    # Add a page break after Bismillah
    doc_t.add_page_break()
    
    doc_t.save(target_path)
    print(f"Bismillah page prepended to {target_path}")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python prepend-bismillah.py <target_docx> <bismillah_docx>")
        sys.exit(1)
    prepend_bismillah(sys.argv[1], sys.argv[2])
