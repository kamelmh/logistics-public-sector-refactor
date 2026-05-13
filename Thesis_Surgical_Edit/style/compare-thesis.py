"""compare-thesis.py — Academix v13.2
Diffs current build metrics against previous build.
Prints color-coded CLI: improved (green), regressed (red), unchanged (gray).
Usage: python compare-thesis.py
  Reads output/metrics/latest.json and previous.json (second-most-recent).
"""
import sys, os, json, glob

METRICS_DIR = "output/metrics"
COLOR_GREEN = "\033[92m"
COLOR_RED = "\033[91m"
COLOR_YELLOW = "\033[93m"
COLOR_GRAY = "\033[90m"
COLOR_CYAN = "\033[96m"
COLOR_RESET = "\033[0m"

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_previous_and_latest():
    builds = sorted(glob.glob(os.path.join(METRICS_DIR, "build-*.json")))
    if len(builds) < 2:
        print(f"{COLOR_YELLOW}Only one build found — no comparison possible.{COLOR_RESET}")
        return None, None
    return load_json(builds[-2]), load_json(builds[-1])

def flatten(d, prefix=""):
    items = []
    for k, v in d.items():
        key = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            items.extend(flatten(v, key).items())
        else:
            items.append((key, v))
    return dict(items)

def cmp_val(a, b, key=""):
    if isinstance(a, bool) and isinstance(b, bool):
        if not a and b: return "improved"
        if a and not b: return "regressed"
        return "unchanged"
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        lower_better = "failed" in key or "error" in key.lower()
        if b > a: return "improved" if not lower_better else "regressed"
        if b < a: return "regressed" if not lower_better else "improved"
        return "unchanged"
    return "changed" if a != b else "unchanged"

def fmt_val(v):
    if isinstance(v, bool):
        return "✅" if v else "❌"
    return str(v)

def main():
    prev, latest = get_previous_and_latest()
    if prev is None or latest is None:
        # Print current state anyway
        if latest:
            print(f"\n{COLOR_CYAN}=== CURRENT BUILD METRICS ==={COLOR_RESET}")
            print(json.dumps(latest, indent=2, ensure_ascii=False)[:1000])
        return

    p_flat = flatten(prev)
    l_flat = flatten(latest)

    improved = []
    regressed = []
    unchanged = []
    new_keys = []

    all_keys = set(list(p_flat.keys()) + list(l_flat.keys()))
    for k in sorted(all_keys):
        if k not in p_flat:
            new_keys.append((k, l_flat[k]))
        elif k not in l_flat:
            regressed.append((k, p_flat[k], None))
        else:
            status = cmp_val(p_flat[k], l_flat[k])
            if status == "improved":
                improved.append((k, p_flat[k], l_flat[k]))
            elif status == "regressed":
                regressed.append((k, p_flat[k], l_flat[k]))
            elif status == "changed":
                unchanged.append((k, p_flat[k], l_flat[k]))
            else:
                unchanged.append((k, p_flat[k], None))

    print(f"\n{COLOR_CYAN}============================={COLOR_RESET}")
    print(f"{COLOR_CYAN}  THESIS BUILD COMPARISON{COLOR_RESET}")
    print(f"{COLOR_CYAN}  {prev['build_id']}  →  {latest['build_id']}{COLOR_RESET}")
    print(f"{COLOR_CYAN}============================={COLOR_RESET}")

    if improved:
        print(f"\n{COLOR_GREEN}✅ IMPROVED ({len(improved)}):{COLOR_RESET}")
        for k, a, b in improved:
            print(f"  {k}: {fmt_val(a)} → {fmt_val(b)}")

    if regressed:
        print(f"\n{COLOR_RED}❌ REGRESSED ({len(regressed)}):{COLOR_RESET}")
        for k, a, b in regressed:
            print(f"  {k}: {fmt_val(a)} → {fmt_val(b) if b is not None else 'MISSING'}")

    if new_keys:
        print(f"\n{COLOR_YELLOW}🆕 NEW ({len(new_keys)}):{COLOR_RESET}")
        for k, v in new_keys:
            print(f"  {k}: {fmt_val(v)}")

    total_unchanged = len(unchanged)
    print(f"\n{COLOR_GRAY}➡️  UNCHANGED: {total_unchanged} metrics{COLOR_RESET}")

    # Exit code: 0 = no regressions, 1 = regressions found
    if regressed:
        print(f"\n{COLOR_RED}⚠️  {len(regressed)} regression(s) detected{COLOR_RESET}")
        sys.exit(1)
    else:
        print(f"\n{COLOR_GREEN}✅ No regressions{COLOR_RESET}")

if __name__ == "__main__":
    main()
