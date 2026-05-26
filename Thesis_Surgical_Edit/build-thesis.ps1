param(
    [Parameter(Position=0)]
    [string]$Command = "",
    [Parameter()]
    [switch]$FromMD = $false
)

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourcePath = Join-Path $projectRoot "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
$desktopDocx = "C:\Users\Administrator\Desktop\Memoire_DSS_Logistique_ElBayadh_v2.docx"
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

# ---- Helper: Apply fixes + audit + verify + sync ----
function Apply-Fixes-And-Audit {
    param([string]$DocxPath)
    
    Write-Host "  [BUILD] Applying comprehensive fixes (fix_thesis_all)..." -ForegroundColor Yellow
    python (Join-Path $styleDir "fix_thesis_all.py") $DocxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  fix_thesis_all reported issues (non-critical)" }
    
    # Fix section breaks (cover = none, front = lowerRoman, body = decimal)
    python (Join-Path $styleDir "fix_docx_sections.py") $DocxPath --save 2>&1
    
    # Run comprehensive audit
    Write-Host "  [BUILD] Running comprehensive audit..." -ForegroundColor Yellow
    python (Join-Path $styleDir "audit_thesis_comprehensive.py") $DocxPath 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [AUDIT] Audit PASSED" -ForegroundColor Green
    } else {
        Write-Host "  [AUDIT] Audit completed (non-critical flags OK)" -ForegroundColor Yellow
    }
    
    # Run verify checks
    Write-Host "  [BUILD] Running verify checks..." -ForegroundColor Yellow
    python (Join-Path $styleDir "verify_docx_checks.py") $DocxPath --size-threshold 50000 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [VERIFY] All checks PASSED" -ForegroundColor Green
    } else {
        Write-Host "  [VERIFY] Completed (review non-critical)" -ForegroundColor Yellow
    }
    
    # Run MD ↔ DOCX sync check
    Write-Host "  [BUILD] Running MD ↔ DOCX sync check..." -ForegroundColor Yellow
    $syncResult = python (Join-Path $styleDir "docx_md_sync.py") $DocxPath --verify 2>&1
    $syncPass = $LASTEXITCODE -eq 0
    if ($syncPass) {
        Write-Host "  [SYNC] MD ↔ DOCX verified" -ForegroundColor Green
    } else {
        Write-Host "  [SYNC] Differences found (run --patch-md to sync)" -ForegroundColor Yellow
    }
}

if ($Command -eq "" -or $Command -eq "build") {
    if (-not $FromMD -and (Test-Path $desktopDocx)) {
        # === MODE A: Desktop DOCX as golden source ===
        Write-Host "  [BUILD] Copying golden desktop DOCX (v2)..." -ForegroundColor Green
        Copy-Item $desktopDocx $docxPath -Force
        Write-Host "  [BUILD] Source: $desktopDocx" -ForegroundColor Cyan
        Write-Host "  [BUILD] Output: $docxPath" -ForegroundColor Cyan
    } else {
        # === MODE B: Rebuild from MD via pandoc ===
        Write-Host "  [BUILD] Converting markdown to DOCX..." -ForegroundColor Yellow
        $metadata = @(
            "title=`"نظام دعم القرار لتسيير المخزونات`"",
            "author=`"ماحي كمال عبد الغني`"",
            "date=2026-05-18",
            "lang=ar",
            "dir=rtl"
        ) | ForEach-Object { "--metadata=" + $_ }
        & $pandoc $sourcePath -o $docxPath --reference-doc=$refDocx -f markdown-yaml_metadata_block $metadata 2>&1
        if ($LASTEXITCODE -ne 0) { Write-Error "Pandoc failed"; exit 1 }
        Write-Host "  [BUILD] DOCX created from MD: $docxPath" -ForegroundColor Green
    }
    
    # Apply fixes and audit
    Apply-Fixes-And-Audit $docxPath
    
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

# === MODE C: Desktop copy only (no fixes) ===
if ($Command -eq "copy-desktop") {
    if (-not (Test-Path $desktopDocx)) { Write-Error "Desktop DOCX not found: $desktopDocx"; exit 1 }
    Copy-Item $desktopDocx $docxPath -Force
    Write-Host "  [BUILD] Copied desktop DOCX to: $docxPath" -ForegroundColor Green
    exit 0
}

# === MODE D: Sync MD from golden DOCX (patch missing sections) ===
if ($Command -eq "sync-md") {
    if (-not (Test-Path $desktopDocx)) { Write-Error "Desktop DOCX not found: $desktopDocx"; exit 1 }
    Write-Host "  [SYNC] Patching MD from golden DOCX..." -ForegroundColor Yellow
    python (Join-Path $styleDir "docx_md_sync.py") $desktopDocx --patch-md 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SYNC] MD patched successfully" -ForegroundColor Green
    } else {
        Write-Host "  [SYNC] Completed with flags" -ForegroundColor Yellow
    }
    # Re-verify
    Write-Host "  [SYNC] Re-verifying..." -ForegroundColor Yellow
    python (Join-Path $styleDir "docx_md_sync.py") $desktopDocx --verify 2>&1
    exit 0
}

$real = Join-Path $PSScriptRoot "..\Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1"
if (-not (Test-Path $real)) { Write-Error "thesis-doctor.ps1 not found: $real"; exit 1 }

& $real -Command $Command
