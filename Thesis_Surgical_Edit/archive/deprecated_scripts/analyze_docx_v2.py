#!/usr/bin/env python3
"""Deep XML-level analysis of thesis DOCX — corrected caption/footnote checks."""
import sys, os, re, json
from pathlib import Path
from lxml import etree

try:
    from docx import Document
    from docx.shared import Cm, Pt, Emu
    from docx.oxml.ns import qn
except ImportError:
    print("ERROR: python-docx not installed. Run: pip install python-docx")
    sys.exit(1)

DOCX_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
OUT_DIR = os.path.dirname(DOCX_PATH)

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

def analyze():
    results = {}
    if not os.path.exists(DOCX_PATH):
        return {"STATUS": "FILE NOT FOUND"}
    
    results["FILE_SIZE_KB"] = round(os.path.getsize(DOCX_PATH) / 1024, 1)
    
    doc = Document(DOCX_PATH)
    
    # ── FOOTNOTE XML — raw inspection ──
    fn_results = {"count": 0, "issues": [], "footnotes": []}
    try:
        for part in doc.part.package.iter_parts():
            if hasattr(part, 'blob') and part.partname and 'footnotes' in str(part.partname):
                blob = part.blob
                fn_xml = etree.fromstring(blob)
                nsmap = {'w': W_NS}
                
                # Count normal footnotes
                footnotes = fn_xml.findall('.//w:footnote[@w:type="normal"]', nsmap)
                fn_results["count"] = len(footnotes)
                
                for i, fn in enumerate(footnotes, 1):
                    paras = fn.findall('.//w:p', nsmap)
                    fn_info = {"id": i, "paras": len(paras), "has_bidi": False, "text_preview": ""}
                    
                    # Get text preview
                    texts = fn.findall('.//w:t', nsmap)
                    full_text = ''.join(t.text or '' for t in texts)
                    fn_info["text_preview"] = full_text[:100]
                    
                    # Check bidi on each paragraph
                    for p in paras:
                        pPr = p.find('w:pPr', nsmap)
                        if pPr is not None:
                            bidi = pPr.find('w:bidi', nsmap)
                            if bidi is not None:
                                fn_info["has_bidi"] = True
                                break
                    
                    if not fn_info["has_bidi"]:
                        fn_results["issues"].append(f"Footnote {i}: NO bidi — text: {fn_info['text_preview'][:60]}")
                    fn_results["footnotes"].append(fn_info)
                
                # Check for ns0/ns1 corruption
                blob_str = blob.decode("utf-8", errors="replace")
                if 'ns0:' in blob_str or 'ns1:' in blob_str:
                    fn_results["issues"].append(f"ns0/ns1 NAMESPACE CORRUPTION in footnotes.xml ({blob_str.count('ns0:')} ns0 occurrences)")
                
                # Save extracted footnote XML for manual inspection
                with open(os.path.join(OUT_DIR, "footnotes_extracted.xml"), "w", encoding="utf-8") as f:
                    f.write(etree.tostring(fn_xml, pretty_print=True).decode("utf-8"))
                
                break
    except Exception as e:
        fn_results["issues"].append(f"Footnote parse error: {e}")
    
    results["FOOTNOTES"] = fn_results
    
    # ── CAPTION RTL — proper check via style lookup ──
    cap_results = {"count": 0, "issues": [], "captions": []}
    try:
        # Find all paragraphs with Caption style
        body = doc.element.body
        for p in body.findall(qn('w:p')):
            pPr = p.find(qn('w:pPr'))
            if pPr is None:
                continue
            pStyle = pPr.find(qn('w:pStyle'))
            if pStyle is None:
                continue
            val = pStyle.get(qn('w:val'))
            if val and 'caption' in val.lower():
                cap_results["count"] += 1
                cap_info = {"num": cap_results["count"], "style": val, "has_bidi": False}
                
                # Check pPr for bidi
                bidi = pPr.find(qn('w:bidi'))
                if bidi is not None:
                    cap_info["has_bidi"] = True
                
                # Check text
                texts = p.findall('.//' + qn('w:t'))
                cap_info["text_preview"] = ''.join(t.text or '' for t in texts)[:80]
                
                if not cap_info["has_bidi"]:
                    cap_results["issues"].append(f"Caption {cap_info['num']}: NO bidi — '{cap_info['text_preview']}'")
                
                cap_results["captions"].append(cap_info)
    except Exception as e:
        cap_results["issues"].append(f"Caption check error: {e}")
    
    results["CAPTIONS"] = cap_results
    
    # ── HEADER/FOOTER RTL ──
    hf_results = {"headers": 0, "footers": 0, "issues": []}
    try:
        for part in doc.part.package.iter_parts():
            if hasattr(part, 'blob') and part.partname:
                pn = str(part.partname)
                if 'header' in pn.lower():
                    hf_results["headers"] += 1
                    blob = part.blob.decode("utf-8", errors="replace")
                    if 'ns0:' in blob or 'ns1:' in blob:
                        hf_results["issues"].append(f"Header {pn}: ns0/ns1 corruption")
                if 'footer' in pn.lower():
                    hf_results["footers"] += 1
                    blob = part.blob.decode("utf-8", errors="replace")
                    if 'ns0:' in blob or 'ns1:' in blob:
                        hf_results["issues"].append(f"Footer {pn}: ns0/ns1 corruption")
    except Exception as e:
        hf_results["issues"].append(f"HF scan error: {e}")
    
    results["HEADERS_FOOTERS"] = hf_results
    
    # ── XML CORRUPTION — scan all parts ──
    corruption = {"issues": [], "parts_scanned": 0}
    try:
        for part in doc.part.package.iter_parts():
            if hasattr(part, 'blob') and part.partname:
                corruption["parts_scanned"] += 1
                blob = part.blob.decode("utf-8", errors="replace")
                pn = str(part.partname)
                
                # ns0/ns1 check
                if 'ns0:' in blob or 'ns1:' in blob:
                    corruption["issues"].append(f"ns0/ns1 in {pn}")
                
                # Stale PAGE field cached result
                # Look for PAGE field type="end" with a number between separate and end
                page_fields = re.findall(
                    r'<w:instrText[^>]*>\s*PAGE\s*</w:instrText>.*?<w:fldChar[^>]*w:fldCharType="separate"/>.*?<w:t[^>]*>(\d+)</w:t>.*?<w:fldChar[^>]*w:fldCharType="end"/>',
                    blob, re.DOTALL
                )
                if page_fields:
                    corruption["issues"].append(f"CACHED PAGE result in {pn}: {page_fields}")
    except Exception as e:
        corruption["issues"].append(f"Scan error: {e}")
    
    results["XML_CORRUPTION"] = corruption
    
    # ── SECTION BREAKS from body XML ──
    sect_results = {"count": 0, "breaks": [], "titlePg": False}
    try:
        body = doc.element.body
        for child in body:
            if child.tag == qn('w:p'):
                pPr = child.find(qn('w:pPr'))
                if pPr is not None:
                    sectPr = pPr.find(qn('w:sectPr'))
                    if sectPr is not None:
                        sect_results["count"] += 1
                        for ch in sectPr:
                            if ch.tag == qn('w:type'):
                                sect_results["breaks"].append(ch.get(qn('w:val')))
                            if ch.tag == qn('w:titlePg'):
                                sect_results["titlePg"] = True
        # Also check document-level sectPr
        for section in doc.sections:
            sectPr = section._sectPr
            for ch in sectPr:
                if ch.tag == qn('w:titlePg'):
                    sect_results["titlePg"] = True
    except Exception as e:
        sect_results["error"] = str(e)
    
    results["SECTIONS"] = sect_results
    
    # ── FOOTER CONTENT (for page numbering) ──
    footer_results = {"count": 0, "content": []}
    try:
        for section in doc.sections:
            for footer_ref in [section.footer, section.first_page_footer, section.even_page_footer]:
                if footer_ref is not None:
                    try:
                        footer_xml = etree.tostring(footer_ref._element, pretty_print=True).decode("utf-8")
                        footer_results["count"] += 1
                        footer_results["content"].append({
                            "section_num": doc.sections.index(section) + 1,
                            "xml_length": len(footer_xml),
                            "has_page_field": "PAGE" in footer_xml,
                            "has_bidi": "bidi" in footer_xml,
                        })
                        # Save footer XML
                        with open(os.path.join(OUT_DIR, f"footer_extracted_s{doc.sections.index(section)+1}.xml"), "w", encoding="utf-8") as f:
                            f.write(footer_xml)
                    except:
                        pass
    except Exception as e:
        footer_results["error"] = str(e)
    
    results["FOOTER_CONTENT"] = footer_results
    
    # ── HEADINGS with numbering ──
    heading_nums = {"numbered": 0, "unnumbered": 0, "missing_numfmt": []}
    try:
        # Check if heading styles have numFmt
        for style in doc.styles:
            if style.name and style.name.startswith("Heading"):
                try:
                    if hasattr(style, 'element'):
                        numPr = style.element.find(qn('w:pPr'))
                        if numPr is not None:
                            np = numPr.find(qn('w:numPr'))
                            if np is not None:
                                heading_nums["numbered"] += 1
                            else:
                                heading_nums["unnumbered"] += 1
                        else:
                            heading_nums["unnumbered"] += 1
                except:
                    heading_nums["unnumbered"] += 1
    except Exception as e:
        heading_nums["error"] = str(e)
    
    results["HEADING_NUMBERING"] = heading_nums
    
    # ── PAGE SIZE + MARGINS (from python-docx, verified) ──
    layout = {"sections": []}
    for i, section in enumerate(doc.sections, 1):
        sec_info = {
            "num": i,
            "width_cm": round(section.page_width / 360000, 2) if section.page_width else None,
            "height_cm": round(section.page_height / 360000, 2) if section.page_height else None,
            "top_cm": round(section.top_margin / 360000, 2) if section.top_margin else None,
            "bottom_cm": round(section.bottom_margin / 360000, 2) if section.bottom_margin else None,
            "left_cm": round(section.left_margin / 360000, 2) if section.left_margin else None,
            "right_cm": round(section.right_margin / 360000, 2) if section.right_margin else None,
            "orientation": str(section.orientation),
            "is_A4": abs((section.page_width or 0) / 360000 - 21.0) < 0.5 and abs((section.page_height or 0) / 360000 - 29.7) < 0.5,
            "margins_ok": all(
                v is not None and abs(v - 2.5) < 0.3
                for v in [
                    round(section.top_margin / 360000, 2) if section.top_margin else None,
                    round(section.bottom_margin / 360000, 2) if section.bottom_margin else None,
                    round(section.left_margin / 360000, 2) if section.left_margin else None,
                    round(section.right_margin / 360000, 2) if section.right_margin else None,
                ]
            )
        }
        layout["sections"].append(sec_info)
    
    results["LAYOUT"] = layout
    
    # ── SUMMARY ──
    all_issues = []
    all_issues.extend(fn_results.get("issues", []))
    all_issues.extend(cap_results.get("issues", []))
    all_issues.extend(hf_results.get("issues", []))
    all_issues.extend(corruption.get("issues", []))
    
    if not all_issues:
        status = "PASS — ALL CHECKS CLEAN"
    elif len(all_issues) <= 3:
        status = f"WARN — {len(all_issues)} minor issues"
    else:
        status = f"ISSUES — {len(all_issues)} problems"
    
    results["STATUS"] = status
    results["TOTAL_ISSUES"] = len(all_issues)
    results["ALL_ISSUES"] = all_issues
    
    return results


