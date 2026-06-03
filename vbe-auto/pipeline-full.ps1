<#
.SYNOPSIS
    Unified Full Pipeline — chains all ERP checks end-to-end.
    vba-check → build → verify → test-macros → dss-audit

.DESCRIPTION
    Runs every verification stage sequentially with unified pass/fail summary.
    Designed for CI/CD, pre-commit hooks, and manual "everything OK?" validation.

.PARAMETER ContinueOnError
    If set, continues pipeline even when a stage fails (runs all stages).
    Default: Stop on first failure.

.PARAMETER SkipBuild
    If set, skips rebuild (useful when only running checks on existing .xlsm).

.PARAMETER OutputPath
    Path to save the pipeline report JSON. Default: vbe-auto/results/pipeline-report.json

.PARAMETER WorkbookPath
    Path to the workbook for verify/test-macros/dss-audit. Default: ERP_v13.3.xlsm

.EXAMPLE
    & "vbe-auto\pipeline-full.ps1"
    # Full pipeline, stop on first failure

.EXAMPLE
    & "vbe-auto\pipeline-full.ps1" -ContinueOnError
    # Full pipeline, run all stages regardless of failures

.EXAMPLE
    & "vbe-auto\pipeline-full.ps1" -SkipBuild
    # Run all checks on existing workbook without rebuilding

.NOTES
    Version: 1.0
    Author: Academix v13.3
    Source: https://github.com/kamelmh/logistics-public-sector-refactor
#>

param(
    [switch]$ContinueOnError,
    [switch]$SkipBuild,
    [string]$OutputPath = "",
    [string]$WorkbookPath = ""
)

$ErrorActionPreference = "Continue"

# ─── Paths ───────────────────────────────────────────────────────────────────
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$VbaSourceDir = "$ProjectRoot\Software_Surgical_Edit\VBA_Modules"
$ConfigPath = "$ScriptDir\config.json"
$ReportDir = "$ScriptDir\results"

if (-not $OutputPath) {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $OutputPath = "$ReportDir\pipeline-report_$timestamp.json"
}
if (-not (Test-Path $ReportDir)) { New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null }

if (-not $WorkbookPath) {
    $WorkbookPath = "$ProjectRoot\ERP_v13.3.xlsm"
}

