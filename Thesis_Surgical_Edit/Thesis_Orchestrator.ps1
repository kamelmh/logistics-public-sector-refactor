# Thesis_Surgical_Edit/Thesis_Orchestrator.ps1
# Regulated pipeline for Thesis Build, Fix, and Verification

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$DocPath = Join-Path $ScriptDir "output/Memoire_DSS_Logistique_ElBayadh.docx"
$ReportPath = Join-Path $ScriptDir "thesis_audit_report.json"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

function Log-Message {
    param([string]$Message, [string]$Level = "INFO")
    $Color = switch($Level) {
        "INFO"  { "White" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        Default { "White" }
    }
    Write-Host "[$Level] $(Get-Date -Format 'HH:mm:ss') - $Message" -ForegroundColor $Color
}

try {
    # 1. Build raw DOCX
    Log-Message "Step 1: Building raw DOCX..."
    & (Join-Path $ScriptDir "build-thesis.ps1")
    if (!(Test-Path $DocPath)) { throw "Build failed: $DocPath not found." }
    Log-Message "Build complete: $DocPath" "SUCCESS"

    # 2. Initial Audit
    Log-Message "Step 2: Performing initial audit..."
    Push-Location $ScriptDir
    try {
        python Thesis_Inspector.py $DocPath
        if (!(Test-Path $ReportPath)) { throw "Audit failed: $ReportPath not found." }
        $Audit = Get-Content $ReportPath | ConvertFrom-Json
    } finally {
        Pop-Location
    }
    Log-Message "Initial audit status: $($Audit.status)"

    # 3. Apply Fixes
    Log-Message "Step 3: Applying fixes from audit report..."
    Push-Location $ScriptDir
    try {
        python Thesis_Fixer.py $DocPath $ReportPath
        $FixedDoc = $DocPath.Replace('.docx', '_fixed.docx')
        if (Test-Path $FixedDoc) {
            Move-Item -Path $FixedDoc -Destination $DocPath -Force
            Log-Message "Fixed document promoted to primary source." "SUCCESS"
        } else {
            throw "Fixer failed: $FixedDoc not found."
        }
    } finally {
        Pop-Location
    }
    Log-Message "Fixes applied." "SUCCESS"

    # 4. Force Field Updates (F9)
    Log-Message "Step 4: Forcing field updates via COM..."
    Push-Location $ScriptDir
    try {
        python Thesis_COM_Control.py update $DocPath
    } finally {
        Pop-Location
    }
    Log-Message "Field updates forced." "SUCCESS"

    # 5. Final Verification
    Log-Message "Step 5: Final verification audit..."
    Push-Location $ScriptDir
    try {
        python Thesis_Inspector.py $DocPath
        if (!(Test-Path $ReportPath)) { throw "Verification failed: $ReportPath not found." }
        $FinalAudit = Get-Content $ReportPath | ConvertFrom-Json
    } finally {
        Pop-Location
    }
    Log-Message "Final audit status: $($FinalAudit.status)"

    if ($FinalAudit.status -ne "PASS") {
        throw "QUALITY GATE FAILED: Final audit status is $($FinalAudit.status). Manual intervention required."
    }

    # 6. PDF Promotion
    Log-Message "Quality Gate PASSED. Promoting to PDF..." "SUCCESS"
    # Using pandoc for PDF promotion
    $pandoc = "C:\Users\ADMINISTRATOR\AppData\Local\Pandoc\pandoc.exe"
    if (-not (Test-Path $pandoc)) {
        $pandoc = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    }
    
    if ($pandoc) {
        $pdfPath = Join-Path (Join-Path $ScriptDir "output") "Memoire_DSS_Logistique_ElBayadh.pdf"
        & $pandoc $DocPath -o $pdfPath
        if ($LASTEXITCODE -eq 0) {
            Log-Message "PDF promoted successfully: $pdfPath" "SUCCESS"
        } else {
            Log-Message "PDF promotion failed (Pandoc exit code $LASTEXITCODE). Check PDF engine installation." "WARN"
        }
    } else {
        Log-Message "Pandoc not found. Skipping PDF promotion." "WARN"
    }

} catch {
    Log-Message "PIPELINE FAILURE: $($_.Exception.Message)" "ERROR"
    
    # Save failure artifacts
    $FailDoc = Join-Path $ScriptDir "Memoire_FAIL_$Timestamp.docx"
    $FailReport = Join-Path $ScriptDir "failure_report.txt"
    
    if (Test-Path $DocPath) {
        Copy-Item $DocPath $FailDoc
        Log-Message "Saved failure document to $FailDoc" "WARN"
    }
    
    "Pipeline failure at $(Get-Date)`nError: $($_.Exception.Message)" | Out-File $FailReport
    Log-Message "Saved failure report to $FailReport" "WARN"
    
    exit 1
}
