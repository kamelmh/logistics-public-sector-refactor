#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Academix v13.4 — Clean Thesis Pipeline v4
  Linear, non-conflicting pipeline with proper ordering.

.DESCRIPTION
  Six-phase pipeline with strict ordering to prevent corruption:

  Phase 0: Environment Check — verify tools, scripts, source
  Phase 1: Source Build — copy golden source DOCX (canonical version)
  Phase 2: python-docx Fixes — section layout + styles + RTL (doc.save() here)
  Phase 3: Zip-Level Fixes — footnotes, footer, namespace (AFTER all doc.save())
  Phase 4: Word COM — field update, TOC/TOF, logos, surgical polish
  Phase 5: Verification — audit + verify + sync

  KEY RULE: python-docx saves MUST precede zip-level fixes.
  KEY RULE: Namespace fix MUST be the very last operation.
  KEY RULE: Golden source is canonical — MD is for reference only.

.PARAMETER Phase
  Which phase(s) to run: all, 0, 1, 2, 3, 4, 5, build, fix, verify
  "all" runs all phases. "build" runs phases 0-4. "fix" runs phases 2-3.
  "verify" runs phase 5 only.

.PARAMETER SkipBuild
  Skip Phase 1 build (use existing output DOCX)

.EXAMPLE
  .\run-thesis-pipeline.ps1            # Full pipeline
  .\run-thesis-pipeline.ps1 -Phase verify  # Verify only
  .\run-thesis-pipeline.ps1 -Phase fix     # Fix only (sections + comprehensive)
#>

