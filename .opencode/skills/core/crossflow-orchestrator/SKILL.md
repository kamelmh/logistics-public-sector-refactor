# CrossFlow Orchestrator — Multi-Window Session Skill

## Purpose
Orchestrate work across multiple AI windows/sessions, each with specialized models,
sharing context via CrossFlow. This is the **براءة اختراع (patent)**: parallel
specialized AI sessions coordinated through a single shared context layer.

## Active Window Topology (Academix v13.2)

```
┌─────────────────────────────────────────────────────┐
│                 CrossFlow (MASTER_CONTEXT.md)        │
│  Shared context, handoff, session log, ground truth  │
└────────────┬──────────────┬──────────────┬──────────┘
             │              │              │
    ┌────────▼───┐  ┌──────▼──────┐  ┌───▼────────┐
    │ main-hub   │  │gemini-thesis│  │claude-proj  │
    │ big-pickle │  │Gemini Flash │  │Claude Desk. │
    │ VBA/ERP    │  │Thesis/MD    │  │Discussion   │
    └────────────┘  └─────────────┘  └─────────────┘
```

## Domain Ownership

| Task Type | Owner Window | Why |
|-----------|-------------|-----|
| VBA code, build, verify | main-hub (big-pickle) | Fast Groq Llama 3.3, VBA-optimized |
| Thesis polish, analysis | gemini-thesis (Gemini Flash) | 1M ctx, deep reasoning |
| Thesis discussion, review | claude-project (Claude Desktop) | Human-in-loop, give-and-take |
| Architecture planning | main-hub | Planning skill, context depth |
| Audit, testing | main-hub | Direct VBA access |

## Handoff Message Format

When handing off between windows, use this format in HANDOFF.md:

```markdown
## Handoff: <source-window> → <target-window>
**Date**: 2026-05-12
**Context**: <what was done, what needs doing>
**Artifacts**: <files changed or created>
**Questions**: <open questions for next agent>
**Next action**: <precise instruction for target>
```

## CrossFlow Commands

| Action | Command |
|--------|---------|
| Read current handoff | `type .crossflow\HANDOFF.md` |
| Write handoff | Edit `.crossflow\HANDOFF.md` |
| Append session log | Edit `.crossflow\SESSION_LOG.md` |
| Read master context | `type .crossflow\MASTER_CONTEXT.md` |
| Start gemini-thesis | `OpenCode gemini thesis` |
| Start claude-project | Launch Claude Desktop manually |

## Freshness Check

On session start, always:
1. Read `HANDOFF.md` — what's pending?
2. Read `MASTER_CONTEXT.md` — current ground truth?
3. Check `SESSION_LOG.md` last entry — what was the last action?
4. If stale (>24h since last entry), flag for human review

## Auto-Routing Rules

When a task comes in:
1. **VBA change?** → main-hub. Build + verify after. Write handoff to gemini-thesis if thesis needs update.
2. **Thesis content?** → gemini-thesis. Rebuild DOCX/PDF after. Write handoff to main-hub if ground truth changes.
3. **Discussion/QA?** → claude-project. After conclusion, write handoff with action items to appropriate window.
4. **Defense prep?** → claude-project (discussion) → main-hub (demo prep) both.
