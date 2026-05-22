# Academix v13.2 — Session & Memory Persistence
# Auto-saves session state, detects drive changes, loads context
param([string]$Action = "save")

$root = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$memoryFile = "$root\.opencode\memory\session.json"
$logFile = "$root\.opencode\memory\session.log"

function Save-Session {
    $session = if (Test-Path $memoryFile) { Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json } else { @{} }
    $session.last_session = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    $session.session_count = [int]$session.session_count + 1
    $session.workspace_mode = if (Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue) { "excel_running" } else { "idle" }
    $session | ConvertTo-Json | Out-File $memoryFile -Encoding UTF8
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Session $($session.session_count) | $($session.workspace_mode)" | Out-File $logFile -Append -Encoding UTF8
}

function Load-Session {
    if (Test-Path $memoryFile) {
        $session = Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "Session #$($session.session_count) | Last: $($session.last_session) | Mode: $($session.workspace_mode)" -ForegroundColor Cyan
        Write-Host "Workbook: $($session.active_workbook)" -ForegroundColor Gray
        return $session
    }
    return $null
}

function Detect-Drives {
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -ne "C:\" -and $_.Root -ne "D:\" }
    $results = @()
    foreach ($d in $drives) {
        try {
            $media = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$($d.Root.TrimEnd('\'))'" -ErrorAction SilentlyContinue)
            $vol = $media.VolumeName
            $size = [Math]::Round($media.Size / 1GB, 1)
            $free = [Math]::Round($media.FreeSpace / 1GB, 1)
            $results += [PSCustomObject]@{ Drive = $d.Root; Label = $vol; SizeGB = $size; FreeGB = $free }
        } catch {}
    }
    return $results
}

switch ($Action) {
    "save"   { Save-Session }
    "load"   { Load-Session }
    "drives" { Detect-Drives }
    default  { Save-Session; Load-Session }
}
