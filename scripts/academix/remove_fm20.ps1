$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

# Remove mod_FM20Constants (conflicts with MSForms library)
try {
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("mod_FM20Constants"))
    Write-Host "Removed mod_FM20Constants"
} catch {
    Write-Host "mod_FM20Constants not found"
}

# List remaining modules
Write-Host "`nRemaining modules:"
foreach ($c in $vbproj.VBComponents) {
    if ($c.Type -eq 1) { Write-Host "  $($c.Name)" }
}

Write-Host "`nSaving..."
$wb.Save()
Write-Host "Done!"
$excel.Quit()
