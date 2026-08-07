"""Rebuild Knowledge Graph with life goal connections."""
import json, os

cache_dir = r"C:\Users\Admin\Projects\active\pdf-image-extractor\cache"
output_dir = r"C:\Users\Admin\Projects\active\enhancements\output"

# Load summaries
with open(os.path.join(cache_dir, "summaries.json"), encoding="utf-8") as f:
    summaries = json.load(f)

# Define life goal mappings
LIFE_GOALS = {
    "Identity": {
        "entity_type": "goal",
        "connections": ["Personal_Profile", "Education_History", "Skills_Inventory"]
    },
    "Skills": {
        "entity_type": "goal",
        "connections": ["Programming_Languages", "AI_ML_Skills", "English_Language", "French_Language"]
    },
    "Career": {
        "entity_type": "goal",
        "connections": ["Career_Roadmap", "CCA-F_Certification", "Freelancing_Guide"]
    },
    "Projects": {
        "entity_type": "goal",
        "connections": ["10_Education_Project", "AstroDashboard", "KDP_Self-Publishing"]
    }
}

# Define skill mappings from categories
CATEGORY_TO_SKILLS = {
    "academic": ["English_Language", "Academic_Writing", "Phonetics", "Literature"],
    "spiritual": ["Astrology", "Islamic_Spirituality", "Quranic_Studies"],
    "logistics": ["Stock_Management", "Purchasing", "Warehousing", "Inventory_Management"],
    "teaching": ["English_Teaching", "Grammar_Instruction", "Curriculum_Design"],
    "personal": ["Identity_Management", "Health_Tracking", "Personal_Finance"],
    "business": ["KDP_Self-Publishing", "Freelancing", "Wedding_Planning"],
    "technical": ["Python_Programming", "VBA", "Computer_Languages", "Astrology_Charts"]
}

# Define goal mappings from categories
CATEGORY_TO_GOALS = {
    "academic": ["Skills", "Career"],
    "spiritual": ["Identity", "Projects"],
    "logistics": ["Skills", "Career"],
    "teaching": ["Projects", "Career"],
    "personal": ["Identity"],
    "business": ["Career", "Projects"],
    "technical": ["Skills", "Projects"]
}

# Build entities
entities = {}
connections = []

# Add life goals as entities
for goal_name, goal_info in LIFE_GOALS.items():
    entities[goal_name] = {
        "entity_type": "goal",
        "name": goal_name,
        "connections": goal_info["connections"]
    }

# Add skills as entities
all_skills = set()
for cat, skills in CATEGORY_TO_SKILLS.items():
    for skill in skills:
        all_skills.add(skill)
        entities[skill] = {
            "entity_type": "skill",
            "name": skill,
            "connections": []
        }

# Add documents and connect them
for path, data in summaries.items():
    cat = data.get("category", "other")
    doc_name = data.get("title", os.path.basename(path))
    
    # Add document entity
    entities[doc_name] = {
        "entity_type": "document",
        "name": doc_name,
        "path": path,
        "category": cat,
        "connections": []
    }
    
    # Connect document to skills
    if cat in CATEGORY_TO_SKILLS:
        for skill in CATEGORY_TO_SKILLS[cat]:
            if skill in entities:
                entities[doc_name]["connections"].append(skill)
                entities[skill]["connections"].append(doc_name)
                connections.append({
                    "from": doc_name,
                    "to": skill,
                    "relationType": "teaches"
                })
    
    # Connect document to goals
    if cat in CATEGORY_TO_GOALS:
        for goal in CATEGORY_TO_GOALS[cat]:
            if goal in entities:
                entities[doc_name]["connections"].append(goal)
                entities[goal]["connections"].append(doc_name)
                connections.append({
                    "from": doc_name,
                    "to": goal,
                    "relationType": "supports"
                })

