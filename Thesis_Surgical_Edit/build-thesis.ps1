# Academix v13.2 — Thesis Build Pipeline
# Converts Markdown → DOCX → PDF with proper Arabic formatting
# Usage: .\build-thesis.ps1 [-SourceMD] [-OutputName]

param(
    [string]$SourceMD = "Final_Thesis_Academix_v13_2_FIXED.md",
    [string]$OutputName = "Memoire_Academix_v13_2_Final"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$style = Join-Path $root "style"
$outDir = Join-Path $root "output"

Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Academix v13.2 — Thesis Build Pipeline     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# Step 1: Generate reference.docx if missing
$refDocx = Join-Path $style "reference.docx"
$refIn = Join-Path $style "reference-in.docx"
if (-not (Test-Path $refDocx)) {
    Write-Host "[1/5] Generating reference template..." -ForegroundColor Yellow
    if (-not (Test-Path $refIn)) {
        pandoc -o $refIn --print-default-data-file reference.docx
    }
    python (Join-Path $style "customize-reference.py")
    if (-not (Test-Path $refDocx)) {
        Write-Host "[ERROR] reference.docx not created" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[1/5] Reference template ready" -ForegroundColor Green
}

# Step 2: Build DOCX directly (pass metadata via CLI, avoid YAML in MD body)
$sourcePath = Join-Path $root $SourceMD
if (-not (Test-Path $sourcePath)) {
    Write-Host "[ERROR] Source not found: $sourcePath" -ForegroundColor Red
    exit 1
}
$metaFile = Join-Path $style "thesis-metadata.yaml"

Write-Host "[2/5] Loading metadata..." -ForegroundColor Yellow
$meta = Get-Content $metaFile -Raw
$metaFlags = @()
foreach ($line in ($meta -split "`n")) {
    if ($line -match '^(\w+):\s*(.+)$') {
        $key = $matches[1]
        $val = $matches[2].Trim().Trim('"', "'")
        if ($val -ne "..." -and $key -notin @("dir","lang","documentclass")) {
            $metaFlags += "--metadata"; $metaFlags += "$key=$val"
        }
    }
}

# Step 3: Generate DOCX
$docx = Join-Path $outDir "$OutputName.docx"
Write-Host "[3/5] Generating DOCX..." -ForegroundColor Yellow
$pandocArgs = @(
    $sourcePath,
    "--from", "markdown+raw_html+grid_tables-yaml_metadata_block",
    "--to", "docx",
    "--reference-doc", $refDocx,
    "--output", $docx,
    "--metadata", "dir=rtl",
    "--resource-path", "$root\images;$root",
    "--wrap", "preserve",
    "--eol", "lf"
) + $metaFlags
try {
    & pandoc $pandocArgs 2>&1
    $size = (Get-Item $docx).Length
    Write-Host "  DOCX: $([math]::Round($size/1KB)) KB — $docx" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Pandoc failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Generate PDF via Word (win32com)
$pdf = Join-Path $outDir "$OutputName.pdf"
Write-Host "[4/5] Generating PDF via Word..." -ForegroundColor Yellow
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $wdDoc = $word.Documents.Open((Resolve-Path $docx).Path)
    $wdDoc.SaveAs2((Resolve-Path $outDir).Path + "\$OutputName.pdf", 17)  # 17 = wdFormatPDF
    $wdDoc.Close()
    $word.Quit()
    $size = (Get-Item $pdf).Length
    Write-Host "  PDF: $([math]::Round($size/1KB)) KB — $pdf" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] PDF via Word failed: $_" -ForegroundColor Yellow
    Write-Host "  Open $docx in Word and save as PDF manually." -ForegroundColor Yellow
}

# Step 5: Done
Write-Host "[5/5] Complete" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Green
Write-Host "DOCX: $docx" -ForegroundColor Cyan
if (Test-Path $pdf) { Write-Host "PDF:  $pdf" -ForegroundColor Cyan }
Write-Host ""
Write-Host "To customize styles, edit: $refDocx" -ForegroundColor Gray
Write-Host "  Open in Word → Modify styles → Save" -ForegroundColor Gray
