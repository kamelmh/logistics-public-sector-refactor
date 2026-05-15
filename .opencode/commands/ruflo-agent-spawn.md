# /ruflo-agent-spawn

Assign a specialized role to the current agent window.

## Description
Defines the current window's identity within the Ruflo swarm. This ensures that the agent adopts the correct behavioral patterns and tools for its specific role.

## Arguments
- `role`: The specialized role to adopt.
  - `architect`: Global state, synthesis, and high-level planning (Window C).
  - `surgeon`: Precision code editing, building, and verification (Window B).
  - `scout`: Reconnaissance, resource discovery, and skill adoption (Window A).
- `name`: (Optional) A custom name for this agent instance.

## Usage
`/ruflo-agent-spawn role=scout name="Gemma-Scout-1"`

## Workflow
1. Updates the `Active Agent` field in `.crossflow/HANDOFF.md`.
2. Injects the role-specific instructions into the session context.
3. Broadcasts the spawn event to the swarm via `scripts/harness.ps1 sync`.
