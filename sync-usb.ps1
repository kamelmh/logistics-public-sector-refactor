# Academix v13.2 — USB Workspace Sync
# Syncs between Dropbox workspace and USB drive
# Usage: .\sync-usb.ps1 [push|pull|status]

param([string]$Mode = "status")

$root = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$usbRoot = "H:\Academix"

$pairs = @(
    @{src="$root\Thesis_Surgical_Edit"; dst="$usbRoot\Thesis"; desc="Thesis source + pipeline"},
    @{src="$root\Thesis_Surgical_Edit\output"; dst="$usbRoot\Thesis\output"; desc="Thesis output (DOCX+PDF)"},
    @{src="$root\Thesis_Surgical_Edit\style"; dst="$usbRoot\Thesis\style"; desc="Style templates"},
    @{src="$root\Software_Surgical_Edit\VBA_Modules"; dst="$usbRoot\Systeme\VBA_Modules"; desc="VBA source modules"},
    @{src="$root\Software_Surgical_Edit\ERP_Academie_v13_2.xlsm"; dst="$usbRoot\Systeme\"; desc="Compiled workbook"}
)

function Show-Status {
    Write-Host "`n=== USB Sync Status ===" -ForegroundColor Cyan
    foreach ($p in $pairs) {
        $srcOk = Test-Path $p.src
        $dstOk = Test-Path $p.dst
        $icon = if ($srcOk -and $dstOk) { "SYNC" } elseif ($srcOk) { "SRC_ONLY" } elseif ($dstOk) { "DST_ONLY" } else { "MISSING" }
        $c = switch($icon){"SYNC"{"Green"}"SRC_ONLY"{"Yellow"}"DST_ONLY"{"Yellow"}default{"Red"}}
        Write-Host "  [$icon] $($p.desc)" -ForegroundColor $c
        Write-Host "         src: $($p.src)"
        Write-Host "         dst: $($p.dst)"
    }
    Write-Host "`nUSB: H:\  $(if(Test-Path $usbRoot){'FOUND'}else{'NOT FOUND'})" -ForegroundColor $(if(Test-Path $usbRoot){'Green'}else{'Red'})
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  .\sync-usb.ps1 push   — USB ← Workspace (backup to USB)" -ForegroundColor White
    Write-Host "  .\sync-usb.ps1 pull   — USB → Workspace (restore from USB)" -ForegroundColor White
}

function Sync-Push {
    Write-Host "Pushing Workspace → USB..." -ForegroundColor Yellow
    foreach ($p in $pairs) {
        if (Test-Path $p.src) {
            if ((Get-Item $p.src) -is [System.IO.DirectoryInfo]) {
                robocopy $p.src $p.dst /MIR /NP /NDL /NFL /NJH /NJS 2>&1 | Out-Null
            } else {
                Copy-Item $p.src $p.dst -Force
            }
            Write-Host "  [OK] $($p.desc)" -ForegroundColor Green
        }
    }
    Write-Host "Push complete." -ForegroundColor Green
}

function Sync-Pull {
    Write-Host "Pulling USB → Workspace..." -ForegroundColor Yellow
    foreach ($p in $pairs) {
        if (Test-Path $p.dst) {
            if ((Get-Item $p.dst) -is [System.IO.DirectoryInfo]) {
                robocopy $p.dst $p.src /MIR /NP /NDL /NFL /NJH /NJS 2>&1 | Out-Null
            } else {
                Copy-Item $p.dst $p.src -Force
            }
            Write-Host "  [OK] $($p.desc)" -ForegroundColor Green
        }
    }
    Write-Host "Pull complete." -ForegroundColor Green
}

switch ($Mode.ToLower()) {
    "push"   { Sync-Push }
    "pull"   { Sync-Pull }
    "status" { Show-Status }
    default  { Write-Host "Unknown: $Mode"; Show-Status }
}