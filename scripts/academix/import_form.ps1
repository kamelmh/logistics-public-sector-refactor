$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$frmPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA\frmStockEntry.frm"

Write-Host "Opening workbook..."
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

$existing = @()
foreach ($c in $vbproj.VBComponents) {
    $existing += $c.Name
}
Write-Host "Existing components: $($existing.Count)"

if ($existing -contains "frmStockEntry") {
    Write-Host "Removing old frmStockEntry..."
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("frmStockEntry"))
}

Write-Host "Importing form..."
$comp = $vbproj.VBComponents.Import($frmPath)
Write-Host "Imported: $($comp.Name) (Type: $($comp.Type))"

Write-Host "Saving..."
$wb.Save()
Write-Host "Done!"

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
