$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$frmPath = "C:\Users\Admin\Dropbox\Logistics.Public.Sector.Refactor\DELIVERY_v13.4\05_Source_VBA\frmStockEntry.frm"

Write-Host "Opening workbook..."
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

$existing = @()
foreach ($c in $vbproj.VBComponents) {
    $existing += $c.Name
}
Write-Host "Existing components: $($existing.Count)"

if ($existing -contains "frmStockEntry") {
    Write-Host "frmStockEntry already exists - removing..."
    $vbproj.VBComponents.Remove($vbproj.VBComponents.Item("frmStockEntry"))
}

Write-Host "Creating new UserForm..."
# vbext_ct_MSForm = 2
$comp = $vbproj.VBComponents.Add(2)
$comp.Name = "frmStockEntry"
$comp.Properties.Item("Caption").Value = "ERP Academix v13.4 - Registre de Stock"
$comp.Properties.Item("Width").Value = 6840
$comp.Properties.Item("Height").Value = 4525
$comp.Properties.Item("StartUpPosition").Value = 1
Write-Host "Form created: $($comp.Name)"

Write-Host "Reading code from .frm file..."
$frmContent = Get-Content $frmPath -Raw
$codeStart = $frmContent.IndexOf("Option Explicit")
if ($codeStart -gt 0) {
    $code = $frmContent.Substring($codeStart)
    Write-Host "Code length: $($code.Length) chars"
    $comp.CodeModule.AddFromString($code)
    Write-Host "Code added! Lines: $($comp.CodeModule.CountOfLines)"
} else {
    Write-Host "ERROR: Could not find Option Explicit"
}

Write-Host "Saving..."
$wb.Save()
Write-Host "Done!"

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
