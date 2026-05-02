---
title: LLM Wiki & Dispatch System
type: master-index
status: active
last_updated: 2026-05-02
tags: [llm, wiki, dispatch, alignment, ai-hub, gemini, claude, opencode]
---

# LLM Wiki & Dispatch System

> A comprehensive knowledge base for managing AI workflows, model selection, and agent dispatching for the Academix v13.2 project.

## Quick Navigation

| Section | Description | Status |
|---------|-------------|--------|
| [[ai-alignment/MODEL_DISPATCH\|Model Dispatch]] | Model selection matrix + routing rules | ✅ Ready |
| [[project-understanding/PROJECT_MEMORY\|Project Memory]] | Ground truth + El Bayadh case study | ✅ Ready |
| [[ai-hub/SKILLS_CATALOG\|Skills Catalog]] | Inventory of 50+ skills | ✅ Ready |
| [[dispatch-system/ALERT_RULES\|Alert Rules]] | Wrong agent/model detection | ✅ Ready |
| [[thesis-drafts/CHAPTER_1\|Thesis Drafts]] | Arabic RTL thesis chapters | 🔄 Ready |
| [[vba-staging/mod_Inventory\|VBA Staging]] | Pure VBA modules storage | 🔄 Ready |

## Status Dashboard

| Component | Status | Last Updated |
|-----------|--------|--------------|
| Manifesto | ✅ Complete | 2026-05-02 |
| Model Dispatch | ✅ Complete | 2026-05-02 |
| Skills Catalog | ✅ Complete | 2026-05-02 |
| Gemini Alignment | 📥 Awaiting NotebookLM | 2026-05-02 |
| Context Strategy | ✅ Complete | 2026-05-02 |

## Project Context

**Academix v13.2** - A pure VBA/Excel Decision Support System (DSS) for the Algerian Public Sector, compliant with CNEPD BTS standards.

**Ground Truth Constants:**
- Institution: Directorate of Education, El Bayadh
- Case Study Article: Toner G030 (ART-001)
- Annual Demand (D): 1,546 units
- Economic Order Quantity (Q*): 176 units
- Reorder Point (ROP): 205.6 units
- Safety Stock (SS): 200 units
- Lead Time (LT): 2 days

## Model Routing Quick Reference

| Task | Model | Alert If Wrong |
|------|-------|----------------|
| Quick lookup | haiku | opus (overkill) |
| Standard coding | sonnet | haiku (insufficient) |
| Architecture | opus | haiku (too weak) |
| NotebookLM | gemini | claude (no context) |
| VBA refactoring | sonnet | haiku (too complex) |
