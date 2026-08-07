$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)

Write-Host "=== CLEAN Workbook Sheets ($($wb.Sheets.Count) total) ==="
$i = 1
foreach ($s in $wb.Sheets) {
    Write-Host "  $i. $($s.Name)"
    $i++
}

$excel.Quit()
