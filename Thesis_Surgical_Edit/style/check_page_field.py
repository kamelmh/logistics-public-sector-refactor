"""check_page_field.py — Verify PAGE field has no cached result in footer2.xml
Usage: python check_page_field.py <path/to.docx>

Checks that the PAGE field in footer2.xml does not have a cached <w:t> value,
which would cause Word to display a stale page number instead of the computed value.
"""

import sys
import os
import zipfile


def check_page_field(path):
    if not os.path.exists(path):
        print(f"ERROR: File not found: {path}", file=sys.stderr)
        return 1

    try:
        with zipfile.ZipFile(path, 'r') as z:
            if 'word/footer2.xml' not in z.namelist():
                print("WARNING: footer2.xml not found in DOCX", file=sys.stderr)
                return 0

            raw = z.read('word/footer2.xml').decode('utf-8')

            # Check for PAGE field
            if 'PAGE' not in raw:
                print("WARNING: No PAGE field found in footer2.xml", file=sys.stderr)
                return 0

            # Check for cached value (stale page number)
            # The pattern <w:t>X</w:t> after fldCharType="separate" indicates a cached value
            if '<w:t>' in raw:
                # Find if there's a <w:t> element that's not empty
                import re
                t_matches = re.findall(r'<w:t[^>]*>(.*?)</w:t>', raw)
                for t in t_matches:
                    if t.strip() and t.strip() != 'PAGE':
                        print(f"FAIL: PAGE field has cached value: '{t.strip()}'")
                        return 1

            print("PASS: PAGE field has no cached value")
            return 0

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python check_page_field.py <path/to.docx>", file=sys.stderr)
        sys.exit(1)

    sys.exit(check_page_field(sys.argv[1]))
