"""Add wiki-links to Knowledge Base MDs connecting to life goals."""
import json, os, re

kb_dir = r"C:\Users\Admin\My Drive\LifeWorkspace\15_Advanced_Tools\Knowledge_Base"
cache_dir = r"C:\Users\Admin\Projects\active\pdf-image-extractor\cache"

# Load summaries
with open(os.path.join(cache_dir, "summaries.json"), encoding="utf-8") as f:
    summaries = json.load(f)

# Define wiki-link mappings
WIKI_LINKS = {
    "academic": {
        "header": "Academic Documents",
        "connections": [
            "[[Learning_Roadmap]] — Study plan",
            "[[Education_History]] — University degrees",
            "[[Skills_Inventory]] — Academic skills",
            "[[CCA-F_Certification]] — Professional certification"
        ]
    },
    "spiritual": {
        "header": "Spiritual Documents",
        "connections": [
            "[[12_Astrology]] — Astro-Quranic system",
            "[[MAHI_Spiritual_System]] — Daily practice",
            "[[AstroDashboard]] — Web dashboard",
            "[[Personal_Vision]] — Life purpose"
        ]
    },
    "logistics": {
        "header": "Logistics Documents",
        "connections": [
            "[[CCA-F_Certification]] — Stock management certification",
            "[[BTS_Logistics]] — BTS degree",
            "[[Career_Roadmap]] — AI architect path",
            "[[Skills_Inventory]] — Logistics skills"
        ]
    },
    "teaching": {
        "header": "Teaching Documents",
        "connections": [
            "[[10_Education_Project]] — English teaching system",
            "[[Exercise_Generator]] — Exercise creation tool",
            "[[English_Teaching]] — Teaching methodology",
            "[[Freelancing_Guide]] — Teaching as income"
        ]
    },
    "personal": {
        "header": "Personal Documents",
        "connections": [
            "[[Personal_Profile]] — Identity management",
            "[[01_Identities_&_Assets]] — Documents vault",
            "[[Health_Tracking]] — Health logs",
            "[[Personal_Finance]] — Financial records"
        ]
    },
    "business": {
        "header": "Business Documents",
        "connections": [
            "[[KDP_Self-Publishing]] — Self-publishing hub",
            "[[Freelancing_Guide]] — Client work",
            "[[30_Day_Action_Plan]] — Launch plan",
            "[[Pricing_Strategy]] — Rate optimization"
        ]
    },
    "technical": {
        "header": "Technical Documents",
        "connections": [
            "[[Programming_Languages]] — Python, VBA, JS",
            "[[AI_ML_Skills]] — Claude API, MCP",
            "[[Tools_Platforms]] — Git, OpenCode",
            "[[AstroDashboard]] — Web dashboard"
        ]
    }
}

# Process each MD file
for cat, link_info in WIKI_LINKS.items():
    md_path = os.path.join(kb_dir, "%s.md" % cat)
    if not os.path.exists(md_path):
        print("Missing: %s" % md_path)
        continue
    
    with open(md_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Add connections section at the top
    connections_section = "\n".join([
        "",
        "## Life Goal Connections",
        "",
    ] + ["- %s" % conn for conn in link_info["connections"]] + [
        "",
        "---",
        ""
    ])
    
    # Insert after the header
    lines = content.split("\n")
    insert_pos = 0
    for i, line in enumerate(lines):
        if line.startswith("## ") and i > 0:
            insert_pos = i
            break
    
    # Insert connections
    new_lines = lines[:insert_pos] + connections_section.split("\n") + lines[insert_pos:]
    
    # Write back
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(new_lines))
    
    print("Updated: %s.md (%d connections)" % (cat, len(link_info["connections"])))

# Update 00-INDEX.md with life goal connections
index_path = os.path.join(kb_dir, "00-INDEX.md")
with open(index_path, "r", encoding="utf-8") as f:
    content = f.read()

# Add life goal section
life_goal_section = """
## Life Goal Connections

| Category | Documents | Primary Goal | Secondary Goals |
|----------|-----------|--------------|-----------------|
| Academic | 174 | [[Skills_Inventory]] | [[Learning_Roadmap]], [[Career_Roadmap]] |
| Spiritual | 170 | [[12_Astrology]] | [[MAHI_Spiritual_System]], [[Personal_Vision]] |
| Logistics | 128 | [[CCA-F_Certification]] | [[BTS_Logistics]], [[Career_Roadmap]] |
| Teaching | 18 | [[10_Education_Project]] | [[Exercise_Generator]], [[Freelancing_Guide]] |
| Personal | 80 | [[Personal_Profile]] | [[01_Identities_&_Assets]], [[Health_Tracking]] |
| Business | 24 | [[KDP_Self-Publishing]] | [[Freelancing_Guide]], [[30_Day_Action_Plan]] |
| Technical | 31 | [[Programming_Languages]] | [[AI_ML_Skills]], [[AstroDashboard]] |

**Total:** 656 documents connected to life goals

---

## Knowledge Graph Stats

- **Entities:** 565 (4 goals, 24 skills, 537 documents)
- **Connections:** 3,415
- **Goal Coverage:** Identity (224), Skills (285), Career (286), Projects (231)
"""

# Insert before the Files section
if "## Files" in content:
    content = content.replace("## Files", life_goal_section + "## Files")

with open(index_path, "w", encoding="utf-8") as f:
    f.write(content)

print("\nUpdated: 00-INDEX.md with life goal connections")
