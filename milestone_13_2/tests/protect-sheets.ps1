# Protect all sheets in the workbook
$ErrorActionPreference = "Stop"
$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$wb = $xl.Workbooks.Open("C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.2.xlsm")

$configPath = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\vbe-auto\config.json"
if (Test-Path $configPath) {
    $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
    $pwd = $cfg.protection.sheet_password
} else {
    Write-Host "WARNING: config.json not found, using default password" -ForegroundColor Yellow
    $pwd = "erp_secure_pwd_2026"
}
$protected = 0; $skipped = 0

foreach ($ws in $wb.Sheets) {
    try {
        if ($ws.ProtectContents) { $ws.Unprotect($pwd) }
        $ws.Protect($pwd, $true, $true, $true, $true, $false, $false, $false, $false, $false, $false, $false, $false, $true, $true, $true)
        $protected++
        Write-Host "  PROTECTED: $($ws.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $($ws.Name) - $_" -ForegroundColor Red
        $skipped++
    }
}

Write-Host "`nProtected: $protected/$($wb.Sheets.Count) | Failed: $skipped" -ForegroundColor Cyan

$wb.Save()
$wb.Close()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
