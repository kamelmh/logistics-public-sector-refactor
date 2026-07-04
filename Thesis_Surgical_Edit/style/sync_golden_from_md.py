"""
sync_golden_from_md.py — Sync body from pandoc into golden source (v5 — zip-level).

Strategy:
1. Golden source = correct cover page, TOC, styles, hyperlinks
2. Pandoc output = correct body content (text, numbers, footnotes, tables)
3. At zip level: replace golden's body children after TOC with pandoc's body children
4. Merge footnotes: golden's root element (namespaces) + pandoc's real footnotes

This preserves golden's front matter (cover + TOC) while getting pandoc's
correct body content and footnotes (matching MD source).

Usage: python sync_golden_from_md.py <golden.docx> <pandoc.docx> [--save]
"""
import sys
import shutil
import zipfile
import re
from lxml import etree


W_URI = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'


def _get_text(elem):
    """Get text content of an XML element."""
    texts = elem.findall(f'.//{{{W_URI}}}t')
    return ''.join(t.text or '' for t in texts)


def _find_toc_end(children):
    """Find the index where TOC ends in golden body children."""
    toc_end = 0
    for i, child in enumerate(children):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            style = child.find(f'.//{{{W_URI}}}pStyle')
            if style is not None:
                style_val = style.get(f'{{{W_URI}}}val', '')
                if 'toc' in style_val.lower():
                    toc_end = i + 1
                elif 'Heading' in style_val and toc_end > 0:
                    break
        elif tag == 'sdt':
            sdt_content = child.find(f'.//{{{W_URI}}}content')
            if sdt_content is not None:
                first_p = sdt_content.find(f'{{{W_URI}}}p')
                if first_p is not None:
                    style = first_p.find(f'.//{{{W_URI}}}pStyle')
                    if style is not None and 'toc' in style.get(f'{{{W_URI}}}val', '').lower():
                        toc_end = i + 1
    return toc_end


def _find_body_start(children, golden_front=None):
    """Find where pandoc's body content starts (first Heading, skipping duplicates).

    Only skip a pandoc heading if the golden version is ALSO a heading
    (not plain text). This ensures proper Heading styles from pandoc
    replace plain-text labels like 'إهداء' and 'شكر وتقدير' in the shell.
    """
    golden_heading_texts = set()
    if golden_front is not None:
        for child in golden_front:
            tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
            if tag == 'p':
                pStyle = child.find(f'.//{{{W_URI}}}pStyle')
                if pStyle is not None and 'Heading' in pStyle.get(f'{{{W_URI}}}val', ''):
                    txt = _get_text(child).strip()
                    if txt:
                        golden_heading_texts.add(txt)
    for i, child in enumerate(children):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            style = child.find(f'.//{{{W_URI}}}pStyle')
            if style is not None and 'Heading' in style.get(f'{{{W_URI}}}val', ''):
                text = _get_text(child).strip()
                if text and text in golden_heading_texts:
                    continue
                return i
    return 0


def _is_front_matter_heading(text):
    """Check if text is a front matter heading that should be preserved from golden."""
    return text.strip() in ('إهداء', 'شكر وتقدير', 'بسم الله الرحمن الرحيم')


