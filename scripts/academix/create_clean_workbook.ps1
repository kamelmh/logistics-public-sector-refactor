$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$sourceDir = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA"
$goldenPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\03_ERP_Workbook\GOLDEN_ERP_v13.4.xlsm"
$outputPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"

Write-Host "=== STEP 1: Create fresh workbook ==="
$wb = $excel.Workbooks.Add()
$vbaProject = $wb.VBProject

Write-Host "`n=== STEP 2: Import all .bas modules ==="
$basFiles = Get-ChildItem "$sourceDir\*.bas" -ErrorAction SilentlyContinue
foreach ($f in $basFiles) {
    Write-Host "  $($f.Name)"
    try {
        $vbaProject.VBComponents.Import($f.FullName)
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)"
    }
}

Write-Host "`n=== STEP 3: Import .cls files ==="
$clsFiles = Get-ChildItem "$sourceDir\*.cls" -ErrorAction SilentlyContinue
foreach ($f in $clsFiles) {
    Write-Host "  $($f.Name)"
    try {
        $vbaProject.VBComponents.Import($f.FullName)
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)"
    }
}

Write-Host "`n=== STEP 4: Import .frm files (without .frx) ==="
# Skip frmStockEntry.frm since .frx is missing - the form builds UI programmatically anyway
Write-Host "  Skipping frmStockEntry.frm (missing .frx, UI built at runtime)"

Write-Host "`n=== STEP 5: Copy data from GOLDEN workbook ==="
$goldenWb = $excel.Workbooks.Open($goldenPath)

# Copy each sheet's data
$sheetNames = @("ARTICLES", "FOURNISSEURS", "CONVENTIONS", "MOUVEMENTS", "ACCUEIL")
foreach ($sheetName in $sheetNames) {
    try {
        $goldenSheet = $goldenWb.Sheets($sheetName)
        $goldenSheet.UsedRange.Copy()
        
        # Create or find sheet in new workbook
        $newSheet = $null
        try {
            $newSheet = $wb.Sheets($sheetName)
        } catch {
            $newSheet = $wb.Sheets.Add()
            $newSheet.Name = $sheetName
        }
        $newSheet.Paste()
        Write-Host "  Copied: $sheetName"
    } catch {
        Write-Host "  Skipped: $sheetName (not found)"
    }
}

$goldenWb.Close($false)

Write-Host "`n=== STEP 6: Save ==="
# Save as macro-enabled
$wb.SaveAs($outputPath, 52)
Write-Host "Saved to: $outputPath"

$wb.Close($false)
Write-Host "`nDONE! Open $outputPath and try Alt+F8 -> AjouterMouvement"
