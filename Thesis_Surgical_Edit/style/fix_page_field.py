#!/usr/bin/env python3
"""Fix broken PAGE field codes in DOCX."""
import zipfile
import re
import os
import shutil
import sys

TARGETS = ['word/footer1.xml', 'word/footer2.xml', 'word/footer3.xml', 'word/header1.xml', 'word/header2.xml', 'word/header3.xml']

def fix_page_field(content):
    # Pattern for the broken field: begin -> instrText:PAGE -> separate -> text:ANYTHING -> end
    # We want to replace it with: begin -> instrText:PAGE -> separate -> end
    pattern = r'<w:fldChar w:fldCharType="begin"/>.*?<w:instrText>PAGE</w:instrText>.*?<w:fldChar w:fldCharType="separate"/>. <w:r><w:t>[^<]*</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    # The above regex is a bit loose. Let's be more precise.
    
    # Let's try to find the sequence of runs
    # 1. begin
    # 2. instrText: PAGE
    # 3. separate
    # 4. text: ...
    # 5. end
    
    # This is a bit complex for a single regex. Let's use a more robust approach.
    
    # Find the start of the field
    start_idx = content.find('<w:fldChar w:fldCharType="begin"/>')
    if start_idx == -1:
        return content, 0
    
    # Find the end of the field
    end_idx = content.find('<w:fldChar w:fldCharType="end"/>', start_idx)
    if end_idx == -1:
        return content, 0
    
    # Find the instrText part
    instr_match = re.search(r'<w:instrText>PAGE</w:instrText>', content[start_idx:end_idx])
    if not instr_match:
        return content, 0
    
    # Find the separate part
    sep_idx = content.find('<w:fldChar w:fldCharType="separate"/>', start_idx)
    if sep_idx == -1 or sep_idx > end_idx:
        return content, 0
    
    # Find the text part (the result)
    # It should be between the separate char and the end char
    text_part_match = re.search(r'<w:r><w:t>[^<]*</w:t></w:r>', content[sep_idx:end_idx])
    if not text_part_match:
        return content, 0
    
    text_start = sep_idx + text_part_match.start()
    text_end = sep_idx + text_part_match.end()
    
    # Construct the new content: remove the text part
    new_content = content[:text_start] + content[text_end:]
    
    return new_content, 1

def main():
    if len(sys.argv) < 2:
        print("Usage: fix_page_field.py <docx_path> [--save]")
        sys.exit(1)

    path = sys.argv[1]
    save = '--save' in sys.argv

    print("=" * 60)
    print("Broken PAGE Field Fixer")
    print("=" * 60)
    print(f"File: {path}")
    print(f"Mode: {'SAVE' if save else 'DRY RUN'}")

    if not os.path.exists(path):
        print(f"ERROR: File not found: {path}")
        sys.exit(1)

    backup = path.replace(".docx", "_pre_pagefieldfix.docx")
    shutil.copy2(path, backup)
    print(f"Backup: {backup}")

    entries = {}
    total_changes = 0

    with zipfile.ZipFile(path, 'r') as z:
        for name in z.namelist():
            data = z.read(name)
            if name in TARGETS:
                content = data.decode('utf-8', errors='replace')
                fixed, changes = fix_page_field(content)
                if changes > 0:
                    data = fixed.encode('utf-8')
                    print(f"  Fixed {name}: {changes} changes")
                    total_changes += changes
                else:
                    print(f"  {name}: already OK")
            entries[name] = data

    if save and total_changes > 0:
        tmp = path + '.tmp'
        with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
            for name, data in entries.items():
                zout.writestr(name, data)
        os.replace(tmp, path)
        size = os.path.getsize(path)
        print(f"\nSaved: {path} ({size} bytes)")
    elif not save:
        print(f"\nDry run -- {total_changes} files would be fixed")
    else:
        print("\nNo changes needed")

    # Verify
    print("\nVerification:")
    with zipfile.ZipFile(path, 'r') as z:
        for t in TARGETS:
            if t in z.namelist():
                raw = z.read(t).decode('utf-8', errors='replace')
                # Check if the text part is gone
                # The text part is <w:r><w:t>...</w:t></w:r> after the separate char
                # We want to see if there's still a <w:t> after the separate char
                sep_idx = raw.find('<w:fldChar w:fldCharType="separate"/>')
                if sep_idx != -1:
                    after_sep = raw[sep_idx:]
                    if '<w:t>' in after_sep and '</w:t>' in after_sep:
                        print(f"  {t}: ISSUE (still has <w:t> after separate char)")
                    else:
                        print(f"  {t}: OK (no <w:t> after separate char)")
                else:
                    print(f"  {t}: ISSUE (no separate char found)")

if __name__ == '__main__':
    main()
