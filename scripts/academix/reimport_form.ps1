$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$frmPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA\frmStockEntry.frm"

Write-Host "Opening workbook..."
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

# Remove old form
try {
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("frmStockEntry"))
    Write-Host "Removed old frmStockEntry"
} catch {
    Write-Host "No old form to remove"
}

# Create new form
Write-Host "Creating new UserForm..."
$comp = $vbproj.VBComponents.Add(2)

# Read and import code
$frmContent = Get-Content $frmPath -Raw
$codeStart = $frmContent.IndexOf("Option Explicit")
$code = $frmContent.Substring($codeStart)
$comp.CodeModule.AddFromString($code)
Write-Host "Code added: $($comp.CodeModule.CountOfLines) lines"

# Rename
$comp.Name = "frmStockEntry"
Write-Host "Form renamed to: $($comp.Name)"

Write-Host "Saving..."
$wb.Save()
Write-Host "Done!"

$excel.Quit()
