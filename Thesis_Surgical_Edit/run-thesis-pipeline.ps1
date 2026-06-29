#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Academix v13.4 — Comprehensive Thesis Pipeline v2
  Orchestrates all thesis build, fix, verify, and report scripts.

.DESCRIPTION
  Five-phase pipeline with pass/fail tracking and JSON+TXT reporting.

  Phase 0: Environment Check — verify tools, golden source, scripts
  Phase 1: Source Prep — copy golden DOCX or build from MD via pandoc
  Phase 2: Section Fixes — fix_docx_sections.py (must run before python-docx save)
  Phase 3: Comprehensive Fixes — fix_thesis_all.py (9 steps) + apply_caption_styles.py
  Phase 4: Field Injection — insert_fields.py (TOC & List of Tables)
  Phase 5: Verification — audit + verify + sync + measure
  Phase 6: Report — generate structured pipeline report

.PARAMETER Phase
  Which phase(s) to run: all, 0, 1, 2, 3, 4, 5, 6, build, fix, verify, report
  "all" runs all phases. "build" runs phases 0-3. "fix" runs phases 2-3.
  "verify" runs phase 5. "report" runs phase 6 only.

.PARAMETER SkipBuild
  Skip Phase 1 build (use existing output DOCX)

.PARAMETER OutputDir
  Directory for pipeline reports (default: pipeline-reports/)

.EXAMPLE
  .\run-thesis-pipeline.ps1            # Full pipeline
  .\run-thesis-pipeline.ps1 -Phase verify  # Verify only
  .\run-thesis-pipeline.ps1 -Phase fix     # Fix only (sections + comprehensive)
#>

