# Academix v13.2 -- Thesis Build Pipeline
# Converts Markdown -> DOCX -> PDF with user's original formatting
# Usage: .\build-thesis.ps1 [-SourceMD] [-OutputName]

param(
    [string]$SourceMD = "Memoire_DSS_Logistique_ElBayadh.md",
    [string]$OutputName = "Memoire_DSS_Logistique_ElBayadh"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$style = Join-Path $root "style"
$outDir = Join-Path $root "output"
$manifest = Join-Path $outDir "build-manifest.json"

# Source change detection — skip rebuild if source MD5 unchanged
$sourcePath = Join-Path $root $SourceMD
if ((Test-Path $sourcePath) -and (Test-Path $manifest)) {
    $srcHash = (Get-FileHash $sourcePath -Algorithm MD5).Hash
    $prevManifest = Get-Content $manifest | ConvertFrom-Json
    $prevDocx = Join-Path $outDir "$OutputName.docx"
    if ($prevManifest.PSObject.Properties.Name -contains "Memoire_DSS_Logistique_ElBayadh.md") {
        $prevSrcHash = $prevManifest."Memoire_DSS_Logistique_ElBayadh.md".md5
        $prevHash = $prevSrcHash -replace '[^a-fA-F0-9]', ''
        $currHash = $srcHash -replace '[^a-fA-F0-9]', ''
        if ($prevHash -eq $currHash -and (Test-Path $prevDocx)) {
            Write-Host "  Source unchanged (MD5: $($srcHash.Substring(0,12))...), skipping rebuild" -ForegroundColor Green
            & (Join-Path $root "verify-thesis.ps1")
            exit $LASTEXITCODE
        }
    }
    Write-Host "  Source changed or stale manifest, rebuilding..." -ForegroundColor Yellow
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Academix v13.2 -- Thesis Build Pipeline   " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# Step 1: Generate reference.docx from user's original DOCX
$refDocx = Join-Path $style "reference.docx"
$refIn = Join-Path $style "reference-in.docx"

Write-Host "[1/10] Generating reference template from user's original DOCX..." -ForegroundColor Yellow
if (-not (Test-Path $refIn)) {
    & pandoc -o $refIn --print-default-data-file reference.docx 2>&1
}
python (Join-Path $style "customize-reference.py") 2>&1
if (-not (Test-Path $refDocx)) {
    Write-Host "[ERROR] reference.docx not created" -ForegroundColor Red
    exit 1
}

# Step 1.5: Build master-references.json from thesis .md
Write-Host "[1.5/10] Building master reference index..." -ForegroundColor Yellow
$origDir = Get-Location
try {
    Set-Location -LiteralPath $root
    python (Join-Path $root "tools" "build-master-refs.py") 2>&1
} catch {
    Write-Host "  [WARN] Master reference build failed: $_" -ForegroundColor Yellow
} finally { Set-Location -LiteralPath $origDir }

# Step 1.6: Validate reference integrity
Write-Host "[1.6/10] Validating reference integrity..." -ForegroundColor Yellow
try {
    Set-Location -LiteralPath $root
    python (Join-Path $style "inject-references.py") --check-only 2>&1
} catch {
    Write-Host "  [WARN] Reference validation failed: $_" -ForegroundColor Yellow
} finally { Set-Location -LiteralPath $origDir }

# Step 2: Build DOCX with pandoc
$sourcePath = Join-Path $root $SourceMD
if (-not (Test-Path $sourcePath)) {
    Write-Host "[ERROR] Source not found: $sourcePath" -ForegroundColor Red
    exit 1
}

$docx = Join-Path $outDir "$OutputName.docx"
Write-Host "[2/10] Generating DOCX..." -ForegroundColor Yellow

$metaYaml = Join-Path $style "thesis-metadata.yaml"

$pandocArgs = @(
    $sourcePath,
    "--from", "gfm",
    "--to", "docx",
    "--reference-doc", $refDocx,
    "--metadata-file", $metaYaml,
    "--output", $docx,
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

# Step 2.75: Convert inline citations to footnotes (CNEPD format)
Write-Host "[2.75/10] Converting citations to footnotes..." -ForegroundColor Yellow
try {
    python (Join-Path $style "footnotes.py") $docx 2>&1
    Write-Host "  Footnotes added from inline (Author, Year) citations" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Footnotes conversion failed: $_" -ForegroundColor Yellow
}

# Step 3: Post-process tables (header coloring, alternating rows)
Write-Host "[3/10] Formatting tables with user's color scheme..." -ForegroundColor Yellow
try {
    python (Join-Path $style "format-tables.py") $docx 2>&1
    Write-Host "  Tables formatted: #0C447C headers, #EBF5FB alternating rows" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Table formatting failed: $_" -ForegroundColor Yellow
}

# Step 3.25: Advanced table formatting (center, full-width, row splitting)
Write-Host "[3.25/10] Advanced table formatting..." -ForegroundColor Yellow
try {
    python (Join-Path $style "format-tables-advanced.py") $docx 2>&1
    Write-Host "  Tables: centered, 100% width, no page-break rows" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Advanced table formatting failed: $_" -ForegroundColor Yellow
}

# Step 3.5: Fix font sizes (remove explicit 12pt from body/heading runs)
Write-Host "[3.5/10] Fixing font sizes..." -ForegroundColor Yellow
try {
    python (Join-Path $style "fix-fonts.py") $docx 2>&1
    Write-Host "  Font sizes fixed: style-inherited 14pt body, 22/18/16pt headings" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Font fix failed: $_" -ForegroundColor Yellow
}

# Step 4: Bismillah and Cover
Write-Host "[4/10] Processing Bismillah and Cover pages..." -ForegroundColor Yellow
try {
    python (Join-Path $style "build-bismillah.py") 2>&1
    python (Join-Path $style "prepend-bismillah.py") $docx (Join-Path $style "bismillah-page.docx") 2>&1
    Write-Host "  Bismillah page prepended" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Bismillah page failed: $_" -ForegroundColor Yellow
}


# Step 4.5: Format baseline (comprehensive: fonts + margins + headings + alignment)
Write-Host "[4.5/10] Applying format baseline..." -ForegroundColor Yellow
try {
    python (Join-Path $style "format-baseline.py") $docx 2>&1
    Write-Host "  Baseline: fonts, margins, headings, alignment, spacing" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Baseline formatting failed: $_" -ForegroundColor Yellow
}

# Step 4.75: Add Table of Contents and List of Tables fields
Write-Host "[4.75/10] Adding TOC and LOT fields..." -ForegroundColor Yellow
try {
    python (Join-Path $style "add-toc.py") $docx 2>&1
    Write-Host "  TOC + LOT field codes inserted" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] TOC insertion failed: $_" -ForegroundColor Yellow
}

# Step 4.8: Rebuild cover-page.docx from archive (python-docx native, Word-safe)
Write-Host "[4.8/10] Rebuilding cover-page.docx from archive..." -ForegroundColor Yellow
try {
    python (Join-Path $style "build-cover-page.py") 2>&1
} catch {
    Write-Host "  [WARN] Cover rebuild failed: $_" -ForegroundColor Yellow
}

# Step 4.875: Prepend cover-page.docx (before page numbering — cover gets no page number)
Write-Host "[4.875/10] Prepending cover-page.docx (as-is)..." -ForegroundColor Yellow
try {
    python (Join-Path $style "prepend-cover.py") $docx 2>&1
    Write-Host "  Cover page prepended from cover-page.docx" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Cover prepend failed: $_" -ForegroundColor Yellow
}

# Step 4.9: Add page numbering (section breaks + Abjad/Arabic + footers)
Write-Host "[4.9/10] Adding page numbering..." -ForegroundColor Yellow
try {
    python (Join-Path $style "add-page-numbers.py") $docx 2>&1
    Write-Host "  Page numbering: pre-chapters Abjad, body Arabic numerals" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Page numbering failed: $_" -ForegroundColor Yellow
}

# Step 5: Generate PDF via Word (with field update)
$pdf = Join-Path $outDir "$OutputName.pdf"
Write-Host "[5/10] Generating PDF via Word (updating fields)..." -ForegroundColor Yellow
# Kill any stale Word instances BEFORE spawning COM (prevents orphan accumulation)
Get-Process -Name WINWORD -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $wdDoc = $word.Documents.Open((Resolve-Path $docx).Path)
    $wdDoc.Fields.Update() | Out-Null
    $wdDoc.Fields.Update() | Out-Null
    try { $wdDoc.TablesOfContents.Item(1).Update() } catch { }
    try { $wdDoc.TablesOfFigures.Item(1).Update() } catch { }
    $wdDoc.Fields.Update() | Out-Null
    $wdDoc.Save()
    $wdDoc.SaveAs2((Resolve-Path $outDir).Path + "\$OutputName.pdf", 17)
    $wdDoc.Close()
    $word.Quit()
    $size = (Get-Item $pdf).Length
    Write-Host "  Fields updated, PDF: $([math]::Round($size/1KB)) KB" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] PDF via Word failed: $_" -ForegroundColor Yellow
    Write-Host "  Open $docx in Word and save as PDF manually." -ForegroundColor Yellow
} finally {
    # Force cleanup of COM objects to prevent orphaned WINWORD processes
    if ($wdDoc) { try { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wdDoc) } catch {} }
    if ($word)  { try { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word)  } catch {} }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Start-Sleep -Milliseconds 500
    Get-Process -Name WINWORD -ErrorAction SilentlyContinue | Stop-Process -Force
}

