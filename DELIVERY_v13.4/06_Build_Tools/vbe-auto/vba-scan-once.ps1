# VBA Scan-Once: Bring VBE to front -> Screenshot -> OCR -> Detect -> Fix
$OcrDir = "$env:USERPROFILE\Desktop\OCR_Output"
$BuildScript = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\vbe-auto\build.ps1"
$ConfigPath = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\vbe-auto\config.json"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Win32Find {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    public static IntPtr FindWindow(string p) {
        IntPtr f = IntPtr.Zero;
        EnumWindows((h, l) => {
            StringBuilder s = new StringBuilder(512);
            GetWindowText(h, s, 512);
            if (s.ToString().Contains(p) && IsWindowVisible(h)) { f = h; return false; }
            return true;
        }, IntPtr.Zero);
        return f;
    }
}
"@ -ErrorAction SilentlyContinue

Write-Host "=== VBA Scan-Once ===" -ForegroundColor Cyan

# Step 1: Find VBE
$hwnd = [Win32Find]::FindWindow("Microsoft Visual Basic for Applications")
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Host "VBE window not found. Open Alt+F11 first." -ForegroundColor Red
    exit 1
}

Write-Host "[1/6] VBE window found, bringing to front..." -ForegroundColor Yellow
[Win32Find]::ShowWindowAsync($hwnd, 9) | Out-Null
[Win32Find]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep 2

# Step 2: Capture VBE window area
Write-Host "[2/6] Capturing VBE window..."
$rect = New-Object Win32Find+RECT
[Win32Find]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top
Write-Host "  VBE window size: ${w}x${h}"

# Capture just VBE region (even if behind other windows)
$bitmap = New-Object System.Drawing.Bitmap $w, $h
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, ($w, $h -as [System.Drawing.Size]))
$graphics.Dispose()

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$pngPath = "$OcrDir\vbe_scan_$timestamp.png"
$bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
Write-Host "  Saved: $pngPath ($((Get-Item $pngPath).Length) bytes)"

# Step 3: OCR
Write-Host "[3/6] OCR scanning..."
$base = [System.IO.Path]::GetFileNameWithoutExtension($pngPath)
$outDir = [System.IO.Path]::GetDirectoryName($pngPath)
& "C:\Program Files\Tesseract-OCR\tesseract.exe" $pngPath "$outDir\$base" --psm 6 2>$null
Start-Sleep 1

$ocrText = Get-Content "$outDir\$base.txt" -Raw -ErrorAction SilentlyContinue
if (-not $ocrText) {
    Write-Host "  OCR produced no output" -ForegroundColor Red
    # Try full-screen fallback
    Write-Host "  Retrying with full-screen capture..."
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $g = [System.Drawing.Graphics]::FromImage($bitmap)
    $g.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
    $g.Dispose()
    $pngPath2 = "$OcrDir\full_scan_$timestamp.png"
    $bitmap.Save($pngPath2, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    & "C:\Program Files\Tesseract-OCR\tesseract.exe" $pngPath2 "$outDir\full_scan_$timestamp" --psm 6 2>$null
    $ocrText = Get-Content "$outDir\full_scan_$timestamp.txt" -Raw -ErrorAction SilentlyContinue
}

if (-not $ocrText) {
    Write-Host "  OCR failed completely" -ForegroundColor Red
    exit 1
}

Write-Host "  OCR text length: $($ocrText.Length) chars"

# Step 4: Check for compile errors
Write-Host "[4/6] Analyzing OCR output..."
$hasError = $false
$errorType = ""
$errorModule = ""

if ($ocrText -match 'Compile error:') {
    $hasError = $true
    $errorType = "Compile error"
    Write-Host "  🚨 COMPILE ERROR DETECTED!" -ForegroundColor Red
} elseif ($ocrText -match 'Expected:') {
    $hasError = $true
    $errorType = "Expected: expression"
    Write-Host "  🚨 'Expected: expression' detected!" -ForegroundColor Red
} elseif ($ocrText -match 'Run-time error') {
    $hasError = $true
    $errorType = "Runtime error"
    Write-Host "  🚨 RUNTIME ERROR DETECTED!" -ForegroundColor Red
}

# Extract module name
if ($ocrText -match '(mod_\w+)') { $errorModule = $matches[1] }

if ($hasError) {
    Write-Host "  Error type: $errorType" -ForegroundColor Yellow
    Write-Host "  Module: $errorModule" -ForegroundColor Yellow
    Write-Host "  OCR excerpt: $($ocrText.Substring(0, [Math]::Min(300, $ocrText.Length)))" -ForegroundColor Gray
    
    # Save error report
    $ocrText | Out-File -FilePath "$OcrDir\error_$timestamp.txt" -Encoding utf8
    
    # Step 5: Kill Excel
    Write-Host "[5/6] Killing Excel..." -ForegroundColor Yellow
    Get-Process -Name EXCEL -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2
    
    # Step 6: Rebuild
    Write-Host "[6/6] Rebuilding from golden master..." -ForegroundColor Yellow
    & $BuildScript -ConfigPath $ConfigPath 2>&1
    
    Write-Host "" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ AUTOFIX COMPLETE - Workbook rebuilt!" -ForegroundColor Green
    Write-Host "  Error: $errorType in $errorModule" -ForegroundColor Green
    Write-Host "  Reopen ERP_v13.3.xlsm to test" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
} else {
    Write-Host "[5/6] ✅ No compile error detected" -ForegroundColor Green
    Write-Host "  VBE window is clean."
}

# Show OCR preview
Write-Host "" -ForegroundColor Gray
Write-Host "=== OCR Preview (first 300 chars) ===" -ForegroundColor Gray
Write-Host $ocrText.Substring(0, [Math]::Min(300, $ocrText.Length)) -ForegroundColor Gray
Write-Host "===================================" -ForegroundColor Gray
