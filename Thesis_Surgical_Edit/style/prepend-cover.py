"""prepend-cover.py -- Academix v13.2
Prepends cover-page.docx to the generated thesis DOCX.
Inserts the cover content at the very beginning, before thesis body,
with a page break after the cover so TOC starts on a fresh page.
"""
import sys, os
from docx import Document
from docx.oxml import OxmlElement
from copy import deepcopy

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
COVER_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "output", "cover-page.docx")

def add_page_break_at(paragraph):
    """Insert a page break run at the end of a paragraph."""
    run = OxmlElement('w:r')
    br = OxmlElement('w:br')
    br.set(f'{W}type', 'page')
    run.append(br)
    paragraph._p.append(run)

def prepend_cover(thesis_path):
    if not os.path.exists(COVER_PATH):
        print(f"  [WARN] cover-page.docx not found at {COVER_PATH}")
        return False

    cover = Document(COVER_PATH)
    thesis = Document(thesis_path)

    cover_body = cover.element.body
    thesis_body = thesis.element.body

    cover_paras = [c for c in list(cover_body) if c.tag != f'{W}sectPr']
    
    insert_before = thesis_body[0] if len(thesis_body) > 0 else None
    
    for para in cover_paras:
        thesis_body.insert(
            0 if insert_before is None else list(thesis_body).index(insert_before),
            deepcopy(para)
        )

    # Add page break after last cover paragraph
    cover_last_para = thesis_body[list(thesis_body).index(insert_before) - 1] if insert_before is not None else thesis_body[-1]
    pPr = cover_last_para.find(f'{W}pPr')
    if pPr is not None:
        # Check if it already has a section break (sectPr)
        if pPr.find(f'{W}sectPr') is None:
            # Insert page break run
            run = OxmlElement('w:r')
            br = OxmlElement('w:br')
            br.set(f'{W}type', 'page')
            run.append(br)
            cover_last_para.append(run)
    else:
        run = OxmlElement('w:r')
        br = OxmlElement('w:br')
        br.set(f'{W}type', 'page')
        run.append(br)
        cover_last_para.append(run)

    thesis.save(thesis_path)
    print(f"  Cover prepended: {len(cover_paras)} paragraphs, page break after cover")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python prepend-cover.py <docx_path>")
        sys.exit(1)
    prepend_cover(sys.argv[1])
