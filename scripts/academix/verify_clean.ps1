$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

# Remove mod_FM20Constants entirely
try {
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("mod_FM20Constants"))
    Write-Host "Removed mod_FM20Constants"
} catch {
    Write-Host "mod_FM20Constants not found"
}

# Verify no FM20 constants remain in any module
Write-Host "`nChecking for remaining FM20 constants..."
foreach ($comp in $vbproj.VBComponents) {
    if ($comp.Type -ne 1) { continue }
    $codeMod = $comp.CodeModule
    if ($codeMod.CountOfLines -eq 0) { continue }
    for ($i = 1; $i -le $codeMod.CountOfLines; $i++) {
        $line = $codeMod.Lines($i, 1).Trim()
        if ($line -match "^Public Const fm\w+") {
            Write-Host "  FOUND: $($comp.Name):$i -> $line"
        }
    }
}

$wb.Save()
Write-Host "Done!"
$excel.Quit()
