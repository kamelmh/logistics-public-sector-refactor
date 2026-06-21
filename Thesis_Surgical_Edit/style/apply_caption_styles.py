"""apply_caption_styles.py — Applies 'Caption' style to paragraphs containing 'الجدول رقم' (Table No.).
Usage: python apply_caption_styles.py <path/to.docx> --save
"""

import sys, os
from docx import Document

def apply_caption_styles(docx_path, save=False):
    doc = Document(docx_path)
    caption_pattern = "الجدول رقم"
    count = 0
    
    for p in doc.paragraphs:
        if caption_pattern in p.text:
            # Check if it already has the Caption style to avoid redundant work
            if p.style.name != 'Caption':
                p.style = doc.styles['Caption']
                count += 1
                
    if count > 0:
        print(f"Applied 'Caption' style to {count} paragraphs containing '{caption_pattern}'.")
        if save:
            doc.save(docx_path)
            print(f"Saved changes to {docx_path}")
        else:
            print("Dry run: No changes saved. Use --save to apply.")
    else:
        print(f"No paragraphs containing '{caption_pattern}' found to style.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python apply_caption_styles.py <path/to.docx> [--save]")
        sys.exit(1)
    
    path = sys.argv[1]
    save = '--save' in sys.argv
    apply_caption_styles(path, save)