def main():
    results = analyze()
    
    print("=" * 80)
    print("THESIS DOCX DEEP ANALYSIS v2 (corrected)")
    print(f"File: {DOCX_PATH}")
    print("=" * 80)
    
    print(f"\nSTATUS: {results.get('STATUS', '?')}")
    print(f"FILE SIZE: {results.get('FILE_SIZE_KB', '?')} KB")
    
    # Layout
    layout = results.get("LAYOUT", {})
    print(f"\n=== LAYOUT ===")
    for s in layout.get("sections", []):
        a4 = "PASS" if s.get("is_A4") else "FAIL"
        mg = "PASS" if s.get("margins_ok") else "FAIL"
        print(f"  Section {s['num']}: {s['width_cm']}x{s['height_cm']}cm [A4:{a4}] | T={s['top_cm']} B={s['bottom_cm']} L={s['left_cm']} R={s['right_cm']} [Margins:{mg}]")
    
    # Sections/breaks
    sects = results.get("SECTIONS", {})
    print(f"\n=== SECTIONS ===")
    print(f"  Section breaks in body: {sects.get('count', '?')}")
    print(f"  Break types: {sects.get('breaks', [])}")
    print(f"  titlePg (different first page): {sects.get('titlePg', '?')}")
    
    # Footnotes
    fn = results.get("FOOTNOTES", {})
    print(f"\n=== FOOTNOTES ===")
    print(f"  Count: {fn.get('count', '?')}")
    print(f"  Bidi issues: {len(fn.get('issues', []))}")
    for issue in fn.get("issues", []):
        print(f"    !! {issue}")
    # Show per-footnote bidi status
    bidi_ok = sum(1 for f in fn.get("footnotes", []) if f.get("has_bidi"))
    bidi_fail = fn.get("count", 0) - bidi_ok
    print(f"  Footnotes with bidi: {bidi_ok}/{fn.get('count', '?')}")
    if bidi_fail > 0:
        print(f"  MISSING BIDI: {bidi_fail}")
    
    # Captions
    cap = results.get("CAPTIONS", {})
    print(f"\n=== CAPTIONS ===")
    print(f"  Count: {cap.get('count', '?')}")
    print(f"  Bidi issues: {len(cap.get('issues', []))}")
    for issue in cap.get("issues", []):
        print(f"    !! {issue}")
    bidi_cap_ok = sum(1 for c in cap.get("captions", []) if c.get("has_bidi"))
    print(f"  Captions with bidi: {bidi_cap_ok}/{cap.get('count', '?')}")
    for c in cap.get("captions", []):
        mark = "OK" if c.get("has_bidi") else "FAIL"
        print(f"    Caption {c['num']}: [{mark}] '{c.get('text_preview', '')}'")
    
    # Headers/Footers
    hf = results.get("HEADERS_FOOTERS", {})
    print(f"\n=== HEADERS/FOOTERS ===")
    print(f"  Headers: {hf.get('headers', '?')}, Footers: {hf.get('footers', '?')}")
    for issue in hf.get("issues", []):
        print(f"    !! {issue}")
    
    # Footer content
    fc = results.get("FOOTER_CONTENT", {})
    print(f"\n=== FOOTER CONTENT ===")
    print(f"  Footer parts: {fc.get('count', '?')}")
    for fi in fc.get("content", []):
        print(f"    Section {fi.get('section_num')}: xml_len={fi.get('xml_length')}, PAGE={fi.get('has_page_field')}, bidi={fi.get('has_bidi')}")
    
    # XML Corruption
    xc = results.get("XML_CORRUPTION", {})
    print(f"\n=== XML CORRUPTION ===")
    print(f"  Parts scanned: {xc.get('parts_scanned', '?')}")
    print(f"  Issues: {len(xc.get('issues', []))}")
    for issue in xc.get("issues", []):
        print(f"    !! {issue}")
    
    # Heading numbering
    hn = results.get("HEADING_NUMBERING", {})
    print(f"\n=== HEADING NUMBERING ===")
    print(f"  Numbered styles: {hn.get('numbered', '?')}")
    print(f"  Unnumbered styles: {hn.get('unnumbered', '?')}")
    
    # Final
    print(f"\n{'=' * 80}")
    print(f"FINAL STATUS: {results.get('STATUS', '?')}")
    print(f"TOTAL ISSUES: {results.get('TOTAL_ISSUES', '?')}")
    if results.get("ALL_ISSUES"):
        for i, iss in enumerate(results["ALL_ISSUES"], 1):
            print(f"  {i}. {iss}")
    print("=" * 80)
    
    # Save JSON
    json_path = DOCX_PATH.replace(".docx", "_analysis_v2.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False, default=str)
    print(f"\nJSON saved: {json_path}")


if __name__ == "__main__":
    main()
