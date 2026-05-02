---
title: Rate Limit Protocol
type: protocol
last_updated: 2026-05-02
tags: [rate-limits, quota, throttling]
---

# Rate Limit Protocol

## Model Rate Limits (Typical)

| Model | Requests/Min | Tokens/Min | Daily Quota |
|-------|--------------|-------------|-------------|
| **Haiku** | ~1000 | ~200K | High |
| **Sonnet** | ~500 | ~200K | Medium |
| **Opus** | ~100 | ~200K | Low |
| **Gemini 1.5 Pro** | ~60 | ~1M | Medium |

*Note: Actual limits vary by API tier and provider.*

---

## Rate Limit Warnings

### When Approaching Limits

```
⚠️ RATE LIMIT: Approaching {model} rate limit
→ Strategy: Switch to haiku for simple tasks
→ Wait: {seconds} seconds before retry
→ Alternative: Use Gemini for research (separate quota)
```

### Handling 429 Errors (Too Many Requests)

1. **Stop current requests**
2. **Wait** recommended retry-after period
3. **Switch model** if possible (haiku for simple tasks)
4. **Log event** to `logs/ALIGNMENT_LOG.md`

---

## Mitigation Strategies

### Strategy 1: Model Downgrade

**When rate limited on Opus/Sonnet:**

| Original Task | Downgrade To | Caveat |
|---------------|---------------|--------|
| Opus (architecture) | Sonnet | Less depth |
| Sonnet (VBA coding) | Haiku | May struggle with complexity |
| Any Claude | Gemini | NotebookLM context lost |

### Strategy 2: Task Batching

**Group similar tasks together:**

```
Batch 1: All quick lookups (haiku)
  - "What is EOQ formula?"
  - "Check VBA syntax"
  - "Verify El Bayadh constants"

Batch 2: All VBA coding (sonnet)
  - Refactor mod_StockEngine.bas
  - Update frmStockEntry.frm
  - Fix VBA syntax errors

Batch 3: All thesis writing (sonnet/opus)
  - Draft Chapter 1
  - Draft Chapter 3
  - Review terminology
```

### Strategy 3: Async Processing

**For large tasks:**

1. **Break into chunks**
2. **Process sequentially** (avoid parallel requests)
3. **Use web-search agent** for independent research
4. **Wait between chunks** (respect rate limits)

---

## Quota Management

### Daily Budget Allocation

| Model | Daily Budget | Reserved For |
|-------|--------------|-------------|
| **Haiku** | High | Quick lookups, simple edits |
| **Sonnet** | Medium | VBA coding, thesis writing |
| **Opus** | Low | Architecture, deep analysis |
| **Gemini** | Medium | NotebookLM, research |

### Warning Thresholds

| Used Quota | Action |
|-------------|--------|
| < 50% | ✅ Safe to continue |
| 50-80% | ⚠️ Start batching tasks |
| 80-95% | 🔴 Use haiku only for rest of day |
| > 95% | 🚨 Stop non-critical tasks |

---

## Cross-Model Fallback

### Fallback Chain

```
Primary: Sonnet (for VBA coding)
    ↓ (if rate limited)
Fallback 1: Haiku (quick fix)
    ↓ (if still limited)
Fallback 2: Gemini (external, no VBA execution)
    ↓ (if all limited)
Wait: Resume next day
```

---

## Logging Rate Limit Events

### Format for `logs/ALIGNMENT_LOG.md`

```markdown
## Rate Limit Event - [timestamp]
- **Model:** [haiku/sonnet/opus/gemini]
- **Task:** [description]
- **Error:** 429 Too Many Requests
- **Action Taken:** [downgrade/wait/switch model]
- **Resolution:** [task completed/deferred]
```

---

## Practical Examples

### Example 1: Opus Rate Limited (Architecture Task)
```
1. Task: "Design VBA DSS architecture" (needs Opus)
2. Error: 429 Too Many Requests
3. Action: Wait 60 seconds
4. Retry: Success (within limits)
```

### Example 2: Sonnet Rate Limited (VBA Coding)
```
1. Task: "Refactor all VBA modules" (needs Sonnet)
2. Error: 429 Too Many Requests
3. Action: Switch to Haiku for simple modules
4. Queue complex modules for next day
```

### Example 3: All Claude Models Limited
```
1. Error: All Claude models returning 429
2. Action: Switch to Gemini for research tasks
3. Note: Cannot execute VBA code in Gemini
4. Wait: Resume VBA tasks next day
```

---

## Cross-Reference

| File | Purpose |
|------|---------|
| `ai-alignment/MODEL_DISPATCH.md` | Model selection |
| `dispatch-system/ALERT_RULES.md` | Rate limit alerts |
| `context-management/CONTEXT_WINDOW_STRATEGY.md` | Token management |
| `logs/ALIGNMENT_LOG.md` | Log rate limit events |

---

*End of Rate Limit Protocol*
