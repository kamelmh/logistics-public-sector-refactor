# /ruflo-swarm-init

Initialize a multi-agent coordination swarm for the current project.

## Description
Sets up the coordination topology (Symmetry Lock) and defines the Master-Worker roles (Architect, Surgeon, Scout). This ensures that all windows are synchronized and roles are clearly defined.

## Arguments
- `topology`: (Optional) The organization of agents. Defaults to `hierarchical-mesh`.
  - `hierarchical`: Master (Architect) -> Workers (Surgeon, Scout). Best for structured tasks.
  - `mesh`: All agents equal. Best for collaborative brainstorming.
  - `hierarchical-mesh`: Hybrid (Recommended).

## Usage
`/ruflo-swarm-init topology=hierarchical`

## Workflow
1. Updates `.crossflow/HANDOFF.md` with the current topology.
2. Initializes `.opencode/memory/patterns.json` if not present.
3. Broadcasts the swarm initialization to all active windows via `scripts/harness.ps1 sync`.
