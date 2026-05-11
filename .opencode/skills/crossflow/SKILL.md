# CrossFlow — Agentic Context Sync Skill

## Overview
CrossFlow synchronizes context between OpenCode (JOC), Claude Code, OMC (oh-my-claudecode), ECC (everything-claude-code), and FCC (free-claude-code proxy). It ensures no data is lost when switching tools, and every agent starts with the full project picture.

## Problem
When working across multiple AI tools (OpenCode for VBA, Claude Code for thesis, OMC for orchestration), context fragments. Each tool has its own CLAUDE.md, its own session, and no awareness of the others. Switching tools means re-explaining context.

## Solution
A unified CROSSFLOW block embedded in every tool's CLAUDE.md, backed by a shared `.crossflow/` directory with master context, handoff notes, session logs, and overflow archival.

## Architecture
```
CLAUDE.md files (each tool)     .crossflow/ (shared storage)
┌──────────────┐               ┌──────────────────────┐
│ OpenCode     │──CROSSFLOW──→│ MASTER_CONTEXT.md    │
│ CLAUDE.md    │   block      │ (full payload)       │
├──────────────┤               ├──────────────────────┤
│ Claude Code  │──CROSSFLOW──→│ HANDOFF.md           │
│ CLAUDE.md    │   block      │ (current state)      │
├──────────────┤               ├──────────────────────┤
│ .agentic-hub │──CROSSFLOW──→│ SESSION_LOG.md       │
│ CLAUDE.md    │   block      │ (chronological)      │
├──────────────┤               ├──────────────────────┤
│ Project root │──CROSSFLOW──→│ OVERFLOW/            │
│ CLAUDE.md    │   block      │ (archived sessions)  │
└──────────────┘               └──────────────────────┘
```

## Commands
### `/crossflow sync`
Push local context state to all CLAUDE.md CROSSFLOW blocks.
1. Reads `.crossflow/MASTER_CONTEXT.md`
2. Generates compact CROSSFLOW block
3. Updates all 4 CLAUDE.md targets
4. Logs to SESSION_LOG.md

### `/crossflow handoff "message"`
Record current state for next agent.
1. Appends to SESSION_LOG.md with timestamp
2. Writes to HANDOFF.md (last action, next step, blockers)
3. Rotates SESSION_LOG.md if >50KB (archives old entries to OVERFLOW/)

### `/crossflow status`
Show current crossflow health.
1. Check all 4 CLAUDE.md files have CROSSFLOW block
2. Check .crossflow/ directory integrity
3. Show last handoff entry
4. Show SESSION_LOG.md size

### `/crossflow accumulate`
Manual trigger for overflow archival.
1. Move old SESSION_LOG entries to OVERFLOW/session-YYYY-MM-DD.md
2. Keep last 10 entries
3. Log the archival

## Integration Points

### With OpenCode (JOC)
- `.opencode/commands/crossflow.md` — slash command
- Reads `~/.config/opencode/instructions.md` for context
- Writes to `.crossflow/` for other tools

### With Claude Code
- Reads CROSSFLOW block from `~/.claude/CLAUDE.md`
- References `.crossflow/MASTER_CONTEXT.md` for full payload
- Checks `.crossflow/HANDOFF.md` on startup

### With OMC (oh-my-claudecode)
- CROSSFLOW block in same `~/.claude/CLAUDE.md` (after OMC block)
- OMC sees both orchestration instructions AND project context

### With FCC Proxy
- Not a direct consumer — FCC is a transport layer
- CrossFlow context helps FCC route requests appropriately

## File Reference
| File | Purpose | Update Pattern |
|------|---------|----------------|
| `.crossflow/MASTER_CONTEXT.md` | Full ground truth + paths + structure | Manual edits only |
| `.crossflow/HANDOFF.md` | Last action, next step, blockers | On every handoff |
| `.crossflow/SESSION_LOG.md` | Chronological history | Append on action, rotate at 50KB |
| `.crossflow/OVERFLOW/*.md` | Archived sessions | Auto on rotation |
| `.crossflow/CROSSFLOW_BLOCK.md` | Reference copy of the block | Sync when MASTER_CONTEXT changes |
| All 4 CLAUDE.md files | Tool-specific + CROSSFLOW block | Updated by `/crossflow sync` |

## Rules
1. MASTER_CONTEXT.md is the SOURCE OF TRUTH — edit there, then sync
2. HANDOFF.md should always be readable in 10 seconds — keep it brief
3. SESSION_LOG.md auto-rotates — don't manually edit
4. Every agent reads HANDOFF.md on start — write it before switching tools
5. The CROSSFLOW block in CLAUDE.md files is auto-generated — don't hand-edit
