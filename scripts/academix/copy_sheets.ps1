$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$goldenPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.4.xlsm"
$cleanPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"

Write-Host "Opening GOLDEN..."
$golden = $excel.Workbooks.Open($goldenPath, 0)

Write-Host "Opening CLEAN..."
$clean = $excel.Workbooks.Open($cleanPath, 0)

Write-Host "`n=== GOLDEN Sheets ==="
$goldenSheets = @()
foreach ($s in $golden.Sheets) {
    $goldenSheets += $s.Name
    Write-Host "  $($s.Name)"
}

Write-Host "`n=== CLEAN Sheets ==="
$cleanSheets = @()
foreach ($s in $clean.Sheets) {
    $cleanSheets += $s.Name
    Write-Host "  $($s.Name)"
}

Write-Host "`n=== Missing Sheets ==="
$missing = @()
foreach ($name in $goldenSheets) {
    if ($cleanSheets -notcontains $name) {
        $missing += $name
        Write-Host "  MISSING: $name"
    }
}

Write-Host "`nCopying $($missing.Count) missing sheets..."
foreach ($name in $missing) {
    try {
        $srcSheet = $golden.Sheets.Item($name)
        $srcSheet.Copy($clean.Sheets.Item($clean.Sheets.Count))
        $newSheet = $clean.Sheets.Item($clean.Sheets.Count)
        $newSheet.Name = $name
        Write-Host "  + $name"
    } catch {
        Write-Host "  ! FAILED: $name - $($_.Exception.Message)"
    }
}

Write-Host "`nFinal CLEAN sheet count: $($clean.Sheets.Count)"
$clean.Save()
Write-Host "Saved!"
$golden.Quit()
$clean.Quit()
