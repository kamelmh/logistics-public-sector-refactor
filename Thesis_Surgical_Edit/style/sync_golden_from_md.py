"""
sync_golden_from_md.py — Patch golden source body text AND headings from pandoc MD build.

Strategy:
1. Golden source = correct formatting, cover page, TOC, styles, hyperlinks, footnotes
2. Pandoc output = correct content from MD (numbers, text, headings)
3. Patch: replace body text AND headings in golden source (skip cover, TOC entries)

Usage: python sync_golden_from_md.py <golden.docx> <pandoc.docx> [--save]
"""
import sys
from docx import Document


def is_toc_paragraph(para):
    """Check if paragraph is a TOC entry."""
    style_name = para.style.name.lower()
    return 'toc' in style_name


def is_cover_page(para, cover_end_idx):
    """Check if paragraph is in cover page."""
    return False  # We handle this by index


def sync_text(golden_path, pandoc_path, save=False):
    print("[SYNC] Opening golden source: %s" % golden_path)
    golden = Document(golden_path)
    
    print("[SYNC] Opening pandoc output: %s" % pandoc_path)
    pandoc = Document(pandoc_path)
    
    # Find cover page end in golden (first Heading 2 = إهداء)
    cover_end = 0
    for i, p in enumerate(golden.paragraphs):
        if p.style.name.startswith('Heading') and 'إهداء' in p.text:
            cover_end = i
            break
    if cover_end == 0:
        cover_end = 14
    
    # Find TOC start/end in golden
    toc_start = None
    toc_end = None
    for i, p in enumerate(golden.paragraphs):
        if is_toc_paragraph(p):
            if toc_start is None:
                toc_start = i
            toc_end = i + 1
    
    # Find body start (after TOC)
    body_start = toc_end if toc_end else cover_end
    
    print("[SYNC] Cover page: 0-%d" % (cover_end - 1))
    print("[SYNC] TOC: %s-%s" % (toc_start, toc_end - 1 if toc_end else "none"))
    print("[SYNC] Body starts at: P%d" % body_start)
    print("[SYNC] Golden body: %d paragraphs" % (len(golden.paragraphs) - body_start))
    print("[SYNC] Pandoc body: %d paragraphs" % len(pandoc.paragraphs))
    
    # Build pandoc text index (skip empty paragraphs, keep headings)
    pandoc_texts = []
    for p in pandoc.paragraphs:
        text = p.text.strip()
        if text:
            pandoc_texts.append(text)
    
    # Patch golden source body paragraphs (skip cover, TOC entries)
    # BUT DO patch headings (so TOC regenerates correctly from MD)
    pandoc_idx = 0
    patched = 0
    skipped = 0
    
    for i in range(body_start, len(golden.paragraphs)):
        gp = golden.paragraphs[i]
        
        # Skip TOC paragraphs
        if is_toc_paragraph(gp):
            continue
        
        # Skip empty paragraphs
        if not gp.text.strip():
            continue
        
        # Skip if pandoc text exhausted
        if pandoc_idx >= len(pandoc_texts):
            skipped += 1
            continue
        
        # Get corresponding pandoc text
        pt = pandoc_texts[pandoc_idx]
        pandoc_idx += 1
        
        # Only patch if text actually changed
        if gp.text.strip() != pt:
            # Replace text in all runs, preserving first run's formatting
            if gp.runs:
                first_run = gp.runs[0]
                first_run.text = pt
                for run in gp.runs[1:]:
                    run.text = ''
                patched += 1
    
    print("[SYNC] Patched %d paragraphs (incl. headings)" % patched)
    print("[SYNC] Skipped %d (golden has more content)" % skipped)
    print("[SYNC] Pandoc texts consumed: %d/%d" % (pandoc_idx, len(pandoc_texts)))
    
    # Patch tables (match by position)
    table_patched = 0
    pandoc_table_idx = 0
    for golden_table in golden.tables:
        if pandoc_table_idx >= len(pandoc.tables):
            break
        pandoc_table = pandoc.tables[pandoc_table_idx]
        
        # Only patch if row/col counts match
        if (len(golden_table.rows) == len(pandoc_table.rows) and 
            len(golden_table.columns) == len(pandoc_table.columns)):
            for ri in range(len(pandoc_table.rows)):
                for ci in range(len(pandoc_table.columns)):
                    try:
                        pt = pandoc_table.cell(ri, ci).text.strip()
                        gt = golden_table.cell(ri, ci).text.strip()
                        if pt and gt != pt:
                            cell = golden_table.cell(ri, ci)
                            for p in cell.paragraphs:
                                if p.runs:
                                    p.runs[0].text = pt
                                    for r in p.runs[1:]:
                                        r.text = ''
                                    table_patched += 1
                                    break
                    except:
                        pass
            pandoc_table_idx += 1
    
    print("[SYNC] Patched %d table cells" % table_patched)
    
    if save:
        golden.save(golden_path)
        print("[SYNC] Saved: %s" % golden_path)
    
    return patched + table_patched


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python sync_golden_from_md.py <golden.docx> <pandoc.docx> [--save]")
        sys.exit(1)
    
    golden_path = sys.argv[1]
    pandoc_path = sys.argv[2]
    save = "--save" in sys.argv
    
    count = sync_text(golden_path, pandoc_path, save)
    sys.exit(0 if count > 0 else 1)
