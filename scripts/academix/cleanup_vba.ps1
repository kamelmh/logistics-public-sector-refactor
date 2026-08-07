$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$fixedPath = "C:\Users\Admin\Desktop\ERP_v13.4_FIXED.xlsm"

Write-Host "Opening workbook..."
$wb = $excel.Workbooks.Open($fixedPath)
$vbaProject = $wb.VBProject

Write-Host "`n=== ALL COMPONENTS ==="
$allComps = @()
foreach ($comp in $vbaProject.VBComponents) {
    $allComps += [PSCustomObject]@{
        Name = $comp.Name
        Type = $comp.Type
        HasDesigner = ($comp.Designer -ne $null)
    }
    Write-Host "  $($comp.Type) | $($comp.Name)"
}

Write-Host "`n=== REMOVING DUPLICATES ==="
# Remove anything ending in "1" (duplicates from failed rename)
$toRemove = @()
foreach ($comp in $vbaProject.VBComponents) {
    $name = $comp.Name
    $type = $comp.Type
    
    # Keep document objects (sheets, ThisWorkbook) - type 100
    if ($type -eq 100) { continue }
    
    # Remove duplicates (ending in "1")
    if ($name -match '1$') {
        $toRemove += $comp
    }
}

Write-Host "Found $($toRemove.Count) duplicates to remove"
foreach ($comp in $toRemove) {
    Write-Host "  Removing: $($comp.Name)"
    try {
        $vbaProject.VBComponents.Remove($comp)
        Write-Host "    OK"
    } catch {
        Write-Host "    FAILED: $($_.Exception.Message)"
    }
}

Write-Host "`n=== FINAL MODULE LIST ==="
foreach ($comp in $vbaProject.VBComponents) {
    Write-Host "  $($comp.Type) | $($comp.Name)"
}

Write-Host "`nSaving..."
$wb.Save()
$wb.Close($false)

Write-Host "DONE!"