# ─── Stage definitions ───────────────────────────────────────────────────────
$stages = @(
    @{ Name="VBA_PRE_CHECK";   Script="python `"$ScriptDir\vba-check.py`"" },
    @{ Name="BUILD";           Script="& `"$ScriptDir\build.ps1`" -ConfigPath `"$ConfigPath`""; SkipIf = { $SkipBuild } },
    @{ Name="VERIFY";          Script="& `"$ScriptDir\verify.ps1`" -ConfigPath `"$ConfigPath`"" },
    @{ Name="MACRO_TESTS";     Script="& `"$ProjectRoot\Software_Surgical_Edit\test-macros.ps1`" -WorkbookPath `"$WorkbookPath`"" },
    @{ Name="DSS_AUDIT";       Script="& `"$ProjectRoot\milestone_13_2\public-lsm\tests\dss-audit.ps1`" -WorkbookPath `"$WorkbookPath`"" }
)

$script:pipelineResults = @()
$script:pipelineAborted = $false

# ─── Functions ───────────────────────────────────────────────────────────────
function Write-Banner {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-StageHeader {
    param([int]$Index, [string]$Name, [int]$Total)
    $n = $Index + 1
    Write-Host ""
    Write-Host "─── [$n/$Total] $Name ───" -ForegroundColor Yellow
}

function Invoke-Stage {
    param([int]$Index, [hashtable]$Stage, [int]$Total)

    $stageName = $Stage.Name
    $scriptBlock = $Stage.Script

    # Check skip condition
    if ($Stage.ContainsKey('SkipIf') -and (& $Stage.SkipIf)) {
        Write-Host "  ⏭️  Skipped (SkipBuild active)" -ForegroundColor DarkGray
        $script:pipelineResults += [PSCustomObject]@{
            Stage = $stageName
            Status = "SKIPPED"
            ExitCode = -1
            DurationMs = 0
            Timestamp = Get-Date -Format 'HH:mm:ss'
        }
        return $true
    }

    Write-StageHeader -Index $Index -Name $stageName -Total $Total

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $output = Invoke-Expression $scriptBlock 2>&1
        $exitCode = $LASTEXITCODE
    } catch {
        $exitCode = 1
        $output = "EXCEPTION: $_"
    }
    $sw.Stop()

    $status = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
    $durationMs = $sw.ElapsedMilliseconds

    $script:pipelineResults += [PSCustomObject]@{
        Stage = $stageName
        Status = $status
        ExitCode = $exitCode
        DurationMs = $durationMs
        Timestamp = Get-Date -Format 'HH:mm:ss'
    }

    Write-Host ""
    if ($status -eq "PASS") {
        Write-Host "  ✅ $stageName PASSED ($durationMs ms)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $stageName FAILED (exit: $exitCode, $durationMs ms)" -ForegroundColor Red
        if (-not $ContinueOnError) {
            $script:pipelineAborted = $true
            return $false
        }
    }
    return $true
}

# ─── MAIN PIPELINE ──────────────────────────────────────────────────────────
Write-Banner "ACADEMIX v13.3 — FULL PIPELINE"

Write-Host ""
Write-Host "  Project:  $ProjectRoot"
Write-Host "  Workbook: $WorkbookPath"
Write-Host "  Mode:     $(if ($ContinueOnError) { 'ContinueOnError' } else { 'StopOnFirstFailure' })"
Write-Host "  Started:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

$pipelineStart = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 0; $i -lt $stages.Count; $i++) {
    $ok = Invoke-Stage -Index $i -Stage $stages[$i] -Total $stages.Count
    if (-not $ok) {
        if ($script:pipelineAborted) {
            Write-Host ""
            Write-Host "  ⛔ Pipeline aborted at [$($stages[$i].Name)]" -ForegroundColor Red
            Write-Host "  → Run with -ContinueOnError to run all stages regardless." -ForegroundColor Yellow
            break
        }
    }
}

$pipelineStart.Stop()
$totalDurationMs = $pipelineStart.ElapsedMilliseconds

# ─── SUMMARY ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              PIPELINE SUMMARY                    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$total = $script:pipelineResults.Count
$passed = ($script:pipelineResults | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($script:pipelineResults | Where-Object { $_.Status -eq "FAIL" }).Count
$skipped = ($script:pipelineResults | Where-Object { $_.Status -eq "SKIPPED" }).Count

foreach ($r in $script:pipelineResults) {
    $icon = switch ($r.Status) {
        "PASS"    { "✅" }
        "FAIL"    { "❌" }
        "SKIPPED" { "⏭️"  }
    }
    $color = switch ($r.Status) {
        "PASS"    { "Green" }
        "FAIL"    { "Red" }
        "SKIPPED" { "DarkGray" }
    }
    Write-Host "  $icon [$($r.Status)] $($r.Stage) — $($r.DurationMs) ms" -ForegroundColor $color
}

Write-Host ""
Write-Host "  Stages:   $total total, $passed passed, $failed failed, $skipped skipped" -ForegroundColor White
Write-Host "  Duration: $([math]::Round($totalDurationMs / 1000, 1)) seconds" -ForegroundColor White

if ($failed -eq 0 -and $passed -gt 0) {
    Write-Host ""
    Write-Host "  🎉 ALL PIPELINE STAGES PASSED" -ForegroundColor Green
    $pipelineOk = $true
} elseif ($failed -gt 0) {
    Write-Host ""
    Write-Host "  ❌ $failed STAGE(S) FAILED — Review output above" -ForegroundColor Red
    $pipelineOk = $false
} else {
    Write-Host ""
    Write-Host "  ⏭️  No stages executed" -ForegroundColor DarkGray
    $pipelineOk = $true
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# ─── Save report ─────────────────────────────────────────────────────────────
$report = [PSCustomObject]@{
    Pipeline = "Academix v13.3 — Full Pipeline"
    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Duration = $totalDurationMs
    ContinueOnError = $ContinueOnError.IsPresent
    SkipBuild = $SkipBuild.IsPresent
    Results = $script:pipelineResults
    Summary = @{
        Total = $total
        Passed = $passed
        Failed = $failed
        Skipped = $skipped
    }
    ExitCode = if ($pipelineOk) { 0 } else { 1 }
}
$report | ConvertTo-Json -Depth 5 | Out-File $OutputPath -Encoding utf8
Write-Host "  Report saved: $OutputPath" -ForegroundColor Gray

exit $(if ($pipelineOk) { 0 } else { 1 })
