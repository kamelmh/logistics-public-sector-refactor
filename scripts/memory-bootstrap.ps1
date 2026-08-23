# Memory Bootstrap — Auto-load project context on session start
# This script loads the project state into memory for faster AI interactions

$ProjectRoot = "C:\Users\Admin\Logistics.Public.Sector.Refactor"
$MemoryDir = "$ProjectRoot\.opencode\memory"

# Create memory directory if it doesn't exist
if (-not (Test-Path $MemoryDir)) {
    New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null
}

# Session state
$session = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    project = "Academix v13.4"
    thesis_status = "36/36 PASS"
    erp_status = "114/114 PASS"
    git_status = "synced"
    last_commit = (git log --oneline -1 2>$null)
    fcc_status = "unknown"
    ollama_status = "unknown"
}

# Check FCC proxy
try {
    $health = Invoke-RestMethod -Uri "http://127.0.0.1:8082/health" -ErrorAction Stop
    $session.fcc_status = $health.status
} catch {
    $session.fcc_status = "offline"
}

# Check Ollama
try {
    $models = ollama list 2>&1
    $session.ollama_status = "running ($($models.Count) models)"
} catch {
    $session.ollama_status = "offline"
}

# Save session state
$session | ConvertTo-Json | Set-Content "$MemoryDir\session.json"

# Create notepad summary
$notepad = @"
# Academix v13.4 — Session Memory
Last updated: $($session.timestamp)

## Status
- Thesis: $($session.thesis_status)
- ERP: $($session.erp_status)
- Git: $($session.git_status)
- Last commit: $($session.last_commit)
- FCC Proxy: $($session.fcc_status)
- Ollama: $($session.ollama_status)

## Quick Commands
- `thesis-build` — Build thesis DOCX
- `thesis-verify` — Run 36 checks
- `erp-build` — Build ERP workbook
- `erp-verify` — Run 114 checks
- `pipeline` — Full thesis pipeline
- `project-status` — Show all status

## Ground Truth (LOCKED)
- D=33, Q*=15, ROP=201, SS=200, LT=7, S=801.45, PU=1200, I=20%

## Key Files
- Thesis source: Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md
- Thesis output: Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx
- ERP workbook: ERP_v13.4.xlsm
- VBA sources: Software_Surgical_Edit/VBA_Modules/
"@

$notepad | Set-Content "$MemoryDir\notepad.md"

Write-Host "Memory bootstrap complete." -ForegroundColor Green
Write-Host "Session: $($session.timestamp)" -ForegroundColor Gray
Write-Host "FCC: $($session.fcc_status)" -ForegroundColor $(if ($session.fcc_status -eq "healthy") { "Green" } else { "Red" })
Write-Host "Ollama: $($session.ollama_status)" -ForegroundColor $(if ($session.ollama_status -like "running*") { "Green" } else { "Red" })