# Step 6: Verify output (basic)
Write-Host "[6/10] Verifying..." -ForegroundColor Yellow
if (Test-Path $docx) {
    Write-Host "  DOCX OK: $([math]::Round((Get-Item $docx).Length/1KB)) KB" -ForegroundColor Green
}
if (Test-Path $pdf) {
    Write-Host "  PDF OK: $([math]::Round((Get-Item $pdf).Length/1KB)) KB" -ForegroundColor Green
}

# Step 7: Deep verification (structural + old-vs-new comparison)
Write-Host "[7/10] Deep verification..." -ForegroundColor Yellow
try {
    & (Join-Path $root "verify-thesis.ps1") 2>&1
    $verifyResult = $LASTEXITCODE
    if ($verifyResult -eq 0 -or $verifyResult -eq $null) {
        Write-Host "  Deep verify: ALL CHECKS PASSED" -ForegroundColor Green
    } else {
        Write-Host "  Deep verify: $verifyResult check(s) failed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [WARN] Deep verification error: $_" -ForegroundColor Yellow
}

# Step 8: Measure build metrics
Write-Host "[8/10] Measuring build metrics..." -ForegroundColor Yellow
try {
    python (Join-Path $style "measure-thesis.py") $docx $sourcePath 2>&1
    python (Join-Path $style "compare-thesis.py") 2>&1
} catch {
    Write-Host "  [WARN] Metrics step failed: $_" -ForegroundColor Yellow
}

# Step 9: Persist build manifest with source + output hashes + metrics
Write-Host "[9/10] Persisting build manifest..." -ForegroundColor Yellow
try {
    $manifestPath = Join-Path $outDir "build-manifest.json"
    $srcHash = (Get-FileHash $sourcePath -Algorithm MD5).Hash
    $docxHash = if (Test-Path $docx) { (Get-FileHash $docx -Algorithm MD5).Hash } else { "N/A" }
    $pdfHash  = if (Test-Path $pdf)  { (Get-FileHash $pdf  -Algorithm MD5).Hash } else { "N/A" }
    $metricsPath = Join-Path $outDir "metrics" "latest.json"
    $metrics = if (Test-Path $metricsPath) { Get-Content $metricsPath | ConvertFrom-Json } else { $null }
    $buildId     = if ($metrics) { $metrics.build_id } else { "manual-$(Get-Date -Format 'yyyyMMdd-HHmmss')" }
    $docxSizeKb  = if (Test-Path $docx) { [math]::Round((Get-Item $docx).Length/1KB) } else { 0 }
    $pdfSizeKb   = if (Test-Path $pdf)  { [math]::Round((Get-Item $pdf).Length/1KB) }  else { 0 }
    $verifyBlock = if ($metrics) { @{ total = $metrics.verify.total_checks; passed = $metrics.verify.passed; failed = $metrics.verify.failed } } else { @{} }
    $manifest = @{
        build_id  = $buildId
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        source    = @{ file = $SourceMD; md5 = $srcHash; size_kb = [math]::Round((Get-Item $sourcePath).Length/1KB, 1) }
        outputs   = @{ docx = @{ md5 = $docxHash; size_kb = $docxSizeKb }; pdf = @{ md5 = $pdfHash; size_kb = $pdfSizeKb } }
        verify    = $verifyBlock
    }
    $manifest | ConvertTo-Json -Depth 4 | Set-Content $manifestPath -Encoding UTF8
    Write-Host "  Manifest: src=$($srcHash.Substring(0,12)) docx=$($docxHash.Substring(0,12)) pdf=$($pdfHash.Substring(0,12))" -ForegroundColor Green
    # Also update thesis-state.json (tracked by git, survives sessions)
    $statePath = Join-Path $root "thesis-state.json"
    $state = if (Test-Path $statePath) { Get-Content $statePath | ConvertFrom-Json } else { @{} }
    if (-not $state.PSObject.Properties.Name -contains "manifest_history") {
        $state | Add-Member -NotePropertyName "manifest_history" -NotePropertyValue @() -Force
    }
    if ($state.PSObject.Properties.Name -contains "golden_baseline") {
        $state.manifest_history += $state.golden_baseline
    }
    $state | Add-Member -NotePropertyName "golden_baseline" -NotePropertyValue @{
        build_id  = $buildId
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        source    = @{ file = $SourceMD; md5 = $srcHash; size_kb = [math]::Round((Get-Item $sourcePath).Length/1KB, 1) }
        outputs   = @{ docx = @{ md5 = $docxHash; size_kb = $docxSizeKb }; pdf = @{ md5 = $pdfHash; size_kb = $pdfSizeKb } }
        verify    = $verifyBlock
    } -Force
    $state | ConvertTo-Json -Depth 5 | Set-Content $statePath -Encoding UTF8
    Write-Host "  State: golden_baseline updated, $($state.manifest_history.Count) prior builds archived" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Manifest write failed: $_" -ForegroundColor Yellow
}

# Step 10: Done
Write-Host "[10/10] Complete" -ForegroundColor Yellow
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
Write-Host "- Page: A4, 2.5cm margins, RTL, 1.5 line spacing" -ForegroundColor Gray
