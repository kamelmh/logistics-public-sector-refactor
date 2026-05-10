$root = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$wbPath = $root + "\Software_Surgical_Edit\ERP_Academie_v13_2.xlsm"

Get-Process excel -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false

try {
    $wb = $xl.Workbooks.Open($wbPath)
    $ws = $wb.Sheets("ARTICLES")
    
    $lastRow = $ws.Cells($ws.Rows.Count, 1).End(-4162).Row
    Write-Host ("ARTICLES rows: " + $lastRow)
    
    $blankCodes = @()
    $badStocks = @()
    for ($i = 2; $i -le $lastRow; $i++) {
        $code = $ws.Cells($i, 1).Text
        $stock = $ws.Cells($i, 3).Text
        if ([string]::IsNullOrWhiteSpace($code)) { $blankCodes += $i }
        $isNum = $false
        if (![string]::IsNullOrWhiteSpace($stock)) { [double]::TryParse($stock, [ref]$isNum) | Out-Null }
        if (![string]::IsNullOrWhiteSpace($stock) -and !$isNum) { $badStocks += $i }
    }
    
    if ($blankCodes.Count -eq 0) { Write-Host "No blank codes found" } 
    else { Write-Host ("Blank rows: " + ($blankCodes -join ' ')) }
    
    if ($badStocks.Count -eq 0) { Write-Host "No bad stock values found" }
    else { Write-Host ("Bad stock rows: " + ($badStocks -join ' ')) }
    
    $nextNum = 13
    foreach ($r in $blankCodes) {
        $name = $ws.Cells($r, 2).Text
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-Host ("Row " + $r + " has no name - deleting")
            $ws.Rows($r).Delete()
        } else {
            $newCode = "ART-{0:D3}" -f $nextNum
            Write-Host ("Row " + $r + " -> " + $newCode + " (" + $name + ")")
            $ws.Cells($r, 1).Value = $newCode
            $nextNum++
        }
    }
    
    foreach ($r in $badStocks) {
        $raw = $ws.Cells($r, 3).Text
        $cleaned = $raw -replace '[^\d.,]', '' -replace ',', '.'
        $parsed = $null
        if ([double]::TryParse($cleaned, [ref]$parsed)) {
            Write-Host ("Row " + $r + ": " + $raw + " -> " + $parsed)
            $ws.Cells($r, 3).Value = $parsed
        } else {
            Write-Host ("Row " + $r + ": " + $raw + " unparseable -> 0")
            $ws.Cells($r, 3).Value = 0
        }
    }
    
    $wb.Save()
    Write-Host "Saved."
    
    $newLast = $ws.Cells($ws.Rows.Count, 1).End(-4162).Row
    $errCount = 0
    for ($i = 2; $i -le $newLast; $i++) {
        if ([string]::IsNullOrWhiteSpace($ws.Cells($i, 1).Text)) { $errCount++ }
        $s = $ws.Cells($i, 3).Text
        if (![string]::IsNullOrWhiteSpace($s)) {
            $isN = $false; [double]::TryParse($s, [ref]$isN) | Out-Null
            if (!$isN) { $errCount++ }
        }
    }
    Write-Host ("Remaining errors: " + $errCount)
    
    $wb.Close($false)
} catch {
    Write-Host ("ERROR: " + $_)
}
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
