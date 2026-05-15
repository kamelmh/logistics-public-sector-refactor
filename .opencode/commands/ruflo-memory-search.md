# /ruflo-memory-search

Search the AgentDB for similar past patterns to solve the current task.

## Description
Before starting a complex task, this command performs a semantic search over stored reasoning patterns. This prevents "re-inventing the wheel" and ensures consistency across the swarm.

## Arguments
- `query`: The natural language description of the current problem or task.
- `namespace`: (Optional) The specific category to search in. Defaults to "patterns".

## Usage
`/ruflo-memory-search query="how to handle ROP discrepancies in thesis"`

## Workflow
1. Scans `.opencode/memory/patterns.json` for keywords matching the query.
2. Returns the most relevant patterns with their original "what worked" descriptions.
3. Suggests the best pattern to apply to the current task.
