# /ruflo-memory-store

Save a successful reasoning pattern to the AgentDB for future recall.

## Description
Instead of just completing a task, this command stores the *method* used to solve it. This creates a self-learning loop where future agents can retrieve the successful pattern to solve similar problems faster.

## Arguments
- `key`: A unique, descriptive name for the pattern (e.g., "fix-vba-pcode-cache").
- `value`: A detailed description of what worked (the approach, the gotchas, the exact fix).
- `namespace`: (Optional) Category for the memory (e.g., "patterns", "vba-fixes", "thesis-style"). Defaults to "patterns".

## Usage
`/ruflo-memory-store key="rop-alignment" value="Check D and LT anchors first, then calculate ROP. If discrepancy exists, prioritize Ground Truth but flag for Architect review." namespace="patterns"`

## Workflow
1. Appends the pattern to `.opencode/memory/patterns.json`.
2. Tags the entry with a timestamp and the current agent's role.
3. Broadcasts a "New Pattern Learned" notification via `scripts/harness.ps1 sync`.
