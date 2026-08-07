$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"

$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

# Re-import mod_StockEntry_Logic
try { $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("mod_StockEntry_Logic")) } catch {}
$comp = $vbproj.VBComponents.Import("C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA\mod_StockEntry_Logic.bas")
Write-Host "Imported: $($comp.Name)"

$wb.Save()
Write-Host "Done!"
$excel.Quit()
