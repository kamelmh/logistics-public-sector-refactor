# Persisting Tesseract PATH and OCR Shortcut

## 1. Make Tesseract available system‑wide

The OCR script requires the `tesseract.exe` binary to be on the system **PATH**.  Adding the directory permanently ensures the OCR demo works from any terminal, not just the shortcut.

### PowerShell (Permanent)
```powershell
# Append Tesseract folder to the machine‑level PATH
$old = [Environment]::GetEnvironmentVariable('Path','Machine')
$new = "$old;C:\Program Files\Tesseract-OCR"
[Environment]::SetEnvironmentVariable('Path',$new,'Machine')
```
After running the above, open a **new** PowerShell window and verify:
```powershell
> tesseract --version
```
You should see the version (e.g., `tesseract 5.5.0`).

## 2. Enhanced Desktop Shortcut

`update_shortcuts.ps1` creates a new shortcut **Run OCR – Claude Code.lnk** on your Desktop.  It launches PowerShell, adds the Tesseract folder to the session‑PATH, runs `ocr_demo.py` on the image `C:\Users\Administrator\Pictures\claude code.PNG`, and then pauses so you can see the output.

### What the shortcut does (pseudo‑code)
```
powershell.exe -NoExit -Command "
    $env:Path += ';C:\Program Files\Tesseract-OCR';
    python "<repo_root>\ocr_demo.py" "C:\Users\Administrator\Pictures\claude code.PNG";
    pause
"
```
- **`-NoExit`** keeps the PowerShell window open after the script finishes.
- **`pause`** waits for a key press, letting you read the OCR result.

## 3. Running the workflow
1. Run the PowerShell script to update shortcuts and create the OCR shortcut:
   ```powershell
   .\update_shortcuts.ps1
   ```
2. (Optional) Run the permanent PATH command above if you want Tesseract available everywhere.
3. Double‑click **Run OCR – Claude Code.lnk** on the Desktop.  The OCR output will be displayed in the PowerShell window.

---
### Quick checklist
- [ ] Execute `update_shortcuts.ps1` (adds the OCR shortcut and updates existing OpenCode shortcuts).
- [ ] Run the permanent PATH command (if you want system‑wide access to `tesseract`).
- [ ] Verify `tesseract --version` works in a fresh terminal.
- [ ] Double‑click the new OCR shortcut and confirm the extracted text appears.
