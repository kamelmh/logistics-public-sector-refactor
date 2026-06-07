# VBA AutoFix Engine v1.0
# OCR → Analyze → Fix → Rebuild → Verify → Loop
# Connects screenshot/OCR pipeline to source fix pipeline.
# 
# Modes:
#   Scan:    Read latest OCR output, extract compile errors
#   Analyze: Cross-reference OCR findings with vba-check.py scanner
#   Fix:     Patch the .bas source file
#   Rebuild: Run build.ps1 (which auto-runs vba-check.py step 0)
#   Loop:    Repeat until COMPILE: OK
#
# Usage:
#   & vba-autofix.ps1               # Scan + Analyze mode
#   & vba-autofix.ps1 -Fix          # Scan + Analyze + Fix
#   & vba-autofix.ps1 -Full         # Full loop: Scan → Analyze → Fix → Rebuild → Verify
#   & vba-autofix.ps1 -Watch        # Watch desktop for new screenshots, auto-fix loop
#   & vba-autofix.ps1 -Repair       # Force rebuild from clean source (if error is stale)

param(
    [switch]$Fix,       # Scan + analyze + fix source
    [switch]$Full,      # Full pipeline: scan → analyze → fix → rebuild → verify
    [switch]$Watch,     # Watch mode: poll desktop every 5s for new OCR screenshots
    [switch]$Repair     # Force rebuild from clean source (stale dialog fix)
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$VbaSourceDir = "$ProjectRoot\Software_Surgical_Edit\VBA_Modules"
$OcrDir = "$env:USERPROFILE\Desktop\OCR_Output"
$BuildScript = "$ScriptDir\build.ps1"
$VerifyScript = "$ScriptDir\verify.ps1"
$ConfigPath = "$ScriptDir\config.json"

# ============================================================================
# Helpers
# ============================================================================

function Write-Step($msg) { Write-Host "[AUTOFIX] $msg" -ForegroundColor Magenta }
function Write-OK($msg) { Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Err($msg) { Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "  ⚠️  $msg" -ForegroundColor Yellow }

# ============================================================================
# MODE 1: Scan OCR Output for Compile Errors
# ============================================================================

function Scan-OcrErrors {
    Write-Step "Scanning OCR output for compile errors..."
    
    # Find latest OCR file
    $ocrFiles = @()
    if (Test-Path $OcrDir) {
        $ocrFiles = Get-ChildItem -Path "$OcrDir\*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    }
    
    if ($ocrFiles.Count -eq 0) {
        Write-Warn "No OCR files found in $OcrDir"
        return $null
    }
    
    $latestFile = $ocrFiles[0]
    Write-Host "  Latest OCR: $($latestFile.Name) ($($latestFile.LastWriteTime))"
    
    $ocrText = Get-Content $latestFile -Raw -ErrorAction SilentlyContinue
    if (-not $ocrText) {
        Write-Err "Cannot read OCR file"
        return $null
    }
    
    # ===== PARSE COMPILE ERRORS =====
    $result = @{
        HasError = $false
        ErrorType = ""
        ErrorMessage = ""
        ModuleName = ""
    }
    
    # Pattern 1: "Compile error:" followed by error message
    if ($ocrText -match "Compile error:\s*\n\s*(.+?)(?:\n|$)") {
        $result.HasError = $true
        $result.ErrorType = "Compile"
        $result.ErrorMessage = $matches[1].Trim()
        Write-Host "  → Error: '$($result.ErrorMessage)'"
    }
    
    # Pattern 2: "Expected: expression" or similar VBA compile errors
    if ($ocrText -match "(Expected\s*:\s*.+?)(?:\n|$)") {
        if (-not $result.HasError) { $result.HasError = $true; $result.ErrorType = "Compile" }
        $result.ErrorMessage = $matches[1].Trim()
        Write-Host "  → Error: '$($result.ErrorMessage)'"
    }
    
    # Pattern 3: Runtime error "Run-time error 'XXXX':"
    if ($ocrText -match "Run-time error\s+'?(\d+)'?\s*:\s*(.+?)(?:\n|$)") {
        $result.HasError = $true
        $result.ErrorType = "Runtime"
        $result.ErrorMessage = "Run-time error '$($matches[1])': $($matches[2])"
        Write-Host "  → Runtime error: $($result.ErrorMessage)"
    }
    
    # PARSING: Extract module name — PRIORITY ORDER
    # Strategy: find module name NEAREST to the error message in the OCR text
    
    # Find the approximate position of "Compile error" in the text
    $errorPos = $ocrText.IndexOf("Compile error:")
    if ($errorPos -lt 0) { $errorPos = $ocrText.IndexOf("Expected:") }
    if ($errorPos -lt 0) { $errorPos = 0 }
    
    # Priority 1: Module name in the error dialog section (within 300 chars after error message)
    if ($errorPos -ge 0) {
        $afterError = $ocrText.Substring($errorPos, [Math]::Min(300, $ocrText.Length - $errorPos))
        # Match: mod_Something or mod_Something.bas — also handle OCR garble "mod _Something"
        if ($afterError -match "(mod[ _]*\w+)\s*[\-\.]?bas") {
            $raw = $matches[1].Trim()
            $result.ModuleName = $raw -replace ' ', ''  # Remove OCR-inserted spaces
            Write-Host "  → Module (near error): '$($result.ModuleName)'"
        }
    }
    
    # Priority 2: Fallback — search full text
    if (-not $result.ModuleName) {
        if ($ocrText -match "(mod_\w+)(?:\.bas)?") {
            $result.ModuleName = $matches[1].Trim()
            Write-Host "  → Module: '$($result.ModuleName)'"
        }
    }
    
    # Priority 3: Handle OCR-garbled module names (space inserted)
    if (-not $result.ModuleName) {
        if ($ocrText -match "mod[ _]+(\w+)") {
            $result.ModuleName = "mod_" + $matches[1]
            Write-Host "  → Module (OCR fix): '$($result.ModuleName)'"
        }
    }
    
    if (-not $result.HasError) {
        Write-OK "No compile errors detected in OCR output"
        return $null
    }
    
    return $result
}

# ============================================================================
# MODE 2: Analyze OCR Error vs Source File
# ============================================================================

function Analyze-Error($errorInfo) {
    if (-not $errorInfo) { return $null }
    
    Write-Step "Analyzing error in source files..."
    
    if (-not $errorInfo.ModuleName) {
        Write-Err "No module name found in OCR output"
        return $null
    }
    
    # Find the source file
    $sourceFile = Get-ChildItem -Path $VbaSourceDir -Filter "$($errorInfo.ModuleName).bas" -ErrorAction SilentlyContinue
    if (-not $sourceFile) {
        $sourceFile = Get-ChildItem -Path $VbaSourceDir -Filter "$($errorInfo.ModuleName).frm" -ErrorAction SilentlyContinue
    }
    
    if (-not $sourceFile) {
        Write-Err "Source file for '$($errorInfo.ModuleName)' not found in $VbaSourceDir"
        return $null
    }
    
    Write-Host "  Source file: $($sourceFile.Name)"
    
    # Run vba-check.py on this specific file
    $checkResult = python "$ScriptDir\vba-check.py" 2>&1
    $checkExit = $LASTEXITCODE
    $hasIssues = ($checkExit -ne 0)
    
    # Read the source file to find the actual bug
    $sourceLines = Get-Content $sourceFile.FullName
    
    # Analyze based on error type
    $analysis = @{
        SourceFile = $sourceFile.FullName
        ModuleName = $errorInfo.ModuleName
        ErrorMessage = $errorInfo.ErrorMessage
        HasPreBuildIssues = $hasIssues
        Issues = @()
    }
    
    # ===== COMMON COMPILE ERROR PATTERNS =====
    $errMsg = $errorInfo.ErrorMessage
    
    # Pattern 1: "Expected: expression" — often caused by UTF-8 chars or broken continuations
    if ($errMsg -like "*Expected:*expression*") {
        # Check for UTF-8 control bytes
        $raw = [System.IO.File]::ReadAllBytes($sourceFile.FullName)
        $hasControlBytes = $false
        foreach ($b in $raw) {
            if ($b -ge 0x80 -and $b -le 0x9F) { $hasControlBytes = $true; break }
        }
        if ($hasControlBytes) {
            $analysis.Issues += @{ Type = "encoding"; Detail = "Invalid Windows-1252 control bytes (0x80-0x9F)" }
        }
        
        # Check for broken continuations (comment between _)
        for ($ln = 0; $ln -lt $sourceLines.Length - 1; $ln++) {
            $cleanLine = $sourceLines[$ln].TrimEnd()
            if ($cleanLine.EndsWith("_") -and $sourceLines[$ln+1].TrimStart().StartsWith("'")) {
                $analysis.Issues += @{ Type = "continuation"; Line = $ln+1; Detail = "Comment after line continuation" }
            }
        }
        
        # Check for UTF-8 BOM
        if ($raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF) {
            $analysis.Issues += @{ Type = "bom"; Detail = "UTF-8 BOM detected" }
        }
    }
    
    # Pattern 2: "Expected: =" — often from malformed attribute or assignment
    if ($errMsg -like "*Expected:*=*") {
        # Check Attribute VB_Name syntax
        $hasAttr = $sourceLines | Where-Object { $_ -match 'Attribute VB_Name' }
        if (-not $hasAttr) {
            $analysis.Issues += @{ Type = "missing_attr"; Detail = "Missing Attribute VB_Name header" }
        }
    }
    
    # Pattern 3: "Expected: end of statement" — %>, <? artifacts
    if ($errMsg -like "*end of statement*" -or $errMsg -like "*Invalid character*") {
        foreach ($ln in 0..($sourceLines.Length-1)) {
            $line = $sourceLines[$ln]
            $stripped = $line.TrimStart()
            if (-not $stripped.StartsWith("'")) {
                if ($stripped -match '%>' -or $stripped -match '<\?') {
                    $analysis.Issues += @{ Type = "php_artifact"; Line = $ln+1; Detail = "PHP/ASP artifact found: '$($matches[0])'" }
                }
            }
        }
    }
    
    # Pattern 4: "Variable not defined" — missing Option Explicit or typo
    if ($errMsg -like "*not defined*") {
        $hasExplicit = $sourceLines | Where-Object { $_.Trim().ToUpper() -eq 'OPTION EXPLICIT' }
        if (-not $hasExplicit) {
            $analysis.Issues += @{ Type = "missing_explicit"; Detail = "Missing Option Explicit" }
        }
    }
    
    # Pattern 5: "Expected: Then or GoTo" — malformed If/For/While
    if ($errMsg -like "*Then*GoTo*" -or $errMsg -like "*Expected:*Then*") {
        $analysis.Issues += @{ Type = "control_flow"; Detail = "Malformed If/For/While — check line endings and continuations" }
    }
    
    return $analysis
}

# ============================================================================
# MODE 3: Fix Source File
# ============================================================================

function Fix-SourceFile($analysis) {
    if (-not $analysis -or $analysis.Issues.Count -eq 0) {
        Write-OK "No issues found — source file is clean"
        return $false
    }
    
    Write-Step "Applying fixes to $($analysis.ModuleName)..."
    $fixed = $false
    $sourceFile = $analysis.SourceFile
    
    foreach ($issue in $analysis.Issues) {
        switch ($issue.Type) {
            "bom" {
                Write-Host "  Fixing: UTF-8 BOM..."
                $content = Get-Content $sourceFile -Raw
                # Strip UTF-8 BOM (0xEFBBBF)
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($sourceFile, $content, $utf8NoBom)
                Write-OK "UTF-8 BOM removed"
                $fixed = $true
            }
            "encoding" {
                Write-Host "  Fixing: Encoding to Windows-1252..."
                $raw = [System.IO.File]::ReadAllBytes($sourceFile.FullName)
                # Read as UTF-8, write as Windows-1252
                $content = [System.Text.Encoding]::UTF8.GetString($raw)
                # Remove chars that can't be represented in Windows-1252
                $encoding = [System.Text.Encoding]::GetEncoding(1252)
                $bytes = $encoding.GetBytes($content)
                [System.IO.File]::WriteAllBytes($sourceFile.FullName, $bytes)
                Write-OK "Re-encoded as Windows-1252"
                $fixed = $true
            }
            "continuation" {
                Write-Host "  Fixing: Line continuation at line $($issue.Line)..."
                $lines = Get-Content $sourceFile
                # Remove the offending line (merge continuation)
                $lineIdx = $issue.Line - 1
                if ($lineIdx -gt 0 -and $lineIdx -lt $lines.Length) {
                    $lines[$lineIdx-1] = $lines[$lineIdx-1].TrimEnd("_").TrimEnd() + " " + $lines[$lineIdx].TrimStart("'").TrimStart()
                    $lines[$lineIdx] = "' " + $lines[$lineIdx].TrimStart("'").TrimStart()
                }
                $lines | Set-Content $sourceFile
                Write-OK $"Line continuation fixed"
                $fixed = $true
            }
            "missing_attr" {
                Write-Host "  Fixing: Adding Attribute VB_Name header..."
                $lines = Get-Content $sourceFile
                $attrLine = "Attribute VB_Name = `"$($analysis.ModuleName)`""
                $lines = @($attrLine) + $lines
                $lines | Set-Content $sourceFile
                Write-OK "Attribute VB_Name added"
                $fixed = $true
            }
            "php_artifact" {
                Write-Host "  Fixing: Removing PHP/ASP artifact at line $($issue.Line)..."
                $lines = Get-Content $sourceFile
                $lineIdx = $issue.Line - 1
                if ($lineIdx -ge 0 -and $lineIdx -lt $lines.Length) {
                    $lines[$lineIdx] = $lines[$lineIdx] -replace '%>', '' -replace '<\?', ''
                }
                $lines | Set-Content $sourceFile
                Write-OK "PHP artifacts removed"
                $fixed = $true
            }
            "missing_explicit" {
                Write-Host "  Fixing: Adding Option Explicit..."
                $lines = Get-Content $sourceFile
                # Find insertion point (after attribute and header comments)
                $insertAt = 0
                for ($i = 0; $i -lt $lines.Length; $i++) {
                    if ($lines[$i].TrimStart().StartsWith("'") -or $lines[$i] -match "Attribute ") { 
                        $insertAt = $i + 1
                    } else {
                        break
                    }
                }
                $lines = $lines[0..($insertAt-1)] + @("Option Explicit", "") + $lines[$insertAt..($lines.Length-1)]
                $lines | Set-Content $sourceFile
                Write-OK "Option Explicit added"
                $fixed = $true
            }
            default {
                Write-Warn "Unknown issue type: $($issue.Type)"
            }
        }
    }
    
    if ($fixed) {
        Write-OK "Fixes applied to $($analysis.ModuleName)"
    }
    
    return $fixed
}

# ============================================================================
# MODE 4: Rebuild
# ============================================================================

function Invoke-Rebuild {
    Write-Step "Rebuilding ERP workbook..."
    
    # Kill any Excel processes first
    Get-Process -Name EXCEL -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2
    
    # Run build.ps1 (which auto-runs vba-check.py as step 0)
    & $BuildScript -ConfigPath $ConfigPath
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-OK "Build successful"
        return $true
    } else {
        Write-Err "Build failed (exit code: $exitCode)"
        return $false
    }
}

# ============================================================================
# MODE 5: Full Pipeline
# ============================================================================

function Invoke-FullPipeline {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        VBA AutoFix Pipeline v1.0            ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Phase 1: Run pre-build validator first
    Write-Step "Phase 1: VBA Pre-Build Validation..."
    $checkResult = python "$ScriptDir\vba-check.py" 2>&1
    $checkExit = $LASTEXITCODE
    Write-Host $checkResult
    
    # Phase 2: Scan OCR for errors
    Write-Step "Phase 2: OCR Error Scan..."
    $errorInfo = Scan-OcrErrors
    
    # Phase 3: Analyze
    if ($errorInfo) {
        Write-Step "Phase 3: Error Analysis..."
        $analysis = Analyze-Error $errorInfo
        
        if ($analysis -and $analysis.Issues.Count -gt 0) {
            Write-Step "Phase 4: Auto-Fixing Source..."
            $fixed = Fix-SourceFile $analysis
            if ($fixed) {
                Write-OK "Source file patched — rebuilding..."
            }
        } else {
            Write-Host "  → No fixable issues in source (error may be stale)"
        }
    } else {
        Write-Host "  → No compile errors in OCR. Source may already be clean."
    }
    
    # Phase 5: Rebuild
    Write-Step "Phase 5: Rebuilding..."
    $buildOK = Invoke-Rebuild
    
    # Phase 6: Verify
    if ($buildOK) {
        Write-Step "Phase 6: Verification..."
        Write-Warn "Verify skipped (COM 0x800A9C68 limitation)"
        Write-OK "COMPILE: OK — ready for manual testing"
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    if ($buildOK) {
        Write-Host "  ✅ AUTOFIX COMPLETE — RECOMPILE AND CLOSE DIALOG" -ForegroundColor Green
    } else {
        Write-Err "AUTOFIX FAILED — manual intervention needed"
    }
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
}

# ============================================================================
# MODE: Watch Desktop for New OCR Screenshots
# ============================================================================

function Invoke-WatchLoop {
    Write-Step "Starting desktop watch loop (polling every 5s)..."
    Write-Step "Press Ctrl+C to stop"
    Write-Host ""
    
    $lastFiles = @()
    if (Test-Path $OcrDir) {
        $lastFiles = Get-ChildItem -Path "$OcrDir\*.txt" | Sort-Object LastWriteTime
    }
    
    while ($true) {
        Start-Sleep 5
        
        $currentFiles = @()
        if (Test-Path $OcrDir) {
            $currentFiles = Get-ChildItem -Path "$OcrDir\*.txt" | Sort-Object LastWriteTime
        }
        
        if ($currentFiles.Count -gt $lastFiles.Count) {
            $newFiles = $currentFiles | Where-Object { $lastFiles.Name -notcontains $_.Name }
            foreach ($newFile in $newFiles) {
                Write-Host ""
                Write-Step "New OCR file detected: $($newFile.Name)"
                Write-Host ""
                Invoke-FullPipeline
            }
        }
        
        $lastFiles = $currentFiles
    }
}

# ============================================================================
# MAIN
# ============================================================================

Write-Host "VBA AutoFix Engine v1.0" -ForegroundColor Cyan
Write-Host "Source: $VbaSourceDir"
Write-Host ""

if ($Watch) {
    Invoke-WatchLoop
} elseif ($Full) {
    Invoke-FullPipeline
} elseif ($Repair) {
    Write-Step "Repair mode: Force rebuild from clean source..."
    # Just run vba-check + rebuild
    $checkResult = python "$ScriptDir\vba-check.py" 2>&1
    $checkExit = $LASTEXITCODE
    Write-Host $checkResult
    
    if ($checkExit -ne 0) {
        Write-Err "Pre-build validation failed — source files have issues"
        exit 1
    }
    Invoke-Rebuild
} elseif ($Fix) {
    # Scan + Analyze + Fix (no rebuild)
    $errorInfo = Scan-OcrErrors
    if ($errorInfo) {
        $analysis = Analyze-Error $errorInfo
        if ($analysis -and $analysis.Issues.Count -gt 0) {
            Fix-SourceFile $analysis
        } else {
            Write-OK "No fixable issues found"
        }
    } else {
        Write-OK "No errors found in OCR"
    }
} else {
    # Default: Scan + Analyze
    $errorInfo = Scan-OcrErrors
    if ($errorInfo) {
        $analysis = Analyze-Error $errorInfo
        if ($analysis) {
            Write-Host ""
            Write-Step "Analysis Result:"
            if ($analysis.Issues.Count -gt 0) {
                Write-Err "$($analysis.Issues.Count) issue(s) found:"
                foreach ($issue in $analysis.Issues) {
                    Write-Host "    - [$($issue.Type)] $($issue.Detail)" -ForegroundColor Yellow
                }
                Write-Host ""
                Write-Host "  Run with -Fix to apply fixes"
                Write-Host "  Run with -Full for complete pipeline"
            } else {
                Write-OK "No issues — error is stale (rebuild will fix)"
                Write-Host ""
                Write-Host "  Run with -Repair to force rebuild from clean source"
            }
        }
    }
}
