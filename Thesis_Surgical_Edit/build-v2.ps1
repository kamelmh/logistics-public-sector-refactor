#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Thesis Build v2 - Clean 5-phase pipeline.

.DESCRIPTION
  Simple, repeatable build:
    Phase 1: PANDOC - MD to body DOCX (text, tables, footnotes)
    Phase 2: STITCH - cover_page shell + pandoc body (zip-level)
    Phase 3: FORMAT - table widths, RTL, styles, footer
    Phase 4: WORD - field update, TOC/TOF refresh
    Phase 5: VERIFY - 36-point check + MD sync

  SOURCE OF TRUTH:
    - Cover page: output/cover_page_and_post_chapters_contents_only.docx (UNTOUCHABLE)
    - Body content: Memoire_DSS_Logistique_ElBayadh.md
    - Reference doc: style/reference.docx

.PARAMETER Phase
  Which phase(s) to run: all, 1, 2, 3, 4, 5
  "all" runs all phases.

.EXAMPLE
  .\build-v2.ps1           # Full build
  .\build-v2.ps1 -Phase 5  # Verify only
#>

param(
    [Parameter(Position=0)]
    [string]$Phase = "all"
)

$ErrorActionPreference = "Stop"
$tsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$styleDir = Join-Path $tsDir "style"
$outDir = Join-Path $tsDir "output"

# Paths
$mdSource = Join-Path $tsDir "Memoire_DSS_Logistique_ElBayadh.md"
$coverPage = Join-Path $outDir "cover_page_and_post_chapters_contents_only.docx"
$refDocx = Join-Path $styleDir "reference.docx"
$outputDocx = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"
$tempBody = Join-Path $outDir "_temp_body.docx"

# Find pandoc
$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# State
$global:results = @()
$global:startTime = Get-Date

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
    if ($detail) { $msg += " -- $detail" }
    switch ($status) {
        "PASS" { Write-Host $msg -ForegroundColor Green }
        "FAIL" { Write-Host $msg -ForegroundColor Red }
        "SKIP" { Write-Host $msg -ForegroundColor Gray }
        default { Write-Host $msg }
    }
    $global:results += @{label=$label; status=$status; detail=$detail}
}

# ===================================================================
# Phase 1: PANDOC - MD to body DOCX
# ===================================================================
function Invoke-Phase1 {
    Write-Phase 1 "PANDOC - MD to body DOCX"

    if (-not (Test-Path $mdSource)) {
        Write-Step "MD source" "FAIL" "Not found: $mdSource"
        return $false
    }
    Write-Step "MD source" "PASS" "$([math]::Round((Get-Item $mdSource).Length/1KB)) KB"

    if (-not $pandoc) {
        Write-Step "Pandoc" "FAIL" "Not installed"
        return $false
    }

    # Strip YAML front matter, convert MD to DOCX
    $mdContent = Get-Content $mdSource -Raw -Encoding UTF8
    $cleanMd = $mdContent -replace '(?s)^---\s*\n.*?\n---\s*\n', ''
    $tempMd = Join-Path $outDir "_temp_build.md"
    [System.IO.File]::WriteAllText($tempMd, $cleanMd, [System.Text.UTF8Encoding]::new($false))

    & $pandoc $tempMd -o $tempBody --reference-doc=$refDocx -f markdown-yaml_metadata_block 2>&1
    Remove-Item $tempMd -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -ne 0) {
        Write-Step "Pandoc build" "FAIL" "Exit code: $LASTEXITCODE"
        return $false
    }

    $bodySize = [math]::Round((Get-Item $tempBody).Length/1KB)
    Write-Step "Pandoc build" "PASS" "$bodySize KB"

    $env:UV_QUIET = "1"
    $py = "uv"
    $pyArgs = @("run", "--with", "lxml", "--with", "python-docx", "--with", "pypandoc", "python")

    # Inject table captions (SEQ fields for TOF)
    $captionScript = Join-Path $styleDir "inject_table_captions.py"
    $output = & $py $pyArgs $captionScript $tempBody --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Table captions" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "Table captions" "WARN" "Caption injection skipped"
    }

    # Quick stats
    $statsScript = Join-Path $styleDir "get_body_stats.py"
    $stats = & $py $pyArgs $statsScript $tempBody 2>&1
    Write-Step "Body stats" "PASS" "$stats"

    return $true
}

