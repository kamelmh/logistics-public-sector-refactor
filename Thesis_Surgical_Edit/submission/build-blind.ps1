<#
.SYNOPSIS
  Build double-blind version of the English paper for ISIA 2026 submission.
.DESCRIPTION
  Strips author info from MD, builds DOCX + PDF in double-blind format.
  Output: Thesis_Surgical_Edit/output/
#>

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outDir = Join-Path $projectRoot "Thesis_Surgical_Edit\output"

Write-Host "=== ISIA 2026 — Double-Blind Build ===" -ForegroundColor Cyan

# Step 1: Build double-blind DOCX
Write-Host "[1/2] Building double-blind DOCX..." -ForegroundColor Yellow
& (Join-Path $projectRoot "Thesis_Surgical_Edit\build-english-paper.ps1") -DoubleBlind -OutputName "English_Research_Paper_Blind.docx"
if ($LASTEXITCODE -ne 0) { Write-Error "DOCX build failed"; exit 1 }

# Step 2: Build double-blind PDF via pandoc + xelatex
Write-Host "[2/2] Building double-blind PDF..." -ForegroundColor Yellow
$mdPath = Join-Path $projectRoot "Thesis_Surgical_Edit\English_Research_Paper.md"
$blindMd = Join-Path $env:TEMP "english-paper-blind.md"
$outPdf = Join-Path $outDir "English_Research_Paper_Blind.pdf"

# Strip author lines
Get-Content $mdPath | Where-Object {
    $_ -notmatch '^Mahi Kamel Abdelghani$' -and
    $_ -notmatch '^National Specialized Institute' -and
    $_ -notmatch '^mahi\.kamel@'
} | Set-Content $blindMd -Encoding utf8

# Check for pandoc + xelatex
$pandocCmd = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandocCmd) { Write-Error "Pandoc not found"; exit 1 }

& pandoc $blindMd --from markdown --to pdf --pdf-engine=xelatex -o $outPdf

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $outPdf).Length
    Write-Host "SUCCESS: PDF created ($([math]::Round($size/1024)) KB)" -ForegroundColor Green
    Write-Host "Path: $outPdf"
} else {
    Write-Host "PDF build failed (xelatex may not be installed) — PDF must be generated another way" -ForegroundColor Yellow
}

# Cleanup
if (Test-Path $blindMd) { Remove-Item $blindMd -Force }

Write-Host ""
Write-Host "=== Double-blind build complete ===" -ForegroundColor Cyan
Write-Host "DOCX: $(Join-Path $outDir 'English_Research_Paper_Blind.docx')"
Write-Host "PDF:  $(Join-Path $outDir 'English_Research_Paper_Blind.pdf')"
Write-Host ""
Write-Host "Submission deadline: May 31, 2026 (5 days)" -ForegroundColor Yellow
Write-Host "EasyChair link: https://easychair.org/cfp/ISIA2026"
