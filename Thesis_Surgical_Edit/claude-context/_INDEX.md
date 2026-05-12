# Academix v13.2 — Claude Code Context Index

```
claude-context/
├── _MASTER_PROMPT.md      ← START HERE (core system prompt)
├── _STRUCTURE_GUIDE.md     ← Chapter hierarchy & mermaid maps
├── _FORMAT_GUIDE.md        ← Fonts, colors, cover integration
├── _BUILD_PIPELINE.md      ← Build steps for DOCX/PDF generation
├── _INDEX.md               ← This file (navigation hub)
│
├── cover-page.docx         ← User's custom cover design (immutable)
│
├── ../Memoire_DSS_Logistique_ElBayadh.md      ← Full thesis source
├── ../THESIS_GROUND_TRUTH.md                   ← Locked reference data
├── ../style/thesis-metadata.yaml               ← Title/author metadata
└── ../output/                                  ← Generated output
```

## Recommended Loading Order
| Step | File | Tokens | Purpose |
|------|------|--------|---------|
| 1 | `_MASTER_PROMPT.md` | ~2K | Role, ground truth, rules |
| 2a | `_STRUCTURE_GUIDE.md` | ~1.5K | Chapter/mabhath/matlab map |
| 2b | `_FORMAT_GUIDE.md` | ~1K | Fonts, colors, cover integration |
| 3 | `_BUILD_PIPELINE.md` | ~1K | How to generate output |
| 4 | `THESIS_GROUND_TRUTH.md` | ~1.5K | Full ART code table |
| 5 | `Final_Thesis_..._FIXED.md` | ~5K | Full thesis body |

## Symlink Reference (logical connections)
| Topic | Connects to |
|-------|------------|
| ART codes → | `THESIS_GROUND_TRUTH.md` |
| Each chapter → | `Final_Thesis_..._FIXED.md` (read relevant section only) |
| Cover page → | `cover-page.docx` (open with python-docx to inspect) |
| Build → | `style/` Python scripts + pandoc |
| Footnotes → | `THESIS_GROUND_TRUTH.md` (template at bottom) |
| Module counts → | `_MASTER_PROMPT.md` → Ground Truth section |

## Token-Saving Strategy
- **Do NOT** load `Final_Thesis_..._FIXED.md` entirely in one go
- Instead: read chapter-by-chapter via line ranges or section search
- Use `_STRUCTURE_GUIDE.md` to find the right section to edit
- Ground truth is compact (~1.5K) — safe to load once and keep
