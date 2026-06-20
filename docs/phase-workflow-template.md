# Academix v13.4 — Phase-Based Workflow Template
# Use this template for structured, multi-phase work

## How to Use This Template
1. Copy this template to a new file: `phase-[N]-[task-name].md`
2. Fill in the phase details
3. Execute the phase
4. Update the status as you go
5. When complete, move to the next phase

---

# Phase [N]: [Task Name]
**Date**: [Start Date] — [End Date]
**Status**: 🔄 In Progress | ✅ Complete | ⏸️ Blocked

## Objective
[One sentence describing what this phase accomplishes]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Tasks
### Task 1: [Description]
- [ ] Subtask 1.1
- [ ] Subtask 1.2
- **Assigned to**: [Tool/Agent]
- **Estimated time**: [X hours]
- **Status**: ⏳ Pending

### Task 2: [Description]
- [ ] Subtask 2.1
- [ ] Subtask 2.2
- **Assigned to**: [Tool/Agent]
- **Estimated time**: [X hours]
- **Status**: ⏳ Pending

## Rate Limit Strategy
| Tool | Limit | Strategy |
|------|-------|----------|
| Claude Opus | 40 req/min | Use for deep analysis |
| Claude Sonnet | 80 req/min | Primary workhorse |
| Claude Haiku | 150 req/min | Quick tasks, exploration |
| Groq | 30 req/min | Fast explore/debug |
| Gemini Flash | 15 req/min | Large context tasks |

**Token Budget**: [X]K tokens for this phase

## Context for Next Phase
- **Files modified**: [list]
- **Key decisions**: [list]
- **Blockers**: [list]
- **Learnings**: [list]

## Verification
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Handoff file updated

## Phase Complete Checklist
- [ ] All tasks completed
- [ ] Success criteria met
- [ ] Rate limits respected
- [ ] Context saved for next phase
- [ ] HANDOFF.md updated
- [ ] Resume prompt updated

---

# Example: Phase 1 — Thesis Deep Verification

## Phase 1: Thesis Deep Verification
**Date**: 2026-06-15 — 2026-06-15
**Status**: 🔄 In Progress

## Objective
Perform comprehensive verification of thesis DOCX for academic quality and formatting accuracy.

## Success Criteria
- [ ] All 32/32 verification checks pass
- [ ] RTL formatting correct
- [ ] Page numbering working
- [ ] Cover logo visible
- [ ] Tables render correctly

## Tasks
### Task 1: Open DOCX in Word
- [ ] Launch Microsoft Word
- [ ] Open thesis DOCX
- [ ] Check for errors
- **Assigned to**: User
- **Estimated time**: 5 minutes
- **Status**: ⏳ Pending

### Task 2: Update Fields
- [ ] Press Ctrl+A to select all
- [ ] Press F9 to update fields
- [ ] Verify TOC updates
- **Assigned to**: User
- **Estimated time**: 2 minutes
- **Status**: ⏳ Pending

### Task 3: Visual Inspection
- [ ] Cover page: No page number
- [ ] TOC: Page 2
- [ ] Body: Starts at page 3
- [ ] RTL alignment correct
- [ ] Tables render correctly
- [ ] Footnotes formatted properly
- **Assigned to**: Claude Desktop GUI
- **Estimated time**: 15 minutes
- **Status**: ⏳ Pending

## Rate Limit Strategy
| Tool | Limit | Strategy |
|------|-------|----------|
| Claude Desktop | N/A | Visual inspection only |

**Token Budget**: 10K tokens for this phase

## Context for Next Phase
- **Files modified**: None (read-only verification)
- **Key decisions**: None yet
- **Blockers**: None
- **Learnings**: None yet

## Verification
- [ ] All visual checks pass
- [ ] No formatting errors
- [ ] Content complete

## Phase Complete Checklist
- [ ] All tasks completed
- [ ] Success criteria met
- [ ] Context saved for next phase
- [ ] HANDOFF.md updated
- [ ] Resume prompt updated

---

# Phase Workflow Summary

| Phase | Name | Status | Date |
|-------|------|--------|------|
| 1 | Planning & Research | ⏳ Pending | — |
| 2 | Implementation | ⏳ Pending | — |
| 3 | Integration | ⏳ Pending | — |
| 4 | Verification | ⏳ Pending | — |
| 5 | Documentation | ⏳ Pending | — |
| 6 | Deployment | ⏳ Pending | — |

## Session Recovery
When starting a new session:
1. Read this file to understand current phase
2. Read `.crossflow/HANDOFF.md` for latest status
3. Read `CLAUDE.md` for project context
4. Copy resume prompt from `C:\Users\Administrator\.opencode\resume-prompt.md`
5. Continue from where you left off

## Rate Limit Recovery
If you hit rate limits:
1. Switch to a different tool (Claude → OpenCode → Claude CLI)
2. Wait 1-2 minutes for limits to reset
3. Use smaller context windows
4. Batch operations to reduce requests
