---
title: Context Management
type: index
last_updated: 2026-05-02
tags: [context, token-limits, repomix, chunking]
---

# Context Management

## Files

| File | Description | Status |
|------|-------------|--------|
| [[CONTEXT_WINDOW_STRATEGY|Context Window Strategy]] | Handling limited contexts | ✅ Complete |
| [[RATE_LIMIT_PROTOCOL|Rate Limit Protocol]] | Rate limit management | ✅ Complete |
| [[REPOMIX_WORKFLOW|Repomix Workflow]] | Context packing strategy | ✅ Complete |
| [[CHUNKING_STRATEGY|Chunking Strategy]] | Breaking large documents | ✅ Complete |

## Model Context Limits

| Model | Context Window | Best Use |
|-------|----------------|----------|
| Haiku | ~200K tokens | Quick lookups, simple edits |
| Sonnet | ~200K tokens | Standard coding, VBA refactoring |
| Opus | ~200K tokens | Deep analysis, architecture |
| Gemini 1.5 Pro | ~1M tokens | Large document analysis, NotebookLM |

## Repomix Files

**Location:** `Logistics.Public.Sector.Refactor/Repomix_Outputs/`

| File | Content | Use Case |
|------|---------|----------|
| `repomix-project.xml` | Full project | General queries |
| `repomix-software.xml` | VBA codebase | Software refactoring |
| `repomix-thesis.xml` | Thesis files | Thesis writing |

## Alert Thresholds

| Used Tokens | Action |
|--------------|--------|
| < 100K | ✅ Safe to continue |
| 100K-150K | ⚠️ Approaching limit - consider compression |
| 150K-180K | 🔴 Warning - use Repomix isolation |
| > 180K | 🚨 Critical - upgrade model or split task |
