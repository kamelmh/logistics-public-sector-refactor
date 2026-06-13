"""fix_docx_sections.py — Single-section thesis layout with A4 page size
Usage: python fix_docx_sections.py <path/to.docx> [--save]

Strategy: ONE section for entire document. Cover uses "different first page" footer (no page number).
Page numbering starts at 1 on cover (counts in sequence) but only displays from page 2 onward.
TOC field auto-generates with correct page numbers.
"""

import sys, os
from docx import Document
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
from docx.shared import Cm

# Force UTF-8 for stdout
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
elif hasattr(sys.stdout, 'buffer'):
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

A4_WIDTH_CM = 21.0
A4_HEIGHT_CM = 29.7


def set_a4_page_size(sect_pr):
    """Set page size to A4 (21.0 x 29.7 cm) on a sectPr element."""
    pgSz = sect_pr.find(qn('w:pgSz'))
    if pgSz is None:
        pgSz = parse_xml(f'<w:pgSz {nsdecls("w")} w:w="11906" w:h="16838"/>')
        sect_pr.insert(0, pgSz)
    else:
        pgSz.set(qn('w:w'), '11906')
        pgSz.set(qn('w:h'), '16838')
    pgSz.attrib.pop(qn('w:orient'), None)


def ensure_single_section(path, save=False):
    """Remove all section breaks, keep only the final body-level sectPr."""
    doc = Document(path)
    body = doc.element.body

    # Find all sectPr in paragraphs (section breaks)
    para_sect_prs = []
    for p in doc.paragraphs:
        pPr = p._p.find(qn('w:pPr'))
        if pPr is not None:
            sect_pr = pPr.find(qn('w:sectPr'))
            if sect_pr is not None:
                para_sect_prs.append((p, pPr, sect_pr))

    print(f"Found {len(para_sect_prs)} section breaks in paragraphs")

    if not save:
        print("[DRY RUN] Use --save to apply")
        return len(para_sect_prs)

    # Remove all paragraph-level sectPr (section breaks)
    for p, pPr, sect_pr in para_sect_prs:
        pPr.remove(sect_pr)
        print(f"  Removed section break at para: {p.text.strip()[:60]}")

    # Get the body-level sectPr (the one that remains)
    body_sect_pr = body.find(qn('w:sectPr'))
    if body_sect_pr is None:
        print("[ERROR] No body-level sectPr found")
        return 0

    # Force A4 on the single section
    set_a4_page_size(body_sect_pr)
    print(f"  [A4] Single section page size set to {A4_WIDTH_CM}x{A4_HEIGHT_CM}cm")

    # Ensure titlePg (different first page) is set on body sectPr
    title_pg = body_sect_pr.find(qn('w:titlePg'))
    if title_pg is None:
        title_pg = parse_xml(f'<w:titlePg {nsdecls("w")}/>')
        body_sect_pr.insert(0, title_pg)
        print("  [titlePg] Enabled 'different first page' for cover")

    # Set page numbering: decimal, start=1 (continuous from cover)
    old_pg = body_sect_pr.find(qn('w:pgNumType'))
    if old_pg is not None:
        body_sect_pr.remove(old_pg)
    pg_num = parse_xml(f'<w:pgNumType {nsdecls("w")} w:fmt="decimal" w:start="1"/>')
    body_sect_pr.insert(0, pg_num)
    print("  [pgNumType] Decimal, start=1 (continuous from cover)")

    if save:
        doc.save(path)
        print(f"Saved: {path}")

    return 1


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
        ensure_single_section(path, save)
    except Exception as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()