param(
    [string]$WorkbookPath = "..\GOLDEN_ERP_v13.3.xlsm",
    [string]$FormName = "frmStockEntry",
    [string]$OutputDir = "..\Software_Surgical_Edit\VBA_Modules"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$wbPath = Resolve-Path (Join-Path $ScriptDir $WorkbookPath)
$outDir = Resolve-Path (Join-Path $ScriptDir $OutputDir)

Write-Host "Exporting form '$FormName' from $WorkbookPath..." -ForegroundColor Cyan

if (-not (Test-Path $wbPath)) {
    Write-Host "[ERROR] Workbook not found: $wbPath" -ForegroundColor Red
    exit 1
}

Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$xl.AutomationSecurity = 1

try {
    $wb = $xl.Workbooks.Open($wbPath, 0, $false)

    $vbComp = $wb.VBProject.VBComponents.Item($FormName)
    if (-not $vbComp) {
        Write-Host "[ERROR] Form '$FormName' not found in workbook" -ForegroundColor Red
        $wb.Close($false)
        $xl.Quit()
        exit 1
    }

    $exportPath = Join-Path $outDir $FormName
    $vbComp.Export($exportPath)

    $frmPath = "$exportPath.frm"
    $frxPath = "$exportPath.frx"

    if (Test-Path $frmPath) {
        $frmSize = (Get-Item $frmPath).Length
        Write-Host "  Exported: $frmPath ($([math]::Round($frmSize/1KB,1)) KB)" -ForegroundColor Green
    }
    if (Test-Path $frxPath) {
        $frxSize = (Get-Item $frxPath).Length
        Write-Host "  Exported: $frxPath ($([math]::Round($frxSize/1KB,1)) KB)" -ForegroundColor Green
        Write-Host "  FRX binary blob restored!" -ForegroundColor Cyan
    } else {
        Write-Host "  WARNING: No .frx file was created (form may have no controls)" -ForegroundColor Yellow
    }

    $wb.Close($false)
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $xl.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseCOMObject($xl) | Out-Null
}

Write-Host "Done." -ForegroundColor Green
