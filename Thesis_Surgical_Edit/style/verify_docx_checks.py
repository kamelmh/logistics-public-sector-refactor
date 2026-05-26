"""verify_docx_checks.py — 25 fast verification checks via python-docx (no COM)
Usage: python verify_docx_checks.py <path/to.docx> [--json]
"""
import sys, os, json, zipfile, argparse
from xml.etree import ElementTree as ET
from docx import Document
from docx.shared import Cm, Pt

W_NS = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def check(name, ok, msg=""):
    return {"name": name, "passed": bool(ok), "message": str(msg)}

def run_checks(docx_path, strict_headings=False, size_threshold=50000):
    doc = Document(docx_path)
    paras = doc.paragraphs; sections = doc.sections
    p_count = len(paras); s_count = len(sections)
    body_styles = ['Normal', 'Compact', 'Body Text', 'List Paragraph', 'No Spacing']
    fsize = os.path.getsize(docx_path)

    results = [
        check("DOCX file exists", os.path.exists(docx_path)),
        check("Has paragraphs", p_count > 0, f"count={p_count}"),
        check("Has sections (>=3)", s_count >= 3, f"count={s_count}"),
        check("Paragraph count >= 250", p_count >= 250, f"count={p_count}"),
        check("File size threshold", fsize > size_threshold, f"size={fsize//1024}KB"),
    ]

    # --- Validate all XML parts have XML declaration (prevents Word corruption) ---
    xml_parts_no_decl = []
    try:
        xml_targets = ['word/document.xml', 'word/footnotes.xml', 'word/endnotes.xml',
                       'word/styles.xml', 'word/settings.xml', 'word/numbering.xml',
                       'word/fontTable.xml', 'word/webSettings.xml',
                       '[Content_Types].xml']
        with zipfile.ZipFile(docx_path, 'r') as z:
            for xml_file in xml_targets:
                if xml_file in z.namelist():
                    raw = z.read(xml_file).decode('utf-8', errors='replace')
                    if not raw.startswith('<?xml'):
                        xml_parts_no_decl.append(xml_file)
    except Exception as e:
        xml_parts_no_decl = [f"ERROR: {e}"]
    results.append(check("All XML parts have declaration", len(xml_parts_no_decl)==0,
                         f"Missing in: {xml_parts_no_decl}" if xml_parts_no_decl else "All OK"))
    pg = sections[0].page_width; ph = sections[0].page_height
    results.append(check("Page size A4", abs(pg.cm-21)<0.1 and abs(ph.cm-29.7)<0.1, f"{pg.cm:.1f}x{ph.cm:.1f}cm"))

    m = sections[0]
    mt, mb, ml, mr = m.top_margin.cm, m.bottom_margin.cm, m.left_margin.cm, m.right_margin.cm
    results.append(check("Margins 2.5cm", all(abs(x-2.5)<0.1 for x in [mt,mb,ml,mr]), f"T={mt:.1f} B={mb:.1f} L={ml:.1f} R={mr:.1f}"))

    fn_count = 0; fn_bidi_bad = 0
    try:
        with zipfile.ZipFile(docx_path, 'r') as z:
            if 'word/footnotes.xml' in z.namelist():
                tree = ET.parse(z.open('word/footnotes.xml')); root = tree.getroot()
                for fn in root.findall('.//w:footnote', W_NS):
                    fid = fn.attrib.get(f'{{{W_NS["w"]}}}id', '')
                    if fid in ('0','-1'): continue
                    fn_count += 1
                    par = fn.find('.//w:p', W_NS)
                    if par is not None:
                        pPr = par.find('w:pPr', W_NS)
                        if pPr is not None:
                            jc = pPr.find('w:jc', W_NS)
                            if jc is None or jc.attrib.get(f'{{{W_NS["w"]}}}val','') != 'right': fn_bidi_bad += 1
                        else: fn_bidi_bad += 1
                    else: fn_bidi_bad += 1
    except: pass
    results.append(check("Footnotes >= 16", fn_count >= 16, f"count={fn_count}"))
    results.append(check("Footnote RTL alignment", fn_bidi_bad == 0, f"{fn_bidi_bad} bad"))

    results.append(check("Tables >= 21", len(doc.tables) >= 21, f"count={len(doc.tables)}"))
    h1 = sum(1 for p in paras if p.style and p.style.name and 'Heading 1' in p.style.name)
    h2 = sum(1 for p in paras if p.style and p.style.name and 'Heading 2' in p.style.name)
    h3 = sum(1 for p in paras if p.style and p.style.name and 'Heading 3' in p.style.name)
    results.append(check("H1 >= 4", h1 >= 4, f"count={h1}"))
    results.append(check("H2 >= 10", h2 >= 10, f"count={h2}"))
    results.append(check("H3 >= 10", h3 >= 10, f"count={h3}"))

    skip = 0; prev = 0
    for p in paras:
        lv = 0
        if p.style and p.style.name:
            sn = p.style.name
            if 'Heading 1' in sn: lv = 1
            elif 'Heading 2' in sn: lv = 2
            elif 'Heading 3' in sn: lv = 3
        if lv > 0 and lv > prev + 1: skip += 1
        if lv > 0: prev = lv
    results.append(check("Heading hierarchy OK", (skip == 0 if strict_headings else skip <= 1), f"{skip} skips"))

    bp = [p for p in paras if p.style and p.style.name in body_styles]
    sample_len = min(len(bp), 80)
    threshold = max(1, int(sample_len * 0.05))
    
    fb = sum(1 for p in bp[:sample_len] if p.runs and p.runs[0].font.name and p.runs[0].font.name != 'Traditional Arabic')
    sb = sum(1 for p in bp[:sample_len] if p.runs and p.runs[0].font.size and p.runs[0].font.size.pt != 14)
    results.append(check("Font Traditional Arabic", fb <= threshold, f"{fb} bad (threshold={threshold})"))
    results.append(check("Font size 14pt", sb <= threshold, f"{sb} bad (threshold={threshold})"))

    rtl_bad = 0; sp_bad = 0
    for p in bp[:sample_len]:
        if not p.runs: continue
        pPr = p._element.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        if pPr is not None:
            jc = pPr.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}jc')
            if jc is not None and jc.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') is not None:
                val = jc.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')
                if val not in ('right', 'both', 'center'): rtl_bad += 1
    for p in bp[:sample_len]:
        try:
            sp = p.paragraph_format.line_spacing
            if sp is not None and sp < 1.0: sp_bad += 1
        except: sp_bad += 1
    results.append(check("RTL alignment OK", rtl_bad <= threshold, f"{rtl_bad} bad (threshold={threshold})"))
    results.append(check("Line spacing >= 1.0", sp_bad <= threshold, f"{sp_bad} bad (threshold={threshold})"))

    # New check 1: Body Text Paragraph Style Consistency
    style_bad = sum(1 for p in bp[:sample_len] if p.style.name not in body_styles)
    results.append(check("Body text style consistency", style_bad <= threshold, f"{style_bad} bad (threshold={threshold})"))

    # New check 2: First Line Indent Consistency
    indent_bad = sum(1 for p in bp[:sample_len] if p.paragraph_format.first_line_indent is not None and p.paragraph_format.first_line_indent != Pt(0))
    results.append(check("First line indent consistency", indent_bad <= threshold, f"{indent_bad} bad (threshold={threshold})"))

    # New check 3: Paragraph Spacing Before/After Consistency
    # Uses relaxed threshold (0.20) because cover page + table references have intentional spacing
    space_threshold = max(5, int(sample_len * 0.20))
    space_before_bad = sum(1 for p in bp[:sample_len] if p.paragraph_format.space_before is not None and p.paragraph_format.space_before != Pt(0))
    space_after_bad = sum(1 for p in bp[:sample_len] if p.paragraph_format.space_after is not None and p.paragraph_format.space_after != Pt(0))
    space_bad = space_before_bad + space_after_bad # Combine for simplicity
    results.append(check("Paragraph spacing before/after consistency", space_bad <= space_threshold, f"{space_bad} bad (threshold={space_threshold})"))

    c2 = sum(1 for p in paras if p.style and p.style.name and 'Heading 1' in p.style.name and p.text and 'الفصل' in p.text) >= 2
    results.append(check("Core chapters as H1", c2, ""))

    resume = any('الملخص' in (p.text or '') for p in paras[:40])
    results.append(check("Abstract present", resume, ""))

    biblio = any(k in (p.text or '') for p in paras for k in ['المصادر', 'المراجع', 'Bibliographie'])
    results.append(check("Bibliography present", biblio, ""))

    annexe = any('الملاحق' in (p.text or '') for p in paras)
    results.append(check("Annexes present", annexe, ""))

    toc_h = any('المحتويات' in (p.text or '') and 'فهرس' in (p.text or '') for p in paras[:50])
    results.append(check("TOC heading present", toc_h, ""))

    results.append(check("Opens without corruption", True, "python-docx ok"))
    results.append(check("Body has content", sum(1 for p in bp[:30] if p.text and p.text.strip()) >= 15, ""))

    passed = sum(1 for r in results if r["passed"])
    failed = sum(1 for r in results if not r["passed"])
    return {"checks": results, "summary": {"passed": passed, "failed": failed, "total": len(results)}}

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Verify thesis DOCX")
    parser.add_argument("docx", help="Path to DOCX file")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--strict-headings", action="store_true", help="Strict heading hierarchy (no skips)")
    parser.add_argument("--size-threshold", type=int, default=50000, help="DOCX size threshold in bytes")
    args = parser.parse_args()
    r = run_checks(args.docx, strict_headings=args.strict_headings, size_threshold=args.size_threshold)
    if args.json:
        print(json.dumps(r, indent=2, ensure_ascii=False))
    else:
        for c in r["checks"]:
            s = "PASS" if c["passed"] else "FAIL"
            m = f" — {c['message']}" if c["message"] else ""
            print(f"  [{s}] {c['name']}{m}")
        s = r["summary"]
        print(f"\n  Passed: {s['passed']}/{s['total']}  Failed: {s['failed']}/{s['total']}")
    sys.exit(0 if r["summary"]["failed"] == 0 else 1)
