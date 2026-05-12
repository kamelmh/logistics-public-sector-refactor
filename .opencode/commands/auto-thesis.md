# Auto-Thesis — Full Thesis Pipeline Command

## Trigger
Load the auto-thesis meta-skill, then route task to appropriate window based on phase.

```markdown
/auto-thesis <phase>

Phases:
  phase1     — Content generation (route to gemma 4 or gemini-thesis)
  phase2     — Ground truth lock (main-hub)
  phase3     — Build DOCX/PDF (main-hub)
  phase4     — Build VBA + verify (main-hub)
  phase5     — Review + defense prep (claude-project)
  full       — Run all phases sequentially
  status     — Report current pipeline state across all windows
```

## Usage examples
- `@auto-thesis phase1 "Expand Chapter 3 section on XYZ matrix"`
- `@auto-thesis full` — end-to-end
- `@auto-thesis status` — check where we are
