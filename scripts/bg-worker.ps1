param(
    [string]$Task = "",
    [switch]$List,
    [switch]$Status
)

$ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$harness = Join-Path $ROOT "scripts\harness.ps1"

if (-not (Test-Path $harness)) {
    Write-Error "Harness not found: $harness"
    exit 1
}

if ($List) {
    $bgDir = Join-Path $ROOT ".tasks\bg"
    if (Test-Path $bgDir) {
        Get-ChildItem $bgDir -File | Select-Object Name, Length, LastWriteTime
    } else {
        Write-Host "No background tasks directory found."
    }
    return
}

if ($Status) {
    $harnessProcess = Get-Process -Name "pwsh" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -match "harness"
    }
    if ($harnessProcess) {
        Write-Host "Harness bg process running (PID: $($harnessProcess.Id))"
    } else {
        Write-Host "Harness bg process not running."
    }
    return
}

if ($Task) {
    & $harness bg $Task
} else {
    Write-Host "Usage: bg-worker.ps1 -Task <name> | -List | -Status"
    Write-Host "  bg-worker.ps1 -Task compact       Run context compaction"
    Write-Host "  bg-worker.ps1 -Task unlock         Release file locks"
    Write-Host "  bg-worker.ps1 -List                List bg task artifacts"
    Write-Host "  bg-worker.ps1 -Status              Check harness bg status"
}