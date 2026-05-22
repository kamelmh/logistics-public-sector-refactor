param(
    [Parameter(Position=0)]
    [string]$Command = "",
    [switch]$Help
)

$real = Join-Path $PSScriptRoot "..\Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1"
if (-not (Test-Path $real)) {
    Write-Error "Real thesis build script not found: $real"
    exit 1
}

if ($Help -or $Command -eq "-?" -or $Command -eq "/?") {
    Write-Host "Delegates to: Research_and_Development\Thesis_Surgical_Edit\thesis-doctor.ps1" -ForegroundColor Cyan
    Write-Host "Run with any thesis-doctor.ps1 command or no args for REPL mode.`n" -ForegroundColor Gray
}

& $real $Command $Help