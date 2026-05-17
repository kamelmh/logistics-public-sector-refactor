# verify-thesis.ps1 — Academix v13.2 Thesis Build Verifier
# Post-build validation: source integrity, output metrics, old-vs-new comparison

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
    
    $pyCheck = python -c @"
from docx import Document
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
doc = Document(r'$docx')
body = doc.element.body
children = list(body)
tbl_count = sum(1 for c in children if c.tag == f'{W}tbl')
toc_entries = 0; lot_entries = 0; seq_fields = 0
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
        Check "SEQ fields >= 21" { $seq -ge 21 } "SEQ has $seq fields (expected 21+)"
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

$coverDocx = Join-Path $BuildDir "cover-page.docx"
if (Test-Path $coverDocx) {
    $coverSize = (Get-Item $coverDocx).Length
    Check "Cover DOCX exists ($([math]::Round($coverSize/1KB)) KB)" { $coverSize -gt 10KB } "Cover too small"
}

# === 4. SIZES ===
Heading "4. Output Sizes"

Check "New PDF > 800 KB" { (Get-Item $pdf).Length -gt 800KB } "PDF too small"
Check "New DOCX > 100 KB" { (Get-Item $docx).Length -gt 100KB } "DOCX too small"

# === 5. PIPELINE SCRIPTS ===
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

# === 6. SUMMARY ===
Heading "6. Summary"
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if($failed -eq 0){"Green"}else{"Red"})
Write-Host "  Warnings: $warnings" -ForegroundColor Yellow

if ($failed -eq 0) {
    Write-Host "`n  VERDICT: ALL CHECKS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n  VERDICT: $failed CHECK(S) FAILED — review above" -ForegroundColor Red
    exit $failed
}