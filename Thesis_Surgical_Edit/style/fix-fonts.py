"""fix-fonts.py — Academix v13.2
Post-processes DOCX to fix font sizes.
Removes explicit 12pt from Normal/Heading runs so style-defined sizes show through.
Also sets Traditional Arabic on runs missing a font name.
"""

import sys, re
from docx import Document
from docx.shared import Pt

BODY_STYLES = {'Normal', 'Body Text', 'Body'}
HEADING_STYLES = {'Heading 1', 'Heading 2', 'Heading 3', 'Heading 4', 'Heading 5'}
SZ_12PT = Pt(12)

def has_heading_style(p):
    return p.style and p.style.name in HEADING_STYLES

def has_body_style(p):
    return p.style and p.style.name in BODY_STYLES

def fix_paragraph(p):
    if not p.runs:
        return 0
    fixed = 0
    for run in p.runs:
        changed = False
        # Remove explicit 12pt so style inheritance works
        if run.font.size and run.font.size == SZ_12PT:
            run.font.size = None
            changed = True
        # Set Traditional Arabic where font name is missing
        if run.font.name is None or run.font.name == '':
            run.font.name = 'Traditional Arabic'
            changed = True
        if changed:
            fixed += 1
    return fixed

def fix_heading(p):
    return fix_paragraph(p)

def main():
    if len(sys.argv) < 2:
        print("Usage: python fix-fonts.py <docx_path>")
        sys.exit(1)

    path = sys.argv[1]
    print(f"Fixing fonts in: {path}")

    doc = Document(path)
    total_fixed = 0
    heading_fixed = 0
    body_fixed = 0

    for p in doc.paragraphs:
        if has_heading_style(p):
            n = fix_heading(p)
            heading_fixed += n
            total_fixed += n
        elif has_body_style(p):
            n = fix_paragraph(p)
            body_fixed += n
            total_fixed += n
        else:
            # Also fix any paragraph with explicit 12pt that might be body text
            n = fix_paragraph(p)
            if n:
                body_fixed += n
                total_fixed += n

    doc.save(path)
    print(f"  Runs fixed: {total_fixed} (headings: {heading_fixed}, body: {body_fixed})")
    print(f"  Saved: {path}")

if __name__ == '__main__':
    main()
