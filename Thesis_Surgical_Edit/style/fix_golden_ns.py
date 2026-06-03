#!/usr/bin/env python3
"""Fix namespace declarations in DOCX footnotes/endnotes using regex.

This is the reliable approach: direct regex on raw bytes to:
1. Replace ns0: -> w: (element names and xmlns declarations)
2. Replace ns1: -> mc: (xmlns and Ignorable attribute)
3. Add missing xmlns:w14, w15, w16se, w16cid, wp14 declarations
"""
import os
import re
import shutil
import sys
import zipfile

MC_NS = "http://schemas.openxmlformats.org/markup-compatibility/2006"
W14_NS = "http://schemas.microsoft.com/office/word/2010/wordml"
W15_NS = "http://schemas.microsoft.com/office/word/2012/wordml"
W16SE_NS = "http://schemas.microsoft.com/office/word/2015/wordml/symex"
W16CID_NS = "http://schemas.microsoft.com/office/word/2016/wordml/cid"
WP14_NS = "http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"

TARGETS = ["word/footnotes.xml", "word/endnotes.xml"]


def fix_xml_regex(content_str):
    """Fix namespace prefixes using regex on raw string."""
    original = content_str
    changes = 0

    # Step 1: Replace xmlns:ns0= with xmlns:w=
    content_str, n = re.subn(r'xmlns:ns0="([^"]+)"', r'xmlns:w="\1"', content_str)
    changes += n

    # Step 2: Replace xmlns:ns1= with xmlns:mc=
    content_str, n = re.subn(r'xmlns:ns1="([^"]+)"', r'xmlns:mc="\1"', content_str)
    changes += n

    # Step 3: Replace ns0: with w: (element and attribute names)
    content_str, n = re.subn(r'\bns0:', 'w:', content_str)
    changes += n

    # Step 4: Replace ns1:Ignorable with mc:Ignorable
    content_str, n = re.subn(r'\bns1:Ignorable', 'mc:Ignorable', content_str)
    changes += n

    # Step 5: Add missing xmlns declarations before closing >
    missing = []
    if "xmlns:mc=" not in content_str:
        missing.append(f'xmlns:mc="{MC_NS}"')
    if "xmlns:w14=" not in content_str:
        missing.append(f'xmlns:w14="{W14_NS}"')
    if "xmlns:w15=" not in content_str:
        missing.append(f'xmlns:w15="{W15_NS}"')
    if "xmlns:w16se=" not in content_str:
        missing.append(f'xmlns:w16se="{W16SE_NS}"')
    if "xmlns:w16cid=" not in content_str:
        missing.append(f'xmlns:w16cid="{W16CID_NS}"')
    if "xmlns:wp14=" not in content_str:
        missing.append(f'xmlns:wp14="{WP14_NS}"')

    if missing:
        # Find the > that closes the root opening tag
        # Match: <w:footnotes ... > or <footnotes ... >
        match = re.search(r'<w?:footnotes[\s>]', content_str)
        if match:
            gt_pos = content_str.find(">", match.start())
            if gt_pos > 0:
                insert = " ".join(missing)
                content_str = content_str[:gt_pos] + " " + insert + content_str[gt_pos:]
                changes += len(missing)

    return content_str, changes


def main():
    if len(sys.argv) < 2:
        print("Usage: fix_golden_ns.py <docx_path> [--save]")
        sys.exit(1)

    path = sys.argv[1]
    save = "--save" in sys.argv

    print("=" * 60)
    print("Golden Source Namespace Fix (regex, v4)")
    print("=" * 60)
    print(f"File: {path}")
    print(f"Mode: {'SAVE' if save else 'DRY RUN'}")

    if not os.path.exists(path):
        print(f"ERROR: File not found: {path}")
        sys.exit(1)

    backup = path.replace(".docx", "_pre_nsfix_v4.docx")
    shutil.copy2(path, backup)
    print(f"Backup: {backup}")

    entries = {}
    total_changes = 0

    with zipfile.ZipFile(path, "r") as zin:
        for name in zin.namelist():
            data = zin.read(name)
            if name in TARGETS:
                content = data.decode("utf-8")
                fixed, changes = fix_xml_regex(content)
                if changes > 0:
                    data = fixed.encode("utf-8")
                    print(f"  Fixed {name}: {changes} changes")
                    total_changes += changes
                else:
                    print(f"  {name}: already OK")
            entries[name] = data

    if save and total_changes > 0:
        tmp = path + ".tmp"
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
            for name, data in entries.items():
                zout.writestr(name, data)
        os.replace(tmp, path)
        size = os.path.getsize(path)
        print(f"\nSaved: {path} ({size} bytes)")
    elif not save:
        print(f"\nDry run — {total_changes} changes would be made")
    else:
        print("\nNo changes needed")

    # Verify
    print("\nVerification:")
    with zipfile.ZipFile(path, "r") as z:
        for t in TARGETS:
            if t in z.namelist():
                raw = z.read(t).decode("utf-8")
                has_ns0 = "ns0:" in raw
                has_ns1 = "ns1:" in raw
                has_mc_decl = "xmlns:mc=" in raw
                has_mc_ignorable = "mc:Ignorable" in raw
                has_w14 = "xmlns:w14=" in raw
                root_ok = raw.startswith("<?xml") and "<w:footnotes" in raw
                status = "OK" if (not has_ns0 and not has_ns1 and has_mc_decl and has_w14 and root_ok) else "ISSUE"
                print(f"  {t}: {status} (ns0={has_ns0} ns1={has_ns1} mc={has_mc_decl} mc:Ign={has_mc_ignorable} w14={has_w14} root={root_ok})")

    # python-docx verify
    try:
        from docx import Document
        doc = Document(path)
        print(f"  python-docx: OK, {len(doc.paragraphs)} paragraphs")
    except Exception as e:
        print(f"  python-docx: FAIL — {e}")


if __name__ == "__main__":
    main()
