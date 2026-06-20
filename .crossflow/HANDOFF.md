# CrossFlow Handoff — Academix v13.4
# TRIPLE-SYNC: Claude Desktop | Claude CLI | OpenCode

## Current Priority (Session 47e — 2026-06-15)
**Technical implementation and ground truth correction completed.**
- Fixed ground truth values (D, Q*, ROP, PU) in all sources.
- Implemented `-NoRebuild` and `-Restore` switches in `build-thesis.ps1`.
- Set the 175KB hand-edited DOCX as the new Golden Source.
- Verified build: 32/32 checks PASS.

**Next**: Launch Claude Desktop GUI, follow 7-phase handoff plan in `ClaudeDesktop_HANDOFF_PLAN.md` for manual deep verification.


## Current Status
- **Thesis Golden Source**: 32/32 verification checks PASS
- **ERP Workbook**: 114/114 verification checks PASS
- **Page numbering**: Fixed — single section with continuous numbering
- **Footnote RTL**: Fixed — 52 Arabic runs all have bidi+rtl
- **Cover Logo**: Restored — 200x200 institute logo on first paragraph
- **Git**: Synced with remote (fcbb9f5)
- **Workspace**: Cleaned and structured (Session 47e)

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

## Ground Truth (DO NOT MODIFY)
| Param | Value |
|-------|-------|
| D | 789 |
| Q* | 37 |
| ROP | 206 |
| SS | 200 |
| LT | 2 days |
| S | 801.45 DZD |
| I | 20% |
| MASTER_PWD | erp_secure_pwd_2026 |

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
- **Session 47e**: Technical implementation complete. Fixed ground truth (D, Q*, ROP, PU), implemented -NoRebuild/-Restore, and locked 175KB Golden Source. 32/32 PASS.
- **Session 47d**: Fixed footnote RTL (52 runs), restored cover logo, 32/32 PASS
- **Session 40**: Fixed page numbering bug, single-section layout
- **Session 34**: Rewrote fix_thesis_all.py as v3 (Anti-Stuffed)
- **Session 33**: Identified stuffing root cause, Gold-Standard Pipeline created
