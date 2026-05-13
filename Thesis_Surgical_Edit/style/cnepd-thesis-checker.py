"""cnepd-thesis-checker.py -- Academix v13.2
Validates thesis markdown against CNEPD ground truth:
ART codes, constants, structure, footnotes, performance claims.
Usage: python cnepd-thesis-checker.py <thesis.md>
"""

import sys, os, re, json

GROUND_TRUTH = {
    "D": "1,546",
    "Q*": "176",
    "ROP": "205.6",
    "SS": "200",
    "LT": "2",
    "S": "500",
    "I": "20%",
    "performance": "99.7%",
    "articles": {
        "ART-001": {"fr": "Toner imprimante G030 (noir)", "ar": "حبر الطابعة Toner G030"},
        "ART-002": {"fr": "Rame papier A4 80g/m²", "ar": "رزم الورق A4"},
        "ART-003": {"fr": "Rame papier A3 80g/m²", "ar": "رزم الورق A3"},
        "ART-004": {"fr": "Boîte archives carton", "ar": "صندوق أرشيف كرتوني"},
        "ART-005": {"fr": "Agrafeuse de bureau", "ar": "أغرف الأغراض (دباسة)"},
        "ART-006": {"fr": "Stylos bille boîte/50", "ar": "أقلام حبر (علبة/50)"},
    },
    "hierarchy": {
        "chapters": 4,
        "sections_per_chapter": {1: 5, 2: 3, 3: 5, 4: 6},
    },
}


def check_file(path):
    if not os.path.exists(path):
        print(f"[ERROR] File not found: {path}")
        return False
    return True


def check_constant(text, name, expected, context="document"):
    pattern = re.compile(r'%s\s*[=:]\s*([\d,.%%%%]+)' % re.escape(name))
    matches = pattern.findall(text)
    if not matches:
        return f"⚠ {name}: not found in {context}"
    for m in matches:
        if m != expected:
            return f"✗ {name}: found '{m}', expected '{expected}'"
    return f"✓ {name}: all occurrences correct ({expected})"


def check_art_codes(text):
    issues = []
    for code, info in GROUND_TRUTH["articles"].items():
        ar_name = info["ar"]
        # Check if the Arabic name appears near the ART code
        pattern = re.compile(r'%s.*?%s|%s.*?%s' % (
            re.escape(code), re.escape(ar_name[:8]),
            re.escape(ar_name[:8]), re.escape(code)
        ), re.DOTALL)
        if not pattern.search(text):
            issues.append(f"✗ {code}: expected Arabic name '{ar_name}' not found near code")
    if not issues:
        return ["✓ All ART codes correctly referenced"]
    return issues


def check_structure(text):
    lines = text.split('\n')
    chapters = [l for l in lines if re.match(r'.*الفصل\s+(الأول|الثاني|الثالث|الرابع|الخامس)', l)]
    sections = [l for l in lines if 'المبحث' in l]
    subsections = [l for l in lines if 'المطلب' in l]
    footnotes = [l for l in lines if re.match(r'\[\^\d+\]:', l)]

    issues = []
    if len(chapters) < 4:
        issues.append(f"✗ Expected ≥4 chapters, found {len(chapters)}")
    else:
        issues.append(f"✓ Chapters: {len(chapters)}")

    ch_found = sum(1 for c in chapters if 'الفصل' in c)
    issues.append(f"✓ Chapter headers: {ch_found}")
    issues.append(f"✓ Sections (مبحث): {len(sections)}")
    issues.append(f"✓ Sub-sections (مطلب): {len(subsections)}")
    issues.append(f"✓ Footnotes: {len(footnotes)}")

    return issues


def check_performance(text):
    # Check for 97% (wrong) vs 99.7% (correct)
    wrong = len(re.findall(r'97%', text))
    correct = len(re.findall(r'99\.7%', text))
    issues = []
    if wrong > 0:
        issues.append(f"✗ '97%' found {wrong} times — should be '99.7%'")
    if correct > 0:
        issues.append(f"✓ '99.7%' found {correct} times")
    else:
        issues.append("✗ '99.7%' not found in document")
    return issues


def check_footnote_format(text):
    footnotes = re.findall(r'\[\^(\d+)\]:\s*(.*)', text)
    issues = []
    if not footnotes:
        return ["✗ No footnotes found"]
    for num, content in footnotes:
        has_period = content.rstrip().endswith('.')
        if not has_period:
            issues.append(f"  ⚠ [^{num}]: missing period at end")
    issues.insert(0, f"✓ Footnotes: {len(footnotes)} total")
    return issues


def main():
    if len(sys.argv) < 2:
        print("Usage: python cnepd-thesis-checker.py <thesis.md> [--json]")
        sys.exit(1)

    path = sys.argv[1]
    as_json = "--json" in sys.argv

    if not check_file(path):
        sys.exit(1)

    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    results = {
        "file": os.path.basename(path),
        "size_bytes": len(text),
        "lines": text.count('\n') + 1,
    }

    print("=" * 60)
    print(f"  CNEPD THESIS CHECKER — {results['file']}")
    print(f"  {results['size_bytes']} bytes, {results['lines']} lines")
    print("=" * 60)

    # Structure
    print("\n--- STRUCTURE ---")
    for r in check_structure(text):
        print(f"  {r}")

    # Constants
    print("\n--- CONSTANTS ---")
    constants = [("D", "1,546"), ("Q\\*", "176"), ("ROP", "205.6"),
                 ("SS", "200"), ("LT", "2"), ("S", "500"), ("I", "20%")]
    for name, expected in constants:
        print(f"  {check_constant(text, name, expected)}")

    # Performance
    print("\n--- PERFORMANCE ---")
    for r in check_performance(text):
        print(f"  {r}")

    # ART codes
    print("\n--- ART CODES ---")
    for r in check_art_codes(text):
        print(f"  {r}")

    # Footnotes
    print("\n--- FOOTNOTES ---")
    for r in check_footnote_format(text):
        print(f"  {r}")

    print("\n" + "=" * 60)

    if as_json:
        print(json.dumps(results, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
