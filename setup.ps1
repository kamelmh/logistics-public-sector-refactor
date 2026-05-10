# Academix v13.2 — Workspace Setup & Launcher
# Detects drives, loads session, sets context
# Usage: .\setup.ps1 [online|offline|drive|status]

param([string]$Mode = "status")

$ErrorActionPreference = "Continue"
$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$memory = "$root\.opencode\memory"
$sessionFile = "$memory\session.json"
$logFile = "$memory\session.log"
$persist = "$memory\persist.ps1"

function Write-Banner {
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Academix v13.2 — Workspace Setup    ║" -ForegroundColor Cyan
    Write-Host "║     ERP Académie - El Bayadh            ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Test-Dropbox {
    $dropbox = "C:\Users\Administrator\Dropbox"
    if (Test-Path $dropbox) {
        $online = (Get-Item "$dropbox\ERP_v13.2.xlsm" -ErrorAction SilentlyContinue) -ne $null
        return @{ exists = $true; online = $online; path = $dropbox }
    }
    return @{ exists = $false; online = $false; path = $null }
}

function Find-RemovableDrives {
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DriveType -eq 2 }
    $results = @()
    foreach ($d in $drives) {
        $disk = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction SilentlyContinue | Where-Object { $_.Index -eq $d.Index }
        $results += [PSCustomObject]@{
            Drive     = "$($d.DeviceID)\"
            Label     = $d.VolumeName
            SizeGB    = [Math]::Round($d.Size / 1GB, 1)
            FreeGB    = [Math]::Round($d.FreeSpace / 1GB, 1)
            FS        = $d.FileSystem
            Model     = if ($disk) { $disk.Model } else { "Unknown" }
            Status    = if ($disk) { $disk.Status } else { "Unknown" }
        }
    }
    return $results
}

function Show-Status {
    Write-Banner
    $dropbox = Test-Dropbox
    Write-Host "`n[Dropbox]" -ForegroundColor Yellow
    if ($dropbox.exists) {
        Write-Host "  Path: $($dropbox.path)" -ForegroundColor Green
        Write-Host "  Status: $(if($dropbox.online){'SYNCED'}else{'UNSYNCED'})" -ForegroundColor $(if($dropbox.online){'Green'}else{'Yellow'})
    } else {
        Write-Host "  NOT FOUND — offline mode" -ForegroundColor Yellow
    }

    $removable = Find-RemovableDrives
    Write-Host "`n[Removable Drives]" -ForegroundColor Yellow
    if ($removable.Count -eq 0) {
        Write-Host "  None detected" -ForegroundColor Gray
    } else {
        $removable | ForEach-Object { Write-Host "  [$($_.Drive)] $($_.Label) — $($_.SizeGB)GB, $($_.FreeGB)GB free, $($_.Status)" }
    }

    Write-Host "`n[Last Session]" -ForegroundColor Yellow
    if (Test-Path $sessionFile) {
        $session = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "  Session: #$($session.session_count)" -ForegroundColor Gray
        Write-Host "  Last: $($session.last_session)" -ForegroundColor Gray
        Write-Host "  Mode: $($session.workspace_mode)" -ForegroundColor Gray
        Write-Host "  Build: $($session.last_build)" -ForegroundColor Gray
        Write-Host "  Verify: $($session.last_verify)" -ForegroundColor Gray
        Write-Host "  Test: $($session.last_test)" -ForegroundColor Gray
    } else {
        Write-Host "  No previous session" -ForegroundColor Gray
    }

    Write-Host "`n[Project]" -ForegroundColor Yellow
    Write-Host "  Root: $root" -ForegroundColor Gray
    Write-Host "  Modules: 36 .bas + 1 .frm + 1 .cls" -ForegroundColor Gray
    Write-Host "  Lines: ~11,400" -ForegroundColor Gray
    Write-Host "  Build: .\vbe-auto\build.ps1 -ConfigPath .\vbe-auto\config.json" -ForegroundColor Gray

    Write-Host "`nCommands:" -ForegroundColor Cyan
    Write-Host "  .\setup.ps1 online   — force online mode" -ForegroundColor White
    Write-Host "  .\setup.ps1 offline  — force offline mode" -ForegroundColor White
    Write-Host "  .\setup.ps1 drive    — detect drives" -ForegroundColor White
    Write-Host "  .\setup.ps1 deploy   — deploy to detected SSD" -ForegroundColor White
    Write-Host "  .\setup.ps1 status   — show this status" -ForegroundColor White
}

