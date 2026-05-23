param(
    [Parameter(Position=0)]
    [string]$Command = ""
)

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourcePath = Join-Path $projectRoot "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
$styleDir = Join-Path $PSScriptRoot "style"
$refDocx = Join-Path $styleDir "reference.docx"
$outDir = Join-Path $projectRoot "Research_and_Development\Thesis_Surgical_Edit\output"
$null = New-Item -ItemType Directory -Path $outDir -Force
$docxPath = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"

$pandoc = "C:\Users\ADMINISTRATOR\AppData\Local\Pandoc\pandoc.exe"
if (-not (Test-Path $pandoc)) {
    $pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if (-not $pandoc) { Write-Error "Pandoc not found"; exit 1 }
}

if ($Command -eq "" -or $Command -eq "build") {
    Write-Host "  [BUILD] Converting markdown to DOCX..." -ForegroundColor Yellow
    # Disable yaml_metadata_block to prevent body ---/... from confusing YAML parser
    # Pass metadata via CLI flags extracted from the source
    $metadata = @(
        "title=`"نظام دعم القرار لتسيير المخزونات`"",
        "author=`"ماحي كمال عبد الغني`"",
        "date=2026-05-18",
        "lang=ar",
        "dir=rtl"
    ) | ForEach-Object { "--metadata=" + $_ }
    & $pandoc $sourcePath -o $docxPath --reference-doc=$refDocx -f markdown-yaml_metadata_block $metadata 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Pandoc failed"; exit 1 }
    Write-Host "  [BUILD] DOCX created: $docxPath" -ForegroundColor Green

    Write-Host "  [BUILD] Applying Python fixes..." -ForegroundColor Yellow
    python (Join-Path $styleDir "fix_docx_formatting.py") $docxPath --save 2>&1
    python (Join-Path $styleDir "fix_docx_sections.py") $docxPath --save 2>&1
    python (Join-Path $styleDir "fix_docx_remaining.py") $docxPath --save 2>&1
    Write-Host "  [BUILD] Build complete." -ForegroundColor Green
    exit 0
}

if ($Command -eq "pandoc-only") {
    $metadata = @(
        "title=`"نظام دعم القرار لتسيير المخزونات`"",
        "author=`"ماحي كمال عبد الغني`"",
        "date=2026-05-18",
        "lang=ar",
        "dir=rtl"
    ) | ForEach-Object { "--metadata=" + $_ }
    & $pandoc $sourcePath -o $docxPath --reference-doc=$refDocx -f markdown-yaml_metadata_block $metadata 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Pandoc failed"; exit 1 }
    Write-Host "  [BUILD] Pandoc conversion only: $docxPath" -ForegroundColor Green
    exit 0
}

$real = Join-Path $PSScriptRoot "..\Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1"
if (-not (Test-Path $real)) { Write-Error "thesis-doctor.ps1 not found: $real"; exit 1 }

& $real -Command $Command
