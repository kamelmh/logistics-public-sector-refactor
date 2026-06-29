param(
    [string]$Task = "",
    [switch]$List,
    [switch]$Status
)

$ROOT = Split-Path -Parent $PSScriptRoot
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

# ===== Direct VBA tasks (no harness dependency) =====
$VbaDir = "$ROOT\vbe-auto"
$VbaAutofix = "$VbaDir\vba-autofix.ps1"
$VbaValidate = "$VbaDir\vba-check.py"

if ($Task) {
    switch -Wildcard ($Task) {
        "vba-autofix*" {
            Write-Host "=== VBA AutoFix (background) ==="
            if (Test-Path $VbaAutofix) {
                $mode = if ($Task -match "full") { "-Full" } elseif ($Task -match "watch") { "-Watch" } else { "-Repair" }
                Start-Process -WindowStyle Hidden -FilePath pwsh -ArgumentList @(
                    "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $VbaAutofix, $mode
                ) -PassThru | Out-Null
                Write-Host "  Launched vba-autofix $mode in background (PID: $((Get-Process -Name pwsh | Select-Object -Last 1).Id))"
            } else {
                Write-Host "  WARNING: $VbaAutofix not found"
            }
        }
        "vba-validate" {
            Write-Host "=== VBA Pre-Build Validation ==="
            if (Test-Path $VbaValidate) {
                & python $VbaValidate
            } else {
                Write-Host "  WARNING: $VbaValidate not found"
            }
        }
        default {
            & $harness bg $Task
        }
    }
} elseif ($List) {
    $bgDir = Join-Path $ROOT ".tasks\bg"
    if (Test-Path $bgDir) {
        Get-ChildItem $bgDir -File | Select-Object Name, Length, LastWriteTime
    } else {
        Write-Host "No background tasks directory found."
    }
} elseif ($Status) {
    $harnessProcess = Get-Process -Name "pwsh" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -match "harness|vba-autofix"
    }
    if ($harnessProcess) {
        Write-Host "VBA bg processes:"
        $harnessProcess | Format-Table Id, @{N="Command";E={$_.CommandLine.Substring(0, [Math]::Min($_.CommandLine.Length, 100))}}
    } else {
        Write-Host "No VBA background processes running."
    }
} else {
    Write-Host "Usage: bg-worker.ps1 -Task <name> | -List | -Status"
    Write-Host ""
    Write-Host "  VBA Tools:"
    Write-Host "    -Task vba-autofix      Run auto-fix pipeline (repair mode)"
    Write-Host "    -Task vba-autofix-full  Run full pipeline (scan→analyze→fix→rebuild)"
    Write-Host "    -Task vba-autofix-watch Watch desktop for new screenshots"
    Write-Host "    -Task vba-validate       Run pre-build validator"
    Write-Host ""
    Write-Host "  Harness Tasks:"
    Write-Host "    -Task compact          Run context compaction"
    Write-Host "    -Task unlock           Release file locks"
    Write-Host "    -Task <other>          Delegates to harness.ps1"
    Write-Host ""
    Write-Host "  Utilities:"
    Write-Host "    -List                  List bg task artifacts"
    Write-Host "    -Status                Check bg process status"
}