param(
    [Parameter(Position=0)]
    [string]$Phase = "all",
    [switch]$SkipBuild,
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Continue"
$projectRoot = Split-Path $PSScriptRoot -Parent
$tsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$styleDir = Join-Path $tsDir "style"
$outDir = Join-Path $tsDir "output"
$null = New-Item -ItemType Directory -Path $outDir -Force

$docxPath = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"
$goldenSource = "C:\Users\Administrator\Desktop\Memoire_DSS_Logistique_ElBayadh_v2.docx"
$sourceMd = Join-Path $tsDir "Memoire_DSS_Logistique_ElBayadh.md"
$refDocx = Join-Path $styleDir "reference.docx"
$pandoc = "C:\Users\ADMINISTRATOR\AppData\Local\Pandoc\pandoc.exe"
if (-not (Test-Path $pandoc)) {
    $pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

# Pipeline report directory
if (-not $OutputDir) {
    $OutputDir = Join-Path $projectRoot "pipeline-reports"
}
$null = New-Item -ItemType Directory -Path $OutputDir -Force
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = Join-Path $OutputDir "pipeline-$timestamp.json"
$reportTxt = Join-Path $OutputDir "pipeline-$timestamp.txt"

# === Pipeline State ===
$global:pipeline = @{
    phases = @{}
    results = @()
    startTime = Get-Date
    totalPassed = 0
    totalFailed = 0
    totalSkipped = 0
}

# === Helpers ===
function Write-Phase($number, $title) {
    Write-Host ""
    Write-Host "+-----------------------------------------------+" -ForegroundColor Cyan
    Write-Host "| PHASE $number : $title" -ForegroundColor Cyan
    Write-Host "+-----------------------------------------------+" -ForegroundColor Cyan
}

function Write-Step($label, $status, $detail="") {
    $icons = @{PASS="[PASS]"; FAIL="[FAIL]"; SKIP="[SKIP]"; WARN="[WARN]"; INFO="[INFO]"}
    $icon = $icons[$status]
    if (-not $icon) { $icon = "      " }
    $msg = "  $icon $label"
    if ($detail) { $msg += " — $detail" }
    switch ($status) {
        "PASS" { Write-Host $msg -ForegroundColor Green }
        "FAIL" { Write-Host $msg -ForegroundColor Red }
        "SKIP" { Write-Host $msg -ForegroundColor Gray }
        "WARN" { Write-Host $msg -ForegroundColor Yellow }
        default { Write-Host $msg }
    }
}

function Invoke-PipelineStep {
    param([string]$Label, [scriptblock]$ScriptBlock, [string]$SkipReason="")
    
    $step = @{
        label = $Label
        status = "SKIP"
        detail = ""
        startTime = Get-Date
        duration = 0
    }
    
    if ($SkipReason) {
        $step.status = "SKIP"
        $step.detail = $SkipReason
        Write-Step $Label "SKIP" $SkipReason
    } else {
        $step.startTime = Get-Date
        try {
            $result = & $ScriptBlock
            $step.duration = ((Get-Date) - $step.startTime).TotalSeconds
            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
                $step.status = "PASS"
                if ($result) { $step.detail = "$result" }
                Write-Step $Label "PASS" $step.detail
            } else {
                $step.status = "FAIL"
                $step.detail = "Exit code: $LASTEXITCODE"
                if ($result) { $step.detail += " | $result" }
                Write-Step $Label "FAIL" $step.detail
            }
        } catch {
            $step.status = "FAIL"
            $step.detail = $_.Exception.Message
            Write-Step $Label "FAIL" $step.detail
        }
    }
    
    $global:pipeline.results += $step
    switch ($step.status) {
        "PASS" { $global:pipeline.totalPassed++ }
        "FAIL" { $global:pipeline.totalFailed++ }
        "SKIP" { $global:pipeline.totalSkipped++ }
    }
    return $step.status -eq "PASS"
}

# ── Phase 0: Environment Check ──────────────────────────────────────────────────

function Invoke-Phase0 {
    Write-Phase 0 "Environment Check"
    $ok = $true
    
    $pyVer = python --version 2>&1
    $ok = (Invoke-PipelineStep "Python available" { python --version 2>&1 }) -and $ok
    
    if ($pandoc) {
        $ok = (Invoke-PipelineStep "Pandoc available" { & $pandoc --version 2>&1 | Select-Object -First 1 }) -and $ok
    } else {
        Invoke-PipelineStep "Pandoc available" -SkipReason "Not installed — will use golden source"
    }
    
    if (Test-Path $goldenSource) {
        $ok = (Invoke-PipelineStep "Golden source exists" {
            $size = (Get-Item $goldenSource).Length
            "Size: $([math]::Round($size/1KB)) KB"
        }) -and $ok
    } else {
        Invoke-PipelineStep "Golden source exists" -SkipReason "Not found at $goldenSource — will rebuild from MD"
    }
    
    $keyScripts = @(
        "fix_docx_sections.py", "fix_thesis_all.py",
        "audit_thesis_comprehensive.py", "verify_docx_checks.py",
        "docx_md_sync.py", "measure-thesis.py",
        "fix_page_field.py", "check_page_field.py",
        "apply_caption_styles.py", "insert_fields.py"
    )
    foreach ($s in $keyScripts) {
        $sp = Join-Path $styleDir $s
        if (Test-Path $sp) {
            Invoke-PipelineStep "Script present: $s" { $sp }
        } else {
            Invoke-PipelineStep "Script present: $s" -SkipReason "Not found at $sp"
        }
    }
    
    if (Test-Path $sourceMd) {
        Invoke-PipelineStep "Source markdown exists" { "Found: $((Get-Item $sourceMd).Length/1KB) KB" }
    } else {
        Invoke-PipelineStep "Source markdown exists" -SkipReason "Not found"
    }
    
    $null = New-Item -ItemType Directory -Path $outDir -Force
    Invoke-PipelineStep "Output directory ready" { "Path: $outDir" }
    
    return $ok
}

# ── Phase 1: Source Preparation ─────────────────────────────────────────────────

function Invoke-Phase1 {
    Write-Phase 1 "Source Preparation"
    $ok = $true
    
    if ($SkipBuild -and (Test-Path $docxPath)) {
        Invoke-PipelineStep "Use existing output DOCX" -SkipReason "SkipBuild active, using $docxPath"
        return $ok
    }
    
    if ((Test-Path $goldenSource) -and (-not $SkipBuild)) {
        Copy-Item $goldenSource $docxPath -Force
        $ok = (Invoke-PipelineStep "Copy golden source to output" {
            $srcSize = (Get-Item $goldenSource).Length
            $dstSize = (Get-Item $docxPath).Length
            "Source: $([math]::Round($srcSize/1KB)) KB → Output: $([math]::Round($dstSize/1KB)) KB"
        }) -and $ok
    } 
    elseif ((Test-Path $sourceMd) -and ($pandoc)) {
        $ok = (Invoke-PipelineStep "Build DOCX from Markdown via pandoc" {
            $metadata = @(
                "title=`"نظام دعم القرار لتسيير المخزونات`"",
                "author=`"ماحي كمال عبد الغني`"",
                "date=2026-05-18",
                "lang=ar",
                "dir=rtl"
            ) | ForEach-Object { "--metadata=" + $_ }
            & $pandoc $sourceMd -o $docxPath --reference-doc=$refDocx -f markdown-yaml_metadata_block $metadata 2>&1
        }) -and $ok
    } else {
        Invoke-PipelineStep "Source preparation" -SkipReason "No golden source or pandoc available"
        $ok = $false
    }
    
    if (Test-Path $docxPath) {
        $ok = (Invoke-PipelineStep "Output DOCX readable" {
            $result = python -c "
import sys
try:
    from docx import Document
    doc = Document(r'$docxPath')
    print(f'Paragraphs: {len(doc.paragraphs)}, Sections: {len(doc.sections)}')
except Exception as e:
    print(f'ERROR: {e}')
    sys.exit(1)
" 2>&1
        }) -and $ok
    } else {
        Invoke-PipelineStep "Output DOCX exists" -SkipReason "File not created"
        $ok = $false
    }
    
    return $ok
}

# ── Phase 2: Section Fixes ──────────────────────────────────────────────────────

function Invoke-Phase2 {
    Write-Phase 2 "Section Fixes (python-docx)"
    $ok = $true
    
    if (-not (Test-Path $docxPath)) {
        Invoke-PipelineStep "Section fixes" -SkipReason "No DOCX to fix at $docxPath"
        return $false
    }
    
    $script = Join-Path $styleDir "fix_docx_sections.py"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "fix_docx_sections.py — section breaks + A4" {
            python $script $docxPath --save 2>&1
        }) -and $ok
    }
    
    return $ok
}

