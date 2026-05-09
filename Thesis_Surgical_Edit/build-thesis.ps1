# Academix v13.2 -- Thesis Build Pipeline
# Converts Markdown -> DOCX -> PDF with user's original formatting
# Usage: .\build-thesis.ps1 [-SourceMD] [-OutputName]

param(
    [string]$SourceMD = "Final_Thesis_Academix_v13_2_FIXED.md",
    [string]$OutputName = "Memoire_Academix_v13_2_Final"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$style = Join-Path $root "style"
$outDir = Join-Path $root "output"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Academix v13.2 -- Thesis Build Pipeline   " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# Step 1: Generate reference.docx from user's original DOCX
$refDocx = Join-Path $style "reference.docx"
$refIn = Join-Path $style "reference-in.docx"

Write-Host "[1/6] Generating reference template from user's original DOCX..." -ForegroundColor Yellow
if (-not (Test-Path $refIn)) {
    & pandoc -o $refIn --print-default-data-file reference.docx 2>&1
}
python (Join-Path $style "customize-reference.py") 2>&1
if (-not (Test-Path $refDocx)) {
    Write-Host "[ERROR] reference.docx not created" -ForegroundColor Red
    exit 1
}

# Step 2: Build DOCX with pandoc
$sourcePath = Join-Path $root $SourceMD
if (-not (Test-Path $sourcePath)) {
    Write-Host "[ERROR] Source not found: $sourcePath" -ForegroundColor Red
    exit 1
}

$docx = Join-Path $outDir "$OutputName.docx"
Write-Host "[2/6] Generating DOCX..." -ForegroundColor Yellow

$pandocArgs = @(
    $sourcePath,
    "--from", "markdown+grid_tables-yaml_metadata_block",
    "--to", "docx",
    "--reference-doc", $refDocx,
    "--output", $docx,
    "--metadata", "dir=rtl",
    "--resource-path", "$root\images;$root",
    "--wrap", "preserve",
    "--eol", "lf"
)

try {
    & pandoc $pandocArgs 2>&1
    $size = (Get-Item $docx).Length
    Write-Host "  DOCX: $([math]::Round($size/1KB)) KB" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Pandoc failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Post-process tables (header coloring, alternating rows)
Write-Host "[3/6] Formatting tables with user's color scheme..." -ForegroundColor Yellow
try {
    python (Join-Path $style "format-tables.py") $docx 2>&1
    Write-Host "  Tables formatted: #0C447C headers, #EBF5FB alternating rows" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Table formatting failed: $_" -ForegroundColor Yellow
}

# Step 4: Format cover page with professional styling
Write-Host "[4/7] Formatting cover page..." -ForegroundColor Yellow
try {
    python (Join-Path $style "format-cover.py") $docx 2>&1
    Write-Host "  Cover formatted with reference DOCX design" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Cover formatting failed: $_" -ForegroundColor Yellow
}

# Step 5: Generate PDF via Word
$pdf = Join-Path $outDir "$OutputName.pdf"
Write-Host "[5/7] Generating PDF via Word..." -ForegroundColor Yellow
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $wdDoc = $word.Documents.Open((Resolve-Path $docx).Path)
    $wdDoc.SaveAs2((Resolve-Path $outDir).Path + "\$OutputName.pdf", 17)
    $wdDoc.Close()
    $word.Quit()
    $size = (Get-Item $pdf).Length
    Write-Host "  PDF: $([math]::Round($size/1KB)) KB" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] PDF via Word failed: $_" -ForegroundColor Yellow
    Write-Host "  Open $docx in Word and save as PDF manually." -ForegroundColor Yellow
}

# Step 6: Verify output
Write-Host "[6/7] Verifying..." -ForegroundColor Yellow
if (Test-Path $docx) {
    Write-Host "  DOCX OK: $([math]::Round((Get-Item $docx).Length/1KB)) KB" -ForegroundColor Green
}
if (Test-Path $pdf) {
    Write-Host "  PDF OK: $([math]::Round((Get-Item $pdf).Length/1KB)) KB" -ForegroundColor Green
}

# Step 7: Done
Write-Host "[7/7] Complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Green
Write-Host "DOCX: $docx" -ForegroundColor Cyan
if (Test-Path $pdf) { Write-Host "PDF:  $pdf" -ForegroundColor Cyan }
Write-Host ""
Write-Host "Design notes (from reference DOCX):" -ForegroundColor Gray
Write-Host "- Font: Traditional Arabic 14pt (docDefaults from user's original)" -ForegroundColor Gray
Write-Host "- Headings: #1B2631 22pt (H1), #0C447C 18pt (H2), #0C447C 16pt (H3)" -ForegroundColor Gray
Write-Host "- Cover: #1A1A1A titles, #1F6B2E English title (Times New Roman), #806000 date" -ForegroundColor Gray
Write-Host "- Tables: #0C447C header fill, white bold text, #EBF5FB alternating rows" -ForegroundColor Gray
Write-Host "- Page: A4, 4cm margins, RTL, 1.5 line spacing" -ForegroundColor Gray
