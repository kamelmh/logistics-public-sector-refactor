---
name: vba-build
description: Build ERP workbook from VBA source files using vbe-auto
level: 2
---

# VBA Build Skill

Use this skill when building, rebuilding, or verifying the ERP workbook.

## Overview

The ERP workbook (`ERP_v13.4.xlsm`) is built from VBA source files in `Software_Surgical_Edit/` using the `vbe-auto` build system.

## Build Commands

```powershell
# Full build
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"

# Verify (114 checks)
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\vbe-auto-config.json"

# Test macros
& "Software_Surgical_Edit\test-macros.ps1"
```

## Rules
1. Never modify .xlsm directly — fix .bas sources then rebuild
2. Always rebuild from scratch (stale p-code cache)
3. Replace UTF-8 em dashes with - (VBA syntax error)
4. Public Const before procedures, Property Get for cross-module

## File Structure
```
Software_Surgical_Edit/
├── *.bas          ← VBA module sources
├── *.cls          ← VBA class sources
├── build.ps1      ← Build script
├── verify.ps1     ← Verification (114 checks)
└── test-macros.ps1 ← Macro tests
```
