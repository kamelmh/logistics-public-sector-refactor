---
name: vba-debug
description: Debug VBA runtime errors, trace execution, diagnose issues
level: 2
---

# VBA Debug Skill

Use this skill when debugging VBA runtime errors or diagnosing ERP issues.

## Common VBA Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Syntax error | UTF-8 em dashes | Replace with - |
| Type mismatch | Wrong variant type | Check variable declarations |
| Subscript out of range | Array bounds | Add bounds checking |
| File not found | Missing path | Use relative paths |

## Debug Commands

```powershell
# Check VBA module syntax
python scripts/check_vba_syntax.py

# Trace execution
python scripts/trace_vba.py

# Check references
python scripts/check_references.py
```

## Debugging Flow
1. Read the error message carefully
2. Check recent changes (git log, git diff)
3. Read the relevant .bas file
4. Trace the execution path
5. Identify root cause
6. Apply fix
7. Rebuild and verify