# Connect skills to goals
SKILL_TO_GOALS = {
    "English_Language": ["Skills", "Career"],
    "Academic_Writing": ["Skills", "Career"],
    "Phonetics": ["Skills", "Projects"],
    "Literature": ["Skills"],
    "Astrology": ["Projects", "Identity"],
    "Islamic_Spirituality": ["Identity"],
    "Quranic_Studies": ["Identity"],
    "Stock_Management": ["Skills", "Career"],
    "Purchasing": ["Skills", "Career"],
    "Warehousing": ["Skills", "Career"],
    "Inventory_Management": ["Skills", "Career"],
    "English_Teaching": ["Projects", "Career"],
    "Grammar_Instruction": ["Projects"],
    "Curriculum_Design": ["Projects"],
    "Identity_Management": ["Identity"],
    "Health_Tracking": ["Identity"],
    "Personal_Finance": ["Identity", "Career"],
    "KDP_Self-Publishing": ["Projects", "Career"],
    "Freelancing": ["Career"],
    "Wedding_Planning": ["Projects"],
    "Python_Programming": ["Skills", "Projects"],
    "VBA": ["Skills", "Projects"],
    "Computer_Languages": ["Skills"],
    "Astrology_Charts": ["Projects"]
}

for skill, goals in SKILL_TO_GOALS.items():
    if skill in entities:
        for goal in goals:
            if goal in entities:
                entities[skill]["connections"].append(goal)
                entities[goal]["connections"].append(skill)
                connections.append({
                    "from": skill,
                    "to": goal,
                    "relationType": "enables"
                })

# Connect goals to projects
GOAL_TO_PROJECTS = {
    "Projects": ["10_Education_Project", "AstroDashboard", "KDP_Self-Publishing"],
    "Career": ["CCA-F_Certification", "Freelancing_Guide", "Career_Roadmap"],
    "Skills": ["Learning_Roadmap", "Certifications"],
    "Identity": ["Personal_Profile", "Education_History"]
}

for goal, projects in GOAL_TO_PROJECTS.items():
    if goal in entities:
        for project in projects:
            entities[goal]["connections"].append(project)

# Remove duplicates
for entity_name, entity_info in entities.items():
    entity_info["connections"] = list(set(entity_info["connections"]))

# Build output
output = {
    "summary": {
        "total_entities": len(entities),
        "total_connections": len(connections),
        "entity_types": {},
        "goal_connections": {}
    },
    "entities": entities,
    "connections": connections
}

# Count entity types
for entity_info in entities.values():
    etype = entity_info.get("entity_type", "unknown")
    output["summary"]["entity_types"][etype] = output["summary"]["entity_types"].get(etype, 0) + 1

# Count goal connections
for goal_name in LIFE_GOALS:
    if goal_name in entities:
        output["summary"]["goal_connections"][goal_name] = len(entities[goal_name]["connections"])

# Save
with open(os.path.join(output_dir, "knowledge_graph_v2.json"), "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

# Generate markdown
md_lines = ["# Knowledge Graph v2", ""]
md_lines.append("Entities: %d" % len(entities))
md_lines.append("Connections: %d" % len(connections))
md_lines.append("")
md_lines.append("## Entity Types")
for etype, count in output["summary"]["entity_types"].items():
    md_lines.append("- %s: %d" % (etype, count))
md_lines.append("")
md_lines.append("## Goal Connections")
for goal, count in output["summary"]["goal_connections"].items():
    md_lines.append("- %s: %d connections" % (goal, count))
md_lines.append("")
md_lines.append("## Top Skills")
skill_entities = [(k, v) for k, v in entities.items() if v.get("entity_type") == "skill"]
skill_entities.sort(key=lambda x: len(x[1]["connections"]), reverse=True)
for name, info in skill_entities[:10]:
    md_lines.append("- %s: %d connections" % (name, len(info["connections"])))

with open(os.path.join(output_dir, "knowledge_graph_v2.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(md_lines))

print("Knowledge Graph v2 built:")
print("  Entities: %d" % len(entities))
print("  Connections: %d" % len(connections))
print("  Entity types: %s" % output["summary"]["entity_types"])
print("  Goal connections: %s" % output["summary"]["goal_connections"])