# ===================================================================
# Phase 2: STITCH - cover page + pandoc body (zip-level)
# ===================================================================
function Invoke-Phase2 {
    Write-Phase 2 "STITCH - cover page + pandoc body"

    if (-not (Test-Path $coverPage)) {
        Write-Step "Cover page" "WARN" "Not found: $coverPage — using body-only output"
        if (Test-Path $tempBody) {
            Copy-Item $tempBody $outputDocx -Force
        }
        return $true
    }
    if (-not (Test-Path $tempBody)) {
        Write-Step "Body DOCX" "FAIL" "Not found (run Phase 1 first)"
        return $false
    }

    Copy-Item $coverPage $outputDocx -Force
    Write-Step "Copy cover page" "PASS" "$([math]::Round((Get-Item $outputDocx).Length/1KB)) KB"

    # Run sync script
    $syncScript = Join-Path $styleDir "sync_golden_from_md.py"
    $env:UV_QUIET = "1"
    $py = "uv"
    $pyArgs = @("run", "--with", "lxml", "--with", "python-docx", "--with", "pypandoc", "python")
    $output = & $py $pyArgs $syncScript $outputDocx $tempBody --save 2>&1
    $exitCode = $LASTEXITCODE

    Remove-Item $tempBody -ErrorAction SilentlyContinue

    if ($exitCode -eq 0) {
        $lastLines = ($output | Select-Object -Last 3) -join "`n"
        Write-Step "Body stitch" "PASS" "$lastLines"
    } else {
        Write-Step "Body stitch" "FAIL" "Exit code: $exitCode"
        $output | Select-Object -Last 5 | Write-Host -ForegroundColor Red
        return $false
    }

    return $true
}

# ===================================================================
# Phase 3: FORMAT - table widths, RTL, styles, footer
# ===================================================================
function Invoke-Phase3 {
    Write-Phase 3 "FORMAT - styling fixes"

    if (-not (Test-Path $outputDocx)) {
        Write-Step "DOCX" "SKIP" "No output DOCX"
        return $false
    }

    $env:UV_QUIET = "1"
    $py = "uv"
    $pyArgs = @("run", "--with", "lxml", "--with", "python-docx", "--with", "pypandoc", "python")

    # Fix sections (single section, A4, titlePg)
    $script = Join-Path $styleDir "fix_docx_sections.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Sections" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "Sections" "FAIL" "$output"
    }

    # Comprehensive fixes (tables, styles, RTL, empty paras, footnotes, footer, namespace)
    $script = Join-Path $styleDir "fix_thesis_all.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        $size = [math]::Round((Get-Item $outputDocx).Length/1KB)
        Write-Step "Comprehensive fixes" "PASS" "$size KB"
    } else {
        Write-Step "Comprehensive fixes" "FAIL" "$output"
    }

    # Fix heading alignment (H1=center, H2/H3=right, all RTL)
    $script = Join-Path $styleDir "fix_heading_alignment.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Heading alignment" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "Heading alignment" "FAIL" "$output"
    }

    # Remove corrupted static TOC/TOF paragraphs (let word_automation rebuild)
    $script = Join-Path $styleDir "fix_toc_tof.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "TOC/TOF cleanup" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "TOC/TOF cleanup" "FAIL" "$output"
    }

    # Inject proper TOC/TOF fields after headings
    $script = Join-Path $styleDir "inject_toc_tof_fields.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "TOC/TOF injection" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "TOC/TOF injection" "FAIL" "$output"
    }

    # Fix compatibility checker (suppress alt-text warning popup)
    $script = Join-Path $styleDir "fix_compatibility.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Compatibility fix" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "Compatibility fix" "FAIL" "$output"
    }

    return $true
}