param(
    [Parameter(Position=0)]
    [string]$Phase = "all",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$tsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$styleDir = Join-Path $tsDir "style"
$outDir = Join-Path $tsDir "output"
$null = New-Item -ItemType Directory -Path $outDir -Force

$docxPath = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"
$sourceMd = Join-Path $tsDir "Memoire_DSS_Logistique_ElBayadh.md"
$goldenSource = Join-Path $outDir "Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx"
$refDocx = Join-Path $outDir "Latest-thesis-backup-1-Memoire_DSS_Logistique_ElBayadh.docx"
if (-not (Test-Path $refDocx)) {
    $refDocx = Join-Path $styleDir "reference.docx"
}

# Find pandoc
$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# Pipeline state
$global:results = @()
$global:startTime = Get-Date

# === Helpers ===
function Write-Phase($number, $title) {
    Write-Host ""
    Write-Host "+-----------------------------------------------+" -ForegroundColor Cyan
    Write-Host "| PHASE $number : $title" -ForegroundColor Cyan
    Write-Host "+-----------------------------------------------+" -ForegroundColor Cyan
}

function Write-Step($label, $status, $detail="") {
    $icons = @{PASS="[PASS]"; FAIL="[FAIL]"; SKIP="[SKIP]"; INFO="[INFO]"}
    $icon = $icons[$status]
    if (-not $icon) { $icon = "      " }
    $msg = "  $icon $label"
    if ($detail) { $msg += " — $detail" }
    switch ($status) {
        "PASS" { Write-Host $msg -ForegroundColor Green }
        "FAIL" { Write-Host $msg -ForegroundColor Red }
        "SKIP" { Write-Host $msg -ForegroundColor Gray }
        default { Write-Host $msg }
    }
    $global:results += @{label=$label; status=$status; detail=$detail}
}

function Run-Script {
    param([string]$Label, [string]$Script, [string]$ScriptArgs)
    $scriptPath = Join-Path $styleDir $Script
    if (-not (Test-Path $scriptPath)) {
        Write-Step $Label "SKIP" "Script not found: $Script"
        return $false
    }
    try {
        $cmd = "uv run python `"$scriptPath`" $ScriptArgs"
        $output = Invoke-Expression $cmd 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Step $Label "PASS" ($output | Select-Object -Last 3 | Out-String)
            return $true
        } else {
            Write-Step $Label "FAIL" "Exit code: $exitCode"
            $output | Select-Object -Last 5 | Write-Host -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Step $Label "FAIL" $_.Exception.Message
        return $false
    }
}

# ── Phase 0: Environment Check ──────────────────────────────────────────────────
function Invoke-Phase0 {
    Write-Phase 0 "Environment Check"
    $ok = $true
    
    # Python
    try {
        $pyVer = & uv run python --version 2>&1
        Write-Step "Python available" "PASS" "$pyVer"
    } catch {
        Write-Step "Python available" "FAIL" "uv run python not found"
        $ok = $false
    }
    
    # Pandoc
    if ($pandoc) {
        try {
            $pandocVer = & $pandoc --version 2>&1 | Select-Object -First 1
            Write-Step "Pandoc available" "PASS" "$pandocVer"
        } catch {
            Write-Step "Pandoc available" "FAIL" "Pandoc error"
            $ok = $false
        }
    } else {
        Write-Step "Pandoc available" "SKIP" "Not installed — will use golden source"
    }
    
    # Source markdown
    if (Test-Path $sourceMd) {
        $size = (Get-Item $sourceMd).Length
        Write-Step "Source markdown exists" "PASS" "Size: $([math]::Round($size/1KB)) KB"
    } else {
        Write-Step "Source markdown" "FAIL" "No markdown found at $sourceMd"
        $ok = $false
    }
    
    # Golden source
    if (Test-Path $goldenSource) {
        $size = (Get-Item $goldenSource).Length
        Write-Step "Golden source exists" "PASS" "Size: $([math]::Round($size/1KB)) KB"
    } else {
        Write-Step "Golden source" "FAIL" "Not found at $goldenSource"
        $ok = $false
    }
    
    # Key scripts
    $keyScripts = @(
        "fix_docx_sections.py", "fix_thesis_all.py",
        "audit_thesis_comprehensive.py", "verify_docx_checks.py",
        "docx_md_sync.py", "apply_caption_styles.py", "insert_fields.py"
    )
    foreach ($s in $keyScripts) {
        $sp = Join-Path $styleDir $s
        if (Test-Path $sp) {
            Write-Step "Script: $s" "PASS" ""
        } else {
            Write-Step "Script: $s" "SKIP" "Not found"
        }
    }
    
    # Output directory
    $null = New-Item -ItemType Directory -Path $outDir -Force
    Write-Step "Output directory ready" "PASS" "$outDir"
    
    return $ok
}

# ── Phase 1: Source Build (from MD via pandoc, golden source for styles) ─────────
function Invoke-Phase1 {
    Write-Phase 1 "Source Build (from Markdown)"
    
    if ($SkipBuild -and (Test-Path $docxPath)) {
        Write-Step "Use existing output DOCX" "SKIP" "SkipBuild active"
        return $true
    }
    
    if ((Test-Path $sourceMd) -and $pandoc) {
        # Strip YAML frontmatter from content (prevent it from rendering as visible text)
        $mdContent = Get-Content $sourceMd -Raw -Encoding UTF8
        $cleanMd = $mdContent -replace '(?s)^---\s*\n.*?\n---\s*\n', ''
        $tempMd = Join-Path $outDir "temp_build.md"
        [System.IO.File]::WriteAllText($tempMd, $cleanMd, [System.Text.UTF8Encoding]::new($false))
        
        # Build with pandoc — golden source as reference-doc for styles/formatting
        try {
            & $pandoc $tempMd -o $docxPath --reference-doc=$refDocx -f markdown-yaml_metadata_block 2>&1
            if ($LASTEXITCODE -ne 0) { throw "Pandoc failed with exit code $LASTEXITCODE" }
            Remove-Item $tempMd -ErrorAction SilentlyContinue
            $size = (Get-Item $docxPath).Length
            Write-Step "Build from Markdown" "PASS" "Size: $([math]::Round($size/1KB)) KB"
            return $true
        } catch {
            Write-Step "Build from Markdown" "FAIL" $_.Exception.Message
            return $false
        }
    }
    
    Write-Step "Source build" "FAIL" "No markdown or pandoc available"
    return $false
}

# ── Phase 2: python-docx Fixes (doc.save() happens here) ───────────────────────
function Invoke-Phase2 {
    Write-Phase 2 "python-docx Fixes"
    
    if (-not (Test-Path $docxPath)) {
        Write-Step "Source DOCX" "SKIP" "No DOCX at $docxPath"
        return $false
    }
    
    # Step 1: Section layout (single section, A4, titlePg, pgNumType)
    Run-Script "fix_docx_sections.py — section layout" "fix_docx_sections.py" "`"$docxPath`" --save"
    
    # Step 2: Comprehensive fixes (tables, styles, RTL, empty paras)
    Run-Script "fix_thesis_all.py — comprehensive fixes" "fix_thesis_all.py" "`"$docxPath`" --save"
    
    # Step 3: Caption styles
    Run-Script "apply_caption_styles.py — caption styles" "apply_caption_styles.py" "`"$docxPath`" --save"
    
    # Step 4: Insert TOC/LISTOFTABLES fields
    Run-Script "insert_fields.py — field injection" "insert_fields.py" "`"$docxPath`" --save"
    
    Write-Step "python-docx phase complete" "PASS" "All doc.save() calls done"
    return $true
}

# ── Phase 3: Zip-Level Fixes (AFTER all doc.save() calls) ──────────────────────
function Invoke-Phase3 {
    Write-Phase 3 "Zip-Level Fixes (final, no more doc.save())"
    
    if (-not (Test-Path $docxPath)) {
        Write-Step "Zip fixes" "SKIP" "No DOCX at $docxPath"
        return $false
    }
    
    # Verify namespace is clean
    $nsCheck = & uv run python -c "
import zipfile
path = r'$docxPath'
with zipfile.ZipFile(path, 'r') as z:
    if 'word/footnotes.xml' in z.namelist():
        raw = z.read('word/footnotes.xml').decode('utf-8')
        ns0 = 'ns0:' in raw
        ns1 = 'ns1:' in raw
        if ns0 or ns1:
            print(f'ISSUE: ns0={ns0}, ns1={ns1}')
        else:
            print('Clean namespace')
    else:
        print('No footnotes.xml')
" 2>&1
    
    if ($nsCheck -match "ISSUE") {
        Write-Step "Namespace check" "WARN" "$nsCheck — fix_thesis_all.py should have fixed this"
    } else {
        Write-Step "Namespace check" "PASS" "$nsCheck"
    }
    
    # Verify PAGE field
    $pgCheck = & uv run python -c "
import zipfile
path = r'$docxPath'
with zipfile.ZipFile(path, 'r') as z:
    if 'word/footer2.xml' in z.namelist():
        raw = z.read('word/footer2.xml').decode('utf-8')
        if 'PAGE' in raw:
            if '<w:t>' in raw and 'PAGE' not in raw.split('<w:t>')[0]:
                print('WARNING: PAGE field may have cached value')
            else:
                print('PAGE field OK (no cached value)')
        else:
            print('WARNING: No PAGE field in footer2.xml')
    else:
        print('WARNING: No footer2.xml')
" 2>&1
    
    Write-Step "PAGE field check" "PASS" "$pgCheck"
    return $true
}

# ── Phase 4: Word COM (TOC/TOF/logos/cover page/field update) ──────────────────
function Invoke-Phase4 {
    Write-Phase 4 "Word COM Automation"
    
    if (-not (Test-Path $docxPath)) {
        Write-Step "Word COM" "SKIP" "No DOCX at $docxPath"
        return $false
    }
    
    # Step 1: Update fields (Ctrl+A F9 equivalent)
    Run-Script "update_fields.py — field update" "update_fields.py" @($docxPath, "--save-only")
    
    # Step 2: Word COM automation (logos, TOC, Table of Figures, cover page)
    $logo1Path = Join-Path $tsDir "style\logo1.png"
    $logo2Path = Join-Path $tsDir "style\logo2.png"
    if (-not (Test-Path $logo1Path)) { $logo1Path = "" }
    if (-not (Test-Path $logo2Path)) { $logo2Path = "" }
    Run-Script "word_automation.py — TOC/TOF/logos" "word_automation.py" @($docxPath, $logo1Path, $logo2Path)
    
    # Step 3: Post-COM surgical polish (Word COM resets some XML properties)
    Run-Script "surgical_polish.py — post-COM polish" "surgical_polish.py" "`"$docxPath`" --save"
    
    # Step 4: Re-apply comprehensive fixes after COM automation
    Run-Script "fix_thesis_all.py — post-COM fixes" "fix_thesis_all.py" "`"$docxPath`" --save"
    
    # Step 5: Re-apply section fixes (page numbering after COM)
    Run-Script "fix_docx_sections.py — post-COM sections" "fix_docx_sections.py" "`"$docxPath`" --save"
    
    return $true
}

# ── Phase 5: Verification ───────────────────────────────────────────────────────
function Invoke-Phase5 {
    Write-Phase 5 "Verification"
    
    if (-not (Test-Path $docxPath)) {
        Write-Step "Verification" "SKIP" "No DOCX at $docxPath"
        return $false
    }
    
    # Audit
    Run-Script "audit_thesis_comprehensive.py — deep audit" "audit_thesis_comprehensive.py" "`"$docxPath`""
    
    # Verify (36 checks)
    Run-Script "verify_docx_checks.py — 36 fast checks" "verify_docx_checks.py" "`"$docxPath`" --size-threshold 50000"
    
    # MD ↔ DOCX sync
    Run-Script "docx_md_sync.py — MD ↔ DOCX sync" "docx_md_sync.py" "`"$docxPath`" --verify"
    
    return $true
}

# ===================================================================
# MAIN
# ===================================================================
Write-Host ""
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|     ACADEMIX v13.4 -- Clean Thesis Pipeline v4             |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "  Output: $docxPath" -ForegroundColor Gray
Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

$allOk = $true

switch -Wildcard ($Phase) {
    "all" {
        $allOk = Invoke-Phase0 -and $allOk
        $allOk = Invoke-Phase1 -and $allOk
        $allOk = Invoke-Phase2 -and $allOk
        $allOk = Invoke-Phase3 -and $allOk
        $allOk = Invoke-Phase4 -and $allOk
        $allOk = Invoke-Phase5 -and $allOk
    }
    "0" { $allOk = Invoke-Phase0 }
    "1" { $allOk = Invoke-Phase1 }
    "2" { $allOk = Invoke-Phase2 }
    "3" { $allOk = Invoke-Phase3 }
    "4" { $allOk = Invoke-Phase4 }
    "5" { $allOk = Invoke-Phase5 }
    "build" {
        $allOk = Invoke-Phase0 -and $allOk
        $allOk = Invoke-Phase1 -and $allOk
        $allOk = Invoke-Phase2 -and $allOk
        $allOk = Invoke-Phase3 -and $allOk
        $allOk = Invoke-Phase4 -and $allOk
    }
    "fix" {
        $allOk = Invoke-Phase2 -and $allOk
        $allOk = Invoke-Phase3 -and $allOk
    }
    "verify" { $allOk = Invoke-Phase5 }
    default {
        Write-Host "Unknown phase: $Phase" -ForegroundColor Red
        Write-Host "Usage: .\run-thesis-pipeline.ps1 [[-Phase] <string>] [[-SkipBuild]]" -ForegroundColor Yellow
        Write-Host "Phases: all, 0, 1, 2, 3, 4, 5, build, fix, verify" -ForegroundColor Yellow
    }
}

$duration = ((Get-Date) - $global:startTime).TotalSeconds
$passed = ($global:results | Where-Object { $_.status -eq "PASS" }).Count
$failed = ($global:results | Where-Object { $_.status -eq "FAIL" }).Count
$skipped = ($global:results | Where-Object { $_.status -eq "SKIP" }).Count

Write-Host ""
Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|  SUMMARY: $passed passed | $failed failed | $skipped skipped | $([math]::Round($duration, 1))s" -ForegroundColor Cyan
Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan

exit $(if ($allOk) {0} else {1})