def replace_body_from_pandoc(golden_path, pandoc_path, save=False):
    """Replace body from pandoc at zip level, keep golden cover+TOC."""

    with zipfile.ZipFile(pandoc_path, 'r') as z:
        pandoc_doc_xml = z.read('word/document.xml')
        pandoc_fn_xml = z.read('word/footnotes.xml')

    with zipfile.ZipFile(golden_path, 'r') as z:
        golden_doc_xml = z.read('word/document.xml')
        golden_fn_xml = z.read('word/footnotes.xml')

    golden_doc = etree.fromstring(golden_doc_xml)
    pandoc_doc = etree.fromstring(pandoc_doc_xml)

    golden_body = golden_doc.find(f'.//{{{W_URI}}}body')
    pandoc_body = pandoc_doc.find(f'.//{{{W_URI}}}body')

    golden_children = list(golden_body)
    pandoc_children = list(pandoc_body)

    # Find boundaries
    toc_end = _find_toc_end(golden_children)
    golden_front = golden_children[:toc_end]
    pandoc_start = _find_body_start(pandoc_children, golden_front=golden_front)

    print("[SYNC] Golden TOC ends at child %d (of %d)" % (toc_end, len(golden_children)))
    print("[SYNC] Pandoc body starts at child %d (of %d)" % (pandoc_start, len(pandoc_children)))

    golden_front = golden_children[:toc_end]
    pandoc_body_content = pandoc_children[pandoc_start:]

    print("[SYNC] Golden front matter: %d children" % len(golden_front))
    print("[SYNC] Pandoc body content: %d children" % len(pandoc_body_content))

    # Rebuild golden body: front matter + pandoc body
    for child in golden_children:
        golden_body.remove(child)
    for child in golden_front:
        golden_body.append(child)
    for child in pandoc_body_content:
        golden_body.append(child)

    # Merge footnotes: golden root (namespaces) + pandoc real footnotes
    golden_fn = etree.fromstring(golden_fn_xml)
    pandoc_fn = etree.fromstring(pandoc_fn_xml)

    golden_real = [fn for fn in golden_fn.findall(f'{{{W_URI}}}footnote')
                   if fn.get(f'{{{W_URI}}}id', '0') not in ('0', '-1')]
    for fn in golden_real:
        golden_fn.remove(fn)

    pandoc_real = [fn for fn in pandoc_fn.findall(f'{{{W_URI}}}footnote')
                   if fn.get(f'{{{W_URI}}}id', '0') not in ('0', '-1')]
    for fn in pandoc_real:
        golden_fn.append(fn)

    print("[SYNC] Footnotes: %d removed, %d added" % (len(golden_real), len(pandoc_real)))

    # Serialize and write
    new_doc_xml = etree.tostring(golden_doc, xml_declaration=True, encoding='UTF-8', standalone=True)
    new_fn_xml = etree.tostring(golden_fn, xml_declaration=True, encoding='UTF-8', standalone=True)

    if save:
        temp = golden_path + '.tmp'
        with zipfile.ZipFile(golden_path, 'r') as zin:
            with zipfile.ZipFile(temp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    if item.filename == 'word/document.xml':
                        zout.writestr(item, new_doc_xml)
                    elif item.filename == 'word/footnotes.xml':
                        zout.writestr(item, new_fn_xml)
                    else:
                        zout.writestr(item, zin.read(item.filename))
        shutil.move(temp, golden_path)
        print("[SYNC] Saved: %s" % golden_path)

    # Verify
    doc_root = etree.fromstring(new_doc_xml)
    fn_refs = doc_root.findall(f'.//{{{W_URI}}}footnoteReference')
    fn_ref_ids = [fn.get(f'{{{W_URI}}}id') for fn in fn_refs]

    fn_root = etree.fromstring(new_fn_xml)
    fn_ids = [fn.get(f'{{{W_URI}}}id') for fn in fn_root.findall(f'{{{W_URI}}}footnote')
              if fn.get(f'{{{W_URI}}}id', '0') not in ('0', '-1')]

    print("[SYNC] Body refs: %d, Footnotes: %d, Match: %s" % (
        len(fn_ref_ids), len(fn_ids), all(r in fn_ids for r in fn_ref_ids)))

    return len(fn_ref_ids)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python sync_golden_from_md.py <golden.docx> <pandoc.docx> [--save]")
        sys.exit(1)

    golden_path = sys.argv[1]
    pandoc_path = sys.argv[2]
    save = "--save" in sys.argv

    count = replace_body_from_pandoc(golden_path, pandoc_path, save)
    sys.exit(0 if count > 0 else 1)
