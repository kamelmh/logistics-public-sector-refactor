"""fixers.footnotes — Footnote RTL and namespace fixes at the zip level."""

import re
import zipfile
from .constants import EXTRA_NS, _is_arabic_run, _zip_replace


def fix_footnotes_zip(docx_path, changes):
    """Fix footnote RTL at the zip level — pPr bidi/jc + run-level bidi/rtl.

    Handles:
    - paragraphs with <w:pPr> (add bidi/jc if missing)
    - paragraphs with NO <w:pPr> (inject one before first child)
    - Missing namespace declarations that Word requires
    """
    fn_file = 'word/footnotes.xml'
    with zipfile.ZipFile(docx_path, 'r') as z:
        if fn_file not in z.namelist():
            return changes
        raw = z.read(fn_file).decode('utf-8')

    modified = False

    # ── 9a: Ensure namespace declarations ──
    for prefix, uri in EXTRA_NS:
        if ('xmlns:%s=' % prefix) not in raw:
            decl_end = raw.find('?>')
            idx = raw.find('>', decl_end + 2) if decl_end > 0 else raw.find('>')
            if idx > 0:
                raw = raw[:idx] + ' xmlns:%s="%s"' % (prefix, uri) + raw[idx:]
                modified = True
                changes['fn_ns_fixes'] += 1

    # ── 9b: Fix existing jc values ──
    jc_pat = re.compile(r'<w:jc\s+w:val="[^"]*"\s*/>')
    for m in jc_pat.finditer(raw):
        if m.group(0) != '<w:jc w:val="right"/>':
            modified = True
            changes['fn_rtl_fixes'] += 1
    raw = jc_pat.sub('<w:jc w:val="right"/>', raw)

    # ── 9c: Fix existing pPr blocks ──
    ppr_pat = re.compile(r'(<w:pPr(?:\s[^>]*)?>)(.*?)</w:pPr>', re.DOTALL)

    def _fix_ppr(m):
        head, inner = m.group(1), m.group(2)
        extra = ''
        if 'w:bidi' not in inner:
            extra += '<w:bidi w:val="1"/>'
            changes['fn_rtl_fixes'] += 1
        if 'w:jc' not in inner:
            extra += '<w:jc w:val="right"/>'
            changes['fn_rtl_fixes'] += 1
        if extra:
            return head + inner + extra + '</w:pPr>'
        return m.group(0)

    new_raw = ppr_pat.sub(_fix_ppr, raw)
    if new_raw != raw:
        modified = True
        raw = new_raw

    # ── 9d: Inject pPr into <w:p> blocks with NO <w:pPr> ──
    p_pat = re.compile(r'(<w:p\b[^>]*>)(.*?)(</w:p>)', re.DOTALL)

    def _inject_ppr(m):
        open_tag, inner, close_tag = m.group(1), m.group(2), m.group(3)
        if '<w:pPr' in inner:
            return m.group(0)
        if 'w:type="separator"' in open_tag or 'w:type="continuationSeparator"' in open_tag:
            return m.group(0)
        ppr_inject = '<w:pPr><w:bidi w:val="1"/><w:jc w:val="right"/></w:pPr>'
        changes['fn_rtl_fixes'] += 1
        return open_tag + ppr_inject + inner + close_tag

    new_raw = p_pat.sub(_inject_ppr, raw)
    if new_raw != raw:
        modified = True
        raw = new_raw

    # ── 9e: Add bidi/rtl to runs containing Arabic text ──
    run_pat = re.compile(r'(<w:r\b[^>]*>)(.*?)(</w:r>)', re.DOTALL)

    def _fix_run(m):
        open_tag, inner, close_tag = m.group(1), m.group(2), m.group(3)
        texts = re.findall(r'<w:t[^>]*>(.*?)</w:t>', inner, re.DOTALL)
        txt = ''.join(texts)
        if not _is_arabic_run(txt):
            return m.group(0)
        rpr_m = re.search(r'(<w:rPr>)(.*?)(</w:rPr>)', inner, re.DOTALL)
        if rpr_m:
            rpr_inner = rpr_m.group(2)
            extra = ''
            if '<w:bidi' not in rpr_inner:
                extra += '<w:bidi/>'
                changes['fn_run_rtl'] += 1
            if '<w:rtl' not in rpr_inner:
                extra += '<w:rtl/>'
                changes['fn_run_rtl'] += 1
            if extra:
                new_inner = inner[:rpr_m.start()] + '<w:rPr>' + rpr_inner + extra + '</w:rPr>' + inner[rpr_m.end():]
                return open_tag + new_inner + close_tag
        else:
            t_pos = inner.find('<w:t')
            if t_pos >= 0:
                new_inner = inner[:t_pos] + '<w:rPr><w:bidi/><w:rtl/></w:rPr>' + inner[t_pos:]
                changes['fn_run_rtl'] += 1
                return open_tag + new_inner + close_tag
        return m.group(0)

    new_raw = run_pat.sub(_fix_run, raw)
    if new_raw != raw:
        modified = True
        raw = new_raw

    if modified:
        _zip_replace(docx_path, {fn_file: raw.encode('utf-8')})

    return changes
