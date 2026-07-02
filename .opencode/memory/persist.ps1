# Academix v13.4 — Session & Memory Persistence
# Auto-saves session state, detects drive changes, loads context
param([string]$Action = "save")

$root = "C:\Users\Admin\Logistics.Public.Sector.Refactor"
$memoryFile = "$root\.opencode\memory\session.json"
$logFile = "$root\.opencode\memory\session.log"
$notepadFile = "$root\.opencode\notepad.md"
$checkpointDir = "C:\Users\Admin\.omc\state\sessions"
$checkpointFile = "$checkpointDir\memory-checkpoint-latest.md"

function Save-Session {
    $session = if (Test-Path $memoryFile) { Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json } else { @{} }
    $session.last_session = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    $session.session_count = [int]$session.session_count + 1
    $session.workspace_mode = if (Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue) { "excel_running" } else { "idle" }
    $session | ConvertTo-Json | Out-File $memoryFile -Encoding UTF8
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Session $($session.session_count) | $($session.workspace_mode)" | Out-File $logFile -Append -Encoding UTF8
    Write-Host "[MEMORY] Session saved (#$($session.session_count))" -ForegroundColor Cyan
}

function Load-Session {
    if (Test-Path $memoryFile) {
        $session = Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "[MEMORY] Session #$($session.session_count) | Last: $($session.last_session) | Mode: $($session.workspace_mode)" -ForegroundColor Cyan
        Write-Host "[MEMORY] Last verify: $($session.last_verify)" -ForegroundColor Gray
        return $session
    }
    Write-Host "[MEMORY] No saved session found" -ForegroundColor Yellow
    return $null
}

function Save-Checkpoint {
    $checkpoint = @"
# OMC Memory Checkpoint
# Auto-generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Project: Academix v13.4

## State
- Session: $(if (Test-Path $memoryFile) { (Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json).session_count } else { "?" })
- Last verify: $(if (Test-Path $memoryFile) { (Get-Content $memoryFile -Raw -Encoding UTF8 | ConvertFrom-Json).last_verify } else { "?" })
- Pipeline: python-docx single save from golden source

## Key Decisions
- Golden source = correct formatting, cover page, TOC, hyperlinks
- Pandoc MD = correct content (numbers, text, tables)
- python-docx single save preserves Word COM compatibility
- Recursive traversal for table paragraphs
- No zipfile string manipulation (breaks Word COM)

## Active Files
| File | Path |
|------|------|
| Pipeline | C:\Users\Admin\AppData\Local\Temp\pipeline_v12_revised.py |
| Golden | $root\Thesis_Surgical_Edit\output\Latest-thesis-backup-Memoire_DSS_Logistique_ElBayadh.docx |
| Output | $root\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx |
| Venv | C:\Users\Admin\AppData\Local\Temp\thesis-venv |
| Notepad | $notepadFile |

## Last Action
$(if (Test-Path $notepadFile) { (Get-Content $notepadFile -Raw -Encoding UTF8) -replace '(?s).*## Last Action\n(.+?)(?=\n## |\Z)','$1' | Select-Object -First 3 | Out-String } else { "Not available" })

## Next Steps
$(if (Test-Path $notepadFile) { (Get-Content $notepadFile -Raw -Encoding UTF8) -replace '(?s).*## Next Steps\n(.+?)(?=\n## |\Z)','$1' | Out-String } else { "Not available" })
"@
    if (-not (Test-Path $checkpointDir)) { New-Item -ItemType Directory -Path $checkpointDir -Force | Out-Null }
    $checkpoint | Out-File $checkpointFile -Encoding UTF8
    Write-Host "[MEMORY] Checkpoint saved" -ForegroundColor Cyan
}

switch ($Action) {
    "save"   { Save-Session; Save-Checkpoint }
    "load"   { Load-Session }
    "drives" { Detect-Drives }
    default  { Save-Session; Load-Session; Save-Checkpoint }
}
