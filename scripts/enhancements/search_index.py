"""Enhancement 5: Search Index - Make all content searchable."""
import os
import json
import re
from collections import defaultdict

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")
CACHE_DIR = os.path.join(os.path.dirname(__file__), "..", "pdf-image-extractor", "cache")
KB_DIR = r"C:\Users\Admin\My Drive\LifeWorkspace\15_Advanced_Tools\Knowledge_Base"


def build_index():
    """Build inverted index from all content."""
    index = defaultdict(list)  # word -> [doc_path, ...]

    # Index PDF summaries
    summaries_path = os.path.join(CACHE_DIR, "summaries.json")
    if os.path.exists(summaries_path):
        with open(summaries_path, encoding="utf-8") as f:
            summaries = json.load(f)
        for path, data in summaries.items():
            text = f"{data.get('title', '')} {data.get('summary', '')} {' '.join(data.get('key_topics', []))}"
            words = set(re.findall(r'\w+', text.lower()))
            for w in words:
                if len(w) > 2:
                    index[w].append({"type": "pdf", "path": path, "title": data.get("title", "")})

    # Index MD files
    if os.path.exists(KB_DIR):
        for f in os.listdir(KB_DIR):
            if f.endswith(".md"):
                with open(os.path.join(KB_DIR, f), encoding="utf-8") as fh:
                    text = fh.read()
                words = set(re.findall(r'\w+', text.lower()))
                for w in words:
                    if len(w) > 2:
                        index[w].append({"type": "md", "path": f, "title": f.replace(".md", "")})

    return dict(index)


def search(query, index, limit=10):
    """Search the index."""
    words = re.findall(r'\w+', query.lower())
    results = defaultdict(lambda: {"score": 0, "title": "", "type": ""})

    for word in words:
        if word in index:
            for item in index[word]:
                key = item["path"]
                results[key]["score"] += 1
                results[key]["title"] = item["title"]
                results[key]["type"] = item["type"]

    sorted_results = sorted(results.items(), key=lambda x: x[1]["score"], reverse=True)
    return sorted_results[:limit]


def run_search():
    """Build and test search index."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("Building search index...")
    index = build_index()
    print(f"Index: {len(index)} terms")

    # Save index
    index_path = os.path.join(OUTPUT_DIR, "search_index.json")
    with open(index_path, "w", encoding="utf-8") as f:
        json.dump(index, f, indent=2, ensure_ascii=False)

    # Test searches
    tests = ["python", "spiritual", "logistics", "english", "astrology"]
    md_path = os.path.join(OUTPUT_DIR, "search_results.md")
    lines = ["# Search Index Results\n"]
    lines.append(f"Index: {len(index)} terms\n\n")

    for query in tests:
        results = search(query, index)
        lines.append(f"## Query: '{query}'\n")
        lines.append(f"Results: {len(results)}\n")
        for path, data in results[:5]:
            lines.append(f"- [{data['title'][:40]}]({path}) ({data['type']}, score: {data['score']})")
        lines.append("")

    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Index saved to: {index_path}")
    print(f"Results saved to: {md_path}")
    return index


if __name__ == "__main__":
    run_search()
