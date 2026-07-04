# Academix v13.4 — Claude Code Project Context

## Quick Start
```bash
# Start FCC proxy (free models)
fcc-server &

# Start OpenCode with free model
opencode -m fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b

# Or use Ollama locally (no limits)
opencode -m ollama/phi4-mini:latest
```

## Project Identity
- **System**: VBA/Excel DSS for inventory management
- **Organization**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Master Password**: erp_secure_pwd_2026

## Ground Truth (LOCKED — Never Modify)
| Param | Value | Description |
|-------|-------|-------------|
| D | 33 units/yr | Annual demand (ART-002) |
| Q* | 15 units | Wilson EOQ (ART-002) |
| ROP | 201 units | Reorder Point (LT=7) |
| SS | 200 units | Safety Stock |
| LT | 7 days | Lead Time |
| S | 801.45 DZD | Order Cost (ART-002) / 50 DZD (others) |
| PU | 1,200 DZD | Unit Price (ART-002) / 400 DZD (ART-001) |
| I | 20% | Holding Rate |

## Current Status (Session 48)
- ERP: 114/114 PASS ✅
- Thesis: 36/36 PASS ✅
- Git: Synced (94122d2) ✅

## Build Commands
```powershell
# ERP
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"

# Thesis
& "Thesis_Surgical_Edit\build-thesis.ps1"
& "Thesis_Surgical_Edit\run-thesis-pipeline.ps1"

# Verify
python Thesis_Surgical_Edit\style\verify_docx_checks.py Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx
```

## Key Paths
- **ERP Workbook**: `ERP_v13.4.xlsm`
- **Thesis Source**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Thesis Output**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`
- **VBA Sources**: `Software_Surgical_Edit/VBA_Modules/`
- **Build Tools**: `vbe-auto/`

## Rules
1. Never modify .xlsm directly — fix .bas sources then rebuild
2. Always rebuild from scratch (stale p-code cache)
3. Replace UTF-8 em dashes with - (VBA syntax error)
4. Public Const before procedures, Property Get for cross-module
5. Run verify after every build
