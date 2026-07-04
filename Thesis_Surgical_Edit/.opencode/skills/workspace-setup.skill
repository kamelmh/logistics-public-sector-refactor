# Academix Workspace Setup Skill

## Purpose
Detect workspace context (online/offline, SSD/USB drives), load session memory, route to correct paths.

## Trigger
Auto-loads on session start. Also invoked via:
- `setup workspace` — full setup
- `setup drives` — detect drives only
- `setup offline` — force offline mode
- `setup online` — force online mode

## Workflow

### 1. Drive Detection
```powershell
& "$env:USERPROFILE\Dropbox\Logistics.Public.Sector.Refactor\.opencode\memory\persist.ps1" -Action drives
```
Returns any non-C: drives with label, size, free space. Use this to find SSD/USB.

### 2. Path Mapping
| Mode | Workbook Path | Source Path | Build Tools |
|------|--------------|-------------|-------------|
| Online (Dropbox) | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` | `...\VBA_Modules\` | `...\vbe-auto\` |
| Offline (local) | `C:\Users\Administrator\Desktop\vbe-auto\Output.xlsm` | `C:\Users\Administrator\Desktop\vbe-auto\VBA_Modules\` (copy) | `C:\Users\Administrator\Desktop\vbe-auto\` |
| SSD (removable) | `{SSD}:\ERP_Academie_v13_2.xlsm` | `{SSD}:\VBA_Modules\` | `{SSD}:\tools\` |
| USB (removable) | `{USB}:\ERP_v13.2.xlsm` | `{USB}:\src\` | N/A (read-only) |

### 3. Session Load
```powershell
& "$root\.opencode\memory\persist.ps1" -Action load
```

### 4. Context Assembly
Reads in order:
1. `.opencode\memory\session.json` — session state
2. `.opencode\memory\session.log` — last 5 lines for history
3. `CLAUDE.md` — project identity
4. `AGENTS.md` — agent instructions

## Offline Mode
When no internet (no Dropbox sync):
- Use local copies in `C:\Users\Administrator\Desktop\vbe-auto\`
- Set `workspace_mode` to `offline` in session.json
- All build/verify scripts work without internet
- VBA compilation and tests are 100% offline-capable

## Online Mode  
When Dropbox is syncing:
- Use Dropbox paths for live workbook
- Sync changes back to Dropbox after builds
- Set `workspace_mode` to `online`

## SSD/USB Protocols

### SSD (First Plug)
1. Run drive detection
2. Identify SSD by label or size (>32GB)
3. Create workspace folders on SSD if missing
4. Copy `VBA_Modules/` and `build-tools/` to SSD
5. Set `drive_config.ssd_expected` in session.json

### USB (Later Plug)
1. Run drive detection
2. Identify USB (FAT32/NTFS, <256GB typical)
3. Mount read-only for file extraction
4. Copy files from USB to staging area
5. Log extracted file manifest

## Cleanup
- Session auto-saves on every build/verify
- Old logs trimmed to last 100 lines
- Drive cache cleared when drive ejected
