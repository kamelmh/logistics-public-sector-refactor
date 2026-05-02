---
title: GitHub Integration
type: integration
last_updated: 2026-05-02
tags: [github, integration, repo, cicd]
---

# GitHub Integration

## Repository Strategy

### Project Repositories

| Repo | Purpose | Status |
|------|---------|--------|
| **Academix-v13.2** | Main project (VBA DSS + Thesis) | Active |
| **LLM-Wiki** | Knowledge base & dispatch system | 🔄 In Progress |
| **AI-Hubs** | Skills, plugins, agents collection | Active |

---

## GitHub CLI (gh) Usage

### Common Commands

```bash
# Check repo status
gh repo view

# Create pull request
gh pr create --title "..." --body "..."

# List issues
gh issue list

# Check CI/CD status
gh run list
```

---

## CI/CD Integration

### Using `ci-cd` Skill

**Skill Path:** `.claude/skills/ci-cd/`  
**Purpose:** Automate builds, tests, deployments

### Pipeline Stages

1. **Build:** Compile VBA project (export to .xlsm)
2. **Test:** Run VBA tests (if available)
3. **Lint:** Check VBA code style
4. **Deploy:** Package for jury submission

---

## Repomix for Context Packing

### What is Repomix?

Tool for generating isolated context files (.xml or .txt) for AI tools.

### Repomix Outputs Location
`C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Repomix_Outputs\`

| File | Content | Use Case |
|------|---------|----------|
| `repomix-project.xml` | Full project context | General queries |
| `repomix-software.xml` | VBA codebase only | Software refactoring |
| `repomix-thesis.xml` | Thesis files only | Thesis writing |

### Workflow

```
1. Generate Repomix file (isolate context)
2. Load into AI tool (Claude/OpenCode)
3. Work in isolated workspace
4. Prevent old Python code "hallucination"
```

---

## Version Control Best Practices

### Git Commands for VBA Project

```bash
# Check status
git status

# Add VBA modules
git add Software_Surgical_Edit/VBA_Modules/

# Commit with descriptive message
git commit -m "refactor: convert mod_SyncBridge to pure VBA arrays"

# Push to remote
git push origin main
```

### .gitignore for VBA Project

```
# Excel temp files
~$*.xlsm
*.tmp

# Backup files
*.bak
*.old

# Python (excluded per Clean Room rules)
*.py
*.pyc
__pycache__/
venv/

# Node modules (for tooling only)
node_modules/

# Logs
*.log
```

---

## GitHub Skills Integration

### Available Skills

| Skill | Purpose | Path |
|-------|---------|------|
| **version-control** | Manage Git repos, branching, PRs | `.claude/skills/version-control/` |
| **ci-cd** | Set up CI/CD pipelines | `.claude/skills/ci-cd/` |
| **dependency-scanning** | Scan for vulnerabilities (SBOM) | `.claude/skills/dependency-scanning/` |

---

## Branch Strategy (Simplified for Single Developer)

```
main (stable)
├── thesis-drafts (for thesis work)
├── vba-staging (for VBA refactoring)
└── llm-wiki (for wiki development)
```

**Note:** Given "Clean Room" constraints (single developer, academic project), simple branching is sufficient.

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `project-understanding/WORKFLOW_INTEGRATION.md` | AI tools pipeline |
| `context-management/REPOMIX_WORKFLOW.md` | Repomix strategy |
| `dispatch-system/VALIDATION_SCRIPTS.md` | CI/CD validation |
| `ai-hub/PLUGINS_INVENTORY.md` | Plugin integrations |

---

*End of GitHub Integration*
