---
description: s06 — Save transcript + compact context
agent: build
---

Save a transcript snapshot and optionally trigger context compression:

1. Save transcript: `pwsh -NoProfile -File scripts/harness.ps1 compact save`
2. Auto-compact if context > threshold: `pwsh -NoProfile -File scripts/harness.ps1 compact auto`

For manual compact, save first, then report the transcript path.
Transcripts go to `.opencode/memory/transcripts/`.