# ── Phase 3: Comprehensive Fixes ────────────────────────────────────────────────

function Invoke-Phase3 {
    Write-Phase 3 "Comprehensive Fixes (zip-level, fixes are final)"
    $ok = $true
    
    if (-not (Test-Path $docxPath)) {
        Invoke-PipelineStep "Comprehensive fixes" -SkipReason "No DOCX to fix at $docxPath"
        return $false
    }
    
    # fix_thesis_all.py — 9-step comprehensive fix (page num, tables, formatting,
    # empty paras, footnotes RTL, namespace fix, PAGE field fix)
    $script = Join-Path $styleDir "fix_thesis_all.py"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "fix_thesis_all.py — 9-step comprehensive fix" {
            python $script $docxPath --save 2>&1
        }) -and $ok
    }

    # apply_caption_styles.py — Ensure table captions have 'Caption' style
    $captionScript = Join-Path $styleDir "apply_caption_styles.py"
    if (Test-Path $captionScript) {
        $ok = (Invoke-PipelineStep "apply_caption_styles.py — style captions" {
            python $captionScript $docxPath --save 2>&1
        }) -and $ok
    }
    
    # Quick check: namespace should be clean
    $ok = (Invoke-PipelineStep "Verify namespace: no ns0/ns1 prefixes" {
        python -c "
import zipfile
path = r'$docxPath'
with zipfile.ZipFile(path, 'r') as z:
    if 'word/footnotes.xml' in z.namelist():
        raw = z.read('word/footnotes.xml').decode('utf-8')
        ns0 = 'ns0:' in raw
        ns1 = 'ns1:' in raw
        mc = 'mc:Ignorable' in raw
        if ns0 or ns1:
            print(f'ISSUE: ns0={ns0}, ns1={ns1} (namespace fix missing?)')
        else:
            print(f'Clean: mc:Ignorable={mc}')
" 2>&1
    }) -and $ok
    
    # Quick check: PAGE field should have no cached result
    $ok = (Invoke-PipelineStep "Verify PAGE field: no cached result" {
        python "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\check_page_field.py" $docxPath 2>&1
    }) -and $ok
    
    return $ok
}

