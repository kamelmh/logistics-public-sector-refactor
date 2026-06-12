"""Quick standalone verify — no COM, no imports from Thesis_COM_Control."""
import sys, os, zipfile
from xml.etree import ElementTree as ET

path = sys.argv[1] if len(sys.argv) > 1 else 'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx'
W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

print('Checking: %s' % path)
print('Size: %.1f KB' % (os.path.getsize(path) / 1024))

with zipfile.ZipFile(path, 'r') as z:
    names = z.namelist()
    print('Footer files: %s' % [f for f in names if 'footer' in f])
    print('Header files: %s' % [f for f in names if 'header' in f])

    # Count paragraphs and check bidi
    root = ET.fromstring(z.read('word/document.xml'))
    paras = root.findall('.//{%s}p' % W)
    print('Paragraphs: %d' % len(paras))

    bidi_ok = 0
    bidi_missing = 0
    TOC_STYLES = {'TOC1', 'TOC2', 'TOC3', 'TOCHeading', 'toc1', 'toc2', 'toc3'}
    for p in paras:
        pPr = p.find('{%s}pPr' % W)
        # Check style — skip TOC entries (Word manages their bidi)
        style_el = pPr.find('{%s}pStyle' % W) if pPr is not None else None
        pstyle = style_el.get('{%s}val' % W, 'Normal') if style_el is not None else 'Normal'
        if pstyle in TOC_STYLES:
            continue
        if pPr is not None:
            bidi = pPr.find('{%s}bidi' % W)
            if bidi is not None:
                bidi_ok += 1
            else:
                bidi_missing += 1
        else:
            bidi_missing += 1
    print('Para bidi OK: %d / missing: %d (TOC excluded)' % (bidi_ok, bidi_missing))

    # Check caption bidi
    cap_ok = 0
    cap_bad = 0
    for p in paras:
        texts = ''.join(t.text or '' for t in p.iter('{%s}t' % W))
        if '\u062c\u062f\u0648\u0644' in texts or '\u0634\u0643\u0644' in texts:
            pPr = p.find('{%s}pPr' % W)
            # Skip TOC captions (TOC1/2/3)
            style_el = pPr.find('{%s}pStyle' % W) if pPr is not None else None
            pstyle = style_el.get('{%s}val' % W, '') if style_el is not None else ''
            if 'TOC' in pstyle or 'toc' in pstyle:
                continue
            bidi = pPr.find('{%s}bidi' % W) if pPr is not None else None
            if bidi is not None:
                cap_ok += 1
            else:
                cap_bad += 1
    print('Caption bidi OK: %d / bad: %d' % (cap_ok, cap_bad))

    # Check footer for PAGE field
    for fn in [f for f in names if 'footer' in f and f.endswith('.xml')]:
        froot = ET.fromstring(z.read(fn))
        has_page = any('PAGE' in (t.text or '') for t in froot.iter('{%s}instrText' % W))
        has_cache = any(t.text and t.text.strip().isdigit()
                        for t in froot.iter('{%s}fldChar' % W))
        print('Footer %s: has PAGE field=%s' % (fn, has_page))

    # Check footnote bidi
    if 'word/footnotes.xml' in names:
        fn_root = ET.fromstring(z.read('word/footnotes.xml'))
        fn_nodes = fn_root.findall('{%s}footnote' % W)
        fn_bidi_ok = fn_bidi_bad = 0
        for fn in fn_nodes:
            # Skip separator/continuationSeparator footnotes (structural, not content)
            ftype = fn.get('{%s}type' % W, 'normal')
            if ftype in ('separator', 'continuationSeparator'):
                continue
            for p in fn.findall('.//{%s}p' % W):
                pPr = p.find('{%s}pPr' % W)
                bidi = pPr.find('{%s}bidi' % W) if pPr is not None else None
                if bidi is not None:
                    fn_bidi_ok += 1
                else:
                    fn_bidi_bad += 1
        print('Footnote para bidi OK: %d / bad: %d' % (fn_bidi_ok, fn_bidi_bad))

print('DONE')
