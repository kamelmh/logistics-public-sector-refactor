# 💓 System Pulse (Pulse.ps1)
# Lightweight Heartbeat for Academix v13.2
# Purpose: Instant health check of the 4 Project Pillars

$ProjectRoot = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$Workbook = "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm"

function Test-Pillar($Name, $Check) {
    try {
        if ($Check) {
            Write-Host "  [OK] $Name" -ForegroundColor Green
            return $true
        } else {
            throw "Check failed"
        }
    } catch {
        Write-Host "  [FAIL] $Name" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n--- ⚡ ACADEMIX SYSTEM PULSE ⚡ ---" -ForegroundColor Cyan

$Healthy = $true

# Pillar 1: Connectivity
$Healthy = $Healthy -and (Test-Pillar "Workbook Access" (Test-Path $Workbook))
$Healthy = $Healthy -and (Test-Pillar "Source Dir" (Test-Path "$ProjectRoot\Software_Surgical_Edit\VBA_Modules"))

# Pillar 2: Integrity
$Healthy = $Healthy -and (Test-Pillar "Bootstrap Config" (Test-Path "$ProjectRoot\.opencode\bootstrap\MASTER_BOOTSTRAP.xml"))
$Healthy = $Healthy -and (Test-Pillar "Certification Matrix" (Test-Path "$ProjectRoot\Software_Surgical_Edit\CERTIFICATION_MATRIX.md"))

# Pillar 3: Intelligence
$Healthy = $Healthy -and (Test-Pillar "OS Spectrum" (Test-Path "$ProjectRoot\.opencode\skills_spectrum\REGISTRY.md"))

# Pillar 4: Sync
$Healthy = $Healthy -and (Test-Pillar "CrossFlow Handoff" (Test-Path "$ProjectRoot\.crossflow\HANDOFF.md"))

Write-Host "----------------------------------"
if ($Healthy) {
    Write-Host "STATUS: SYSTEM HEALTHY [READY]" -ForegroundColor Green
} else {
    Write-Host "STATUS: SYSTEM DEGRADED [ACTION REQUIRED]" -ForegroundColor Red
}
Write-Host "----------------------------------`n"
