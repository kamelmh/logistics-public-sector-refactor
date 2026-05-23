<#
.SYNOPSIS
  Build the English Research Paper DOCX from markdown via pandoc.
.DESCRIPTION
  Phase B pipeline: converts English_Research_Paper.md to a submission-ready
  DOCX formatted for IEEE/CIIA-style journal submission.
#>

$script:projectRoot = Split-Path -Parent $PSScriptRoot
$paperMd = Join-Path $script:projectRoot "Thesis_Surgical_Edit\English_Research_Paper.md"
$outDir = Join-Path $script:projectRoot "Research_and_Development\Thesis_Surgical_Edit\output"
$outDocx = Join-Path $outDir "English_Research_Paper_IEEE.docx"
$refDocx = Join-Path $script:projectRoot "Thesis_Surgical_Edit\style\english-paper-ref.docx"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host "=== Phase B: Build English Research Paper ===" -ForegroundColor Cyan
Write-Host "Source: $paperMd"
Write-Host "Output: $outDocx"

# Pandoc conversion with IEEE-style reference
pandoc $paperMd `
  --from markdown `
  --to docx `
  --reference-doc=$refDocx `
  --metadata title="Offline-First DSS for Inventory Optimization" `
  --metadata author="Mahi Kamel Abdelghani" `
  --output $outDocx

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $outDocx).Length
    Write-Host "SUCCESS: DOCX created ($([math]::Round($size/1024)) KB)" -ForegroundColor Green
    Write-Host "Path: $outDocx"
# Run metrics
& python C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\style\measure-thesis.py $outDocx $paperMd
} else {
    Write-Host "FAILED: pandoc exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
