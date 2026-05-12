"""add-copyright.py — Academix v13.2
Add copyright headers to all .bas VBA modules.
Inserts after Attribute VB_Name line, preserving existing content.
"""
import os, glob

COPYRIGHT_BLOCK = """' ============================================================================
' Academix v13.2 — DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation — Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================
"""

BAS_DIR = os.path.join(os.path.dirname(__file__), '..', '..',
                       'Software_Surgical_Edit', 'VBA_Modules')

HEADER_MARKER = "' ============="

def add_copyright(path):
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    lines = content.split('\n')

    # Find line 1: Attribute VB_Name
    if not lines[0].startswith('Attribute VB_Name'):
        print(f'  SKIP (no Attribute): {os.path.basename(path)}')
        return False

    # Check if copyright already exists
    if 'Copyright (c) 2025-2026 Mahi' in content:
        print(f'  EXISTS: {os.path.basename(path)}')
        return True

    # Find the line after Attribute VB_Name where we insert
    insert_at = 1  # default: right after line 1

    # Skip existing block comment headers (lines starting with ')
    for i in range(1, min(10, len(lines))):
        line = lines[i].strip()
        if line == '' or line.startswith("'"):
            insert_at = i + 1
        else:
            break

    # Insert copyright block
    new_lines = lines[:1] + [COPYRIGHT_BLOCK.rstrip('\n')] + [''] + lines[insert_at:]
    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write('\n'.join(new_lines))

    print(f'  ADDED: {os.path.basename(path)}')
    return True


def main():
    bas_files = sorted(glob.glob(os.path.join(BAS_DIR, '*.bas')))
    print(f'Found {len(bas_files)} .bas files')
    ok = exists = 0
    for f in bas_files:
        if add_copyright(f):
            ok += 1
    print(f'Done: {ok} files processed')


if __name__ == '__main__':
    main()
