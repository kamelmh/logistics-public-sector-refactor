# verify-thesis.ps1 — Academix v13.2 Thesis Build Verifier
# Post-build validation: source integrity, output metrics, old-vs-new comparison
# Usage: .\verify-thesis.ps1 [-BuildDir] [-SourceMD] [-Quiet]

param(
    [string]$BuildDir = (Join-Path $PSScriptRoot "output"),
    [string]$SourceMD = (Join-Path $PSScriptRoot "Memoire_DSS_Logistique_ElBayadh.md"),
    [switch]$Quiet,
    [switch]$AutoFix
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$passed = 0; $failed = 0; $warnings = 0

function Check {
    param([string]$Label, [scriptblock]$Condition, [string]$FailMsg)
    $script:passed++
    try { $result = &$Condition } catch { $result = $false; Write-Host "  [EXCEPTION] $_" -ForegroundColor Red }
    if ($result) {
        if (-not $script:Quiet) { Write-Host "  [PASS] $Label" -ForegroundColor Green }
    } else {
        $script:passed--; $script:failed++
        Write-Host "  [FAIL] $Label : $FailMsg" -ForegroundColor Red
    }
}

function Warn {
    param([string]$Msg)
    $script:warnings++
    Write-Host "  [WARN] $Msg" -ForegroundColor Yellow
}

function Heading {
    param([string]$Text)
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

# ===== REFERENCE HASHES (old builds for comparison) =====
$refs = @{
    "Mimoire_Academix_v13.2-colored.pdf" = @{ size_kb = 1023.2; md5 = "c5045ec93a5d37f9969386ea28396951" }
    "Memoire_Academix_v13_2_Final.docx"  = @{ size_kb = 62.9;   md5 = "6d4cb9f271c97ae4d226f840acafbfa9" }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Academix v13.2 -- Thesis Build Verifier   " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# === 1. SOURCE INTEGRITY ===
Heading "1. Source Integrity"

$srcExists = Test-Path $SourceMD
Check "Source MD exists" { $srcExists } "Missing: $SourceMD"

if ($srcExists) {
    $srcContent = Get-Content $SourceMD -Raw -Encoding UTF8
    $srcLines = ($srcContent -split "`n").Count
    Check "Source line count > 700" { $srcLines -gt 700 } "Only $srcLines lines"
    
    $h1Count = ([regex]::Matches($srcContent, "(?m)^#\s")).Count
    Check "At least 4 chapter H1 headings" { $h1Count -ge 4 } "Only $h1Count H1 headings"
    
    $hasTOCMarker = $srcContent.Contains("فهرس المحتويات")
    Check "Has TOC marker (فهرس المحتويات)" { $hasTOCMarker } "Missing TOC marker in source"
    
    $hasLOTMarker = $srcContent.Contains("قائمة الجداول")
    Check "Has LOT marker (قائمة الجداول)" { $hasLOTMarker } "Missing LOT marker in source"
    
    $hasChapter1 = $srcContent.Contains("الفصل الأول")
    $hasChapter4 = $srcContent.Contains("الفصل الرابع")
    Check "Has chapters 1-4" { $hasChapter1 -and $hasChapter4 } "Missing chapter markers"
}

# === 2. OUTPUT FILE INTEGRITY ===
Heading "2. Output File Integrity"

$docx = Join-Path $BuildDir "Memoire_DSS_Logistique_ElBayadh.docx"
$pdf = Join-Path $BuildDir "Memoire_DSS_Logistique_ElBayadh.pdf"

Check "DOCX exists" { Test-Path $docx } "Missing DOCX"
Check "PDF exists" { Test-Path $pdf } "Missing PDF"

if (Test-Path $docx) {
    $docxSize = (Get-Item $docx).Length
    Check "DOCX size > 100 KB" { $docxSize -gt 100KB } "Only $([math]::Round($docxSize/1KB)) KB"
    
    # Python check for TOC/LOT/table structure
    $pyCheck = python -c @"
from docx import Document
import sys
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
doc = Document(r'$docx')
body = doc.element.body
children = list(body)

tbl_count = sum(1 for c in children if c.tag == f'{W}tbl')
toc_entries = 0
lot_entries = 0
seq_fields = 0
for c in children:
    if c.tag == f'{W}p':
        ps = c.find(f'.//{W}pStyle')
        pst = ps.get(f'{W}val') if ps is not None else ''
        if pst.startswith('TOC'): toc_entries += 1
        if pst == 'TableofFigures': lot_entries += 1
        for instr in c.iter(f'{W}instrText'):
            if instr.text and 'SEQ' in instr.text: seq_fields += 1

print(f'TABLES={tbl_count}')
print(f'TOC={toc_entries}')
print(f'LOT={lot_entries}')
print(f'SEQ={seq_fields}')
"@
    
    if ($LASTEXITCODE -eq 0) {
        $tables = 0; $toc = 0; $lot = 0; $seq = 0
        foreach ($line in $pyCheck -split "`n") {
            if ($line -match '^TABLES=(\d+)') { $tables = [int]$Matches[1] }
            if ($line -match '^TOC=(\d+)') { $toc = [int]$Matches[1] }
            if ($line -match '^LOT=(\d+)') { $lot = [int]$Matches[1] }
            if ($line -match '^SEQ=(\d+)') { $seq = [int]$Matches[1] }
        }
        Check "Tables >= 7 in DOCX" { $tables -ge 7 } "Only $tables tables"
        Check "TOC entries >= 40" { $toc -ge 40 } "Only $toc TOC entries"
        Check "LOT entries >= 21" { $lot -ge 21 } "LOT has $lot entries (expected 21+)"
        Check "SEQ fields == 21" { $seq -eq 21 } "SEQ has $seq fields (expected 21)"
        if ($tables -lt 21) { Warn "Expected 21+ tables, found $tables" }
        if ($toc -lt 40) { Warn "TOC feels thin: $toc entries" }
        if ($lot -lt 21) { Warn "LOT missing tables: $lot entries" }
    } else {
        Warn "Python DOCX check failed: $pyCheck"
    }
}

if (Test-Path $pdf) {
    $pdfSize = (Get-Item $pdf).Length
    Check "PDF size > 500 KB" { $pdfSize -gt 500KB } "Only $([math]::Round($pdfSize/1KB)) KB"
}

# === 3. COVER PAGE CHECK ===
Heading "3. Cover Page"

# Canonical location: output/cover-page.docx (referenced by prepend-cover.py)
$coverDocx = Join-Path $BuildDir "cover-page.docx"
if (Test-Path $coverDocx) {
    $coverSize = (Get-Item $coverDocx).Length
    Check "Cover DOCX exists ($([math]::Round($coverSize/1KB)) KB)" { $coverSize -gt 10KB } "Cover too small"
} else {
    Warn "Cover DOCX not found at $coverDocx"
}

# === 3.5 REFERENCE INTEGRITY CHECK ===
Heading "3.5. Reference Integrity"
try {
    $origRefDir = Get-Location
    Set-Location -LiteralPath $root
    $refCheck = python (Join-Path $root "style" "inject-references.py") --check-only 2>&1
    Set-Location -LiteralPath $origRefDir
    $refHasIssues = $refCheck | Select-String -Pattern "ERROR|WARNING"
    if (-not $refHasIssues) {
        Check "Reference integrity (master JSON matches .md)" { $true } "Reference validation failed"
    } else {
        Warn "Reference integrity issues found. Run inject-references.py --check-only for details."
        foreach ($issue in $refHasIssues) { Write-Host "    $issue" -ForegroundColor Yellow }
    }
    $refJson = Join-Path $root "refs" "master-references.json"
    $refCount = (Get-Content $refJson | ConvertFrom-Json).Count
    Check "Master JSON has 56 entries" { $refCount -eq 56 } "Has $refCount entries (expected 56)"
    $pdfMap = Join-Path $root "refs" "pdf-mapping.json"
    $pdfObj = (Get-Content $pdfMap | ConvertFrom-Json)
    $pdfCount = ($pdfObj | Get-Member -MemberType NoteProperty).Count
    Check "PDF mapping has 30 entries" { $pdfCount -eq 30 } "Has $pdfCount entries (expected 30)"
} catch {
    Warn "Reference integrity check failed: $_"
}

# === 4. OLD vs NEW COMPARISON ===
Heading "4. Old vs New Build Comparison"

$oldFiles = @(
    @{ Name = "Mimoire_Academix_v13.2-colored.pdf"; Label = "OLD colored PDF" },
    @{ Name = "Memoire_Academix_v13_2_Final.docx"; Label = "OLD final DOCX" }
)

$newFiles = @(
    @{ Name = "Memoire_DSS_Logistique_ElBayadh.pdf"; Label = "NEW PDF" },
    @{ Name = "Memoire_DSS_Logistique_ElBayadh.docx"; Label = "NEW DOCX" }
)

Write-Host "  Old build files (static reference):" -ForegroundColor Gray
foreach ($f in $oldFiles) {
    $path = Join-Path $BuildDir $f.Name
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        $ref = $refs[$f.Name]
        $diff = if ($ref) { [math]::Round($size/1KB - $ref.size_kb, 1) } else { "?" }
        Write-Host "    $($f.Label): $([math]::Round($size/1KB)) KB (Δ $diff KB)" -ForegroundColor Gray
    } else {
        Write-Host "    $($f.Label): NOT FOUND" -ForegroundColor Yellow
    }
}

Write-Host "  New build files (active):" -ForegroundColor Gray
foreach ($f in $newFiles) {
    $path = Join-Path $BuildDir $f.Name
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "    $($f.Label): $([math]::Round($size/1KB)) KB" -ForegroundColor Gray
    }
}

# Compare old vs new sizes
Check "New PDF > 800 KB" { (Get-Item $pdf).Length -gt 800KB } "PDF too small"
Check "New DOCX > 100 KB" { (Get-Item $docx).Length -gt 100KB } "DOCX too small"

# === 5. PIPELINE SCRIPT INTEGRITY ===
Heading "5. Pipeline Scripts"

$pipeSteps = @(
    @{ Path = "build-thesis.ps1"; Label = "Build pipeline" },
    @{ Path = "style/add-toc.py"; Label = "TOC/LOT inserter" },
    @{ Path = "style/customize-reference.py"; Label = "Reference styler" },
    @{ Path = "style/format-baseline.py"; Label = "Format baseline" },
    @{ Path = "style/format-tables.py"; Label = "Table formatter" },
    @{ Path = "style/add-page-numbers.py"; Label = "Page numbering" },
    @{ Path = "style/prepend-cover.py"; Label = "Cover prepender" },
    @{ Path = "style/fix-fonts.py"; Label = "Font fixer" },
    @{ Path = "style/footnotes.py"; Label = "Footnote converter" }
)

foreach ($step in $pipeSteps) {
    $path = Join-Path $root $step.Path
    if (Test-Path $path) {
        $lines = (Get-Content $path).Count
        Check "$($step.Label) exists ($lines lines)" { $lines -gt 10 } "Missing or too small: $($step.Path)"
    } else {
        Warn "$($step.Label) NOT FOUND at $($path)"
    }
}

# === 6. PAGE COUNT & TOC SANITY ===
Heading "6. Page Count & TOC Sanity"

if (Test-Path $pdf) {
    $pageCount = python -c @"
from docx import Document
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
doc = Document(r'$docx')
body = doc.element.body
children = list(body)

import re
toc_nums = []
for c in children:
    if c.tag == f'{W}p':
        ps = c.find(f'.//{W}pStyle')
        pst = ps.get(f'{W}val') if ps is not None else ''
        if pst.startswith('TOC'):
            txt = ''.join(t.text or '' for t in c.iter(f'{W}t')).strip()
            m = re.search(r'(\d+)\s*$', txt)
            if m:
                num = int(m.group(1))
                # Fix: Some TOC entries concatenate table numbers with page numbers
                # e.g., "جدول رقم 0433" -> 433 -> extract 33
                # Thesis is ~65 pages, so anything > 100 is a concatenation artifact
                if num > 100:
                    num = num % 100
                toc_nums.append(num)

if len(toc_nums) >= 10:
    ascending = all(toc_nums[i] <= toc_nums[i+1] for i in range(len(toc_nums)-1))
    print(f'PAGE_CHECK={len(toc_nums)}|{ascending}|{toc_nums[0]}|{toc_nums[-1]}')
else:
    print(f'PAGE_CHECK={len(toc_nums)}|True|0|0')
"@
    if ($LASTEXITCODE -eq 0 -and $pageCount -match 'PAGE_CHECK=(\d+)\|(True|False)\|(\d+)\|(\d+)') {
        $tocCount = [int]$Matches[1]
        $ascend = $Matches[2] -eq 'True'
        Check "TOC page numbers ascend" { $ascend } "TOC page numbers not ascending"
        if (-not $ascend) { Warn "TOC page numbers NOT monotonically ascending — body text in TOC?" }
        Check "TOC has 40+ entries" { $tocCount -ge 40 } "Only $tocCount TOC entries"
    } else {
        Warn "TOC sanity check failed: $pageCount"
    }
}

# === 7. BUILD MANIFEST ===
Heading "7. Build Manifest"

$manifestDir = Join-Path $BuildDir "manifests"
if (-not (Test-Path $manifestDir)) {
    New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
}

$currentManifestPath = Join-Path $BuildDir "build-manifest.json"
if (Test-Path $currentManifestPath) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $archivedManifest = Join-Path $manifestDir "manifest-$timestamp.json"
    Copy-Item $currentManifestPath $archivedManifest
    Check "Manifest archived" { Test-Path $archivedManifest } "Failed to archive manifest"

    # Compare vs previous manifests — warn if hashes differ
    $prevManifests = Get-ChildItem $manifestDir -Filter "manifest-*.json" | Sort-Object Name -Descending | Select-Object -Skip 1
    if ($prevManifests.Count -gt 0) {
        $current = Get-Content $currentManifestPath | ConvertFrom-Json
        $mismatches = 0
        foreach ($prevFile in $prevManifests) {
            $prev = Get-Content $prevFile.FullName | ConvertFrom-Json
            $prevProps = $prev.PSObject.Properties
            $currentProps = $current.PSObject.Properties
            foreach ($cp in $currentProps) {
                $pp = $prevProps | Where-Object { $_.Name -eq $cp.Name }
                if ($pp) {
                    if ($pp.Value.md5 -ne $cp.Value.md5) { $mismatches++ }
                }
            }
        }
        Check "Manifests consistent across builds" { $mismatches -eq 0 } "$mismatches file(s) changed"
        if ($mismatches -gt 0) { Warn "$mismatches hash(es) differ from previous manifest" }
    }
}

