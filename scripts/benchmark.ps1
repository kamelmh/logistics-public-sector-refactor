# ============================================================================
# benchmark.ps1 — Academix v13.2 Performance Baseline
# Measures build, verify, and scan times to detect degradation
# Usage: .\scripts\benchmark.ps1 [-Iterations 3]
# ============================================================================

param(
    [int]$Iterations = 3
)

$ErrorActionPreference = "Continue"
$ROOT = Split-Path $PSScriptRoot -Parent
$RESULTS_DIR = Join-Path $ROOT "benchmarks"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HHmmss"

if (-not (Test-Path $RESULTS_DIR)) {
    New-Item -ItemType Directory -Path $RESULTS_DIR -Force | Out-Null
}

$results = @()

function Measure-Operation {
    param([string]$Name, [scriptblock]$Block)
    Write-Host "`n[bench] $Name..." -ForegroundColor Cyan

    $times = @()
    for ($i = 1; $i -le $Iterations; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            & $Block
        } catch {
            # Expected for some operations
        }
        $sw.Stop()
        $times += $sw.ElapsedMilliseconds
        Write-Host "  Run $i`: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Gray
    }

    $avg = [math]::Round(($times | Measure-Object -Average).Average)
    $min = ($times | Measure-Object -Minimum).Minimum
    $max = ($times | Measure-Object -Maximum).Maximum

    Write-Host "  Avg: ${avg}ms | Min: ${min}ms | Max: ${max}ms" -ForegroundColor Yellow

    return [PSCustomObject]@{
        Operation = $Name
        AvgMs = $avg
        MinMs = $min
        MaxMs = $max
        Iterations = $Iterations
        Timestamp = $TIMESTAMP
    }
}

# ============================================================
# BENCHMARKS
# ============================================================

Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  Academix v13.2 — PERFORMANCE BENCHMARK" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  Iterations: $Iterations" -ForegroundColor Gray
Write-Host "  Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

# 1. VBA module file scan
$results += Measure-Operation "VBA module scan" {
    Get-ChildItem "$ROOT\Software_Surgical_Edit\VBA_Modules\*.bas" -ErrorAction SilentlyContinue | Out-Null
}

# 2. Script syntax parse
$results += Measure-Operation "Script syntax parse" {
    $scripts = Get-ChildItem "$ROOT\scripts\*.ps1" -ErrorAction SilentlyContinue
    foreach ($s in $scripts) {
        $null = [System.Management.Automation.Language.Parser]::ParseFile($s.FullName, [ref]$null, [ref]$null)
    }
}

# 3. Git status
$results += Measure-Operation "Git status" {
    git status --porcelain 2>$null | Out-Null
}

# 4. Git log (last 100)
$results += Measure-Operation "Git log (100 commits)" {
    git log --oneline -100 2>$null | Out-Null
}

# 5. Full file enumeration
$results += Measure-Operation "Full file enumeration" {
    Get-ChildItem $ROOT -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\\.git\\' } | Out-Null
}

# 6. XML context parse
$results += Measure-Operation "XML context parse" {
    $xmlFiles = Get-ChildItem "$ROOT\Software_Surgical_Edit\*.xml" -ErrorAction SilentlyContinue
    foreach ($x in $xmlFiles) {
        [xml](Get-Content $x.FullName -ErrorAction SilentlyContinue) | Out-Null
    }
}

# 7. Symlink resolution
$results += Measure-Operation "Symlink resolution (75 links)" {
    $links = Get-ChildItem "$ROOT\links" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Attributes -match "ReparsePoint" }
    foreach ($l in $links) {
        Test-Path $l.FullName -ErrorAction SilentlyContinue | Out-Null
    }
}

# ============================================================
# SAVE RESULTS
# ============================================================

$resultsFile = Join-Path $RESULTS_DIR "benchmark_$TIMESTAMP.json"
$results | ConvertTo-Json | Out-File -FilePath $resultsFile -Encoding utf8

# Also save latest for easy access
$latestFile = Join-Path $RESULTS_DIR "benchmark-latest.json"
$results | ConvertTo-Json | Out-File -FilePath $latestFile -Encoding utf8

# ============================================================
# SUMMARY
# ============================================================

Write-Host "`n══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  BENCHMARK RESULTS" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta

$results | Format-Table -Property Operation, AvgMs, MinMs, MaxMs -AutoSize | Out-String | Write-Host

$totalAvg = ($results | Measure-Object -Property AvgMs -Sum).Sum
Write-Host "  Total average time: ${totalAvg}ms" -ForegroundColor Cyan
Write-Host "  Results saved to: $resultsFile" -ForegroundColor Gray
Write-Host "  Latest: $latestFile" -ForegroundColor Gray
