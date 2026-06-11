import os, sys
from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

def main():
    path = sys.argv[1]
    doc = Document(path)
    
    for p in doc.paragraphs:
        # Use Arial as a safe test font
        for r in p.runs:
            r.font.name = 'Arial'
            r.font.size = Pt(12)
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT # Test with LEFT
        p.paragraph_format.line_spacing = 1.0
        
    doc.save(path)
    print(f"Applied Safe-Format to {path}")

if __name__ == '__main__':
    main()
