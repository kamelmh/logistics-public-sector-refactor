$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$fixedPath = "C:\Users\Admin\Desktop\ERP_v13.4_FIXED.xlsm"
$sourceDir = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA"

Write-Host "Opening fixed workbook..."
$wb = $excel.Workbooks.Open($fixedPath)
$vbaProject = $wb.VBProject

# Step 1: Remove all old modules (without "1" suffix)
Write-Host "`n=== REMOVING OLD MODULES ==="
$toRemove = @()
foreach ($comp in $vbaProject.VBComponents) {
    $name = $comp.Name
    $type = $comp.Type
    
    # Skip document objects (sheets, ThisWorkbook)
    if ($type -eq 100 -or $type -eq 1) { continue }
    
    # Old modules don't have "1" suffix
    if ($name -notmatch '1$' -and $name -ne 'frmStockEntry') {
        $toRemove += $comp
    }
}

foreach ($comp in $toRemove) {
    Write-Host "  Removing old: $($comp.Name)"
    try {
        $vbaProject.VBComponents.Remove($comp)
    } catch {
        Write-Host "    Failed: $($_.Exception.Message)"
    }
}

# Step 2: Rename new modules (remove "1" suffix)
Write-Host "`n=== RENAMING MODULES ==="
foreach ($comp in $vbaProject.VBComponents) {
    $name = $comp.Name
    if ($name -match '^(.+)1$') {
        $newName = $Matches[1]
        Write-Host "  Renaming: $name -> $newName"
        try {
            $comp.Name = $newName
        } catch {
            Write-Host "    Failed: $($_.Exception.Message)"
        }
    }
}

# Step 3: Import the form (without .frx)
Write-Host "`n=== IMPORTING FORM ==="
$frmPath = "$sourceDir\frmStockEntry.frm"
if (Test-Path $frmPath) {
    try {
        $vbaProject.VBComponents.Import($frmPath)
        Write-Host "  Imported frmStockEntry"
    } catch {
        Write-Host "  Form import failed (non-critical): $($_.Exception.Message)"
    }
}

Write-Host "`nSaving..."
$wb.Save()

Write-Host "Closing..."
$wb.Close($false)

Write-Host "`nDONE! File: $fixedPath"
