#!/usr/bin/env python3
"""Analyze footnotes XML directly."""
import re

FN_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\footnotes_extracted.xml"

with open(FN_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# Count footnotes by id
all_fn = re.findall(r'<w:footnote\s', content)
ids = re.findall(r'<w:footnote\s[^>]*w:id="(\d+)"', content)

print(f"Total footnote elements: {len(all_fn)}")
print(f"Footnotes with numeric id: {len(ids)}")
if ids:
    print(f"ID range: {min(int(x) for x in ids)} to {max(int(x) for x in ids)}")
    print(f"IDs: {ids}")

# Check for PAGE field
page_fields = re.findall(r'w:instrText>PAGE<', content)
print(f"\nPAGE fields in footnotes.xml: {len(page_fields)}")

# Check for cached PAGE result (between separate and end)
cached = re.findall(
    r'w:fldCharType="separate"/>.*?<w:t[^>]*>(\d+)</w:t>.*?<w:fldChar[^>]*w:fldCharType="end"',
    content, re.DOTALL
)
print(f"Cached PAGE results: {cached}")

# Check ns0/ns1
if "ns0:" in content or "ns1:" in content:
    count = content.count("ns0:") + content.count("ns1:")
    print(f"CORRUPTION: ns0/ns1 found ({count} occurrences)")
else:
    print("Namespace: CLEAN (no ns0/ns1)")

# Check bidi on first few footnotes
for fid in ["1", "2", "3"]:
    fn_match = re.search(
        r'<w:footnote\s[^>]*w:id="' + fid + r'".*?</w:footnote>',
        content, re.DOTALL
    )
    if fn_match:
        fn_text = fn_match.group()
        has_bidi = "<w:bidi/>" in fn_text or "<w:bidi " in fn_text
        has_rtl = "<w:rtl/>" in fn_text
        # Count paragraphs with/without bidi
        paras = re.findall(r'<w:p\b.*?</w:p>', fn_text, re.DOTALL)
        bidi_count = sum(1 for p in paras if "<w:bidi" in p)
        print(f"Footnote {fid}: bidi={has_bidi}, rtl={has_rtl}, paras={len(paras)}, paras_with_bidi={bidi_count}")

# Overall bidi stats
paras_total = re.findall(r'<w:p\b', content)
paras_bidi = re.findall(r'<w:bidi', content)
print(f"\nTotal <w:p> in footnotes.xml: {len(paras_total)}")
print(f"Total <w:bidi> in footnotes.xml: {len(paras_bidi)}")
