"""Enhancement 4: Knowledge Graph - Connect entities across documents."""
import os
import json
import re
from collections import defaultdict

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")
CACHE_DIR = os.path.join(os.path.dirname(__file__), "..", "pdf-image-extractor", "cache")


def extract_entities():
    """Extract people, places, topics from summaries."""
    summaries_path = os.path.join(CACHE_DIR, "summaries.json")
    if not os.path.exists(summaries_path):
        return {}

    with open(summaries_path, encoding="utf-8") as f:
        summaries = json.load(f)

    entities = defaultdict(lambda: {"type": "", "count": 0, "sources": []})

    for path, data in summaries.items():
        # Extract title
        title = data.get("title", "")
        if title:
            entities[title]["type"] = "document"
            entities[title]["count"] += 1
            entities[title]["sources"].append(path)

        # Extract topics
        for topic in data.get("key_topics", []):
            entities[topic]["type"] = "topic"
            entities[topic]["count"] += 1
            entities[topic]["sources"].append(path)

        # Extract category
        category = data.get("category", "other")
        entities[category]["type"] = "category"
        entities[category]["count"] += 1

    return dict(entities)


def find_connections(entities):
    """Find connections between entities."""
    connections = []
    # Group by co-occurrence in same document
    doc_entities = defaultdict(list)
    for name, data in entities.items():
        for source in data.get("sources", []):
            doc_entities[source].append(name)

    for doc, ents in doc_entities.items():
        for i, e1 in enumerate(ents):
            for e2 in ents[i+1:]:
                connections.append({"from": e1, "to": e2, "via": doc})

    return connections


def run_graph():
    """Build knowledge graph."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    entities = extract_entities()
    connections = find_connections(entities)

    # Save entities
    entities_path = os.path.join(OUTPUT_DIR, "entities.json")
    with open(entities_path, "w", encoding="utf-8") as f:
        json.dump(entities, f, indent=2, ensure_ascii=False)

    # Save connections
    connections_path = os.path.join(OUTPUT_DIR, "connections.json")
    with open(connections_path, "w", encoding="utf-8") as f:
        json.dump(connections, f, indent=2, ensure_ascii=False)

    # Generate MD
    md_path = os.path.join(OUTPUT_DIR, "knowledge_graph.md")
    lines = ["# Knowledge Graph\n"]
    lines.append(f"Entities: {len(entities)}\n")
    lines.append(f"Connections: {len(connections)}\n\n")

    # Top entities
    top = sorted(entities.items(), key=lambda x: x[1]["count"], reverse=True)[:30]
    lines.append("## Top Entities\n")
    lines.append("| Entity | Type | Count |")
    lines.append("|--------|------|-------|")
    for name, data in top:
        lines.append(f"| {name[:50]} | {data['type']} | {data['count']} |")

    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Entities: {len(entities)}")
    print(f"Connections: {len(connections)}")
    print(f"Saved to: {OUTPUT_DIR}")
    return entities, connections


if __name__ == "__main__":
    run_graph()
