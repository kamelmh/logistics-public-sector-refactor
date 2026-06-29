# CrossFlow Handoff — Academix v13.4
# TRIPLE-SYNC: Claude Desktop | Claude CLI | OpenCode

## Current Priority (Session 48+ — 2026-06-29)
**UNICODE FIXES + BOM FIXES + UPDATE_FIELDS.PY + GROUND_TRUTH FIX 36/36 PASS**
- ✅ `update_fields.py` — New Word COM field update step (body, headers/footers, TOC, footnotes, shapes)
- ✅ Unicode/cp1256 crash fixed — 7 build scripts patched with encoding detection + ASCII fallbacks
- ✅ UTF-8 BOM added to `build-thesis.ps1` + `run-thesis-pipeline.ps1` (Arabic metadata in PowerShell)
- ✅ `build-thesis.ps1` — Field update step integrated before COM automation
- ✅ `audit_thesis_comprehensive.py` — Content coverage fixed (EOQ/ROP/safety_stock concept-level patterns)
- ✅ `docx_md_sync.py` — Multi-article GROUND_TRUTH_SETS (ART-001 + ART-002), false-positive warnings eliminated
- ✅ Thesis DOCX: 36/36 verification checks PASS (expanded from 32 checks)
- ✅ ERP Workbook: 114/114 checks PASS
- ✅ VBA pre-build: 46 files, 0 errors PASS
- ✅ Git: Pushed (4c2d5fc)

**Next**: Desktop — Pandoc build + COM field update → PDF export → Submission

## Current Status
- **Thesis DOCX**: 36/36 verification checks PASS (expanded from 29→32→36)
- **Thesis PDF**: Needs rebuild on desktop (Pandoc + COM)
- **ERP Workbook**: 114/114 verification checks PASS
- **COM Approach**: v13 — now includes `update_fields.py` before `word_automation.py` for thorough field refresh
- **update_fields.py**: New — COM field update across body, headers/footers, TOC, footnotes, shapes
- **Unicode safety**: 7 build scripts patched — auto-detect console encoding, ASCII fallback, no cp1256 crashes
- **BOM fix**: `build-thesis.ps1` + `run-thesis-pipeline.ps1` — UTF-8 BOM for PowerShell Arabic compatibility
- **GROUND_TRUTH**: Multi-article sets (ART-001 + ART-002) — false-positive warnings eliminated
- **Git**: Synced with remote (4c2d5fc)
- **Workspace**: Clean, debug scripts cleaned

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
| **github** | Git operations, PRs, issues | *(token regenerated — remove expired token from docs)* |
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
| COM field update | `Thesis_Surgical_Edit/style/update_fields.py` |
| MD sync tool | `Thesis_Surgical_Edit/style/docx_md_sync.py` |
| Content audit | `Thesis_Surgical_Edit/style/audit_thesis_comprehensive.py` |
| Build script | `Thesis_Surgical_Edit/build-thesis.ps1` |
| MCP Config (unified) | `.claude/mcp-unified.json` |
| Backup Script | `scripts/backup-project.ps1` |
| Cleanup Script | `scripts/cleanup-workspace.ps1` |

## Ground Truth (DO NOT MODIFY) — CALIBRATED v13.4
| Param | ART-001 (Papier A4) | ART-002 (Toner G030) | Notes |
|-------|---------------------|----------------------|-------|
| D | 2,007 | 33 | Annual demand |
| Q* | 50 | 15 | Wilson EOQ |
| ROP | 416 | 200 | Reorder point |
| SS | 400 | 200 | Safety stock |
| LT | 2 days | 2 days | Lead time |
| S | 50 | 801.45 DZD | Order cost |
| PU | 400 | 1,200 DZD | Unit price |
| I | 20% | 20% | Holding rate |
| MASTER_PWD | erp_secure_pwd_2026 | erp_secure_pwd_2026 | Sheet protection |
| **Note** | **ART-001 = Papier A4. ART-002 = Toner G030 (primary case study). Codes swapped in v13.3; fixed in v13.4.** | | |

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
- **Session 48+**: UNICODE + BOM + FIELD UPDATE + GROUND_TRUTH FIX. Patched 7 scripts for cp1256 Unicode crash, added `update_fields.py` COM step, UTF-8 BOM on both .ps1 build scripts, multi-article GROUND_TRUTH_SETS, content coverage audit fix, 36/36 PASS, 4 commits pushed (`4c2d5fc`).
- **Session 48a**: PIPELINE FIX + MD CLEANUP + REBUILD 32/32. Fixed dead code in fix_thesis_all.py (IndentationError), cleaned MD source, updated docx_md_sync.py, full rebuild 32/32 PASS, git pushed (9c1a0b2).
- **Session 47g**: FULL PIPELINE COMPLETE. COM corruption fix confirmed (v11 Selection.Find), post-COM section fixes, verify check widened, 32/32 PASS, workspace cleaned.
- **Session 47f**: FULL PIPELINE COMPLETE. Ground truth reconciliation, clickable hyperlinks (TOC + Table of Figures), thesis 32/32 PASS, ERP 114/114 PASS, workspace cleaned, all docs synchronized.
- **Session 47e**: Technical implementation complete. Fixed ground truth (D, Q*, ROP, PU), implemented -NoRebuild/-Restore, and locked 175KB Golden Source. 32/32 PASS.
- **Session 47d**: Fixed footnote RTL (52 runs), restored cover logo, 32/32 PASS
- **Session 40**: Fixed page numbering bug, single-section layout
- **Session 34**: Rewrote fix_thesis_all.py as v3 (Anti-Stuffed)
- **Session 33**: Identified stuffing root cause, Gold-Standard Pipeline created
