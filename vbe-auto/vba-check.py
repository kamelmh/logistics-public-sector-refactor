#!/usr/bin/env python3
"""
VBA Pre-Build Validator
Scans all .bas/.frm files for common VBA-breaking issues.
No Excel/COM needed — pure static analysis.
Returns exit code 0 if clean, 1 if errors found.
"""

import os
import sys
import glob

VBA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 
                        "Software_Surgical_Edit", "VBA_Modules")
CHECKS_PASSED = 0
CHECKS_FAILED = 0
ERRORS = []
WARNINGS = []

def err(msg):
    global CHECKS_FAILED
    CHECKS_FAILED += 1
    ERRORS.append(msg)

def warn(msg):
    WARNINGS.append(msg)

def validate_file(fpath):
    global CHECKS_PASSED
    fname = os.path.basename(fpath)
    
    with open(fpath, 'rb') as f:
        raw = f.read()
    
    try:
        with open(fpath, 'r', encoding='windows-1252') as f:
            lines = f.readlines()
    except:
        err(f"{fname}: Cannot read as Windows-1252 encoding")
        return
    
    content = ''.join(lines)
    
    # === CHECK 1: UTF-8 BOM ===
    if raw[:3] == b'\xef\xbb\xbf':
        err(f"{fname}: UTF-8 BOM detected (VBA chokes on this)")
    
    # === CHECK 2: Non-ASCII bytes outside valid Windows-1252 range ===
    for i, b in enumerate(raw):
        if 0x80 <= b <= 0x9F:
            err(f"{fname}: Invalid control byte 0x{b:02X} at position {i}")
            break
    
    # === CHECK 3: Missing Attribute VB_Name ===
    has_attr = any('Attribute VB_Name' in l for l in lines)
    if not has_attr:
        err(f"{fname}: Missing 'Attribute VB_Name = ...' header")
    
    # === CHECK 4: Missing Option Explicit ===
    has_explicit = any(l.strip().upper() == 'OPTION EXPLICIT' for l in lines)
    if not has_explicit:
        warn(f"{fname}: Missing 'Option Explicit'")
    
    # === CHECK 5: PHP/ASP artifacts ===
    for ln, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("'"):
            continue
        if '%>' in stripped:
            err(f"{fname} line {ln}: PHP closing tag '%>' found")
        if '<?' in stripped:
            err(f"{fname} line {ln}: PHP opening tag '<?' found")
    
    # === CHECK 6: Comment between line continuation ===
    for ln in range(len(lines) - 1):
        clean_line = lines[ln].rstrip()
        if clean_line.endswith('_') and lines[ln+1].strip().startswith("'"):
            if not clean_line.strip().startswith("'"):
                err(f"{fname} line {ln+2}: Comment after line continuation (_) breaks VBA parser")
    
    # === CHECK 7: Empty/short file ===
    if len(lines) < 5:
        warn(f"{fname}: Only {len(lines)} lines (suspiciously short)")
    
    # === CHECK 8: Continuation comment without leading apostrophe ===
    # VBA's .bas import parser treats continuation lines (with leading whitespace
    # after a ' comment) as part of the comment, but the VBA COMPILER treats them
    # as code, causing "Expected: expression" errors like:
    #   ' Exports sheets defined by
    #    folder if not set).  ← This line is treated as CODE by compiler!
    # Flag lines that follow a comment and look like natural language (not code).
    import re
    # VBA keywords valid in module header (not continuation comments)
    HEADER_KEYWORDS = {'PUBLIC', 'PRIVATE', 'FRIEND', 'DIM', 'CONST', 'ENUM', 'TYPE',
                       'OPTION', 'ATTRIBUTE', 'DECLARE', '#IF', '#END', '#CONST',
                       'GLOBAL', 'STATIC'}
    in_header = True
    for ln, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith("'"):
            upper = stripped.upper()
            # Stop at declaration: [Public|Private|Friend]? Sub|Function|Property|Type|Enum
            if re.match(r'^((PUBLIC|PRIVATE|FRIEND)\s+)?(SUB|FUNCTION|PROPERTY\s+(GET|LET|SET)|TYPE|ENUM)\s', upper):
                in_header = False
                break
        if ln > 0 and lines[ln-1].strip().startswith("'"):
            curr = line.rstrip()
            if curr.strip() and not curr.strip().startswith("'"):
                first_word = curr.strip().split()[0].upper() if curr.strip().split() else ""
                # Only flag if first word is NOT a VBA keyword (looks like natural language)
                if first_word not in HEADER_KEYWORDS and not first_word.startswith('#'):
                    err(f"{fname} line {ln+1}: Comment continuation without leading ' — '{line.rstrip()}'")
    
    # === CHECK 9: Const declaration using Array() (runtime function in Const) ===
    for ln, line in enumerate(lines):
        stripped = line.strip().upper()
        if 'CONST' in stripped and 'ARRAY(' in stripped:
            # Remove comments for accurate check
            code_part = line.strip().split("'")[0].upper()
            if 'CONST' in code_part and 'ARRAY(' in code_part:
                err(f"{fname} line {ln+1}: Const declaration uses Array() — use module-level variable instead: '{line.rstrip()}'")
    
    CHECKS_PASSED += 1


def main():
    global CHECKS_PASSED, CHECKS_FAILED
    
    if not os.path.isdir(VBA_DIR):
        print(f"❌ Source directory not found: {VBA_DIR}")
        sys.exit(1)
    
    files = sorted(glob.glob(os.path.join(VBA_DIR, "*.bas")) + 
                   glob.glob(os.path.join(VBA_DIR, "*.frm")) +
                   glob.glob(os.path.join(VBA_DIR, "*.cls")))
    
    print("╔══════════════════════════════════════════════╗")
    print("║        VBA Pre-Build Validator v1.0         ║")
    print("╚══════════════════════════════════════════════╝")
    print(f"  Scanning: {VBA_DIR}")
    print(f"  Files:    {len(files)}")
    print()
    
    for fpath in files:
        validate_file(fpath)
    
    # RESULTS
    print("╔══════════════════════════════════════════════╗")
    print("║                  RESULTS                    ║")
    print("╚══════════════════════════════════════════════╝")
    print()
    print(f"  Files scanned: {len(files)}")
    print(f"  Errors:       {CHECKS_FAILED}")
    
    if ERRORS:
        print()
        print("── ERRORS ────────────────────────────────────────")
        for e in ERRORS:
            print(f"  ❌ {e}")
    
    if WARNINGS:
        print()
        print("── WARNINGS ──────────────────────────────────────")
        for w in WARNINGS:
            print(f"  ⚠️  {w}")
    
    print()
    if CHECKS_FAILED == 0:
        print("  ✅ ALL CHECKS PASSED — SAFE TO BUILD")
        return 0
    else:
        print(f"  ❌ {CHECKS_FAILED} ERROR(S) — FIX BEFORE BUILD")
        return 1

if __name__ == "__main__":
    sys.exit(main())
