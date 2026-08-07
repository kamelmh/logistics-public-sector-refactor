$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$srcDir = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA"
$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$goldenPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.4.xlsm"

# Step 1: Open GOLDEN, copy data sheets
Write-Host "Step 1: Copying data from GOLDEN..."
$golden = $excel.Workbooks.Open($goldenPath, 0)
$clean = $excel.Workbooks.Add()
$clean.SaveAs($wbPath, 52) '52 = xlOpenXMLWorkbookMacroEnabled

# Copy data sheets from GOLDEN to CLEAN
$sheetsToCopy = @("ACCUEIL", "MOUVEMENTS", "CONVENTIONS", "FOURNISSEURS", "ARTICLES", "DASHBOARD")
foreach ($sheetName in $sheetsToCopy) {
    try {
        $srcSheet = $golden.Sheets.Item($sheetName)
        $srcSheet.Copy($clean.Sheets.Item($clean.Sheets.Count))
        Write-Host "  Copied: $sheetName"
    } catch {
        Write-Host "  SKIP: $sheetName (not found)"
    }
}

# Remove default Sheet1/Sheet2/Sheet3
foreach ($s in @("Sheet1", "Sheet2", "Sheet3")) {
    try { $excel.DisplayAlerts = $false; $clean.Sheets.Item($s).Delete() } catch {}
}
$excel.DisplayAlerts = $false

$clean.Save()
Write-Host "  Data sheets copied"

# Step 2: Enable Trust Access
Write-Host "Step 2: Enabling Trust Access..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Security" -Name "AccessVBOM" -Value 1 -Type DWord

# Step 3: Import ALL modules EXCEPT mod_FM20Constants
Write-Host "Step 3: Importing modules..."
$vbproj = $clean.VBProject

$exclude = @("mod_FM20Constants")
$basFiles = Get-ChildItem "$srcDir\*.bas" | Where-Object { $exclude -notcontains $_.BaseName }
$frmFiles = Get-ChildItem "$srcDir\*.frm"

foreach ($f in $basFiles) {
    try {
        $comp = $vbproj.VBComponents.Import($f.FullName)
        Write-Host "  + $($f.BaseName)"
    } catch {
        Write-Host "  ! FAILED: $($f.BaseName) - $($_.Exception.Message)"
    }
}

foreach ($f in $frmFiles) {
    try {
        $comp = $vbproj.VBComponents.Import($f.FullName)
        Write-Host "  + $($f.BaseName) (form)"
    } catch {
        Write-Host "  ! FAILED: $($f.BaseName) - $($_.Exception.Message)"
    }
}

$clean.Save()
Write-Host "Step 4: All modules imported"

# Step 5: Clean up FM20 constant duplicates from ALL modules
Write-Host "Step 5: Removing FM20 constant duplicates..."
foreach ($comp in $vbproj.VBComponents) {
    if ($comp.Type -eq 1) { 'Module
        $codeMod = $comp.CodeModule
        if ($codeMod.CountOfLines -gt 0) {
            $allCode = ""
            for ($i = 1; $i -le $codeMod.CountOfLines; $i++) {
                $line = $codeMod.Lines($i, 1)
                if ($line -match "^Public Const fm\w+") {
                    Write-Host "  Removed: $($comp.Name): $line"
                    continue
                }
                $allCode += $line + "`r`n"
            }
            if ($allCode -ne "") {
                $codeMod.DeleteLines(1, $codeMod.CountOfLines)
                $codeMod.AddFromString($allCode)
            }
        }
    }
}

$clean.Save()
Write-Host "Done!"
$golden.Quit()
$clean.Quit()
