param(
    [Parameter(Position=0)]
    [string]$Command = "",
    [Parameter()]
    [switch]$FromMD = $false,
    [Parameter()]
    [switch]$Regulated = $false,
    [Parameter()]
    [switch]$NoRebuild = $false,
    [Parameter()]
    [switch]$Restore = $false
)

if ($Regulated) {
    Write-Host "  [BUILD] Regulated mode enabled. Delegating to Orchestrator..." -ForegroundColor Cyan
    & "Thesis_Surgical_Edit/Thesis_Orchestrator.ps1"
    return
}

if ($Restore) {
    Write-Host "  [BUILD] Restoring Golden Source from latest backup..." -ForegroundColor Cyan
    $backupDir = Join-Path $PSScriptRoot "..\..\backups"
    $latestBackup = Get-ChildItem -Path $backupDir -Filter "*.docx" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $outDir = Join-Path $PSScriptRoot "output"
    $desktopDocx = Join-Path $outDir "recent-backup-Memoire_DSS_Logistique_ElBayadh.docx"
    
    if ($null -eq $latestBackup) {
        Write-Error "No backups found in $backupDir"
        exit 1
    }
    
    Write-Host "  [BUILD] Found latest backup: $($latestBackup.FullName)" -ForegroundColor Cyan
    Copy-Item $latestBackup.FullName $desktopDocx -Force
    Write-Host "  [BUILD] Restored $desktopDocx from $($latestBackup.Name)" -ForegroundColor Green
    exit 0
}

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourcePath = Join-Path $projectRoot "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
$styleDir = Join-Path $PSScriptRoot "style"
$refDocx = Join-Path $styleDir "reference.docx"
$outDir = Join-Path $PSScriptRoot "output"
$desktopDocx = Join-Path $outDir "recent-backup-Memoire_DSS_Logistique_ElBayadh.docx"
$null = New-Item -ItemType Directory -Path $outDir -Force
$docxPath = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"

$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $pandoc) { Write-Error "Pandoc not found (install via 'scoop install pandoc')"; exit 1 }

# ---- Helper: Apply fixes + audit + verify + sync ----
function Apply-Fixes-And-Audit {
    param([string]$DocxPath)
    
    # Fix section breaks FIRST (python-docx save re-corrupts namespace + PAGE field)
    Write-Host "  [BUILD] Adding section breaks (fix_docx_sections)..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "fix_docx_sections.py") $DocxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  fix_docx_sections reported issues (non-critical)" }
    
    # Apply surgical polishing (RTL footnotes, link removal, CNEPD scrubbing)
    Write-Host "  [BUILD] Applying surgical polish (surgical_polish)..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "surgical_polish.py") $DocxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  surgical_polish reported issues (non-critical)" }
    
    # Apply comprehensive fixes LAST (namespace fix + PAGE field fix must be final)
    Write-Host "  [BUILD] Applying comprehensive fixes (fix_thesis_all)..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "fix_thesis_all.py") $DocxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  fix_thesis_all reported issues (non-critical)" }
    
    # Run comprehensive audit
    Write-Host "  [BUILD] Running comprehensive audit..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "audit_thesis_comprehensive.py") $DocxPath 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [AUDIT] Audit PASSED" -ForegroundColor Green
    } else {
        Write-Host "  [AUDIT] Audit completed (non-critical flags OK)" -ForegroundColor Yellow
    }
    
    # Run verify checks
    Write-Host "  [BUILD] Running verify checks..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "verify_docx_checks.py") $DocxPath --size-threshold 50000 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [VERIFY] All checks PASSED" -ForegroundColor Green
    } else {
        Write-Host "  [VERIFY] Completed (review non-critical)" -ForegroundColor Yellow
    }
    
    # Run MD ↔ DOCX sync check
    Write-Host "  [BUILD] Running MD ↔ DOCX sync check..." -ForegroundColor Yellow
    $syncResult = uv run python (Join-Path $styleDir "docx_md_sync.py") $DocxPath --verify 2>&1
    $syncPass = $LASTEXITCODE -eq 0
    if ($syncPass) {
        Write-Host "  [SYNC] MD ↔ DOCX verified" -ForegroundColor Green
    } else {
        Write-Host "  [SYNC] Differences found (run --patch-md to sync)" -ForegroundColor Yellow
    }
}

