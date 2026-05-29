param(
    [Parameter(Position=0)]
    [string]$Command = "all",
    [switch]$Json,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
$tsDir = Join-Path $projectRoot "Thesis_Surgical_Edit"
$styleDir = Join-Path $tsDir "style"
$outDir = Join-Path $tsDir "output"
$reportDir = Join-Path $projectRoot "pipeline-reports"
$null = New-Item -ItemType Directory -Path $reportDir -Force

$thesisDocx = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"
$thesisDocxLocal = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh.docx"
$fixedDocx = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh_fixed.docx"
$preFixDocx = Join-Path $outDir "Memoire_DSS_Logistique_ElBayadh_pre_fix.docx"
$refDocx = Join-Path $styleDir "reference.docx"
$refInDocx = Join-Path $styleDir "reference-in.docx"
$englishRef = Join-Path $styleDir "english-paper-ref.docx"
$sourceMd = Join-Path $tsDir "Memoire_DSS_Logistique_ElBayadh.md"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = Join-Path $reportDir "pipeline-$timestamp.json"
$reportTxt = Join-Path $reportDir "pipeline-$timestamp.txt"

function Write-Step($msg) {
    Write-Host "`n>>> $msg" -ForegroundColor Cyan
}

function Invoke-Python($script, $args) {
    $result = python @script @args 2>&1
    $exitCode = $LASTEXITCODE
    return @{Output = $result; ExitCode = $exitCode}
}

# === STEP 0: Collect all available DOCX files ===
function Get-AvailableDocx {
    $files = @{}
    if (Test-Path $thesisDocxLocal) { $files["thesis_local"] = $thesisDocxLocal }
    if (Test-Path $thesisDocx) { $files["thesis_rd"] = $thesisDocx }
    if (Test-Path $fixedDocx) { $files["thesis_fixed"] = $fixedDocx }
    if (Test-Path $preFixDocx) { $files["thesis_pre_fix"] = $preFixDocx }
    if (Test-Path $refDocx) { $files["ref_style"] = $refDocx }
    if (Test-Path $refInDocx) { $files["ref_style_in"] = $refInDocx }
    if (Test-Path $englishRef) { $files["english_ref"] = $englishRef }
    return $files
}

# === STEP 1: Build thesis DOCX ===
function Step-Build {
    Write-Step "STEP 1/5: Build thesis DOCX from Markdown"
    $buildScript = Join-Path $tsDir "build-thesis.ps1"
    if (-not (Test-Path $buildScript)) {
        Write-Warning "Build script not found: $buildScript"
        return $false
    }
    & $buildScript build 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Build failed (exit code $LASTEXITCODE)"
        return $false
    }
    Write-Host "  [BUILD] Thesis DOCX built successfully" -ForegroundColor Green
    return $true
}

# === STEP 2: Verify thesis DOCX ===
function Step-Verify {
    Write-Step "STEP 2/5: Verify thesis DOCX (28 checks)"
    $targets = @()
    if (Test-Path $thesisDocx) { $targets += @{Name="R&D output"; Path=$thesisDocx} }
    if (Test-Path $thesisDocxLocal) { $targets += @{Name="Local output"; Path=$thesisDocxLocal} }
    
    $results = @{}
    foreach ($t in $targets) {
        $pyScript = Join-Path $styleDir "verify_docx_checks.py"
        $r = Invoke-Python @($pyScript, $t.Path, "--json")
        $parsed = if ($r.Output -join "`n" | ConvertFrom-Json 2>$null) {
            $r.Output -join "`n" | ConvertFrom-Json
        } else {
            @{summary=@{passed=0;failed=0;total=0}}
        }
        $results[$t.Name] = @{
            path = $t.Path
            passed = $parsed.summary.passed
            failed = $parsed.summary.failed
            total = $parsed.summary.total
        }
        Write-Host "  [VERIFY] $($t.Name): $($parsed.summary.passed)/$($parsed.summary.total) passed" -ForegroundColor $(if ($parsed.summary.failed -eq 0) {"Green"} else {"Yellow"})
    }
    return $results
}

# === STEP 3: Measure metrics ===
function Step-Measure {
    Write-Step "STEP 3/5: Measure thesis metrics"
    if (-not (Test-Path $thesisDocx)) {
        Write-Warning "No thesis DOCX to measure"
        return @{}
    }
    $measurer = Join-Path $styleDir "measure-thesis.py"
    $r = Invoke-Python @($measurer, $thesisDocx, $sourceMd)
    $parsed = $r.Output -join "`n" | ConvertFrom-Json 2>$null
    if ($parsed) {
        Write-Host "  [MEASURE] $($parsed.paragraph_count)p $($parsed.table_count)tbl $($parsed.file_size_kb)KB" -ForegroundColor Green
    }
    return @{Raw = $r.Output -join "`n"}
}

