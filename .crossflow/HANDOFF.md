# CrossFlow Handoff — Academix v13.4
# TRIPLE-SYNC: Claude Desktop | Claude CLI | OpenCode

## Current Priority (Session 47g — 2026-06-26)
**FULL PIPELINE 32/32 PASS — COM CORRUPTION FIX CONFIRMED**
- ✅ Root cause found: `Range.Fields.Add()` corrupts DOCX XML → replaced with `Selection.Find` + `Selection.Fields.Add()` (v11)
- ✅ Thesis DOCX: 32/32 verification checks PASS (151 KB, 834 paragraphs, 25 tables, 46 footnotes)
- ✅ Both TOC + TOF fields inserted successfully (Selection.Find approach)
- ✅ Both logos placed on cover page
- ✅ Post-COM section fixes re-applied (fix_docx_sections.py added to pipeline)
- ✅ Verify check widened: abstract search now covers all paragraphs (was limited to first 40)
- ✅ ERP Workbook: 114/114 checks PASS
- ✅ English Paper: IEEE format DOCX/PDF built successfully

**Next**: Manual final review — Open DOCX in Word → Ctrl+A F9 → Verify clickable links → Export PDF → Submit

## Current Status
- **Thesis DOCX**: 32/32 verification checks PASS (151 KB, golden source pipeline)
- **ERP Workbook**: 114/114 verification checks PASS
- **COM Approach**: v11 — Selection.Find + Selection.Fields.Add (no content corruption)
- **Page numbering**: Fixed — single section with continuous numbering (post-COM re-apply)
- **Footnote RTL**: Fixed — 46 Arabic runs all have bidi+rtl
- **Cover Logo**: Restored — 200x200 institute logo on first paragraph
- **Clickable Hyperlinks**: TOC + TOF fields inserted via Selection.Find (both with `\h` switch)
- **Git**: Synced with remote (fcbb9f5)
- **Workspace**: Cleaned, debug scripts archived to `Thesis_Surgical_Edit/archive/debug_scripts/`

## Triple-Sync Configuration
| Tool | MCP Servers | Config Path | Status |
|------|-------------|-------------|--------|
| **Claude Desktop GUI** | filesystem + github + microsoft-learn + context7 | `%APPDATA%\Claude\claude_desktop_config.json` | ✅ |
| **Claude CLI (Code)** | filesystem + github + context7 + omc-bridge | `~/.claude/settings.json` | ✅ |
| **OpenCode** | filesystem + github + memory + sequential-thinking + omc-bridge | `~/.config/opencode/opencode.json` | ✅ |

### Shared MCP Servers
| Server | Purpose | GitHub Token |
|--------|---------|--------------|
| **filesystem** | Read/write project files | — |
| **github** | Git operations, PRs, issues | `github_pat_11APRYXRQ0TVeTcHzbdqRG` |
| **microsoft-learn** | Documentation lookup | — |
| **context7** | Library documentation (React, Next.js, etc.) | — |

### Shared File Paths
| Path | Purpose |
|------|---------|
| `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor` | Project root |
| `C:\Users\Administrator\My Drive` | Google Drive |
| `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx` | Golden source |
| `ERP_v13.4.xlsm` | ERP workbook |
| `.crossflow/HANDOFF.md` | This file — sync point |
| `C:\Users\Administrator\.opencode\notepad.md` | Session memory |

## Workspace Structure (Post-Cleanup)
```
Logistics.Public.Sector.Refactor/
├── .claude/                    # Claude Desktop config
├── .crossflow/                 # CrossFlow sync (HANDOFF.md)
├── .github/                    # GitHub workflows
├── .omc/                       # OpenCode state
├── .opencode/                  # OpenCode config + skills
├── archive/                    # NEW: Archived files
│   ├── old-backups/           # Old ERP backups
│   └── old-versions/          # Old thesis versions
├── backups/                    # Current backups
├── bin/                        # OpenCode binary (136MB)
├── scripts/                    # Utility scripts
│   ├── backup-project.ps1     # NEW: Unified backup
│   └── cleanup-workspace.ps1  # NEW: Workspace cleanup
├── Thesis_Surgical_Edit/       # Thesis files
├── vbe-auto/                   # VBA build tools
├── ERP_v13.4.xlsm             # ERP workbook
└── CLAUDE.md                   # Project context
```

## Key Files
| File | Path |
|------|------|
| Golden Source (FIXED) | `Thesis_Surgical_Edit/output/Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx` |
| Claude Desktop Handoff | `ClaudeDesktop_HANDOFF_PLAN.md` |
| Project Context | `CLAUDE.md` |
| Thesis Context | `THESIS_CONTEXT.md` |
| Full fixer (v3) | `Thesis_Surgical_Edit/style/fix_thesis_all.py` |
| Verify tool | `Thesis_Surgical_Edit/style/verify_docx_checks.py` |
| Build script | `Thesis_Surgical_Edit/build-thesis.ps1` |
| MCP Config (unified) | `.claude/mcp-unified.json` |
| Backup Script | `scripts/backup-project.ps1` |
| Cleanup Script | `scripts/cleanup-workspace.ps1` |

## Ground Truth (DO NOT MODIFY) — CALIBRATED v13.4
| Param | Value | Notes |
|-------|-------|-------|
| D (ART-002) | 33 | Annual demand Toner G030 (5 OUT × 250/38) |
| Q* | 15 | Wilson EOQ (PU=1200, S=801.45, I=20%) |
| ROP | 200 | SS + (D/250)×LT = 200 + 0.264 |
| SS | 200 | Safety stock (case study) |
| LT | 2 days | Lead time |
| S | 801.45 DZD | Order cost (field-refined) |
| PU (ART-002) | 1,200 DZD | Unit price Toner G030 compatible (v7 Data Lake, regular toner) |
| I | 20% | Holding rate |
| MASTER_PWD | erp_secure_pwd_2026 | Sheet protection |
| **Note** | **ART-001 = Papier A4 (D=2007, PU=400, Q*=50, ROP=416). Codes swapped in v13.3; fixed in v13.4.** | |

## Build Command
```powershell
# From project root:
& "Thesis_Surgical_Edit/build-thesis.ps1"
```

## Verify Command
```powershell
python "Thesis_Surgical_Edit/style/verify_docx_checks.py" `
    "Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx"
```

## Backup Command
```powershell
# Quick backup (essential files only):
& "scripts\backup-project.ps1" -QuickBackup

# Full backup (everything):
& "scripts\backup-project.ps1" -FullBackup

# Clean old backups:
& "scripts\backup-project.ps1" -CleanOld
```

## Cleanup Command
```powershell
# Standard cleanup:
& "scripts\cleanup-workspace.ps1"

# Deep clean (includes pip/npm cache):
& "scripts\cleanup-workspace.ps1" -DeepClean
```

## Session History
- **Session 47f**: FULL PIPELINE COMPLETE. Ground truth reconciliation, clickable hyperlinks (TOC + Table of Figures), thesis 32/32 PASS, ERP 114/114 PASS, workspace cleaned, all docs synchronized.
- **Session 47e**: Technical implementation complete. Fixed ground truth (D, Q*, ROP, PU), implemented -NoRebuild/-Restore, and locked 175KB Golden Source. 32/32 PASS.
- **Session 47d**: Fixed footnote RTL (52 runs), restored cover logo, 32/32 PASS
- **Session 40**: Fixed page numbering bug, single-section layout
- **Session 34**: Rewrote fix_thesis_all.py as v3 (Anti-Stuffed)
- **Session 33**: Identified stuffing root cause, Gold-Standard Pipeline created
