#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
parse_md.py — Academix v13.2 Markdown Parser
Converts Memoire_DSS_Logistique_ElBayadh.md into block dicts
for python-docx rendering.
"""

import re

def parse_markdown(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.read().split('\n')
    blocks = []
    in_footnote = False
    footnote_num = 0
    in_table = False
    table_lines = []
    in_code = False
    code_lines = []

    for raw_line in lines:
        line = raw_line.strip()

        # Code block detection
        if line.startswith('```'):
            if in_code:
                blocks.append({'type': 'code', 'text': '\n'.join(code_lines)})
                code_lines = []
                in_code = False
            else:
                in_code = True
            continue
        if in_code:
            code_lines.append(raw_line)
            continue

        # Table detection
        if line.startswith('|') and line.endswith('|'):
            table_lines.append(line)
            in_table = True
            continue
        elif in_table:
            blocks.extend(_parse_table(table_lines))
            table_lines = []
            in_table = False

        # Footnote detection
        fn_match = re.match(r'^\[\^(\d+)\]:\s*(.*)', line)
        if fn_match:
            fn_text = line[line.index(']:') + 2:].strip()
            if not fn_text:
                continue
            blocks.append({'type': 'footnote', 'num': fn_match.group(1), 'text': fn_text})
            in_footnote = True
            continue

        # Empty line
        if not line:
            if in_footnote:
                in_footnote = False
            blocks.append({'type': 'blank', 'text': ''})
            continue

        # Separator
        if line in ('---', '***', '___'):
            blocks.append({'type': 'separator', 'text': line})
            continue

        # Chapter heading: ## الفصل ...
        ch_match = re.match(r'^##\s+(الفصل\s+(الأول|الثاني|الثالث|الرابع|الخامس|السادس).*)', line)
        if ch_match:
            blocks.append({'type': 'chapter', 'text': ch_match.group(1)})
            continue

        # Section heading: ## (non-chapter)
        h2_match = re.match(r'^##\s+(.+)', line)
        if h2_match:
            blocks.append({'type': 'body', 'text': h2_match.group(1)})
            continue

        # H3 headings
        h3_match = re.match(r'^###\s+(.+)', line)
        if h3_match:
            blocks.append({'type': 'body', 'text': h3_match.group(1)})
            continue

        # مبحث: bold **...** or plain on its own line
        mb_match = re.match(r'\*\*المبحث\s+(الأول|الثاني|الثالث|الرابع|الخامس|السادس|السابع|الثامن).*?\*\*', line)
        if not mb_match:
            mb_match = re.match(r'^المبحث\s+(الأول|الثاني|الثالث|الرابع|الخامس|السادس|السابع|الثامن)[\s:]+(.+)', line)
        if mb_match:
            blocks.append({'type': 'mabhath', 'text': line.strip('* ')})
            continue

        # مطلب: bold **...** or plain on its own line
        mt_match = re.match(r'\*\*المطلب\s+(الأول|الثاني|الثالث|الرابع|الخامس|السادس).*?\*\*', line)
        if not mt_match:
            mt_match = re.match(r'^المطلب\s+(الأول|الثاني|الثالث|الرابع|الخامس|السادس)[\s:]+(.+)', line)
        if mt_match:
            blocks.append({'type': 'matlab', 'text': line.strip('* ')})
            continue

        # أولاً / ثانياً / ثالثاً / رابعاً: bold **...** or plain
        aw_match = re.match(r'\*\*(أولاً|ثانياً|ثالثاً|رابعاً|خامساً|سادساً)[:\s]+(.+?)\*\*', line)
        if not aw_match:
            aw_match = re.match(r'^(أولاً|ثانياً|ثالثاً|رابعاً|خامساً|سادساً)[:\s]+(.+)', line)
        if aw_match:
            blocks.append({'type': 'awalan', 'text': line.strip('* ')})
        continue

        # تمهيد
        if 'تمهيد' in line and len(line) < 30:
            blocks.append({'type': 'matlab', 'text': 'تمهيد'})
            continue

        # Footnote continuation (indented text after [^n]:)
        if in_footnote and line:
            if blocks and blocks[-1]['type'] == 'footnote':
                blocks[-1]['text'] += ' ' + line
            continue

        # Regular body paragraph
        blocks.append({'type': 'body', 'text': raw_line})

    # Handle any remaining table
    if table_lines:
        blocks.extend(_parse_table(table_lines))

    # Handle any remaining code
    if code_lines:
        blocks.append({'type': 'code', 'text': '\n'.join(code_lines)})

    return blocks


def _parse_table(lines):
    """Parse markdown table lines into a block dict"""
    blocks = []
    rows = []
    headers = []
    for i, line in enumerate(lines):
        line = line.strip()
        if not line.startswith('|'):
            continue
        # Skip separator lines like |---|---|
        if re.match(r'^\|[\s\-:]+\|', line):
            continue
        cells = [c.strip() for c in line.split('|')[1:-1]]
        if i == 0:
            headers = cells
        else:
            rows.append(cells)

    if headers:
        blocks.append({'type': 'table', 'headers': headers, 'rows': rows})
    return blocks


if __name__ == '__main__':
    import sys
    test_path = sys.argv[1] if len(sys.argv) > 1 else None
    if test_path:
        blocks = parse_markdown(test_path)
        print(f"Parsed {len(blocks)} blocks")
        counts = {}
        for b in blocks:
            t = b['type']
            counts[t] = counts.get(t, 0) + 1
        for t, c in sorted(counts.items()):
            print(f"  {t}: {c}")
    else:
        print("Usage: python parse_md.py <path_to_md>")