# === STEP 4: Diff comparison ===
function Step-Diff {
    Write-Step "STEP 4/5: Diff comparison across all thesis versions"
    $files = Get-AvailableDocx
    $diffs = @()
    
    $main = $null
    if ($files.ContainsKey("thesis_rd")) { $main = $files["thesis_rd"] }
    elseif ($files.ContainsKey("thesis_local")) { $main = $files["thesis_local"] }
    
    if (-not $main) {
        Write-Warning "No main thesis DOCX for comparison"
        return $diffs
    }
    
    $comparisons = @()
    foreach ($kv in $files.GetEnumerator()) {
        $key = $kv.Key; $path = $kv.Value
        if ($path -ne $main -and ($key -match "thesis_" -or $key -match "ref_style")) {
            $comparisons += @{Name = $key; Path = $path}
        }
    }
    
    $diffScript = Join-Path $styleDir "diff-thesis.py"
    foreach ($c in $comparisons) {
        Write-Host "  [DIFF] Comparing thesis vs $($c.Name)..." -ForegroundColor Yellow
        $r = Invoke-Python @($diffScript, $main, $c.Path, "--json")
        $rawOutput = $r.Output -join "`n"
        $parsed = try { $rawOutput | ConvertFrom-Json } catch { $null }
        if ($parsed) {
            $diffs += $parsed
            $s = $parsed.summary
            Write-Host "    H1 sim=$($s.h1_similarity)% H2 sim=$($s.h2_similarity)% H3 sim=$($s.h3_similarity)% size delta=$($s.size_diff_kb)KB" -ForegroundColor Gray
        }
    }
    return $diffs
}

# === STEP 5: Completeness audit ===
function Step-Audit {
    Write-Step "STEP 5/5: Completeness audit"
    $targets = @()
    if (Test-Path $thesisDocx) { $targets += @{Name="R&D thesis"; Path=$thesisDocx} }
    if (Test-Path $thesisDocxLocal) { $targets += @{Name="Local thesis"; Path=$thesisDocxLocal} }
    
    $audits = @()
    $auditScript = Join-Path $styleDir "audit-thesis.py"
    foreach ($t in $targets) {
        Write-Host "  [AUDIT] Auditing $($t.Name)..." -ForegroundColor Yellow
        $r = Invoke-Python @($auditScript, $t.Path, "--json")
        $parsed = $r.Output -join "`n" | ConvertFrom-Json 2>$null
        if ($parsed) {
            $audits += @{Name = $t.Name; Result = $parsed}
            $s = $parsed.summary
            Write-Host "    Score: $($s.passed)/$($s.total) ($($s.score_pct)%)" -ForegroundColor $(if ($s.score_pct -ge 80) {"Green"} elseif ($s.score_pct -ge 60) {"Yellow"} else {"Red"})
        }
    }
    return $audits
}

