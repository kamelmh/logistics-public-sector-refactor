$ErrorActionPreference = "Continue"

# Kill any existing Excel first
Get-Process excel -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$xl.EnableEvents = $false
$xl.ScreenUpdating = $false
$xl.Interactive = $false

try {
    $wb = $xl.Workbooks.Open("C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\ERP_Academie_v13_2.xlsm", 0, $true)

    Write-Host "=== CALCULS_EOQ Structure ==="
    $ws = $wb.Sheets("CALCULS_EOQ")
    for ($i = 1; $i -le 15; $i++) {
        try {
            $r = $ws.Cells($i, 1).Value2
            $v = $ws.Cells($i, 2).Value2
            Write-Host "Row ${i}: Param=[$r] Value=[$v]"
        } catch {
            Write-Host "Row ${i}: ERROR reading cells"
        }
    }

    Write-Host "`n=== ARTICLES Column C (Stock) ==="
    $wsArt = $wb.Sheets("ARTICLES")
    $lastRow = $wsArt.Cells($wsArt.Rows.Count, 1).End(-4162).Row
    for ($i = 2; $i -le $lastRow; $i++) {
        try {
            $code = $wsArt.Cells($i, 1).Value2
            $stock = $wsArt.Cells($i, 3).Value2
            $isNum = [double]::TryParse([string]$stock, [ref]$null)
            $status = if ($isNum) { "OK" } else { "BAD" }
            Write-Host "Row ${i}: Code=[$code] Stock=[$stock] Type=$status"
        } catch {
            Write-Host "Row ${i}: ERROR reading cells"
        }
    }
} catch {
    Write-Host "ERROR: $_"
} finally {
    $wb.Close($false)
    $xl.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
    Write-Host "Done"
}
