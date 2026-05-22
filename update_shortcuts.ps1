# Update OpenCode shortcuts and create OCR shortcut
# -------------------------------------------------
# 1. Replace any OpenCode shortcut that uses the `allam` mode with `ollama`.
# 2. Create a new desktop shortcut "Run OCR – Claude Code.lnk" that opens a PowerShell
#    window, adds Tesseract to PATH, and runs the OCR demo on the image.

$desktop = [Environment]::GetFolderPath('Desktop')
$wsh = New-Object -ComObject WScript.Shell

# ----- Step 1: Update existing OpenCode shortcuts -----
Get-ChildItem -Path $desktop -Filter *.lnk -File | ForEach-Object {
    $lnkPath = $_.FullName
    $shortcut = $wsh.CreateShortcut($lnkPath)
    $target = $shortcut.TargetPath
    $args = $shortcut.Arguments.Trim()
    if ($target -like '*OpenCode.bat' -and $args -match '\ballam\b') {
        $shortcut.Arguments = 'ollama'
        $shortcut.Save()
        Write-Host "Updated shortcut: $($_.Name) to use ollama"
    }
}

# ----- Step 2: Create enhanced OCR shortcut -----
$ocrShortcutPath = Join-Path $desktop 'Run OCR – Claude Code.lnk'
$targetPath = (Get-Command powershell.exe).Source
# PowerShell command that adds Tesseract to the session PATH and runs the OCR script
$psCommand = "`$env:Path += ';C:\Program Files\Tesseract-OCR'; python `"$pwd\ocr_demo.py`" `"C:\Users\Administrator\Pictures\claude code.PNG`"; pause"
$shortcut = $wsh.CreateShortcut($ocrShortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = "-NoExit -Command \"$psCommand\""
$shortcut.WorkingDirectory = "$pwd"
$shortcut.IconLocation = "$targetPath,0"
$shortcut.Save()
Write-Host "Created OCR shortcut at $ocrShortcutPath"