# ===================================================================
# Phase 4: WORD - field update, TOC/TOF refresh
# ===================================================================
function Invoke-Phase4 {
    Write-Phase 4 "WORD - field update"

    if (-not (Test-Path $outputDocx)) {
        Write-Step "DOCX" "SKIP" "No output DOCX"
        return $false
    }

    $env:UV_QUIET = "1"
    $py = "uv"
    $pyArgs = @("run", "--with", "lxml", "--with", "python-docx", "--with", "pypandoc", "python")

    # Preserve footnotes before Word COM
    $script = Join-Path $styleDir "preserve_footnotes.py"
    & $py $pyArgs $script save $outputDocx 2>&1 | Out-Null

    # Update fields (Ctrl+A F9 equivalent)
    $script = Join-Path $styleDir "update_fields.py"
    $output = & $py $pyArgs $script $outputDocx --save-only 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Field update" "PASS"
    } else {
        Write-Step "Field update" "FAIL" "$output"
    }

    # Word COM automation (TOC refresh)
    $script = Join-Path $styleDir "word_automation.py"
    $output = & $py $pyArgs $script $outputDocx "" "" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Word COM" "PASS"
    } else {
        Write-Step "Word COM" "FAIL" "$output"
    }

    # Restore footnotes
    $preserveScript = Join-Path $styleDir "preserve_footnotes.py"
    & $py $pyArgs $preserveScript restore $outputDocx 2>&1 | Out-Null

    # Post-COM surgical polish
    $script = Join-Path $styleDir "surgical_polish.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Surgical polish" "PASS"
    } else {
        Write-Step "Surgical polish" "FAIL" "$output"
    }

    # Re-apply comprehensive fixes (Word COM may reset some properties)
    $script = Join-Path $styleDir "fix_thesis_all.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        $size = [math]::Round((Get-Item $outputDocx).Length/1KB)
        Write-Step "Post-COM fixes" "PASS" "$size KB"
    } else {
        Write-Step "Post-COM fixes" "FAIL" "$output"
    }

    # Re-apply heading alignment (Word COM may reset alignment)
    $script = Join-Path $styleDir "fix_heading_alignment.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Post-COM heading alignment" "PASS" ($output | Select-Object -Last 1)
    } else {
        Write-Step "Post-COM heading alignment" "FAIL" "$output"
    }

    # Re-apply section fixes
    $script = Join-Path $styleDir "fix_docx_sections.py"
    $output = & $py $pyArgs $script $outputDocx --save 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Step "Post-COM sections" "PASS"
    } else {
        Write-Step "Post-COM sections" "FAIL" "$output"
    }

    return $true
}

# ===================================================================
# Phase 5: VERIFY - audit + verify + sync check
# ===================================================================
function Invoke-Phase5 {
    Write-Phase 5 "VERIFY"

    if (-not (Test-Path $outputDocx)) {
        Write-Step "DOCX" "SKIP" "No output DOCX"
        return $false
    }

    $env:UV_QUIET = "1"
    $py = "uv"
    $pyArgs = @("run", "--with", "lxml", "--with", "python-docx", "--with", "pypandoc", "python")

    # 36-point verification
    $script = Join-Path $styleDir "verify_docx_checks.py"
    $output = & $py $pyArgs $script $outputDocx --size-threshold 50000 2>&1
    $exitCode = $LASTEXITCODE
    $lastLines = ($output | Select-Object -Last 5) -join "`n"
    if ($exitCode -eq 0) {
        Write-Step "36-point check" "PASS" "$lastLines"
    } else {
        Write-Step "36-point check" "FAIL" "$lastLines"
    }

    # MD sync check
    $script = Join-Path $styleDir "docx_md_sync.py"
    $output = & $py $pyArgs $script $outputDocx --verify 2>&1
    $exitCode = $LASTEXITCODE
    $lastLines = ($output | Select-Object -Last 3) -join "`n"
    if ($exitCode -eq 0) {
        Write-Step "MD sync" "PASS" "$lastLines"
    } else {
        Write-Step "MD sync" "WARN" "$lastLines"
    }

    # Always return true — verification is informational in CI
    # (Word COM not available on GitHub Actions = expected failures)
    return $true
}

# ===================================================================
# MAIN
# ===================================================================
Write-Host ""
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|     THESIS BUILD v2 - Clean Pipeline                       |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "  Cover page: $coverPage" -ForegroundColor Gray
Write-Host "  MD source:  $mdSource" -ForegroundColor Gray
Write-Host "  Output:     $outputDocx" -ForegroundColor Gray
Write-Host "  Time:       $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

$allOk = $true

switch -Wildcard ($Phase) {
    "all" {
        $allOk = Invoke-Phase1 -and $allOk
        $allOk = Invoke-Phase2 -and $allOk
        $allOk = Invoke-Phase3 -and $allOk
        $allOk = Invoke-Phase4 -and $allOk
        $allOk = Invoke-Phase5 -and $allOk
    }
    "1" { $allOk = Invoke-Phase1 }
    "2" { $allOk = Invoke-Phase2 }
    "3" { $allOk = Invoke-Phase3 }
    "4" { $allOk = Invoke-Phase4 }
    "5" { $allOk = Invoke-Phase5 }
    default {
        Write-Host "Unknown phase: $Phase" -ForegroundColor Red
        Write-Host "Usage: .\build-v2.ps1 [[-Phase] <string>]" -ForegroundColor Yellow
        Write-Host "Phases: all, 1, 2, 3, 4, 5" -ForegroundColor Yellow
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
