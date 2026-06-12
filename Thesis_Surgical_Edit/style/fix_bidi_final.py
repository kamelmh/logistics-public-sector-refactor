"""fix_bidi_final.py — Zip-level pass to inject bidi into ALL remaining paragraphs.

This handles:
1. Any <w:p> in document.xml that still lacks <w:bidi> in its pPr,
   EXCEPT TOC/toc styled paragraphs (they're managed by Word's TOC field).
2. The empty separator footnote paragraph (no pPr at all).
3. Table captions missing bidi.

Works at raw XML level — bypasses python-docx style/paragraph API.
Safe: only adds bidi where missing, never modifies existing bidi elements.

Usage: python fix_bidi_final.py <docx_path> [--save]
"""
import sys, os, zipfile, re, time as _time

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

# Styles to SKIP (TOC entries managed by Word field engine)
SKIP_STYLES = {'TOC1', 'TOC2', 'TOC3', 'TOCHeading', 'toc1', 'toc2', 'toc3',
               'TableOfFigures', 'TableOfAuthorities'}


def _safe_replace(tmp, dest, retries=4):
    for _ in range(retries):
        try:
            os.replace(tmp, dest)
            return
        except PermissionError:
            _time.sleep(1.5)
    os.replace(tmp, dest)


def _zip_write(docx_path, replacements):
    import tempfile
    fd, tmp = tempfile.mkstemp(suffix='.tmp', prefix='bidifinal_',
                               dir=os.path.dirname(docx_path))
    os.close(fd)
    try:
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.namelist():
                    zout.writestr(item, replacements.get(item) or zin.read(item))
        _safe_replace(tmp, docx_path)
    except Exception:
        if os.path.exists(tmp): os.remove(tmp)
        raise


def inject_bidi_document(raw, counts):
    """Inject <w:bidi/> into every <w:p> that lacks it, except TOC styles."""
    fixes = 0

    # We process paragraph by paragraph using regex
    # Strategy: find each <w:p ...>...</w:p> block, check pStyle + bidi

    def _fix_para(m):
        nonlocal fixes
        open_tag, inner, close = m.group(1), m.group(2), m.group(3)

        # Determine style of this paragraph
        style_m = re.search(r'<w:pStyle\s+w:val="([^"]+)"', inner)
        pstyle = style_m.group(1) if style_m else 'Normal'

        # Skip TOC styles
        if pstyle in SKIP_STYLES:
            return m.group(0)

        # Check for existing pPr
        ppr_m = re.search(r'(<w:pPr\b[^>]*>)(.*?)(</w:pPr>)', inner, re.DOTALL)

        if ppr_m:
            ppr_open, ppr_inner, ppr_close = ppr_m.group(1), ppr_m.group(2), ppr_m.group(3)
            # Check if bidi already present
            if '<w:bidi' in ppr_inner:
                return m.group(0)   # already has bidi
            # Inject bidi as first element in pPr
            new_ppr = ppr_open + '<w:bidi/>' + ppr_inner + ppr_close
            fixes += 1
            new_inner = inner[:ppr_m.start()] + new_ppr + inner[ppr_m.end():]
            return open_tag + new_inner + close
        else:
            # No pPr at all — inject a minimal one
            # Find first child element to insert before
            first_child = re.search(r'<w:', inner)
            ppr_inject = '<w:pPr><w:bidi/></w:pPr>'
            if first_child:
                pos = first_child.start()
                new_inner = inner[:pos] + ppr_inject + inner[pos:]
            else:
                new_inner = ppr_inject + inner
            fixes += 1
            return open_tag + new_inner + close

    result = re.sub(r'(<w:p\b[^>]*>)(.*?)(</w:p>)', _fix_para, raw, flags=re.DOTALL)
    counts['doc_bidi_injected'] = fixes
    return result


def inject_bidi_footnotes(raw, counts):
    """Inject bidi into footnote paragraphs missing it."""
    fixes = 0

    def _fix_para(m):
        nonlocal fixes
        open_tag, inner, close = m.group(1), m.group(2), m.group(3)
        # Skip separator/continuation separator
        if 'w:type="separator"' in open_tag or 'continuationSeparator' in inner:
            return m.group(0)
        ppr_m = re.search(r'(<w:pPr\b[^>]*>)(.*?)(</w:pPr>)', inner, re.DOTALL)
        if ppr_m:
            ppr_open, ppr_inner, ppr_close = ppr_m.group(1), ppr_m.group(2), ppr_m.group(3)
            if '<w:bidi' in ppr_inner:
                return m.group(0)
            new_ppr = ppr_open + '<w:bidi/>' + ppr_inner + ppr_close
            fixes += 1
            new_inner = inner[:ppr_m.start()] + new_ppr + inner[ppr_m.end():]
            return open_tag + new_inner + close
        else:
            first = re.search(r'<w:', inner)
            ppr_inject = '<w:pPr><w:bidi/><w:jc w:val="right"/></w:pPr>'
            if first:
                pos = first.start()
                new_inner = inner[:pos] + ppr_inject + inner[pos:]
            else:
                new_inner = ppr_inject + inner
            fixes += 1
            return open_tag + new_inner + close

    result = re.sub(r'(<w:p\b[^>]*>)(.*?)(</w:p>)', _fix_para, raw, flags=re.DOTALL)
    counts['fn_bidi_injected'] = fixes
    return result


def main():
    args = sys.argv[1:]
    save = '--save' in args
    args = [a for a in args if a != '--save']
    path = args[0] if args else None

    if not path or not os.path.exists(path):
        print('Usage: python fix_bidi_final.py <docx_path> [--save]', file=sys.stderr)
        sys.exit(1)

    counts = {'doc_bidi_injected': 0, 'fn_bidi_injected': 0}

    with zipfile.ZipFile(path, 'r') as z:
        doc_raw = z.read('word/document.xml').decode('utf-8')
        fn_raw  = z.read('word/footnotes.xml').decode('utf-8') if 'word/footnotes.xml' in z.namelist() else None

    new_doc = inject_bidi_document(doc_raw, counts)
    new_fn  = inject_bidi_footnotes(fn_raw, counts) if fn_raw else None

    print('document.xml bidi injected : %d' % counts['doc_bidi_injected'])
    print('footnotes.xml bidi injected: %d' % counts['fn_bidi_injected'])

    if save:
        replacements = {'word/document.xml': new_doc.encode('utf-8')}
        if new_fn:
            replacements['word/footnotes.xml'] = new_fn.encode('utf-8')
        _zip_write(path, replacements)
        print('SAVED → %s' % path)
    else:
        print('DRY RUN — use --save to apply')

    return 0


if __name__ == '__main__':
    sys.exit(main())
