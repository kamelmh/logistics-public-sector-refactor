# Claude Desktop Deep Verification — Resume Prompt
# Use this if you hit rate limits mid-phase

---

## Resume Template

Copy and customize this when resuming after rate limit:

```
Resume from where I left off. Here's what was completed:

PHASES COMPLETED:
- Phase 1: ✅ Complete — [paste summary from MSG 1]
- Phase 2: ✅ Complete — [paste summary from MSG 2]
- Phase 3: 🔄 In Progress — [paste what was done]

CONTINUE FROM:
[Exact point where you stopped — copy the last few lines of Claude's response]

RESUME PROMPT:
[Copy the specific resume prompt from the phase you were working on]
```

---

## Phase-Specific Resume Prompts

### Phase 1 Resume:
```
Continue Phase 1 content check. You were checking chapter completeness and ground truth values. Report findings so far.
```

### Phase 2 Resume:
```
Continue Phase 2 footnote check. You were verifying citation completeness and cross-referencing with bibliography.
```

### Phase 3 Resume:
```
Continue Phase 3 RTL check. You were verifying Arabic/French bilingual quality and terminology consistency.
```

### Phase 4 Resume:
```
Continue Phase 4 formatting check. You were verifying visual design, table styling, and typography.
```

### Phase 5 Resume:
```
Continue Phase 5 numbering check. You were verifying TOC, table numbering, and cross-references.
```

### Phase 6 Resume:
```
Continue Phase 6 calculations check. You were verifying Wilson formula, ROP, total cost, and hypothesis proof.
```

---

## Rate Limit Reset Schedule

| Plan | Messages | Window | Reset Strategy |
|------|----------|--------|----------------|
| Free | 25 | 4 hours | Wait 4 hours, or use different session |
| Pro | 100 | 4 hours | Wait 4 hours |

**Tip:** If you hit the limit, take a break. The system resets automatically.

---

## Saving Responses

After each message, copy the response and save to:

```
C:/Users/Administrator/Dropbox/Logistics.Public.Sector.Refactor/Thesis_Surgical_Edit/deep_verification/phase_1_response.md
C:/Users/Administrator/Dropbox/Logistics.Public.Sector.Refactor/Thesis_Surgical_Edit/deep_verification/phase_2_response.md
... etc.
```

This way you have a complete record of the verification.
