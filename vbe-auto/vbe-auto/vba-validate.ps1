<#
.SYNOPSIS
    Pre-build VBA source validator — catches syntax errors BEFORE compile
    Scans all .bas/.frm files for common VBA-breaking issues
    No Excel/COM needed — pure text analysis
#>

param(
    [string]$SourceDir = "Software_Surgical_Edit\VBA_Modules"
)

$global:errors = @()
$global:warnings = @()

function Add-Error($msg) { $global:errors += $msg }
function Add-Warning($msg) { $global:warnings += $msg }

function Test-BasFile {
    param([string]$Path)
    
    $name = Split-Path $Path -Leaf
    $raw = [System.IO.File]::ReadAllBytes($Path)
    $content = [System.Text.Encoding]::Default.GetString($raw)
    $lines = $content -split "`r?`n"
    
    # --- CHECK 1: Non-ASCII bytes that aren't valid Windows-1252 ---
    for ($i = 0; $i -lt $raw.Length; $i++) {
        $b = $raw[$i]
        if ($b -gt 127) {
            # Valid Windows-1252 range: 0x80-0x9F are control chars
            # 0xA0-0xFF are valid accented chars and symbols
            if ($b -ge 0x80 -and $b -le 0x9F) {
                Add-Error "$name : Invalid control byte 0x$('{0:X2}' -f $b) at position $i"
            }
        }
    }
    
    # --- CHECK 2: PHP/ASP/template artifacts ---
    $patterns = @(
        @{Pattern='%>'; Severity='Error'; Msg='PHP closing tag artifact'},
        @{Pattern='<?'; Severity='Error'; Msg='PHP opening tag artifact'},
        @{Pattern='<%='; Severity='Error'; Msg='ERB template artifact'},
        @{Pattern='{{', Severity='Warning'; Msg='Mustache template artifact (maybe intentional in string)'},
        @{Pattern='}}', Severity='Warning'; Msg='Mustache closing artifact'},
        @{Pattern='`(?!")', Severity='Error'; Msg='Backtick character (not valid VBA)'}
    )
    
    foreach ($p in $patterns) {
        $matches = [regex]::Matches($content, $p.Pattern)
        foreach ($m in $matches) {
            $lineNo = ($content.Substring(0, $m.Index) -split "`n").Count
            if ($p.Severity -eq 'Error') {
                Add-Error "$name line $lineNo : $($p.Msg) at '$($m.Value)'"
            } else {
                Add-Warning "$name line $lineNo : $($p.Msg)"
            }
        }
    }
    
    # --- CHECK 3: Line continuation with comment between ---
    for ($i = 0; $i -lt $lines.Count - 1; $i++) {
        $line = $lines[$i]
        $nextLine = $lines[$i + 1]
        if ($line -match '_$' -and $nextLine -match '^\s*''') {
            Add-Error "$name line $($i+1) : Comment between line continuation and next line (VBA parser breaks)"
        }
    }
    
    # --- CHECK 4: UTF-8 BOM ---
    if ($raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF) {
        Add-Error "$name : UTF-8 BOM detected (VBA chokes on this)"
    }
    
    # --- CHECK 5: Attribute VB_Name missing ---
    $hasAttribute = $lines | Where-Object { $_ -match '^Attribute VB_Name' }
    if (-not $hasAttribute) {
        Add-Error "$name : Missing 'Attribute VB_Name = ...' header"
    }
    
    # --- CHECK 6: Option Explicit missing ---
    $hasOptionExplicit = $lines | Where-Object { $_ -match '^\s*Option\s+Explicit' }
    if (-not $hasOptionExplicit) {
        Add-Warning "$name : Missing Option Explicit"
    }
    
    # --- CHECK 7: Empty file or too short ---
    if ($lines.Count -lt 3) {
        Add-Error "$name : File is too short ($($lines.Count) lines)"
    }
    
    # --- CHECK 8: Line too long (>1000 chars) ---
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -gt 1000) {
            Add-Warning "$name line $($i+1) : Very long line ($($lines[$i].Length) chars)"
        }
    }
}

Write-Host "`n" -NoNewline
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "|        VBA Pre-Build Validator              |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host ""

# Resolve source directory
$srcDir = Resolve-Path $SourceDir -ErrorAction SilentlyContinue
if (-not $srcDir) {
    Write-Host "Source directory not found: $SourceDir" -ForegroundColor Red
    exit 1
}

Write-Host "Scanning: $srcDir" -ForegroundColor Gray
Write-Host ""

$files = Get-ChildItem -Path $srcDir -Include "*.bas","*.frm" -Recurse | Sort-Object Name

foreach ($file in $files) {
    Test-BasFile -Path $file.FullName
}

# --- SUMMARY ---
$totalFiles = $files.Count
$cleanFiles = $totalFiles - ($global:errors | Where-Object {$_} | Select-Object -Unique | ForEach-Object { 
    $_.Split(':')[0] 
} | Select-Object -Unique).Count

Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "|                  RESULTS                      |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host ""

if ($global:errors.Count -eq 0 -and $global:warnings.Count -eq 0) {
    Write-Host "  [PASS] ALL $totalFiles FILES PASS -- NO ISSUES" -ForegroundColor Green
} else {
    Write-Host "  Files scanned: $totalFiles" -ForegroundColor Gray
    Write-Host "  Errors:       $($global:errors.Count)" -ForegroundColor $(if($global:errors.Count -gt 0){'Red'}else{'Green'})
    Write-Host "  Warnings:     $($global:warnings.Count)" -ForegroundColor $(if($global:warnings.Count -gt 0){'Yellow'}else{'Green'})
    
    if ($global:errors.Count -gt 0) {
        Write-Host ""
        Write-Host "-- ERRORS -----------------------------------------" -ForegroundColor Red
        $global:errors | ForEach-Object { Write-Host "  [FAIL] $_" -ForegroundColor Red }
    }
    
    if ($global:warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "-- WARNINGS ---------------------------------------" -ForegroundColor Yellow
        $global:warnings | ForEach-Object { Write-Host "  [WARN] $_" -ForegroundColor Yellow }
    }
}

Write-Host ""
Write-Host "Build recommendation:" -NoNewline -ForegroundColor Cyan
if ($global:errors.Count -eq 0) {
    Write-Host " [PASS] SAFE TO BUILD" -ForegroundColor Green
} else {
    Write-Host " [FAIL] FIX ERRORS FIRST" -ForegroundColor Red
    Write-Host ""
    Write-Host "HINT: Most VBA encoding errors come from UTF-8 special characters" -ForegroundColor Yellow
    Write-Host "      that VBA can't parse. Check comments and string literals" -ForegroundColor Yellow
    Write-Host "      for: accent marks, special punctuation, and symbols." -ForegroundColor Yellow
}
