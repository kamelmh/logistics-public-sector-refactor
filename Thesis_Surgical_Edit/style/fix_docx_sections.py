"""fix_docx_sections.py — Add section breaks at logical thesis boundaries, set A4 page size
Usage: python fix_docx_sections.py <path/to.docx> [--save]
"""

import sys, os, json, copy
from docx import Document
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
from docx.shared import Cm

# Force UTF-8 for stdout (avoids 'charmap' codec error on Windows with Arabic text)
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
elif hasattr(sys.stdout, 'buffer'):
    # Python <3.7 fallback
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# A4 dimensions in cm
A4_WIDTH_CM = 21.0
A4_HEIGHT_CM = 29.7

# Boundary markers: look for paragraphs containing these strings AND matching heading style
# Each tuple: (marker text, section_name, must_be_first_h1)
BOUNDARIES = [
    ("المقدمة العامة", "Body", True),         # first chapter-level H1
    ("قائمة المصادر والمراجع", "BackMatter", False),
    ("الملاحق", "Annexes", False),
]


def set_a4_page_size(sect_pr):
    """Set page size to A4 (21.0 x 29.7 cm) on a sectPr element."""
    pgSz = sect_pr.find(qn('w:pgSz'))
    if pgSz is None:
        pgSz = parse_xml(f'<w:pgSz {nsdecls("w")} w:w="11906" w:h="16838"/>')
        sect_pr.insert(0, pgSz)
    else:
        pgSz.set(qn('w:w'), '11906')   # A4 width in twips (21cm)
        pgSz.set(qn('w:h'), '16838')   # A4 height in twips (29.7cm)
    # Remove any letter-size override
    pgSz.attrib.pop(qn('w:orient'), None)


def add_section_breaks(path, save=False):
    doc = Document(path)
    paras = doc.paragraphs

    # Get the body-level sectPr (last section properties in w:body)
    body = doc.element.body
    body_sect_pr = body.find(qn('w:sectPr'))
    if body_sect_pr is None:
        print("[ERROR] No sectPr found in document body")
        return

    # Force A4 page size on the body section
    set_a4_page_size(body_sect_pr)
    print(f"  [A4] Body section page size set to {A4_WIDTH_CM}x{A4_HEIGHT_CM}cm")

    HEADING_STYLES = {"Heading 1", "Heading 2", "Heading 3", "Titre 1", "Titre 2", "Titre 3"}
    # Find boundary paragraphs — match actual headings, not TOC entries
    insert_before_indices = []
    for marker, name, _ in BOUNDARIES:
        for i, p in enumerate(paras):
            txt = p.text.strip()
            if marker in txt and p.style.name in HEADING_STYLES:
                insert_before_indices.append((i, p, name))
                break

    insert_before_indices.sort(key=lambda x: x[0])
    print(f"Found {len(insert_before_indices)} section boundaries:")
    for idx, p, name in insert_before_indices:
        print(f"  Section break before para [{idx}]: {p.text.strip()[:50]}")

    if not save:
        print("\n[DRY RUN] Use --save to apply")
        return len(insert_before_indices)

    # Apply breaks in REVERSE order so indices stay valid
    applied = 0
    for idx, p, name in reversed(insert_before_indices):
        if idx == 0:
            continue
        prev_para = paras[idx - 1]
        p_elem = prev_para._p
        pPr = p_elem.find(qn('w:pPr'))

        # Skip if a sectPr already exists in this paragraph's pPr
        if pPr is not None and pPr.find(qn('w:sectPr')) is not None:
            print(f"  Skipped (exists): break before [{idx}] \"{p.text.strip()[:50]}\"")
            continue

        new_sect_pr = copy.deepcopy(body_sect_pr)
        # Force A4 on new sections too
        set_a4_page_size(new_sect_pr)
        if pPr is None:
            pPr = parse_xml(f'<w:pPr {nsdecls("w")}/>')
            p_elem.insert(0, pPr)
        pPr.append(new_sect_pr)
        applied += 1
        print(f"  Applied: break before [{idx}] \"{p.text.strip()[:50]}\"")

    print(f"\nApplied {applied} section breaks (total sections: {applied + 1})")

    if save:
        doc.save(path)
        print(f"Saved: {path}")

    return applied


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_docx_sections.py <path/to.docx> [--save]", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    save = "--save" in sys.argv

    if not os.path.exists(path):
        print(f"[ERROR] File not found: {path}", file=sys.stderr)
        sys.exit(1)

    try:
        add_section_breaks(path, save)
    except Exception as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
