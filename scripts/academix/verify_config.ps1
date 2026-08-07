$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)

Write-Host "=== CONFIG Sheet ==="
$wsCfg = $wb.Sheets.Item("CONFIG")
for ($i = 1; $i -le 8; $i++) {
    $param = $wsCfg.Cells($i, 1).Value
    $val = $wsCfg.Cells($i, 2).Value
    $unit = $wsCfg.Cells($i, 3).Value
    Write-Host "  $param = $val $unit"
}

Write-Host "`n=== Component Count ==="
$modules = 0
$forms = 0
foreach ($c in $wb.VBProject.VBComponents) {
    if ($c.Type -eq 1) { $modules++ }
    if ($c.Type -eq 2) { $forms++ }
}
Write-Host "  Modules: $modules"
Write-Host "  Forms: $forms"
Write-Host "  Total: $($modules + $forms)"

Write-Host "`n=== frmStockEntry exists ==="
try {
    $frm = $wb.VBProject.VBComponents.Item("frmStockEntry")
    Write-Host "  YES - Code lines: $($frm.CodeModule.CountOfLines)"
} catch {
    Write-Host "  NO"
}

$excel.Quit()
