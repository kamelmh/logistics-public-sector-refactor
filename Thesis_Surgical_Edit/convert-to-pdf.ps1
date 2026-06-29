# Convert thesis DOCX to PDF (Color + Grayscale)
# Uses Word COM for highest fidelity conversion

$projectRoot = Split-Path -Parent $PSScriptRoot
$docxPath = Join-Path $projectRoot "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
$pdfColorPath = Join-Path $projectRoot "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh_COLOR.pdf"
$pdfGrayPath = Join-Path $projectRoot "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh_GRAYSCALE.pdf"

Write-Host "Starting Word COM..." -ForegroundColor Cyan
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    Write-Host "Opening document..." -ForegroundColor Cyan
    $doc = $word.Documents.Open($docxPath)

    # Ensure all fields are updated (TOC, page numbers, cross-references)
    Write-Host "Updating all fields (TOC, page numbers)..." -ForegroundColor Yellow
    $doc.Fields.Update()
    $doc.TablesOfContents | ForEach-Object { $_.Update() }

    # Save COLOR PDF (wdFormatPDF = 17)
    Write-Host "Saving COLOR PDF..." -ForegroundColor Green
    $doc.SaveAs([ref]$pdfColorPath, [ref]17)
    Write-Host "Color PDF saved: $pdfColorPath" -ForegroundColor Green

    $doc.Close()

    # For grayscale: Word COM doesn't support direct grayscale PDF export
    # Best approach: Use Ghostscript post-processing if available
    # Check for Ghostscript
    $gsPath = Get-Command "gswin64c.exe" -ErrorAction SilentlyContinue
    if (-not $gsPath) {
        $gsPath = Get-Command "gswin32c.exe" -ErrorAction SilentlyContinue
    }
    if (-not $gsPath) {
        $gsPath = "C:\Program Files\gs\gs10.04.0\bin\gswin64c.exe" # Common install path
        if (-not (Test-Path $gsPath)) {
            $gsPath = "C:\Program Files (x86)\gs\gs10.04.0\bin\gswin32c.exe"
        }
    }

    if (Test-Path $gsPath) {
        Write-Host "Ghostscript found at: $gsPath" -ForegroundColor Cyan
        Write-Host "Converting to GRAYSCALE PDF via Ghostscript..." -ForegroundColor Yellow
        
        $gsArgs = @(
            "-sDEVICE=pdfwrite",
            "-sColorConversionStrategy=Gray",
            "-dProcessColorModel=/DeviceGray",
            "-dCompatibilityLevel=1.7",
            "-dPDFSETTINGS=/prepress",
            "-dEmbedAllFonts=true",
            "-dSubsetFonts=true",
            "-dAutoFilterColorImages=false",
            "-dAutoFilterGrayImages=false",
            "-dColorImageFilter=/FlateEncode",
            "-dGrayImageFilter=/FlateEncode",
            "-o `"$pdfGrayPath`"",
            "`"$pdfColorPath`""
        )
        
        & $gsPath $gsArgs
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Grayscale PDF saved: $pdfGrayPath" -ForegroundColor Green
        } else {
            Write-Host "Ghostscript conversion failed with exit code $LASTEXITCODE" -ForegroundColor Red
            Write-Host "Falling back: copying color PDF as grayscale placeholder..." -ForegroundColor Yellow
            Copy-Item $pdfColorPath $pdfGrayPath -Force
        }
    } else {
        Write-Host "Ghostscript not found. Install Ghostscript for true grayscale conversion." -ForegroundColor Yellow
        Write-Host "Creating grayscale placeholder (copy of color PDF)..." -ForegroundColor Yellow
        Copy-Item $pdfColorPath $pdfGrayPath -Force
        Write-Host "Note: $pdfGrayPath is currently a color PDF. Run Ghostscript manually for true grayscale:" -ForegroundColor Cyan
        Write-Host "  gswin64c.exe -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -o `"$pdfGrayPath`" `"$pdfColorPath`"" -ForegroundColor Cyan
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($doc) { $doc.Close($false) }
    if ($word) { 
        $word.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

Write-Host "Conversion complete." -ForegroundColor Green