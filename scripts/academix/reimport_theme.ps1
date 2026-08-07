$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$modPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA\mod_ThemingEngine.bas"

$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

# Remove old
try {
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("mod_ThemingEngine"))
    Write-Host "Removed old mod_ThemingEngine"
} catch {}

# Import fixed
$comp = $vbproj.VBComponents.Import($modPath)
Write-Host "Imported: $($comp.Name)"

$wb.Save()
Write-Host "Done!"
$excel.Quit()
