# VBA Watcher Loop v1.0
# Perpetual: Screenshot → OCR → Detect Compile Error → AutoFix → Rebuild → Loop
# Runs as background job, polls every 5 seconds.
# Uses: tesseract.exe + vba-autofix.ps1 + vba-check.py + build.ps1

param(
    [int]$Interval = 5,        # Polling interval in seconds
    [switch]$Background,       # Run as background job
    [switch]$Once             # Single shot mode (for testing)
)

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$OcrDir = "$env:USERPROFILE\Desktop\OCR_Output"
$AutoFixScript = "$ScriptDir\vba-autofix.ps1"
$CheckScript = "$ScriptDir\vba-check.py"
$BuildScript = "$ScriptDir\build.ps1"
$ConfigPath = "$ScriptDir\vbe-auto-config.json"

# Ensure OCR output directory exists
if (-not (Test-Path $OcrDir)) { New-Item -ItemType Directory -Path $OcrDir -Force | Out-Null }

$watcherVersion = "vba-watcher-loop-v1"
$loopCount = 0
$fixCount = 0

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $msg"
}

function Take-VbeScreenshot {
    <#
    .SYNOPSIS
    Captures the VBE window using PrintWindow API (captures behind windows).
    Falls back to full-screen capture if VBE window not found.
    #>
    $path = "$OcrDir\watcher_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    
    # Define Win32 API for window capture
    $win32 = Add-Type -MemberDefinition @"
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, int nFlags);
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
        
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
        
        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);
        
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
        
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left; public int Top; public int Right; public int Bottom;
        }
        
        public static IntPtr FindVbeWindow() {
            IntPtr found = IntPtr.Zero;
            EnumWindows((hWnd, lParam) => {
                System.Text.StringBuilder sb = new System.Text.StringBuilder(512);
                GetWindowText(hWnd, sb, 512);
                string title = sb.ToString();
                if (title.Contains("Microsoft Visual Basic for Applications") && IsWindowVisible(hWnd)) {
                    found = hWnd;
                    return false; // Stop enumerating
                }
                return true;
            }, IntPtr.Zero);
            return found;
        }
"@ -Name "Win32Capture" -Namespace "Win32" -PassThru -ErrorAction SilentlyContinue
    
    try {
        # First try: Find VBE window and capture it with PrintWindow
        $vbeHwnd = [Win32Capture]::FindVbeWindow()
        
        if ($vbeHwnd -ne [IntPtr]::Zero) {
            Write-Log "  VBE window found (HWND: $vbeHwnd)"
            $rect = New-Object Win32Capture+RECT
            [Win32Capture]::GetWindowRect($vbeHwnd, [ref]$rect) | Out-Null
            $w = $rect.Right - $rect.Left
            $h = $rect.Bottom - $rect.Top
            
            if ($w -gt 0 -and $h -gt 0) {
                $bitmap = New-Object System.Drawing.Bitmap $w, $h
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $hdc = $graphics.GetHdc()
                $result = [Win32Capture]::PrintWindow($vbeHwnd, $hdc, 0)
                $graphics.ReleaseHdc($hdc)
                $graphics.Dispose()
                
                if ($result) {
                    $bitmap.Save("$path.png", [System.Drawing.Imaging.ImageFormat]::Png)
                    $bitmap.Dispose()
                    Write-Log "  VBE window captured: ${w}x${h}"
                    return "$path.png"
                }
                $bitmap.Dispose()
            }
        }
        
        # Fallback: Full-screen capture (if VBE not found)
        Write-Log "  VBE not found, using full-screen capture..."
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
        $graphics.Dispose()
        $bitmap.Save("$path.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        return "$path.png"
        
    } catch {
        Write-Log "Screenshot failed: $_"
        return $null
    }
}

function Take-Screenshot {
    # Alias for backward compatibility
    return Take-VbeScreenshot
}