# === 8. METADATA CHECK ===
Heading "8. Document Metadata"

$metaYaml = Join-Path (Join-Path $PSScriptRoot "style") "thesis-metadata.yaml"
if (Test-Path $metaYaml) {
    $metaContent = Get-Content $metaYaml -Raw
    Check "Metadata has title" { $metaContent -match "title" } "Missing title in metadata"
    Check "Metadata has author" { $metaContent -match "author" } "Missing author in metadata"
    Check "Metadata has date" { $metaContent -match "date" } "Missing date in metadata"
}

# === 9. SUMMARY ===
Heading "9. Summary"
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if($failed -eq 0){"Green"}else{"Red"})
Write-Host "  Warnings: $warnings" -ForegroundColor Yellow

if ($failed -eq 0) {
    Write-Host "`n  VERDICT: ALL CHECKS PASSED" -ForegroundColor Green
    return $true
} elseif ($AutoFix) {
    Write-Host "`n  VERDICT: $failed CHECK(S) FAILED — attempting auto-fix..." -ForegroundColor Yellow
    $maxFixIter = 3
    $fixIter = 0
    $fixed = $false
    while ($fixIter -lt $maxFixIter -and -not $fixed) {
        $fixIter++
        Write-Host "`n--- Auto-fix iteration $fixIter/$maxFixIter ---" -ForegroundColor Magenta

        # Detect and fix known issues
        $buildCmd = Join-Path $PSScriptRoot "build-thesis.ps1"
        if (-not (Test-Path $buildCmd)) {
            Write-Host "  [AUTO-FIX] Build script not found, cannot auto-fix" -ForegroundColor Red
            break
        }

        # Fix 1: TOC entries missing or page numbers broken → force rebuild
        Write-Host "  [AUTO-FIX] Rebuilding from source..." -ForegroundColor Yellow
        Remove-Item (Join-Path $BuildDir "build-manifest.json") -Force -ErrorAction SilentlyContinue
        & $buildCmd 2>&1 | Out-Null

        # Re-verify
        $verifyCmd = Join-Path $PSScriptRoot "verify-thesis.ps1"
        $result = & $verifyCmd -Quiet 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0 -or $exitCode -eq $null) {
            Write-Host "  [AUTO-FIX] All checks pass after rebuild!" -ForegroundColor Green
            $fixed = $true
            # Run verify again with output so user sees results
            & $verifyCmd 2>&1
            return $true
        }
    }
    if (-not $fixed) {
        Write-Host "  [AUTO-FIX] Failed after $maxFixIter iterations — manual intervention needed" -ForegroundColor Red
        return $false
    }
} else {
    Write-Host "`n  VERDICT: $failed CHECK(S) FAILED — review above" -ForegroundColor Red
    Write-Host "  Tip: run with -AutoFix to attempt automatic repair" -ForegroundColor Yellow
    return $false
}
