$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)

Write-Host "=== Components ==="
foreach ($c in $wb.VBProject.VBComponents) {
    $type = switch ($c.Type) {
        1 { "Module" }
        2 { "UserForm" }
        3 { "Class" }
        100 { "Document" }
        default { $c.Type }
    }
    Write-Host "  $($c.Name) ($type)"
}

Write-Host ""
Write-Host "=== frmStockEntry Code (first 30 lines) ==="
$comp = $wb.VBProject.VBComponents.Item("frmStockEntry")
$codeMod = $comp.CodeModule
for ($i = 1; $i -le [Math]::Min(30, $codeMod.CountOfLines); $i++) {
    Write-Host $codeMod.Lines($i, 1)
}

Write-Host ""
Write-Host "Total code lines: $($codeMod.CountOfLines)"

$excel.Quit()
