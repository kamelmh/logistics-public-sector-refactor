<#
.SYNOPSIS
  Build IEEE double-column PDF for CCA'2026 submission.
.DESCRIPTION
  Converts English paper MD to IEEE LaTeX format, builds blind version.
  Output: Thesis_Surgical_Edit/output/English_Research_Paper_CCA2026.pdf
#>

$projectRoot = Split-Path -Parent $PSScriptRoot
$mdPath = Join-Path $projectRoot "Thesis_Surgical_Edit\English_Research_Paper.md"
$outDir = Join-Path $projectRoot "Thesis_Surgical_Edit\output"
$latexDir = Join-Path $projectRoot "Thesis_Surgical_Edit\latex"

Write-Host "=== CCA'2026 - IEEE Double-Column Build ===" -ForegroundColor Cyan

# Step 1: Create blind version (strip author info)
Write-Host "[1/4] Creating blind version..." -ForegroundColor Yellow
$blindMd = Join-Path $latexDir "paper-blind.md"
$lines = Get-Content $mdPath -Encoding UTF8
$blindLines = @()
$skipSection = $false
foreach ($line in $lines) {
    if ($line -match '^Mahi Kamel Abdelghani$') { continue }
    if ($line -match '^National Specialized Institute') { continue }
    if ($line -match '^mahi\.kamel@') { continue }
    if ($line -match '^\*\*Keywords:\*\*') { continue }
    if ($line -match '^## AI Disclosure') { $skipSection = $true; continue }
    if ($skipSection -and $line -match '^##') { $skipSection = $false }
    if ($skipSection) { continue }
    $blindLines += $line
}
$blindLines | Set-Content $blindMd -Encoding UTF8
Write-Host "  Blind MD: $($blindLines.Count) lines"

# Step 2: Convert to LaTeX body with pandoc
Write-Host "[2/4] Converting to IEEE LaTeX..." -ForegroundColor Yellow
$bodyTex = Join-Path $latexDir "body.tex"
& pandoc $blindMd --from markdown --to latex --wrap=auto -o $bodyTex
if ($LASTEXITCODE -ne 0) { Write-Error "Pandoc body conversion failed"; exit 1 }

$bodyContent = Get-Content $bodyTex -Raw -Encoding UTF8

# Extract metadata
$allText = $blindLines -join "`n"
$titleMatch = [regex]::Match($allText, "^#\s+(.+)$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
$title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { "Untitled" }

$abstractMatch = [regex]::Match($allText, "##\s+Abstract\s*\n\s*\n(.+?)(?=\n\s*\n)", [System.Text.RegularExpressions.RegexOptions]::Singleline)
$abstract = if ($abstractMatch.Success) { $abstractMatch.Groups[1].Value.Trim() } else { "" }

$kwMatch = [regex]::Match($allText, "\*\*Keywords:\*\*\s*(.+)")
$keywords = if ($kwMatch.Success) { $kwMatch.Groups[1].Value.Trim() } else { "" }

Write-Host "  Title: $title"
Write-Host "  Abstract: $($abstract.Length) chars"

# Build LaTeX document parts
$latexPreamble = @()
$latexPreamble += "\documentclass[conference]{IEEEtran}"
$latexPreamble += "\usepackage{amsmath,amssymb,amsfonts}"
$latexPreamble += "\usepackage{graphicx}"
$latexPreamble += "\usepackage{textcomp}"
$latexPreamble += "\usepackage{xcolor}"
$latexPreamble += "\usepackage{booktabs}"
$latexPreamble += "\usepackage{hyperref}"
$latexPreamble += "\usepackage[utf8]{inputenc}"
$latexPreamble += "\usepackage[T1]{fontenc}"
$latexPreamble += ""
$latexPreamble += "\hypersetup{"
$latexPreamble += "    colorlinks=true,"
$latexPreamble += "    linkcolor=blue,"
$latexPreamble += "    citecolor=blue,"
$latexPreamble += "    urlcolor=blue"
$latexPreamble += "}"
$latexPreamble += ""
$latexPreamble += "\begin{document}"
$latexPreamble += ""
$latexPreamble += "\title{$title}"
$latexPreamble += ""
$latexPreamble += "\author{"
$latexPreamble += "\IEEEauthorblockN{Anonymous Author}"
$latexPreamble += "\IEEEauthorblockA{Anonymous Institution\\"
$latexPreamble += "Anonymous Email}"
$latexPreamble += "}"
$latexPreamble += ""
$latexPreamble += "\maketitle"
$latexPreamble += ""
$latexPreamble += "\begin{abstract}"
$latexPreamble += $abstract
$latexPreamble += "\end{abstract}"
$latexPreamble += ""
$latexPreamble += "\begin{IEEEkeywords}"
$latexPreamble += $keywords
$latexPreamble += "\end{IEEEkeywords}"
$latexPreamble += ""

$latexEnd = @()
$latexEnd += ""
$latexEnd += "\bibliographystyle{IEEEtran}"
$latexEnd += ""
$latexEnd += "\end{document}"

$fullTex = ($latexPreamble -join "`n") + "`n" + $bodyContent + "`n" + ($latexEnd -join "`n")
$fullTexPath = Join-Path $latexDir "paper-full.tex"
$fullTex | Set-Content $fullTexPath -Encoding UTF8
Write-Host "  LaTeX: $($fullTex.Length) chars"

# Step 3: Compile to PDF
Write-Host "[3/4] Compiling PDF..." -ForegroundColor Yellow
Push-Location $latexDir
& pdflatex -interaction=nonstopmode "paper-full.tex" 2>&1 | Out-Null
& pdflatex -interaction=nonstopmode "paper-full.tex" 2>&1 | Out-Null
Pop-Location

$pdfPath = Join-Path $latexDir "paper-full.pdf"
if (Test-Path $pdfPath) {
    $size = (Get-Item $pdfPath).Length
    Write-Host "  PDF: $([math]::Round($size/1024)) KB" -ForegroundColor Green
    $outPdf = Join-Path $outDir "English_Research_Paper_CCA2026.pdf"
    Copy-Item $pdfPath $outPdf -Force
    Write-Host "  Output: $outPdf"
} else {
    Write-Error "PDF compilation failed"
    exit 1
}

# Step 4: Build DOCX
Write-Host "[4/4] Building DOCX..." -ForegroundColor Yellow
$outDocx = Join-Path $outDir "English_Research_Paper_CCA2026.docx"
& pandoc $blindMd --from markdown --to docx -o $outDocx
if ($LASTEXITCODE -eq 0) {
    $docxSize = (Get-Item $outDocx).Length
    Write-Host "  DOCX: $([math]::Round($docxSize/1024)) KB" -ForegroundColor Green
}

# Cleanup
Remove-Item $blindMd -Force -ErrorAction SilentlyContinue
Remove-Item $bodyTex -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== CCA'2026 Build Complete ===" -ForegroundColor Cyan
Write-Host "PDF: $outPdf"
Write-Host "DOCX: $outDocx"
Write-Host "Deadline: August 15, 2026" -ForegroundColor Yellow
Write-Host "Submit: https://cmt3.research.microsoft.com/CCA2026/" -ForegroundColor Yellow
