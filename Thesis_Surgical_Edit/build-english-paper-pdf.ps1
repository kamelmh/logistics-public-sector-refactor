<#
.SYNOPSIS
  Build the English Research Paper as a submission-ready PDF via pandoc + xelatex.
.DESCRIPTION
  Phase C submission pipeline: generates an IEEE-format PDF suitable for
  ISIA 2026 / similar Algerian computer science conferences.
#>

$script:projectRoot = Split-Path -Parent $PSScriptRoot
$paperMd = Join-Path $script:projectRoot "Thesis_Surgical_Edit\English_Research_Paper.md"
$outDir = Join-Path $PSScriptRoot "output"
$outPdf = Join-Path $outDir "English_Research_Paper_IEEE.pdf"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host "=== Phase C: Build PDF for Journal Submission ===" -ForegroundColor Cyan
Write-Host "Source: $paperMd"
Write-Host "Output: $outPdf"

# Generate PDF via pandoc + xelatex (single-column for review phase)
pandoc $paperMd `
  --from markdown `
  --to pdf `
  --pdf-engine=xelatex `
  -V fontsize=11pt `
  -V papersize=a4 `
  -V geometry:margin=2.5cm `
  -V linestretch=1.0 `
  --metadata title="Offline-First DSS for Inventory Optimization" `
  --metadata author="Mahi Kamel Abdelghani" `
  --output $outPdf 2>&1 | Select-String -NotMatch "security risk|major issue"

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $outPdf).Length
    Write-Host "SUCCESS: PDF created ($([math]::Round($size/1024)) KB)" -ForegroundColor Green
    
    # Count pages via pdftotext
    try {
        $pageCount = python -c "
import subprocess
r = subprocess.run(['pdftotext', r'$outPdf', '-'], capture_output=True, text=True, timeout=15)
pages = r.stdout.count(chr(12)) + 1 if r.stdout else 0
print(pages)
" 2>$null
        if ($pageCount -and $pageCount -gt 0) { Write-Host "Pages: $pageCount" }
    } catch { }
    
    Write-Host "Path: $outPdf"
} else {
    Write-Host "FAILED: pandoc exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
