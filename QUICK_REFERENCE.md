# Academix v13.2 — Quick Reference Card

## Ground Truth (LOCKED)
| Param | Value | Meaning |
|-------|-------|---------|
| D | 1,546 | Annual demand (ART-001 Toner G030) |
| Q* | 176 | EOQ (Wilson formula) |
| ROP | 212.4 | Reorder point |
| SS | 200 | Safety stock |
| LT | 2 days | Lead time |
| S | 801.45 DZD | Order cost (field-refined) |
| I | 20% | Holding rate |
| Performance | 99.7% | NOT 97% |

## Build Commands
\\\powershell
# ERP
.\links\03-Build\build.ps1          # Build from .bas sources
.\links\03-Build\verify.ps1         # 174 verification checks
.\links\03-Build\test-macros.ps1    # 20 macro tests

# Thesis
.\links\03-Build\build-thesis.ps1   # MD → DOCX → PDF
.\links\03-Build\verify-thesis.ps1  # 36 thesis checks
.\links\03-Build\cnepd-thesis-checker.py  # CNEPD compliance

# System
.\links\07-Scripts\system-health-maintenance.ps1
.\links\07-Scripts\model-picker.ps1
.\links\07-Scripts\OpenCode.bat     # Launch OpenCode
