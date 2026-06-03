"""
⚠️  DEPRECATED — Replaced by: verify_docx_checks.py (includes measurement)
    This script is superseded and no longer part of the active pipeline.
    Kept for reference only. Do not use in new workflows.
"""
"""measure-thesis.py — Record thesis metrics, matching thesis-doctor format
Usage: python measure-thesis.py <docx_path> <source_path> [--verify-passed N] [--verify-failed N]
"""
import sys, os, json, datetime, importlib.util

docx_path = sys.argv[1] if len(sys.argv) > 1 else ''
source_path = sys.argv[2] if len(sys.argv) > 2 else ''

if not docx_path or not os.path.exists(docx_path):
    print(json.dumps({"error": "DOCX not found", "path": docx_path}))
    sys.exit(1)

verify_passed = 0; verify_failed = 0
for i, a in enumerate(sys.argv):
    if a == '--verify-passed' and i + 1 < len(sys.argv): verify_passed = int(sys.argv[i + 1])
    if a == '--verify-failed' and i + 1 < len(sys.argv): verify_failed = int(sys.argv[i + 1])

inspect_path = os.path.join(os.path.dirname(__file__), 'inspect_docx_metrics.py')
spec = importlib.util.spec_from_file_location("inspect", inspect_path)
inspect = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inspect)

raw = inspect.inspect_docx(docx_path)
build_id = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

file_size_kb = os.path.getsize(docx_path) // 1024

entry = {
    "build_id": build_id,
    "timestamp": timestamp,
    "source": os.path.abspath(source_path) if source_path else "",
    "docx": {
        "paragraph_count": raw.get("paragraph_count", 0),
        "table_count": raw.get("table_count", 0),
        "footnote_count": raw.get("footnote_count", 0),
        "section_count": raw.get("section_count", 0),
        "h1_count": raw.get("h1_count", 0),
        "h2_count": raw.get("h2_count", 0),
        "h3_count": raw.get("h3_count", 0),
        "file_size_kb": file_size_kb,
        "font_ok": raw.get("body_font_ok", 0),
        "font_bad": raw.get("body_font_bad", 0),
        "size_ok": raw.get("body_size_ok", 0),
        "size_bad": raw.get("body_size_bad", 0),
        "rtl_ok": raw.get("rtl_ok", 0),
        "rtl_bad": raw.get("rtl_bad", 0),
        "spacing_ok": raw.get("spacing_ok", 0),
        "spacing_bad": raw.get("spacing_bad", 0),
    },
    "verify": {
        "passed": verify_passed,
        "failed": verify_failed,
        "total": verify_passed + verify_failed,
    },
    "build": {
        "steps": ["pandoc", "python-fixes"]
    },
}

metrics_dir = os.path.join(os.path.dirname(docx_path), "metrics")
os.makedirs(metrics_dir, exist_ok=True)

entry_file = os.path.join(metrics_dir, f"build-{build_id}.json")
with open(entry_file, 'w', encoding='utf-8') as f:
    json.dump(entry, f, indent=2, ensure_ascii=False)
# Append to build history
history_file = os.path.join(metrics_dir, "build_history.json")
if os.path.exists(history_file):
    with open(history_file, 'r', encoding='utf-8') as hf:
        history = json.load(hf)
else:
    history = []
history.append(entry)
with open(history_file, 'w', encoding='utf-8') as hf:
    json.dump(history, hf, indent=2, ensure_ascii=False)

print(json.dumps({
    "build_id": build_id,
    "paragraph_count": entry["docx"]["paragraph_count"],
    "table_count": entry["docx"]["table_count"],
    "footnote_count": entry["docx"]["footnote_count"],
    "section_count": entry["docx"]["section_count"],
    "file_size_kb": file_size_kb,
    "verify_passed": verify_passed,
    "verify_failed": verify_failed,
}, indent=2))