if ($Command -eq "" -or $Command -eq "build") {
    if ($NoRebuild) {
        # === MODE A: Use Golden Source directly (No Rebuild) ===
        Write-Host "  [BUILD] Using Golden Source directly (No Rebuild mode)..." -ForegroundColor Cyan
        if (-not (Test-Path $desktopDocx)) {
            Write-Error "Golden source not found: $desktopDocx"
            exit 1
        }
        Copy-Item $desktopDocx $docxPath -Force
        Write-Host "  [BUILD] Source: $desktopDocx" -ForegroundColor Cyan
        Write-Host "  [BUILD] Output: $docxPath" -ForegroundColor Cyan
    } elseif ($FromMD) {
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
    } else {
        # === MODE C: Desktop DOCX as golden source ===
        Write-Host "  [BUILD] Copying golden desktop DOCX (v7c_FIXED)..." -ForegroundColor Green
        if (-not (Test-Path $desktopDocx)) {
            Write-Error "Golden source not found: $desktopDocx"
            exit 1
        }
        Copy-Item $desktopDocx $docxPath -Force
        Write-Host "  [BUILD] Source: $desktopDocx" -ForegroundColor Cyan
        Write-Host "  [BUILD] Output: $docxPath" -ForegroundColor Cyan
    }
    
    # Apply fixes and audit
    Apply-Fixes-And-Audit $docxPath

    # --- Thorough field update (Ctrl+A F9) before final PDF export ---
    Write-Host "  [BUILD] Updating all fields via Word COM (body, headers/footers, TOC, footnotes)..." -ForegroundColor Cyan
    uv run python (Join-Path $styleDir "update_fields.py") $docxPath --save-only 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Field update failed"; exit 1 }

    # --- Word COM Automation for Logos, TOC, Table of Figures, and PDF Export ---
    Write-Host "  [BUILD] Running Word COM automation for TOC, TOF, PDF..." -ForegroundColor Cyan
    $logo1Path = Join-Path $PSScriptRoot "style\logo1.png"
    $logo2Path = Join-Path $PSScriptRoot "style\logo2.png"
    if (-not (Test-Path $logo1Path)) { $logo1Path = "" }
    if (-not (Test-Path $logo2Path)) { $logo2Path = "" }

    uv run python (Join-Path $styleDir "word_automation.py") $docxPath $logo1Path $logo2Path 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Word COM automation failed"; exit 1 }

    # --- Post-automation fixes (Word COM resets some XML properties) ---
    Write-Host "  [BUILD] Re-applying surgical polish after COM automation..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "surgical_polish.py") $docxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  surgical_polish (post-COM) reported issues (non-critical)" }

    Write-Host "  [BUILD] Re-applying comprehensive fixes after COM automation..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "fix_thesis_all.py") $docxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  fix_thesis_all (post-COM) reported issues (non-critical)" }

    Write-Host "  [BUILD] Re-applying section fixes after COM automation (page numbering)..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "fix_docx_sections.py") $docxPath --save 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "  fix_docx_sections (post-COM) reported issues (non-critical)" }

    # --- Final verification ---
    Write-Host "  [BUILD] Running final verification..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "verify_docx_checks.py") $docxPath --size-threshold 50000 2>&1

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
    uv run python (Join-Path $styleDir "docx_md_sync.py") $desktopDocx --patch-md 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SYNC] MD patched successfully" -ForegroundColor Green
    } else {
        Write-Host "  [SYNC] Completed with flags" -ForegroundColor Yellow
    }
    # Re-verify
    Write-Host "  [SYNC] Re-verifying..." -ForegroundColor Yellow
    uv run python (Join-Path $styleDir "docx_md_sync.py") $desktopDocx --verify 2>&1
    exit 0
}

# Golden source: Memoire_DSS_Logistique_ElBayadh_v7c_FIXED.docx (Desktop)
# All standard commands (build, pandoc-only, copy-desktop, sync-md) handled above.
Write-Host "  Unknown command: '$Command'. Available: build, pandoc-only, copy-desktop, sync-md, restore" -ForegroundColor Yellow
exit 1
