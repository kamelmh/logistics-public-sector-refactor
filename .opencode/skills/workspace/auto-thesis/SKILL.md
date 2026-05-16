# Auto-Thesis — Unified Academix Thesis Pipeline (براءة اختراع)

## Purpose
End-to-end thesis production: generate content → cross-ref citations → format → build DOCX/PDF → verify ground truth → deploy. Orchestrates across 3 windows with automatic routing.

## Composition
This meta-skill loads and coordinates:
1. `crossflow-orchestrator` — Multi-window routing & handoff
2. `thesis-to-docx` — Markdown → formatted DOCX/PDF pipeline
3. `vba-deployer` — VBA build & verify (ground truth sync)

## Pipeline (sequential)

```
Phase 1: Content (gemini-thesis / gemma 4)
  │
  ├─ 1a. Generate/revise chapters (.md)
  ├─ 1b. Academic coherence scan (1M ctx)
  ├─ 1c. Citation cross-ref vs refs/Semester_1-4/*.bib
  │
  ▼
Phase 2: Ground Truth Lock (main-hub)
  │
  ├─ 2a. Verify thesis S=801.45 matches VBA mod_StockEngine
  ├─ 2b. Verify Q*=176, ROP=212.4, SS=200 throughout
  ├─ 2c. Flag any discrepancy → handoff back to Phase 1
  │
  ▼
Phase 3: Build (main-hub)
  │
  ├─ 3a. Run build-thesis.ps1 → DOCX + PDF
  ├─ 3b. Verify output (file size, table count)
  │
  ▼
Phase 4: VBA Sync (main-hub)
  │
  ├─ 4a. Build VBA → COMPILE: OK
  ├─ 4b. Verify → 174/174 PASS
  ├─ 4c. Tests → 20/20 PASS
  ├─ 4d. DSS Audit → 16 PASS
  │
  ▼
Phase 5: Review (claude-project)
  │
  ├─ 5a. Discussion / defense Q&A
  └─ 5b. Final sign-off
```

## Window Routing

| Task | Window | Model | Why |
|------|--------|-------|-----|
| Content generation | gemma 4 (ogg) | Gemma 4 26B | Open-weight, fast, good Arabic prose |
| Deep thesis analysis | gemini-thesis | Gemini 2.5 Flash | 1M ctx, full-doc coherence scan |
| Citation cross-ref | gemini-thesis | Gemini 2.5 Flash | Heavy bib parsing, pattern matching |
| Ground truth lock | main-hub | big-pickle / Llama 3.3 | Direct VBA source access |
| Build DOCX/PDF | main-hub | big-pickle | Has build-thesis.ps1 |
| Build VBA + verify | main-hub | big-pickle | Has vbe-auto toolkit |
| Discussion / review | claude-project | Claude 4 Sonnet | Natural conversation |
| Defense demo prep | claude-project | Claude 4 Sonnet | Narrative script writing |

## Handoff Protocol

After each phase, the active window MUST write to `.crossflow\HANDOFF.md`:

```markdown
## Handoff: <window> → <next-window>
**Phase**: <phase number>
**Completed**: <what was done>
**Artifacts**: <files changed>
**Ground truth check**: S=<value>, Q*=<value>, ROP=<value>, SS=<value>
**Ready for**: <next phase>
```

## Ground Truth Assertions (must match across thesis + VBA)

| Param | Value | VBA Source | Thesis Source |
|-------|-------|-----------|---------------|
| D | 1,546 | mod_Config | Chapter 2 field data table |
| S (Order Cost) | 801.45 DZD | mod_StockEngine.ORDER_COST_S | Chapter 2 formula + table |
| Q* (EOQ) | 176 | mod_Analysis.ComputeEOQ | Chapter 2 field data table |
| ROP | 212.4 | mod_StockEntry_Logic | Chapter 2 field data table |
| SS (Safety Stock) | 200 | mod_Config | Chapter 2 field data table |
| LT | 2 days | mod_Config | Chapter 2 |
| I (Holding Rate) | 20% | mod_StockEngine | Chapter 2 formula |
| Service Level | 99.7% | — | Chapter 2 |
| PU (ART-001) | 400 DZD | ARTICLES sheet | Chapter 2 field data table |

## Verification Gate

Before marking Phase 5 complete, run these in order:
```powershell
& "Thesis_Surgical_Edit\build-thesis.ps1"
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"
& "Software_Surgical_Edit\test-macros.ps1"
& "milestone_13_2\tests\dss-audit.ps1"
```

All must PASS. Any failure → handoff back to relevant phase.

## Defense Demo Trigger

After Phase 5 sign-off:
```powershell
cat milestone_13_2\defense-demo-checklists.md
```
Handoff to claude-project for demo script generation.

