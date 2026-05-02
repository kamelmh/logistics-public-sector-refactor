# LLM Wiki & Dispatch System

Welcome to the comprehensive knowledge base for managing AI workflows, model selection, and agent dispatching.

## Purpose

This wiki serves as the central nervous system for the **Academix v13.2** project — a pure VBA/Excel Decision Support System (DSS) for the Algerian Public Sector, compliant with CNEPD BTS standards.

## Structure

```
LLM_WIKI_AND_DISPATCH/
├── _INDEX.md                    # Master index (Notion-style)
├── README.md                    # This file
│
├── ai-alignment/               # AI alignment rules and protocols
│   ├── MANIFESTO.md            # Core project manifesto
│   ├── MODEL_DISPATCH.md       # Model selection matrix
│   ├── GEMINI_ALIGNMENT.md     # NotebookLM alignment (pending)
│   ├── AGENT_PROTOCOLS.md      # OMC/OpenCode agent rules
│   └── DISPATCH_ALERTS.md      # Wrong agent detection
│
├── project-understanding/       # Project knowledge base
│   ├── PROJECT_MEMORY.md       # Ground truth + constants
│   ├── ARCHITECTURE.md         # VBA DSS architecture
│   ├── WORKFLOW_INTEGRATION.md # AI tools pipeline
│   ├── CNEPD_STANDARDS.md      # Compliance docs
│   ├── TERMINOLOGY_MAPPING.md # Tech → Administrative
│   └── EL_BAYADH_DATASET.md   # Case study data (NEW)
│
├── ai-hub/                     # AI resources catalog
│   ├── SKILLS_CATALOG.md      # 50+ skills inventory
│   ├── AGENTS_REGISTRY.md      # Agent types & routing
│   ├── GITHUB_INTEGRATION.md  # Repo + CI/CD
│   └── PLUGINS_INVENTORY.md   # AI-Hubs plugins audit
│
├── context-management/          # Context window strategies
│   ├── CONTEXT_WINDOW_STRATEGY.md
│   ├── RATE_LIMIT_PROTOCOL.md
│   ├── REPOMIX_WORKFLOW.md
│   └── CHUNKING_STRATEGY.md
│
├── dispatch-system/            # Model/agent dispatch logic
│   ├── MODEL_MATRIX.md
│   ├── ALERT_RULES.md
│   ├── ROUTING_LOGIC.md
│   └── VALIDATION_SCRIPTS.md
│
├── thesis-drafts/             # Arabic RTL thesis chapters (NEW)
│   ├── CHAPTER_1.md
│   ├── CHAPTER_2.md
│   ├── CHAPTER_3.md
│   └── CHAPTER_4.md
│
├── vba-staging/               # Pure VBA modules (NEW)
│   ├── mod_Inventory.bas
│   ├── mod_Database.bas
│   └── frm_StockEntry.frm
│
└── logs/                      # Evolution tracking
    ├── CHANGELOG.md
    ├── SESSION_LOG.md
    └── ALIGNMENT_LOG.md
```

## Quick Start

1. **For AI Agents**: Read `ai-alignment/MANIFESTO.md` first
2. **For Model Selection**: Check `dispatch-system/MODEL_MATRIX.md`
3. **For Project Context**: Start with `project-understanding/PROJECT_MEMORY.md`
4. **For Skills**: Browse `ai-hub/SKILLS_CATALOG.md`

## Key Rules (Non-Negotiable)

- ✅ Pure VBA/Excel only (NO Python, NO Flask, NO APIs)
- ✅ Formal Academic Arabic (RTL) for thesis
- ✅ CNEPD BTS hierarchy: فصل → مبحث → مطلب
- ✅ Zero external dependencies
- ✅ Administrative terminology (not technical)

## Next Steps

1. Paste Gemini NotebookLM export into `ai-alignment/GEMINI_ALIGNMENT.md`
2. Populate `thesis-drafts/` with Arabic chapters
3. Stage VBA modules in `vba-staging/`
4. Lock in El Bayadh dataset in `project-understanding/EL_BAYADH_DATASET.md`
