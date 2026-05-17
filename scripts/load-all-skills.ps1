# Academix v13.2 — Master Skill Loader
# Usage: .\scripts\load-all-skills.ps1
# Loads all project skills in dependency order

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ACADEMIX v13.2 — SKILL LOADER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$skills = @(
    # Core infrastructure (load first)
    @{Name="engineering-harness"; Path=".opencode\skills\workspace\engineering-harness"; Desc="Central orchestrator (s01-s12)"},
    @{Name="crossflow-orchestrator"; Path=".opencode\skills\core\crossflow-orchestrator"; Desc="Multi-window sync"},
    @{Name="semantic-memory"; Path=".opencode\skills\core\semantic-memory"; Desc="Knowledge persistence"},
    @{Name="workspace-setup"; Path=".opencode\skills\core\workspace-setup"; Desc="Project initialization"},
    
    # Workspace skills
    @{Name="auto-thesis"; Path=".opencode\skills\workspace\auto-thesis"; Desc="Thesis automation"},
    @{Name="thesis-docx"; Path=".opencode\skills\workspace\thesis-docx"; Desc="DOCX generation"},
    @{Name="thesis-to-docx"; Path=".opencode\skills\workspace\thesis-to-docx"; Desc="MD to DOCX"},
    @{Name="python-docx-tools"; Path=".opencode\skills\core\python-docx-tools"; Desc="Word automation"},
    @{Name="vba-deployer"; Path=".opencode\skills\core\vba-deployer"; Desc="ERP deployment"},
    @{Name="autonomous-iteration"; Path=".opencode\skills\workspace\autonomous-iteration"; Desc="Self-improvement"},
    
    # Spectrum drivers
    @{Name="algerian-thesis"; Path=".opencode\skills_spectrum\Drivers\algerian-thesis.skill"; Desc="CNEPD formatting"},
    @{Name="github-workflow"; Path=".opencode\skills_spectrum\Drivers\github-workflow.skill"; Desc="CI/CD integration"},
    @{Name="mcp-builder"; Path=".opencode\skills_spectrum\Drivers\mcp-builder.skill"; Desc="MCP servers"},
    @{Name="doc-coauthoring"; Path=".opencode\skills_spectrum\Drivers\doc-coauthoring.skill"; Desc="Collaborative editing"},
    @{Name="path-orchestrator"; Path=".opencode\skills_spectrum\Drivers\path-orchestrator.skill"; Desc="Path management"}
)

$loaded = 0
$failed = 0

foreach ($skill in $skills) {
    $path = Join-Path $PSScriptRoot ".." $skill.Path
    if (Test-Path $path) {
        Write-Host "  ✓ $($skill.Name) — $($skill.Desc)" -ForegroundColor Green
        $loaded++
    } else {
        Write-Host "  ✗ $($skill.Name) — NOT FOUND at $($skill.Path)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  LOADED: $loaded | FAILED: $failed" -ForegroundColor $(if ($failed -eq 0) {"Green"} else {"Yellow"})
Write-Host "============================================" -ForegroundColor Cyan
