param([string]$DocxPath = "")
if (-not $DocxPath) { Write-Error "Usage: verify-thesis.ps1 <path/to/docx>"; exit 1 }
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$pyScript = Join-Path $projectRoot "Thesis_Surgical_Edit\style\verify_docx_checks.py"
if (-not (Test-Path $pyScript)) {
    $pyScript = Join-Path $PSScriptRoot "style\verify_docx_checks.py"
}
$result = python $pyScript $DocxPath 2>&1
if ($LASTEXITCODE -eq 0) { Write-Host $result } else { Write-Host $result -ForegroundColor Red }
exit $LASTEXITCODE