function Set-Mode {
    param([string]$NewMode)
    if (Test-Path $sessionFile) {
        $session = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $session = @{ session_count = 0 }
    }
    $session.workspace_mode = $NewMode
    $session.last_session = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    $session.session_count = [int]$session.session_count + 1
    $session | ConvertTo-Json | Out-File $sessionFile -Encoding UTF8
    if (Test-Path $persist) {
        & $persist -Action save >$null
    } else {
        Write-Host "  [WARN] persist.ps1 not found at $persist — session not persisted" -ForegroundColor Yellow
    }
    Write-Host "Mode set to: $NewMode" -ForegroundColor Green
}

function Show-Drives {
    $removable = Find-RemovableDrives
    if ($removable.Count -eq 0) {
        Write-Host "No removable drives detected." -ForegroundColor Yellow
        return
    }
    Write-Host "`nRemovable Drives:" -ForegroundColor Cyan
    $removable | Format-Table Drive, Label, SizeGB, FreeGB, FS, Status -AutoSize | Out-String | Write-Host
}

function Deploy-ToDrive {
    $drives = Find-RemovableDrives
    if ($drives.Count -eq 0) {
        Write-Host "No removable drive to deploy to." -ForegroundColor Red
        return
    }
    $target = $drives[0].Drive
    Write-Host "Deploying to $target ..." -ForegroundColor Yellow
    $dest = Join-Path $target "Academix"
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    New-Item -ItemType Directory -Path "$dest\VBA_Modules" -Force | Out-Null
    New-Item -ItemType Directory -Path "$dest\tools" -Force | Out-Null

    # Copy source modules
    Copy-Item "$root\Software_Surgical_Edit\VBA_Modules\*" "$dest\VBA_Modules\" -Recurse -Force
    # Copy build tools
    Copy-Item "$root\Software_Surgical_Edit\vbe.ps1" "$dest\tools\" -Force
    # Copy master
    Copy-Item "$root\Software_Surgical_Edit\ERP_Academie_v13_Master.xlsm" "$dest\" -Force
    # Copy session context
    Copy-Item "$root\.opencode" "$dest\.opencode\" -Recurse -Force

    Write-Host "Deployed to $dest" -ForegroundColor Green
    Write-Host "  Modules: $(@(Get-ChildItem "$dest\VBA_Modules\*.bas").Count) .bas" -ForegroundColor Gray
    Write-Host "  Master: $(Test-Path "$dest\ERP_Academie_v13_Master.xlsm")" -ForegroundColor Gray
    Write-Host "  Tools: $(@(Get-ChildItem "$dest\tools\*.ps1").Count) .ps1" -ForegroundColor Gray

    # Update session
    if (Test-Path $sessionFile) {
        $session = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $session.drive_config.ssd_expected = $target.TrimEnd('\')
        $session.last_deploy = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        $session | ConvertTo-Json | Out-File $sessionFile -Encoding UTF8
    }
}

# ===== MAIN =====
switch ($Mode.ToLower()) {
    "online"  { Set-Mode "online"; Show-Status }
    "offline" { Set-Mode "offline"; Show-Status }
    "drive"   { Show-Drives }
    "deploy"  { Deploy-ToDrive }
    "status"  { Show-Status }
    default   { Write-Host "Unknown mode: $Mode"; Show-Status }
}
