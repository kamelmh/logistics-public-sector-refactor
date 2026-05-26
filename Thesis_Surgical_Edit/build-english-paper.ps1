<#
.SYNOPSIS
  Build the English Research Paper DOCX from markdown via pandoc.
.DESCRIPTION
  Phase B pipeline: converts English_Research_Paper.md to a submission-ready
  DOCX formatted for IEEE/CIIA-style journal submission.

.PARAMETER DoubleBlind
  If set, strips author name/affiliation from the manuscript for double-blind review.
.PARAMETER OutputName
  Output filename (default: English_Research_Paper_IEEE.docx).
#>

param(
    [Parameter()]
    [switch]$DoubleBlind = $false,
    [Parameter()]
    [string]$OutputName = "English_Research_Paper_IEEE.docx"
)

$script:projectRoot = Split-Path -Parent $PSScriptRoot
$paperMd = Join-Path $script:projectRoot "Thesis_Surgical_Edit\English_Research_Paper.md"
$outDir = Join-Path $script:projectRoot "Research_and_Development\Thesis_Surgical_Edit\output"
$outDocx = Join-Path $outDir $OutputName
$refDocx = Join-Path $script:projectRoot "Thesis_Surgical_Edit\style\english-paper-ref.docx"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host "=== Build English Research Paper ===" -ForegroundColor Cyan
Write-Host "Source: $paperMd"
Write-Host "Output: $outDocx"
if ($DoubleBlind) { Write-Host "Mode: DOUBLE-BLIND (author info stripped)" -ForegroundColor Yellow }

# Prepare source: strip author lines for double-blind
$sourceMd = $paperMd
if ($DoubleBlind) {
    $blindMd = Join-Path $env:TEMP "english-paper-blind.md"
    Get-Content $paperMd | Where-Object {
        $_ -notmatch '^Mahi Kamel Abdelghani$' -and
        $_ -notmatch '^National Specialized Institute' -and
        $_ -notmatch '^mahi\.kamel@'
    } | Set-Content $blindMd -Encoding utf8
    $sourceMd = $blindMd
    Write-Host "  Author info stripped for double-blind review" -ForegroundColor Gray
}

# Pandoc conversion with IEEE-style reference
$pandocArgs = @(
    $sourceMd,
    "--from", "markdown",
    "--to", "docx",
    "--reference-doc=$refDocx",
    "--metadata", "title=Offline-First DSS for Inventory Optimization",
    "--output", $outDocx
)
if (-not $DoubleBlind) {
    $pandocArgs += "--metadata", "author=Mahi Kamel Abdelghani"
}
& pandoc $pandocArgs

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $outDocx).Length
    Write-Host "SUCCESS: DOCX created ($([math]::Round($size/1024)) KB)" -ForegroundColor Green
    Write-Host "Path: $outDocx"
} else {
    Write-Host "FAILED: pandoc exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

# Cleanup temp file
if ($DoubleBlind -and (Test-Path $blindMd)) { Remove-Item $blindMd -Force }