# ── Phase 4: Field Injection ────────────────────────────────────────────────────

function Invoke-Phase4 {
    Write-Phase 4 "Field Injection (TOC & List of Tables)"
    $ok = $true
    
    if (-not (Test-Path $docxPath)) {
        Invoke-PipelineStep "Field injection" -SkipReason "No DOCX to inject fields into at $docxPath"
        return $false
    }

    $script = Join-Path $styleDir "insert_fields.py"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "insert_fields.py — inject TOC/LISTOFTABLES" {
            python $script $docxPath --save 2>&1
        }) -and $ok
    }

    return $ok
}

# ── Phase 5: Verification ───────────────────────────────────────────────────────

function Invoke-Phase5 {
    Write-Phase 5 "Verification"
    $ok = $true
    
    if (-not (Test-Path $docxPath)) {
        Invoke-PipelineStep "Verification" -SkipReason "No DOCX at $docxPath"
        return $false
    }
    
    # Audit (comprehensive)
    $script = Join-Path $styleDir "audit_thesis_comprehensive.py"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "audit_thesis_comprehensive.py — deep audit" {
            python $script $docxPath 2>&1
        }) -and $ok
    }
    
    # Verify (29 checks)
    $script = Join-Path $styleDir "verify_docx_checks.py"
    $backupPath = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh_v7c_BACKUP.docx"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "verify_docx_checks.py — 29 fast checks" {
            python $script $docxPath --size-threshold 50000 --backup $backupPath 2>&1 | Select-Object -Last 30
        }) -and $ok
    }
    
    # MD ↔ DOCX sync
    $script = Join-Path $styleDir "docx_md_sync.py"
    if (Test-Path $script) {
        $ok = (Invoke-PipelineStep "docx_md_sync.py — MD ↔ DOCX sync" {
            python $script $docxPath --verify 2>&1
        }) -and $ok
    }
    
    # Measure metrics
    $script = Join-Path $styleDir "measure-thesis.py"
    if ((Test-Path $script) -and (Test-Path $sourceMd)) {
        Invoke-PipelineStep "measure-thesis.py — metrics recording" {
            $r = python $script $docxPath $sourceMd 2>&1
            $r -join "`n"
        }
    } else {
        Invoke-PipelineStep "measure-thesis.py" -SkipReason "Script or source MD not found"
    }
    
    return $ok
}

# ── Phase 6: Report ─────────────────────────────────────────────────────────────