function Run-Ocr($imagePath) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($imagePath)
    $outDir = [System.IO.Path]::GetDirectoryName($imagePath)
    $outPath = Join-Path $outDir $baseName
    & "C:\Program Files\Tesseract-OCR\tesseract.exe" $imagePath $outPath --psm 6 2>&1 | Out-Null
    $txtPath = "$outPath.txt"
    if (Test-Path $txtPath) {
        return Get-Content $txtPath -Raw
    }
    return $null
}

function Has-CompileError($ocrText) {
    if (-not $ocrText) { return $false }
    # Multiple patterns for compile errors
    $patterns = @(
        'Compile error:',
        'Expected:',
        'Run-time error',
        'Variable not defined',
        'Method not found',
        'Sub or Function not defined',
        'Invalid character',
        'Type mismatch',
        'Object required',
        'Argument not optional',
        'ByRef argument type mismatch',
        'Only comments may appear after End Sub',
        'End Sub',
        'End Function',
        'End If',
        'Else without If',
        'Loop without Do',
        'Wend without While',
        'Next without For'
    )
    foreach ($p in $patterns) {
        if ($ocrText -match [regex]::Escape($p)) {
            Write-Log "Detected pattern: '$p'"
            return $true
        }
    }
    return $false
}

function Invoke-WatcherCycle {
    param([switch]$Verbose)
    $script:loopCount++
    
    Write-Log "[$loopCount] Taking screenshot..."
    $screenshotPath = Take-Screenshot
    if (-not $screenshotPath) {
        Write-Log "  ⚠ Screenshot failed, retrying..."
        return $false
    }
    
    Write-Log "  OCR scanning..."
    $ocrText = Run-Ocr $screenshotPath
    if (-not $ocrText) {
        Write-Log "  ⚠ OCR produced no output"
        return $false
    }
    
    if ($Verbose) {
        Write-Log "  OCR text length: $($ocrText.Length) chars"
    }
    
    if (Has-CompileError $ocrText) {
        $script:fixCount++
        Write-Log "  🚨 COMPILE ERROR DETECTED! Running autofix pipeline..."
        Write-Log "  OCR sample: $($ocrText.Substring(0, [Math]::Min(200, $ocrText.Length)))"
        
        # Save error OCR for audit
        $errorLogPath = "$OcrDir\error_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $ocrText | Out-File -FilePath $errorLogPath -Encoding utf8
        Write-Log "  Error log saved: $errorLogPath"
        
        # Phase 1: Run vba-check.py first
        Write-Log "  Phase 1: VBA source validation..."
        $checkResult = python $CheckScript 2>&1
        Write-Host $checkResult
        
        # Phase 2: Try autofix scan+analyze
        Write-Log "  Phase 2: Running autofix analysis..."
        & $AutoFixScript 2>&1 | ForEach-Object { Write-Host "    $_" }
        
        # Phase 3: Force rebuild
        Write-Log "  Phase 3: Force rebuild..."
        Get-Process -Name EXCEL -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep 2
        & $BuildScript -ConfigPath $ConfigPath 2>&1 | ForEach-Object { Write-Host "    $_" }
        
        # Phase 4: Verify
        Write-Log "  Phase 4: Re-checking sources..."
        $checkResult = python $CheckScript 2>&1
        Write-Host $checkResult
        
        Write-Log "  ✅ Fix cycle #$fixCount complete"
        return $true
    } else {
        if ($Verbose) { Write-Log "  ✅ No compile error detected" }
        # Clean up old screenshots (keep last 5)
        Get-ChildItem "$OcrDir\watcher_scan_*.png" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -Skip 5 | Remove-Item -Force
        return $false
    }
}

# ============================================================================
# MAIN
# ============================================================================

Write-Log "╔══════════════════════════════════════════════╗"
Write-Log "║       VBA Watcher Loop $watcherVersion        ║"
Write-Log "╚══════════════════════════════════════════════╝"
Write-Log "OCR dir: $OcrDir"
Write-Log "Polling: every ${Interval}s"
Write-Log ""

if ($Once) {
    # Single shot mode
    Invoke-WatcherCycle -Verbose
    exit
}

