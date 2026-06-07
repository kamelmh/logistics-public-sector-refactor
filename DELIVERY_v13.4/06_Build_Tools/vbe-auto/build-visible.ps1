# Build with VISIBLE Excel (workaround for false COMPILE: OK)
param(
    [string]$ConfigPath = "vbe-auto\vbe-auto-config.json"
)

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$configPath = Resolve-Path "$ScriptDir\vbe-auto-config.json"

Write-Host "=== Visible Build ===" -ForegroundColor Cyan

# Read config
$config = Get-Content $configPath -Raw | ConvertFrom-Json
$masterPath = $config.master_workbook
$sourceDir = $config.vba_source_dir
$outputPath = $config.output_workbook

Write-Host "Master: $masterPath"
Write-Host "Source: $sourceDir"
Write-Host "Output: $outputPath"

# Kill all Excel first
Get-Process -Name EXCEL -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 3

# Launch Excel fresh
Start-Process "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
Write-Host "Waiting for Excel to start..."
Start-Sleep 10

Add-Type -AssemblyName Microsoft.VisualBasic

# Connect to running Excel
$xl = $null
try {
    $xl = [Microsoft.VisualBasic.Interaction]::GetObject("", "Excel.Application")
} catch {
    Start-Sleep 5
    $xl = [Microsoft.VisualBasic.Interaction]::GetObject("", "Excel.Application")
}

$xl.Visible = $true
$xl.DisplayAlerts = $false
Write-Host "Excel v$($xl.Version) connected and visible"

# Open master
Write-Host "[1/5] Opening master workbook..."
$wb = $xl.Workbooks.Open($masterPath, 0, $false)
Write-Host "  Sheets: $($wb.Sheets.Count)"

# Strip modules
Write-Host "[2/5] Stripping modules..."
$components = @()
foreach ($c in $wb.VBProject.VBComponents) {
    if ($c.Type -in @(1,2,3)) {
        $components += $c.Name
    }
}
$removed = 0
foreach ($name in $components) {
    try {
        $comp = $wb.VBProject.VBComponents.Item($name)
        $wb.VBProject.VBComponents.Remove($comp)
        $removed++
    } catch {
        Write-Host "  Can't remove ${name}: $_" -ForegroundColor Red
    }
}
Write-Host "  Removed $removed modules"

# Import source files
Write-Host "[3/5] Importing source files..."
$basFiles = Get-ChildItem "$sourceDir\*.bas" | Sort-Object Name
$frmFiles = Get-ChildItem "$sourceDir\*.frm" | Sort-Object Name

foreach ($f in $basFiles) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    if ($name -eq "ThisWorkbook") { continue }
    try {
        $comp = $wb.VBProject.VBComponents.Import($f.FullName)
        Write-Host "  + ${name} ($($comp.CodeModule.CountOfLines) lines)"
    } catch {
        Write-Host "  FAILED ${name}: $_" -ForegroundColor Red
    }
}

foreach ($f in $frmFiles) {
    try {
        $wb.VBProject.VBComponents.Import($f.FullName)
        Write-Host "  + $($f.Name)"
    } catch {
        Write-Host "  FAILED $($f.Name): $_" -ForegroundColor Red
    }
}

# Inject ThisWorkbook
$twbPath = "$sourceDir\ThisWorkbook.cls"
if (Test-Path $twbPath) {
    try {
        $twb = $wb.VBProject.VBComponents.Item("ThisWorkbook")
        $twb.CodeModule.DeleteLines(1, $twb.CodeModule.CountOfLines)
        $rawCode = Get-Content $twbPath -Raw
        $code = ($rawCode -split "`n" | Where-Object { $_ -notmatch '^\s*Attribute\s+' }) -join "`n"
        $twb.CodeModule.AddFromString($code)
        Write-Host "  + ThisWorkbook injected"
    } catch {
        Write-Host "  FAILED ThisWorkbook: $_" -ForegroundColor Red
    }
}

# COMPILE visible
Write-Host "[4/5] Compiling (visible mode)..." -ForegroundColor Yellow
Start-Sleep 2
try {
    $xl.VBE.CommandBars.FindControl(1, 578).Execute()
    Write-Host "  COMPILE: OK" -ForegroundColor Green
    
    # Save
    Write-Host "[5/5] Saving..."
    if (Test-Path $outputPath) { Remove-Item $outputPath -Force }
    $wb.SaveAs($outputPath, 52)
    $fi = Get-Item $outputPath
    Write-Host "  Saved: $($fi.Name) ($([math]::Round($fi.Length/1KB,1)) KB)" -ForegroundColor Green
} catch {
    Write-Host "  COMPILE ERROR DETECTED!" -ForegroundColor Red
    
    # Try to get details
    try {
        $vbe = $xl.VBE
        $activePane = $vbe.ActiveCodePane
        if ($activePane) {
            $cm = $activePane.CodeModule
            $top = $activePane.TopLine
            Write-Host "  Active pane: $($cm.Name) at line $top" -ForegroundColor Yellow
            $lines = $cm.Lines($top, [Math]::Min(10, $cm.CountOfLines - $top + 1))
            Write-Host "  Error context:" -ForegroundColor Yellow
            for ($ln = 0; $ln -lt ($lines -split "`n").Length; $ln++) {
                $lineNum = $top + $ln
                $lineText = ($lines -split "`n")[$ln]
                Write-Host "    $($lineNum): $($lineText)" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "  Can't read VBE state: $_" -ForegroundColor Red
    }
    
    # Check VBE main window for error dialog
    try {
        $mainHwnd = $xl.VBE.MainWindow.HWnd
        Write-Host "  VBE MainWindow HWND: $mainHwnd"
    } catch {}
}

Write-Host "`nBuild complete. Check Excel window for any error dialogs."

# Don't close Excel - user can see the result
# [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($xl) | Out-Null
