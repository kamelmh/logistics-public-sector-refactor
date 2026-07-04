"""fix_thesis_all.py — Comprehensive thesis DOCX fixer v5 (Modular)

Thin wrapper around fixers.orchestrator. All logic lives in:
  fixers/tables.py      — table column widths, borders, cell padding
  fixers/styles.py      — style-level formatting (body, footnote, heading)
  fixers/rtl.py         — paragraph RTL + run RTL for Arabic text
  fixers/empty_paras.py — consecutive empty paragraph cleanup
  fixers/footnotes.py   — footnote RTL (zip-level)
  fixers/footer.py      — footer injection (PAGE field)
  fixers/namespace.py   — ns0/ns1 namespace fix

Usage: python fix_thesis_all.py <path/to.docx> [--save]
"""

import sys
import os

# Add parent dir to path so fixers package is importable
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fixers.orchestrator import run_all_fixers


def main():
    if len(sys.argv) < 2:
        print('Usage: python fix_thesis_all.py <path/to.docx> [--save]', file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    save = '--save' in sys.argv

    if not os.path.exists(path):
        print('[ERROR] File not found: %s' % path, file=sys.stderr)
        sys.exit(1)

    changes = run_all_fixers(path, save=save)
    return 0


if __name__ == '__main__':
    sys.exit(main())
