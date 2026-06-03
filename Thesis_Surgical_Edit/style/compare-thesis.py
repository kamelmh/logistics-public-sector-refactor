"""
⚠️  DEPRECATED — Replaced by: diff-thesis.py (for comparison only)
    This script is superseded and no longer part of the active pipeline.
    Kept for reference only. Do not use in new workflows.
"""
"""compare-thesis.py — Compare last 2 thesis builds from metrics history
Usage: python compare-thesis.py [--json]
"""
import sys, os, json
from pathlib import Path

style_dir = os.path.dirname(os.path.abspath(__file__))
ts_dir = os.path.dirname(style_dir)  # Thesis_Surgical_Edit/
project_root = os.path.dirname(ts_dir)
output_dir = os.path.join(project_root, "Thesis_Surgical_Edit", "output")
history_file = os.path.join(output_dir, "metrics", "build_history.json")

if not os.path.exists(history_file):
    print(json.dumps({"note": "No build history found"}))
    sys.exit(0)

with open(history_file, 'r', encoding='utf-8') as f:
    history = json.load(f)

if len(history) < 2:
    print(json.dumps({"note": "Only 1 build in history", "builds": len(history), "latest": history[-1] if history else None}))
    sys.exit(0)

current = history[-1]
previous = history[-2]

fields = ["paragraph_count", "table_count", "footnote_count", "section_count",
          "h1_count", "h2_count", "h3_count", "file_size_kb", "score_overall"]

deltas = {}
for field in fields:
    c = current.get(field, 0) or 0
    p = previous.get(field, 0) or 0
    delta = c - p
    emoji = "▲" if delta > 0 else ("▼" if delta < 0 else "─")
    deltas[field] = {"current": c, "previous": p, "delta": delta, "arrow": emoji}

comparison = {
    "current_build": current.get("build_id"),
    "previous_build": previous.get("build_id"),
    "deltas": deltas,
}

if "--json" in sys.argv:
    print(json.dumps(comparison, indent=2, ensure_ascii=False))
else:
    b1 = current.get("build_id", "?")
    b2 = previous.get("build_id", "?")
    print(f"  Comparing build {b2} → {b1}")
    for field, d in deltas.items():
        print(f"    {d['arrow']} {field}: {d['previous']} → {d['current']} ({d['delta']:+d})")
