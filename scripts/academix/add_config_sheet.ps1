$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$srcDir = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA"

Write-Host "Opening workbook..."
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

Write-Host "Adding CONFIG sheet..."
$wsCfg = $wb.Sheets.Add($wb.Sheets.Item($wb.Sheets.Count))
$wsCfg.Name = "CONFIG"

$wsCfg.Cells(1, 1).Value = "Parameter"
$wsCfg.Cells(1, 2).Value = "Value"
$wsCfg.Cells(1, 3).Value = "Unit"
$wsCfg.Cells(1, 4).Value = "Description"
$wsCfg.Range("A1:D1").Font.Bold = $true

$wsCfg.Cells(2, 1).Value = "ORDER_COST_S"
$wsCfg.Cells(2, 2).Value = 801.45
$wsCfg.Cells(2, 3).Value = "DZD"
$wsCfg.Cells(2, 4).Value = "Cost per order (S) - Wilson EOQ"

$wsCfg.Cells(3, 1).Value = "HOLDING_RATE"
$wsCfg.Cells(3, 2).Value = 0.2
$wsCfg.Cells(3, 3).Value = "ratio"
$wsCfg.Cells(3, 4).Value = "Annual holding cost rate (I) - 20%"

$wsCfg.Cells(4, 1).Value = "LEAD_TIME_DEFAULT"
$wsCfg.Cells(4, 2).Value = 2
$wsCfg.Cells(4, 3).Value = "days"
$wsCfg.Cells(4, 4).Value = "Default supplier lead time (LT)"

$wsCfg.Cells(5, 1).Value = "WORKING_DAYS_PER_YEAR"
$wsCfg.Cells(5, 2).Value = 250
$wsCfg.Cells(5, 3).Value = "days"
$wsCfg.Cells(5, 4).Value = "Algerian working days per year"

$wsCfg.Cells(6, 1).Value = "OBSERVATION_DAYS"
$wsCfg.Cells(6, 2).Value = 38
$wsCfg.Cells(6, 3).Value = "days"
$wsCfg.Cells(6, 4).Value = "Internship observation period"

$wsCfg.Cells(7, 1).Value = "MASTER_PWD"
$wsCfg.Cells(7, 2).Value = "erp_secure_pwd_2026"
$wsCfg.Cells(7, 3).Value = "-"
$wsCfg.Cells(7, 4).Value = "System password"

$wsCfg.Cells(8, 1).Value = "SERVICE_LEVEL_Z"
$wsCfg.Cells(8, 2).Value = 1.65
$wsCfg.Cells(8, 3).Value = "ratio"
$wsCfg.Cells(8, 4).Value = "Service level factor (95% = 1.65)"

$wsCfg.Columns("A").ColumnWidth = 25
$wsCfg.Columns("B").ColumnWidth = 18
$wsCfg.Columns("C").ColumnWidth = 10
$wsCfg.Columns("D").ColumnWidth = 50

Write-Host "CONFIG sheet created"

Write-Host "Re-importing modified modules..."
$modulesToImport = @("mod_Config", "mod_StockEngine", "mod_Dashboard", "mod_Procurement", "mod_SyncBridge", "mod_UI_Setup")

foreach ($modName in $modulesToImport) {
    $basFile = "$srcDir\$modName.bas"
    if (Test-Path $basFile) {
        try { $vbproj.VBComponents.Remove($vbproj.VBComponents.Item($modName)) | Out-Null } catch {}
        try {
            $comp = $vbproj.VBComponents.Import($basFile)
            Write-Host "  + $modName"
        } catch {
            Write-Host "  ! FAILED: $modName"
        }
    }
}

Write-Host "Saving..."
$wb.Save()
Write-Host "Done!"
$excel.Quit()
