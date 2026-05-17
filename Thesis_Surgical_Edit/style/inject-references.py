"""inject-references.py — Academix v13.2
Phase 2.4: Injects formatted references from master-references.json
into the thesis .md source. Uses forked thesis-skills core modules.

Usage: python inject-references.py [--check-only] [--apply]

Reads refs/master-references.json and Memoire_DSS_Logistique_ElBayadh.md.
With --apply, replaces the bibliography section in the .md.
With --check-only (default), only validates and reports.
"""
import json, os, sys, re
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools" / "thesis-skills"))

from core.markdown_parser import parse_thesis, check_integrity, replace_bibliography
from core.bib_render import render_markdown_bibliography

THESIS_MD = Path("Memoire_DSS_Logistique_ElBayadh.md")
MASTER_JSON = Path("refs") / "master-references.json"
PDF_MAPPING = Path("refs") / "pdf-mapping.json"

SECTION_ORDER = [
    ["academic_books", "أولاً: الكتب والمراجع العلمية"],
    ["legal_framework", "ثانياً: الإطار القانوني والتنظيمي الجزائري"],
    ["bts_curriculum", "ثالثاً: المنهاج الدراسي BTS GSL (TAG1801)"],
    ["technical_refs", "رابعاً: المراجع التقنية"],
    ["parallel_theses", "خامساً: مشاريع وأطروحات موازية"],
    ["field_data", "سادساً: مصادر البيانات الميدانية"],
    ["software_ref", "سابعاً: المراجع البرمجية"],
]


def load_master():
    with open(MASTER_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_pdf_mapping():
    if not PDF_MAPPING.exists():
        return {}
    with open(PDF_MAPPING, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate_references(thesis, entries, pdf_map):
    issues = []

    inline_issues = check_integrity(thesis)
    issues.extend(inline_issues)

    for e in entries:
        if e.get("linked_pdf") and not os.path.exists(e["linked_pdf"]):
            issues.append({
                "severity": "warning",
                "code": "BIB_PDF_MISSING",
                "message": f"Entry #{e['number']} ({e['key']}): linked PDF not found: {e['linked_pdf']}",
                "line": 0,
            })

    return issues


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Inject references into thesis .md")
    parser.add_argument("--apply", action="store_true", help="Apply changes to the .md file")
    parser.add_argument("--check-only", action="store_true", default=True, help="Only validate (default)")
    args = parser.parse_args()

    print("=" * 50)
    print("Academix v13.2 — Reference Injector")
    print("=" * 50)

    if not THESIS_MD.exists():
        print(f"[ERROR] Thesis MD not found: {THESIS_MD}")
        sys.exit(1)
    if not MASTER_JSON.exists():
        print(f"[ERROR] Master JSON not found: {MASTER_JSON}")
        sys.exit(1)

    print(f"\n[1/4] Loading master-references.json...")
    entries = load_master()
    print(f"  {len(entries)} entries loaded")

    print(f"\n[2/4] Parsing thesis Markdown...")
    thesis = parse_thesis(THESIS_MD)
    print(f"  {len(thesis.lines)} lines")
    print(f"  Bibliography: lines {thesis.bib_start_line}-{thesis.bib_end_line}")
    print(f"  Inline citations found: {len(thesis.inline_citations)}")
    for cite in thesis.inline_citations[:7]:
        print(f"    L{cite.line}: {cite.text}")

    print(f"\n[3/4] Validating reference integrity...")
    pdf_map = load_pdf_mapping()
    issues = validate_references(thesis, entries, pdf_map)

    errors = [i for i in issues if i.get("severity") == "error"]
    warnings = [i for i in issues if i.get("severity") == "warning"]
    infos = [i for i in issues if i.get("severity") == "info"]
    
    if issues:
        print(f"  Issues found: {len(errors)} errors, {len(warnings)} warnings, {len(infos)} info")
        for i in issues:
            print(f"    [{i['severity'].upper()}] {i['code']}: {i['message']}")
    else:
        print(f"  No issues found — reference integrity: OK")

    if args.apply:
        print(f"\n[4/4] Injecting references into .md...")
        new_bib = render_markdown_bibliography(entries, SECTION_ORDER)
        new_content = replace_bibliography(thesis, new_bib)

        backup = THESIS_MD.with_suffix(".md.bak")
        THESIS_MD.rename(backup)
        print(f"  Backup saved: {backup}")

        with open(THESIS_MD, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  Updated: {THESIS_MD} ({len(new_content)} bytes)")
    else:
        print(f"\n[4/4] Check-only mode. Use --apply to inject.")

    print(f"\n{'=' * 50}")
    print(f"SUMMARY:")
    print(f"  Bibliography entries: {len(entries)}")
    print(f"  Inline citations: {len(thesis.inline_citations)}")
    print(f"  Integrity issues: {len(issues)} ({len(errors)}E/{len(warnings)}W/{len(infos)}I)")
    print(f"{'=' * 50}")

    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())