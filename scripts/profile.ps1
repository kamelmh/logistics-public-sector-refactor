# Academix v13.4 — PowerShell Profile
# Add to $PROFILE: . "C:\Users\Admin\Logistics.Public.Sector.Refactor\scripts\profile.ps1"

$ProjectRoot = "C:\Users\Admin\Logistics.Public.Sector.Refactor"

# Thesis commands
function thesis-build { & "$ProjectRoot\Thesis_Surgical_Edit\build-thesis.ps1" @args }
function thesis-verify { python "$ProjectRoot\Thesis_Surgical_Edit\style\verify_docx_checks.py" "$ProjectRoot\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx" }
function thesis-pipeline { & "$ProjectRoot\Thesis_Surgical_Edit\run-thesis-pipeline.ps1" @args }
function thesis-audit { python "$ProjectRoot\Thesis_Surgical_Edit\style\audit_thesis_comprehensive.py" "$ProjectRoot\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx" }
function thesis-md { code "$ProjectRoot\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md" }

# ERP commands
function erp-build { & "$ProjectRoot\vbe-auto\build.ps1" -ConfigPath "$ProjectRoot\vbe-auto\vbe-auto-config.json" }
function erp-verify { & "$ProjectRoot\vbe-auto\verify.ps1" -ConfigPath "$ProjectRoot\vbe-auto\vbe-auto-config.json" }
function erp-test { & "$ProjectRoot\Software_Surgical_Edit\test-macros.ps1" }

# OpenCode commands
function oc-free { opencode -m fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b }
function oc-local { opencode -m ollama/phi4-mini:latest }
function oc-router { opencode -m fcc/open_router/openrouter/free }
function oc-groq { opencode -m fcc/groq/llama-3.3-70b-versatile }

# FCC proxy
function fcc-start { Start-Process -NoNewWindow fcc-server; Start-Sleep 3; Write-Host "FCC Proxy started on http://127.0.0.1:8082" }
function fcc-stop { Get-Process -Name "fcc-server" -ErrorAction SilentlyContinue | Stop-Process -Force }
function fcc-status { try { Invoke-RestMethod -Uri "http://127.0.0.1:8082/health" } catch { Write-Host "FCC Proxy is offline" } }

# Git shortcuts
function gs { git status }
function gl { git log --oneline -10 }
function gd { git diff }
function gc { git commit -m $args }
function gp { git push }

# Project status
function project-status {
    Write-Host "=== Academix v13.4 Status ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Git:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    Write-Host "Thesis:" -ForegroundColor Yellow
    Get-ChildItem "$ProjectRoot\Thesis_Surgical_Edit\output\*.docx" -ErrorAction SilentlyContinue | Select-Object Name, @{N="Size";E={"$([math]::Round($_.Length/1KB))KB"}}, LastWriteTime | Format-Table -AutoSize
    Write-Host "FCC Proxy:" -ForegroundColor Yellow
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8082/health"; Write-Host "  Status: $($r.status)" -ForegroundColor Green } catch { Write-Host "  Status: OFFLINE" -ForegroundColor Red }
    Write-Host "Ollama:" -ForegroundColor Yellow
    try { ollama list 2>&1 | Select-Object -Skip 1 | ForEach-Object { Write-Host "  $_" } } catch { Write-Host "  Status: OFFLINE" -ForegroundColor Red }
}

# Aliases
Set-Alias -Name tb -Value thesis-build
Set-Alias -Name tv -Value thesis-verify
Set-Alias -Name tp -Value thesis-pipeline
Set-Alias -Name ta -Value thesis-audit
Set-Alias -Name eb -Value erp-build
Set-Alias -Name ev -Value erp-verify
Set-Alias -Name et -Value erp-test
Set-Alias -Name ps -Value project-status

Write-Host "Academix v13.4 profile loaded. Type 'project-status' to see system state." -ForegroundColor Green
