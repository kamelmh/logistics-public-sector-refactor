# Semantic Memory Skill

Based on the `claude-mem` persistent context system. This skill transforms linear logging into a structured, searchable, and compressed memory layer for the agent.

## Core Philosophy
Stop relying on the agent's context window to remember past failures. Capture every "observation" as a discrete data point, compress it, and retrieve it using progressive disclosure.

## The 3-Layer Retrieval Workflow

To avoid token bloat, the agent MUST follow this sequence when querying memory:

1. **`mem-search` (The Index)**: Search for keywords or patterns. Returns a list of Observation IDs and compact summaries (~50 tokens each).
2. **`mem-timeline` (The Context)**: Request the chronological sequence of events surrounding a specific ID to understand the "story" of the bug/feature.
3. **`mem-detail` (The Truth)**: Fetch the full, uncompressed observation for only the most relevant IDs.

## Memory Operations

### 1. Capture (`mem-capture`)
Whenever a significant event occurs (e.g., a build fails, a test passes, a design decision is made), the agent creates an observation:
- **Tag**: (e.g., `bugfix`, `optimization`, `thesis-style`)
- **Observation**: A concise description of what happened and the result.
- **Context**: The file path and line number associated with the event.

### 2. Synthesize (`mem-summarize`)
At the end of a session or a task, the agent reviews the latest observations and generates a "Semantic Summary"—a compressed version of the learned lessons that is easier to retrieve.

## Integration with Autonomous Iteration
The `autonomous-iteration` loop should now use `mem-capture` instead of just writing to `notepad.md`. This allows the agent to "remember" why a specific hypothesis failed in a previous session.

## Trigger Commands
- `/mem-search <query>`
- `/mem-timeline <id>`
- `/mem-detail <id>`
- `/mem-capture <tag> <observation>`
