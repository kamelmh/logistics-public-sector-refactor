#!/usr/bin/env python3
"""Fix Word compatibility issues in DOCX footnotes/endnotes.

Fixes python-docx namespace pollution:
- ns0: -> w: (element/attribute names)
- ns1: -> mc: (xmlns and Ignorable attribute)
- Adds missing xmlns declarations (mc, w14, w15, w16se, w16cid, wp14)
"""
import os
import re
import sys
import zipfile

MC_NS = 'http://schemas.openxmlformats.org/markup-compatibility/2006'
REQUIRED_NS = {
    'mc': MC_NS,
    'w14': 'http://schemas.microsoft.com/office/word/2010/wordml',
    'w15': 'http://schemas.microsoft.com/office/word/2012/wordml',
    'w16se': 'http://schemas.microsoft.com/office/word/2015/wordml/symex',
    'w16cid': 'http://schemas.microsoft.com/office/word/2016/wordml/cid',
    'wp14': 'http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing',
}
TARGETS = ['word/footnotes.xml', 'word/endnotes.xml']


def fix_xml_regex(content):
    """Fix namespace prefixes using regex on raw XML string."""
    original = content
    changes = 0

    # Replace ns1:Ignorable → mc:Ignorable (before ns1->mc replacement)
    content, n = re.subn(r'\bns1:Ignorable', 'mc:Ignorable', content)
    changes += n

    # Replace xmlns:ns0= with xmlns:w=
    content, n = re.subn(r'xmlns:ns0="([^"]+)"', r'xmlns:w="\1"', content)
    changes += n

    # Replace xmlns:ns1= with xmlns:mc=
    content, n = re.subn(r'xmlns:ns1="([^"]+)"', r'xmlns:mc="\1"', content)
    changes += n

    # Replace ns0: with w: (element/attribute names)
    content, n = re.subn(r'\bns0:', 'w:', content)
    changes += n

    # Replace ns1: with mc:
    content, n = re.subn(r'\bns1:', 'mc:', content)
    changes += n

    # Add missing namespace declarations
    for prefix, uri in REQUIRED_NS.items():
        if 'xmlns:%s=' % prefix not in content:
            match = re.search(r'<w?:footnotes[\s>]', content)
            if match:
                gt_pos = content.find('>', match.start())
                if gt_pos > 0:
                    content = (content[:gt_pos] +
                              ' xmlns:%s="%s"' % (prefix, uri) +
                              content[gt_pos:])
                    changes += 1

    return content, changes


def fix_docx(docx_path, save=False):
    """Fix Word compatibility in a DOCX file."""
    print("=" * 60)
    print("DOCX Word Compatibility Fix")
    print("=" * 60)
    print("File: %s" % docx_path)
    print("Mode: %s" % ('SAVE' if save else 'DRY RUN'))

    if not os.path.exists(docx_path):
        print("ERROR: File not found: %s" % docx_path)
        return False

    entries = {}
    total_changes = 0

    with zipfile.ZipFile(docx_path, 'r') as z:
        for name in z.namelist():
            data = z.read(name)
            if name in TARGETS:
                content = data.decode('utf-8', errors='replace')
                fixed, changes = fix_xml_regex(content)
                if changes > 0:
                    data = fixed.encode('utf-8')
                    print("  Fixed %s: %d changes" % (name, changes))
                    total_changes += changes
                else:
                    print("  %s: already OK" % name)
            entries[name] = data

    if save and total_changes > 0:
        tmp = docx_path + '.tmp'
        with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
            for name, data in entries.items():
                zout.writestr(name, data)
        os.replace(tmp, docx_path)
        size = os.path.getsize(docx_path)
        print("\nSaved: %s (%d bytes)" % (docx_path, size))
    elif not save:
        print("\nDry run -- %d changes would be made" % total_changes)
    else:
        print("\nNo changes needed")

    # Verify
    print("\nVerification:")
    with zipfile.ZipFile(docx_path, 'r') as z:
        for t in TARGETS:
            if t in z.namelist():
                raw = z.read(t).decode('utf-8', errors='replace')
                has_ns0 = 'ns0:' in raw
                has_ns1 = 'ns1:' in raw
                has_mc = 'xmlns:mc=' in raw
                has_w14 = 'xmlns:w14=' in raw
                status = "OK" if (not has_ns0 and not has_ns1 and has_mc and has_w14) else "ISSUE"
                print("  %s: %s" % (t, status))

    # python-docx verify
    try:
        from docx import Document
        doc = Document(docx_path)
        print("  python-docx: OK, %d paragraphs" % len(doc.paragraphs))
    except Exception as e:
        print("  python-docx: FAIL -- %s" % e)

    return total_changes > 0


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_docx_word_compat.py <docx_path> [--save]")
        sys.exit(1)

    path = sys.argv[1]
    save = '--save' in sys.argv
    fix_docx(path, save=save)


if __name__ == '__main__':
    main()

