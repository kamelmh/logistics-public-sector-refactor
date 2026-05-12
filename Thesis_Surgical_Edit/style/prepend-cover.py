"""prepend-cover.py -- Academix v13.2
Prepends cover-page.docx to the generated thesis DOCX.
Inserts the cover content at the very beginning, before thesis body.
"""
import sys, os
from docx import Document
from docx.oxml import parse_xml
from copy import deepcopy

COVER_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "cover-page.docx")

def prepend_cover(thesis_path):
    if not os.path.exists(COVER_PATH):
        print(f"  [WARN] cover-page.docx not found at {COVER_PATH}")
        return False

    cover = Document(COVER_PATH)
    thesis = Document(thesis_path)

    cover_body = cover.element.body
    thesis_body = thesis.element.body

    cover_paras = list(cover_body)
    
    insert_before = thesis_body[0] if len(thesis_body) > 0 else None
    
    for para in reversed(cover_paras):
        thesis_body.insert(
            0 if insert_before is None else list(thesis_body).index(insert_before),
            deepcopy(para)
        )

    thesis.save(thesis_path)
    print(f"  Cover prepended: {len(cover_paras)} paragraphs from cover-page.docx")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python prepend-cover.py <docx_path>")
        sys.exit(1)
    prepend_cover(sys.argv[1])
