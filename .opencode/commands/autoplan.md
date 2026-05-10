---
description: Planning workflow — architecture, task breakdown, research
agent: build
model: groq/llama-3.3-70b-versatile
---

Run a planning session for the current task or request $ARGUMENTS.

Plan workflow:
1. Load the `plan` skill if available
2. Break down requirements into tasks
3. Identify dependencies and architecture decisions
4. Present a structured plan with acceptance criteria
5. Use `planning-and-task-breakdown` skill for task decomposition

Be thorough: consider architecture, data flow, security, and testing.