function Invoke-Phase6 {
    Write-Phase 6 "Pipeline Report"
    
    $duration = ((Get-Date) - $global:pipeline.startTime).TotalSeconds
    $total = $global:pipeline.totalPassed + $global:pipeline.totalFailed + $global:pipeline.totalSkipped
    
    $reportLines = @()
    $reportLines += "=" * 80
    $reportLines += "  ACADEMIX v13.4 — COMPREHENSIVE THESIS PIPELINE REPORT"
    $reportLines += "  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $reportLines += "  Duration: $([math]::Round($duration, 1))s"
    $reportLines += "=" * 80
    $reportLines += ""
    $reportLines += "  Summary: [PASS] $($global:pipeline.totalPassed) passed | [FAIL] $($global:pipeline.totalFailed) failed | [SKIP] $($global:pipeline.totalSkipped) skipped"
    $reportLines += ""
    $reportLines += "  Current Phase: $currentPhase"
    $reportLines += ""
    $currentPhase = 0
    foreach ($step in $global:pipeline.results) {
        $icons = @{PASS="[PASS]"; FAIL="[FAIL]"; SKIP="[SKIP]"; WARN="[WARN]"}
        $icon = $icons[$step.status]
        if (-not $icon) { $icon = "  " }
        $reportLines += "  $icon [$($step.status)] $($step.label) -- $($step.detail) ($([math]::Round($step.duration, 1))s)"
    }
    
    $reportLines += ""
    $reportLines += "  Files:"
    $reportLines += "    Output:  $docxPath"
    if (Test-Path $docxPath) {
        $size = (Get-Item $docxPath).Length
        $reportLines += "    Size:    $([math]::Round($size/1KB)) KB"
    }
    $reportLines += "    Report:  $reportFile"
    $reportLines += ""
    $reportLines += "=" * 80
    $reportLines += "  END OF PIPELINE REPORT"
    $reportLines += "=" * 80
    
    $report = $reportLines -join "`n"
    
    # Write TXT report
    $report | Out-File -FilePath $reportTxt -Encoding utf8
    Invoke-PipelineStep "Write TXT report" { "Saved to $reportTxt" }
    
    # Write JSON report
    $jsonData = @{
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        duration = $duration
        summary = @{
            passed = $global:pipeline.totalPassed
            failed = $global:pipeline.totalFailed
            skipped = $global:pipeline.totalSkipped
            total = $total
        }
        steps = $global:pipeline.results | ForEach-Object {
            @{
                label = $_.label
                status = $_.status
                detail = $_.detail
                duration = $_.duration
            }
        }
        files = @{
            output = $docxPath
            report = $reportFile
        }
    }
    $jsonData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding utf8
    Invoke-PipelineStep "Write JSON report" { "Saved to $reportFile" }
}

# ===================================================================
# MAIN — Phase Routing
# ===================================================================
Write-Host ""
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|     ACADEMIX v13.4 -- Comprehensive Thesis Pipeline v2      |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "  Output: $docxPath" -ForegroundColor Gray
 
$allOk = $true
 
switch -Wildcard ($Phase) {
    "all" {
        $allOk = Invoke-Phase0 -and $allOk
        $allOk = Invoke-Phase1 -and $allOk
        $allOk = Invoke-Phase2 -and $allOk
        $allOk = Invoke-Phase3 -and $allOk
        $allOk = Invoke-Phase4 -and $allOk
        $allOk = Invoke-Phase5 -and $allOk
        Invoke-Phase6
    }
    "0" { $allOk = Invoke-Phase0 }
    "1" { $allOk = Invoke-Phase1 }
    "2" { $allOk = Invoke-Phase2 }
    "3" { $allOk = Invoke-Phase3 }
    "4" { $allOk = Invoke-Phase4 }
    "5" { $allOk = Invoke-Phase5 }
    "6" { Invoke-Phase6 }
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
    "report" { Invoke-Phase6 }
    default {
        Write-Host "Unknown phase: $Phase" -ForegroundColor Red
        Write-Host "Usage: .\run-thesis-pipeline.ps1 [[-Phase] <string>] [[-SkipBuild]]" -ForegroundColor Yellow
        Write-Host "Phases: all, 0, 1, 2, 3, 4, 5, 6, build, fix, verify, report" -ForegroundColor Yellow
    }
}
 
if (-not $allOk) {
    Write-Host "`n[WARN] Pipeline completed with failures -- review report for details." -ForegroundColor Yellow
}
 
exit $(if ($allOk) {0} else {1})
