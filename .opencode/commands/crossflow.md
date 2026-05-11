# CrossFlow Command

## Description
Cross-platform context sync between OpenCode, Claude Code, OMC, ECC, and FCC. Keeps all agents in sync via a shared `.crossflow/` directory and unified CROSSFLOW blocks in every CLAUDE.md file.

## Usage
```
/crossflow sync                       # Push context to all CLAUDE.md files
/crossflow handoff "message"          # Record handoff note
/crossflow status                     # Check crossflow health
/crossflow accumulate                 # Archive old sessions to OVERFLOW/
```

## Where it runs
- **OpenCode**: Reads from project root, writes to `.crossflow/`
- **Claude Code**: Reads CROSSFLOW block from its CLAUDE.md, references `.crossflow/MASTER_CONTEXT.md`
- **OMC**: Same CLAUDE.md file as Claude Code — sees both OMC and CROSSFLOW blocks

## Trigger phrases
- "sync context" → `/crossflow sync`
- "handoff to crossflow" → `/crossflow handoff`
- "crossflow status" → `/crossflow status`
- "overflow archive" → `/crossflow accumulate`
