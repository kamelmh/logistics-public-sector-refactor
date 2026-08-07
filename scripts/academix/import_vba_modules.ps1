$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$goldenPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\03_ERP_Workbook\GOLDEN_ERP_v13.4.xlsm"
$sourceDir = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA"
$outputPath = "C:\Users\Admin\Desktop\ERP_v13.4_FIXED.xlsm"

Write-Host "Opening GOLDEN workbook..."
$wb = $excel.Workbooks.Open($goldenPath)

Write-Host "Accessing VBA project..."
$vbaProject = $wb.VBProject

# Remove all existing modules (old versions)
Write-Host "Removing old modules..."
foreach ($comp in @($vbaProject.VBComponents)) {
    $name = $comp.Name
    $type = $comp.Type
    
    # Remove modules (type 1 = document, 2 = module, 3 = class, 4 = userform)
    if ($type -ne 1) {  # Don't remove document objects (sheets, ThisWorkbook)
        try {
            $vbaProject.VBComponents.Remove($comp)
            Write-Host "  Removed: $name"
        } catch {
            Write-Host "  Failed to remove: $name - $($_.Exception.Message)"
        }
    }
}

# Import all .bas files (modules)
Write-Host "`nImporting .bas modules..."
Get-ChildItem "$sourceDir\*.bas" | ForEach-Object {
    Write-Host "  Importing: $($_.Name)"
    try {
        $vbaProject.VBComponents.Import($_.FullName)
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)"
    }
}

# Import all .frm files (UserForms)
Write-Host "`nImporting .frm forms..."
Get-ChildItem "$sourceDir\*.frm" | ForEach-Object {
    Write-Host "  Importing: $($_.Name)"
    try {
        $vbaProject.VBComponents.Import($_.FullName)
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)"
    }
}

# Import all .cls files (class modules)
Write-Host "`nImporting .cls classes..."
Get-ChildItem "$sourceDir\*.cls" | ForEach-Object {
    Write-Host "  Importing: $($_.Name)"
    try {
        $vbaProject.VBComponents.Import($_.FullName)
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)"
    }
}

Write-Host "`nSaving to $outputPath..."
$wb.SaveAs($outputPath, 52)  # 52 = xlOpenXMLWorkbookMacroEnabled

Write-Host "Closing workbook..."
$wb.Close($false)

Write-Host "`nDONE! All modules imported."
Write-Host "File saved to: $outputPath"
