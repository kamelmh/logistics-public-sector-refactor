"""trim-brackets.py — Academix v13.2 (Titan)
Phase 1b: Remove repeat English/French parenthetical terms (keep first mention per section).
Phase 1c: Convert numbered (1)/(2)/(3) lists to Arabic enumeration.
"""
import re, sys

THESIS_PATH = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"

def is_latin(s):
    return bool(re.search(r'[A-Za-z\u00C0-\u024F]', s))

def normalize_term(t):
    """Normalize a term for comparison: lowercase, strip whitespace, remove punctuation."""
    t = re.sub(r'[\s\-_/]+', ' ', t).strip().lower()
    t = re.sub(r'[.,;:!?]+', '', t)
    return t

def process_thesis(text):
    lines = text.split('\n')
    out = []
    terms_seen = set()
    in_math = False

    for line in lines:
        stripped = line.strip()

        # Track math mode
        if stripped.startswith('$$'):
            in_math = not in_math
            out.append(line)
            continue
        if in_math:
            out.append(line)
            continue

        # Reset terms per section header
        if re.match(r'^#{1,3}\s', stripped):
            terms_seen = set()
            out.append(line)
            continue

        # Skip reference lines (numbered + bold author)
        if re.match(r'^\d+\.\s+\*\*', stripped):
            out.append(line)
            continue

        # Skip table rows, table separators, list markers
        if stripped in ('---', '***'):
            out.append(line)
            continue

        # Phase 1c: (1)/(2)/(3) → Arabic enumeration (only small numbers, not table cells)
        line = re.sub(
            r'\(([1-5])\)\s+',
            lambda m: {1: 'أولاً: ', 2: 'ثانياً: ', 3: 'ثالثاً: ', 4: 'رابعاً: ', 5: 'خامساً: '}.get(
                int(m.group(1)), ''
            ),
            line
        )

        # Phase 1b: Remove repeat English/French parenthetical terms
        def replace_term(m):
            content = m.group(1).strip()
            if not is_latin(content):
                return m.group(0)
            # Skip citations (Author, Year) or (Author & Author, Year)
            if re.search(r'\d{4}', content) or '&' in content:
                return m.group(0)
            # Skip combined acronym lists (ABC، EOQ، ROP)
            if '،' in content or '،' in content:
                return m.group(0)
            norm = normalize_term(content)
            if norm in terms_seen:
                return ''
            terms_seen.add(norm)
            return m.group(0)

        line = re.sub(r'\(([^)]*)\)', replace_term, line)
        out.append(line)

    return '\n'.join(out)

def main():
    with open(THESIS_PATH, 'r', encoding='utf-8') as f:
        text = f.read()

    result = process_thesis(text)

    # Clean up whitespace artifacts
    result = re.sub(r' {2,}', ' ', result)
    result = re.sub(r'\s+\.', '.', result)
    result = re.sub(r'\s+،', '،', result)
    result = re.sub(r'\s+\)', ')', result)
    result = re.sub(r'\(\s+', '(', result)
    result = re.sub(r'\s+\n', '\n', result)

    with open(THESIS_PATH, 'w', encoding='utf-8') as f:
        f.write(result)

    remaining = len(re.findall(r'\([A-Za-z\u00C0-\u024F][^)]*\)', result))
    print(f"English/French parentheticals remaining: {remaining}")
    print("trim-brackets: done")

if __name__ == '__main__':
    main()