if ($Background) {
    # If -Background is set, this instance just starts the job and returns
    $jobName = "VBAWatcherLoop"
    $scriptBlock = {
        param($int, $autoFixScript, $checkScript, $buildScript, $configPath, $ocrDir, $projectRoot)
        # Reload the script in the job context
        & $autoFixScript.Replace('vba-autofix.ps1', 'vba-watcher-loop.ps1') @{ Interval = $int }
    }
    
    $job = Start-Job -Name $jobName -ScriptBlock {
        param($Int, $OcrDir, $AutoFixScript, $CheckScript, $BuildScript, $ConfigPath, $ProjectRoot)
        Set-Location $ProjectRoot
        
        function Write-Log($msg) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Output "[$timestamp] $msg"
        }
        
        function Take-Screenshot {
            $path = "$OcrDir\watcher_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            try {
                $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
                $graphics.Dispose()
                $bitmap.Save("$path.png", [System.Drawing.Imaging.ImageFormat]::Png)
                $bitmap.Dispose()
                return "$path.png"
            } catch { return $null }
        }
        
        function Run-Ocr($imagePath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($imagePath)
            $outPath = Join-Path $OcrDir $baseName
            & "C:\Program Files\Tesseract-OCR\tesseract.exe" $imagePath $outPath --psm 6 2>$null
            $txtPath = "$outPath.txt"
            if (Test-Path $txtPath) { return Get-Content $txtPath -Raw }
            return $null
        }
        
        function Has-CompileError($ocrText) {
            if (-not $ocrText) { return $false }
            return ($ocrText -match 'Compile error:' -or 
                    $ocrText -match 'Expected:' -or
                    $ocrText -match 'Run-time error')
        }
        
        $loopCount = 0
        $fixCount = 0
        
        while ($true) {
            $loopCount++
            $screenshotPath = Take-Screenshot
            if ($screenshotPath) {
                $ocrText = Run-Ocr $screenshotPath
                if ($ocrText -and (Has-CompileError $ocrText)) {
                    $fixCount++
                    Write-Log "🚨 COMPILE ERROR #$fixCount detected! Running autofix..."
                    
                    # Save error OCR
                    $ocrText | Out-File -FilePath "$OcrDir\error_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt" -Encoding utf8
                    
                    # Kill Excel and rebuild
                    Get-Process -Name EXCEL -ErrorAction SilentlyContinue | Stop-Process -Force
                    Start-Sleep 2
                    
                    # Run build
                    & $BuildScript -ConfigPath $ConfigPath 2>&1 | ForEach-Object { Write-Log "  $_" }
                    
                    # Verify
                    python $CheckScript 2>&1 | ForEach-Object { Write-Log "  $_" }
                    
                    Write-Log "✅ Fix cycle #$fixCount complete"
                }
            }
            # Cleanup old screenshots
            Get-ChildItem "$OcrDir\watcher_scan_*.png" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -Skip 5 | Remove-Item -Force
            Start-Sleep $Int
        }
    } -ArgumentList $Interval, $OcrDir, $AutoFixScript, $CheckScript, $BuildScript, $ConfigPath, $ProjectRoot
    
    Write-Log "Watcher started as background job: $($job.Name) (Id: $($job.Id))"
    Write-Log "It will poll every ${Interval}s, screenshot → OCR → detect error → rebuild"
    Write-Log ""
    Write-Log "To check status:  Get-Job -Name VBAWatcherLoop | Receive-Job"
    Write-Log "To stop:          Stop-Job -Name VBAWatcherLoop; Remove-Job -Name VBAWatcherLoop"
    return
}

# ============================================================================
# Foreground loop mode (runs continuously in this terminal)
# ============================================================================

Write-Log "Starting foreground watcher loop (Ctrl+C to stop)..."
Write-Log ""

while ($true) {
    $startTime = Get-Date
    Invoke-WatcherCycle
    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    $sleepTime = [Math]::Max(1, $Interval - $elapsed)
    Start-Sleep $sleepTime
}
