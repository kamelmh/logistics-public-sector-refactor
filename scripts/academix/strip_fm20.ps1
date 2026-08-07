$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$wbPath = "C:\Users\Admin\Desktop\ERP_v13.4_CLEAN.xlsm"
$wb = $excel.Workbooks.Open($wbPath, 0)
$vbproj = $wb.VBProject

Write-Host "Scanning all modules for FM20 constants..."

foreach ($comp in $vbproj.VBComponents) {
    if ($comp.Type -ne 1) { continue }
    $codeMod = $comp.CodeModule
    if ($codeMod.CountOfLines -eq 0) { continue }
    
    $linesToRemove = @()
    for ($i = 1; $i -le $codeMod.CountOfLines; $i++) {
        $line = $codeMod.Lines($i, 1).Trim()
        if ($line -match "^Public Const fm\w+") {
            $linesToRemove += $i
            Write-Host "  $($comp.Name):$i -> $line"
        }
    }
    
    if ($linesToRemove.Count -gt 0) {
        for ($j = $linesToRemove.Count - 1; $j -ge 0; $j--) {
            $codeMod.DeleteLines($linesToRemove[$j], 1)
        }
        Write-Host "  Removed $($linesToRemove.Count) lines from $($comp.Name)"
    }
}

$wb.Save()
Write-Host "Done!"
$excel.Quit()
