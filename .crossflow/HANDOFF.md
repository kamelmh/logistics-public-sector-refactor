# CrossFlow Handoff — Academix v13.4
# TRIPLE-SYNC: Claude Desktop | Claude CLI | OpenCode

## Current Priority (Session 49 — 2026-06-29)
**GROUND TRUTH CONFIG FIX + GT NUMERICAL AUDIT + BUILD PORTABILITY + CCA'2026 REBUILD**
- ✅ `CLAUDE.md`, `THESIS_CONTEXT.md`, `MASTER_CONTEXT.md` — Ground truth values aligned to thesis source (D=33, Q*=15, PU=1200)
- ✅ `audit_thesis_comprehensive.py` — 8 numerical ground truth verification checks added + table cell text included in scan
- ✅ `audit_thesis_comprehensive.py` — Removed dead `gt_missing` variable, ground truth display in print_report()
- ✅ `build-thesis.ps1` — Hardcoded `Administrator/Dropbox` paths replaced with portable `Join-Path` + `$PSScriptRoot`
- ✅ Unicode/cp1256 fixes — 4 more files patched (→→`->`, ⚠️→`[!!]`): `fix_thesis_all.py`, `fix_bidi_final.py`, `fix_backup_v7c.py`, `debug_footer2.py`
- ✅ Thesis pipeline: 36/36 PASS, PDF 1,257 KB, all 8 ground truth checks PASS
- ✅ English Paper CCA'2026: Rebuilt via MiKTeX + Pandoc (IEEE double-column PDF 162 KB + DOCX 22 KB)
- ✅ Environment: Pandoc 3.6.3 (Scoop), python-docx + pywin32 (uv), MiKTeX (Scoop)
- ✅ Git: Committed (864a8a5)

**Next**: Visual verification in Word → Final submission

## Current Status
- **Thesis DOCX**: 36/36 verification checks PASS — all ground truth numerical checks PASS
- **Thesis PDF**: 1,257 KB — rebuilt via COM automation (TOC/TOF with \h hyperlinks)
- **English Paper CCA'2026**: PDF 162 KB + DOCX 22 KB — IEEE double-column format
- **ERP Workbook**: 114/114 verification checks PASS
- **Ground Truth**: Config files (CLAUDE.md, THESIS_CONTEXT.md, MASTER_CONTEXT.md) now aligned with thesis source values
- **GT Audit**: 8 automated checks in audit_thesis_comprehensive.py detect missing/mismatched numerical values
- **Build**: Pipeline runs fully on this machine (no Administrator/Dropbox dependency) — uses uv for Python, Scoop for system tools
- **Unicode safety**: 11 build scripts now patched for cp1256 console compat
- **Git**: Committed (864a8a5) — 9 files, push pending

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
- **Session 49**: GROUND TRUTH CONFIG FIX + GT NUMERICAL AUDIT + BUILD PORTABILITY + CCA'2026. Fixed ground truth in CLAUDE.md/THESIS_CONTEXT.md/MASTER_CONTEXT.md (D=33, Q*=15, PU=1200), added 8 numerical GT checks to audit_thesis_comprehensive.py with table cell text inclusion, replaced hardcoded Administrator/Dropbox paths in build-thesis.ps1 with Join-Path, patched 4 more scripts for cp1256 Unicode (→, ⚠️), rebuilt CCA'2026 English Paper via MiKTeX, full thesis pipeline 36/36 PASS + PDF 1,257 KB, committed (864a8a5).
- **Session 48+**: UNICODE + BOM + FIELD UPDATE + GROUND_TRUTH FIX. Patched 7 scripts for cp1256 Unicode crash, added `update_fields.py` COM step, UTF-8 BOM on both .ps1 build scripts, multi-article GROUND_TRUTH_SETS, content coverage audit fix, 36/36 PASS, 4 commits pushed (`4c2d5fc`).
- **Session 48a**: PIPELINE FIX + MD CLEANUP + REBUILD 32/32. Fixed dead code in fix_thesis_all.py (IndentationError), cleaned MD source, updated docx_md_sync.py, full rebuild 32/32 PASS, git pushed (9c1a0b2).
- **Session 47g**: FULL PIPELINE COMPLETE. COM corruption fix confirmed (v11 Selection.Find), post-COM section fixes, verify check widened, 32/32 PASS, workspace cleaned.
- **Session 47f**: FULL PIPELINE COMPLETE. Ground truth reconciliation, clickable hyperlinks (TOC + Table of Figures), thesis 32/32 PASS, ERP 114/114 PASS, workspace cleaned, all docs synchronized.
- **Session 47e**: Technical implementation complete. Fixed ground truth (D, Q*, ROP, PU), implemented -NoRebuild/-Restore, and locked 175KB Golden Source. 32/32 PASS.
- **Session 47d**: Fixed footnote RTL (52 runs), restored cover logo, 32/32 PASS
- **Session 40**: Fixed page numbering bug, single-section layout
- **Session 34**: Rewrote fix_thesis_all.py as v3 (Anti-Stuffed)
- **Session 33**: Identified stuffing root cause, Gold-Standard Pipeline created
