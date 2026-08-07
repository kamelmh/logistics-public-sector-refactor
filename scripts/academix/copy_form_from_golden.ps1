$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$goldenPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.4.xlsm"
$cleanPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"

Write-Host "Opening GOLDEN workbook..."
$golden = $excel.Workbooks.Open($goldenPath, 0)

Write-Host "Opening CLEAN workbook..."
$clean = $excel.Workbooks.Open($cleanPath, 0)

# Export form from GOLDEN
Write-Host "Exporting frmStockEntry from GOLDEN..."
$goldenProj = $golden.VBProject
$frmComp = $null
try {
    $frmComp = $goldenProj.VBComponents.Item("frmStockEntry")
} catch {
    Write-Host "frmStockEntry not found in GOLDEN!"
    $golden.Quit()
    $clean.Quit()
    exit
}

$exportPath = "C:\Users\Admin\Dropbox\frmStockEntry_exported.frm"
$frmComp.Export($exportPath)
Write-Host "Exported to: $exportPath"

# Remove old form from CLEAN
Write-Host "Removing old form from CLEAN..."
$cleanProj = $clean.VBProject
try {
    $cleanProj.VBComponents.Remove($cleanProj.VBComponents.Item("frmStockEntry"))
    Write-Host "Removed old form"
} catch {
    Write-Host "No old form to remove"
}

# Import form from GOLDEN export
Write-Host "Importing form from GOLDEN export..."
$imported = $cleanProj.VBComponents.Import($exportPath)
Write-Host "Imported: $($imported.Name), Type: $($imported.Type)"

Write-Host "Saving CLEAN workbook..."
$clean.Save()
Write-Host "Done!"

$golden.Quit()
$clean.Quit()
