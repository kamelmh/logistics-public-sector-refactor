# /vba-autofix

OCR → Analyze → Fix → Rebuild integrated pipeline for VBA compile errors.

## Description
Connects the desktop OCR pipeline to the VBA fix → rebuild → verify loop.
When a compile error dialog is on screen, snap a screenshot → OCR reads it →
autofix analyzes the error → patches the .bas source → rebuilds → loops until clean.

## Modes
| Mode | Command | Action |
|------|---------|--------|
| Scan | `/vba-autofix` | Read latest OCR, extract error info |
| Fix | `/vba-autofix -Fix` | Scan + analyze + apply source fix |
| Full | `/vba-autofix -Full` | Full pipeline: scan → analyze → fix → rebuild → verify |
| Watch | `/vba-autofix -Watch` | Poll desktop every 5s for new screenshots, auto-fix loop |
| Repair | `/vba-autofix -Repair` | Skip OCR, just rebuild from clean source (for stale dialogs) |

## Workflow
```
Screenshot → AutoOCR-Watcher → OCR text file
    ↓
vba-autofix reads OCR → extracts error type + module name
    ↓
Cross-references with vba-check.py scanner
    ↓
Applies fix to .bas source file (encoding, headers, artifacts, continuations)
    ↓
build.ps1 rebuilds (with vba-check.py pre-validation)
    ↓
Loop until COMPILE: OK
```

## Common errors this handles
- "Expected: expression" → UTF-8 chars, broken continuations, BOM
- "Expected: =" → missing Attribute VB_Name header
- "Invalid character" → PHP artifacts (%>), stray template code
- "Expected: end of statement" → same artifacts
- "Variable not defined" → missing Option Explicit

## Integration
Uses `vbe-auto/vba-check.py` for pre-validation and `vbe-auto/build.ps1` for rebuild.
