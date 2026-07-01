"""
sync_golden_from_md.py — Patch golden source DOCX body text from pandoc MD build.

Strategy:
1. Golden source = correct formatting, cover page, styles
2. Pandoc output = correct content from MD
3. Patch: replace body text in golden source with text from pandoc output

The golden source has ~717 paragraphs. First ~14 are cover page.
The pandoc output has ~323 paragraphs starting with dedication.
We map golden source paragraphs [cover_end:] to pandoc paragraphs [0:].

Usage: python sync_golden_from_md.py <golden.docx> <pandoc.docx> [--save]
"""
import sys
from docx import Document


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
        cover_end = 14  # Default
    
    print("[SYNC] Cover page: paragraphs 0-%d" % (cover_end - 1))
    print("[SYNC] Golden body: %d paragraphs" % (len(golden.paragraphs) - cover_end))
    print("[SYNC] Pandoc body: %d paragraphs" % len(pandoc.paragraphs))
    
    # Build pandoc text index (skip empty paragraphs for matching)
    pandoc_texts = []
    for p in pandoc.paragraphs:
        text = p.text.strip()
        if text:
            pandoc_texts.append(text)
    
    # Patch golden source body paragraphs
    pandoc_idx = 0
    patched = 0
    skipped = 0
    
    for i in range(cover_end, len(golden.paragraphs)):
        gp = golden.paragraphs[i]
        
        # Skip headings (keep golden source headings for formatting)
        if gp.style.name.startswith('Heading'):
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
                # Clear all runs except first
                first_run = gp.runs[0]
                first_run.text = pt
                for run in gp.runs[1:]:
                    run.text = ''
                patched += 1
            else:
                # No runs — add text via runs
                from docx.oxml.ns import qn
                from lxml import etree
                r = etree.SubElement(gp._element, qn('w:r'))
                t = etree.SubElement(r, qn('w:t'))
                t.text = pt
                t.set(qn('xml:space'), 'preserve')
                patched += 1
    
    print("[SYNC] Patched %d paragraphs" % patched)
    print("[SYNC] Skipped %d (golden has more content)" % skipped)
    print("[SYNC] Pandoc texts consumed: %d/%d" % (pandoc_idx, len(pandoc_texts)))
    
    # Also patch tables
    table_patched = 0
    for pandoc_table in pandoc.tables:
        for golden_table in golden.tables:
            # Match tables by row count
            if len(golden_table.rows) == len(pandoc_table.rows):
                for ri in range(len(pandoc_table.rows)):
                    for ci in range(len(pandoc_table.columns)):
                        try:
                            pt = pandoc_table.cell(ri, ci).text.strip()
                            gt = golden_table.cell(ri, ci).text.strip()
                            if pt and gt != pt:
                                # Replace cell text
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
                break  # Only match first table with same row count
    
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
