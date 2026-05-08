# Protect all sheets in the workbook
$ErrorActionPreference = "Stop"
$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$wb = $xl.Workbooks.Open("C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\ERP_Academie_v13_2.xlsm")

$pwd = "erp_secure_pwd_2026"
$protected = 0
$skipped = 0

foreach ($ws in $wb.Sheets) {
    try {
        if (-not $ws.ProtectContents) {
            $ws.Protect($pwd, $true, $true, $true, $true, $false, $false, $false, $false, $false, $false, $false, $false, $true, $true, $true)
            $protected++
            Write-Host "  PROTECTED: $($ws.Name)" -ForegroundColor Green
        } else {
            Write-Host "  ALREADY: $($ws.Name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  ERROR: $($ws.Name) - $_" -ForegroundColor Red
    }
}

Write-Host "`nProtected: $protected | Skipped: $skipped | Total: $($wb.Sheets.Count)" -ForegroundColor Cyan

$wb.Save()
$wb.Close()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