# === Generate report ===
function Write-Report($data) {
    $lines = @()
    $lines += "=" * 80
    $lines += "  THESIS DOCX PIPELINE REPORT"
    $lines += "  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $lines += "=" * 80
    
    # Available files
    $lines += "`n── Available DOCX Files ──"
    foreach ($kv in $data.Available.GetEnumerator()) {
        $lines += "  $($kv.Key): $($kv.Value)"
    }
    
    # Build step
    $lines += "`n── Build ──"
    $lines += "  Status: $(if ($data.Build) {'OK'} else {'SKIPPED/FAILED'})"
    
    # Verify results
    $lines += "`n── Verify ──"
    foreach ($kv in $data.Verify.GetEnumerator()) {
        $v = $kv.Value
        $lines += "  $($kv.Name): $($v.passed)/$($v.total) passed"
    }
    
    # Measure
    $lines += "`n── Metrics ──"
    if ($data.Measure -and $data.Measure.Raw) {
        $lines += "  $($data.Measure.Raw)"
    }
    
    # Diffs
    $lines += "`n── Diff Comparisons ──"
    if ($data.Diffs.Count -eq 0) {
        $lines += "  No comparisons available"
    }
    foreach ($d in $data.Diffs) {
        if ($d.summary) {
            $s = $d.summary
            $lines += "  Ref: $($d.ref.label) vs Comp: $($d.comp.label)"
            $lines += "    H1 similarity: $($s.h1_similarity)% | H2: $($s.h2_similarity)% | H3: $($s.h3_similarity)%"
            $lines += "    Size diff: $($s.size_diff_kb)KB | Para diff: $($s.para_diff)"
            if ($d.structural_diffs) {
                foreach ($df in $d.structural_diffs) {
                    $lines += "    $($df.arrow) $($df.field): $($df.ref) → $($df.comp)"
                }
            }
        }
    }
    
    # Audit
    $lines += "`n── Completeness Audits ──"
    foreach ($a in $data.Audits) {
        $r = $a.Result
        $lines += "  $($a.Name): $($r.summary.passed)/$($r.summary.total) ($($r.summary.score_pct)%)"
        foreach ($cat in $r.categories.PSObject.Properties) {
            $lines += "    $($cat.Name): $($cat.Value.passed)/$($cat.Value.total)"
        }
        # Show failed required checks
        $reqFails = $r.checks | Where-Object { -not $_.passed -and $_.severity -eq "Required" }
        if ($reqFails) {
            $lines += "    FAILED REQUIRED:"
            foreach ($c in $reqFails) {
                $lines += "      FAIL $($c.code): $($c.name) — $($c.message)"
            }
        } else {
            $lines += "    All required checks PASS"
        }
    }
    
    $lines += "`n" + "=" * 80
    $lines += "  END OF PIPELINE REPORT"
    $lines += "=" * 80
    
    $report = $lines -join "`n"
    
    # Write text report
    $reportTxt = Join-Path $reportDir "pipeline-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $report | Out-File -FilePath $reportTxt -Encoding utf8
    Write-Host "`nReport written to: $reportTxt" -ForegroundColor Green
    
    # Write JSON report
    $jsonData = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        build = $data.Build
        verify = $data.Verify
        diffs = $data.Diffs
        audits = $data.Audits
        available = $data.Available
    }
    $jsonPath = $reportTxt -replace '\.txt$', '.json'
    $jsonData | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding utf8
    Write-Host "JSON report: $jsonPath" -ForegroundColor Gray
    
    return $report
}

# === MAIN PIPELINE ===
switch ($Command) {
    "all" {
        $pipelineData = @{
            Available = (Get-AvailableDocx)
            Build = $false
            Verify = @{}
            Measure = @{}
            Diffs = @()
            Audits = @()
        }
        
        if (-not $SkipBuild) {
            $pipelineData.Build = Step-Build
        }
        
        $pipelineData.Verify = Step-Verify
        $pipelineData.Measure = Step-Measure
        $pipelineData.Diffs = Step-Diff
        $pipelineData.Audits = Step-Audit
        
        $report = Write-Report $pipelineData
        Write-Host "`n$report"
        
        # Write summary
        Write-Host "`n" -NoNewline
        Write-Host "═══ PIPELINE COMPLETE ═══" -ForegroundColor Magenta
        $vPassed = @($pipelineData.Verify.Values | ForEach-Object { $_.passed })
        $vTotal = @($pipelineData.Verify.Values | ForEach-Object { $_.total })
        if ($vTotal) { Write-Host "  Verify: $($vPassed | Measure-Object -Sum | Select-Object -ExpandProperty Sum)/$($vTotal | Measure-Object -Sum | Select-Object -ExpandProperty Sum)" -ForegroundColor Green }
        $aScore = @($pipelineData.Audits | ForEach-Object { $_.Result.summary.score_pct })
        if ($aScore) { $aScore | ForEach-Object { Write-Host "  Audit score: $_%" -ForegroundColor $(if ($_ -ge 80) {"Green"} elseif ($_ -ge 60) {"Yellow"} else {"Red"}) } }
    }
    
    "build" { Step-Build }
    "verify" { Step-Verify }
    "measure" { Step-Measure }
    "diff" { Step-Diff }
    "audit" { Step-Audit }
    "report" { 
        # Generate report from existing results
        $latestJson = Get-ChildItem $reportDir -Filter "*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestJson) {
            Get-Content $latestJson.FullName
        } else {
            Write-Warning "No previous pipeline reports found"
        }
    }
    
    default {
        Write-Host "Usage: docx-pipeline.ps1 [command]"
        Write-Host "  all       Full pipeline: build → verify → measure → diff → audit → report"
        Write-Host "  build     Build thesis DOCX from markdown"
        Write-Host "  verify    Run 28 verification checks"
        Write-Host "  measure   Record thesis metrics"
        Write-Host "  diff      Compare thesis versions"
        Write-Host "  audit     Completeness audit"
        Write-Host "  report    Show last pipeline report"
        Write-Host ""
        Write-Host "Options:"
        Write-Host "  -SkipBuild  Skip the build step (use existing DOCX)"
    }
}
