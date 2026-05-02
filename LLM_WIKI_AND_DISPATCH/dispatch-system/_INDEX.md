---
title: Dispatch System
type: index
last_updated: 2026-05-02
tags: [dispatch, model, agent, alerts]
---

# Dispatch System

## Files

| File | Description | Status |
|------|-------------|--------|
| [[MODEL_MATRIX|Model Matrix]] | haiku/sonnet/opus/gemini matrix | ✅ Complete |
| [[ALERT_RULES|Alert Rules]] | When to warn about wrong model | ✅ Complete |
| [[ROUTING_LOGIC|Routing Logic]] | Task → Model → Agent flow | ✅ Complete |
| [[VALIDATION_SCRIPTS|Validation Scripts]] | Verification checklists | ✅ Complete |

## Model Selection Quick Reference

| Task | Model | Alert If Wrong |
|------|-------|----------------|
| Quick lookup | haiku | opus (overkill) |
| Standard coding | sonnet | haiku (insufficient) |
| Architecture | opus | haiku (too weak) |
| NotebookLM | gemini | claude (no context) |
| VBA refactoring | sonnet | haiku (too complex) |

## Routing Decision Tree

```
User Request
├── NotebookLM/Research? → Gemini
├── Quick/Simple? → haiku
├── Architecture/Deep? → opus
├── VBA Coding/Thesis? → sonnet
└── Default: sonnet
```

## Alert Types

| Alert | Trigger | Action |
|-------|---------|--------|
| MODEL MISMATCH | Wrong model for task | Suggest correct model |
| TOOL MISMATCH | Claude doing Gemini task | Export to Gemini |
| CONSTRAINT VIOLATION | Python/externals detected | Rewrite pure VBA |
| TERMINOLOGY VIOLATION | Tech terms in thesis | Use administrative vocab |
| CONTEXT WARNING | Approaching token limit | Use Repomix isolation |

## OMC Commands

| Command | Agent | Model |
|---------|--------|-------|
| `/team 3:executor "fix errors"` | executor | sonnet |
| `/orchestrate` | team-plan + architect | opus |
| `/ultrawork` | Multiple agents | Mixed |
| `/ralph` | ralph | sonnet |
