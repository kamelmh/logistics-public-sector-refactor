$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)

try {
    $wb.Sheets.Item("Sheet1").Delete()
    Write-Host "Removed Sheet1"
} catch {
    Write-Host "Sheet1 not found"
}

$wb.Save()
Write-Host "Final sheet count: $($wb.Sheets.Count)"
$excel.Quit()
