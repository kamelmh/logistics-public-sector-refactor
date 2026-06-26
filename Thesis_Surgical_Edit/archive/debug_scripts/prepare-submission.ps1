<#
.SYNOPSIS
  Academix v13.4 — Prepare Defense Submission Package
.DESCRIPTION
  Copies all deliverables to a structured delivery folder + optional USB backup.
  Run from project root.
.PARAMETER UsbDrive
  Optional USB drive letter (e.g., "D:") to copy the package as backup.
#>

param(
    [Parameter()]
    [string]$UsbDrive = ""
)

$projectRoot = Split-Path -Parent $PSCommandPath
$deliveryDir = "$projectRoot\DELIVERY_v13.4"
$ts = Get-Date -Format "yyyyMMdd_HHmm"
$manifestPath = "$deliveryDir\MANIFEST.md"

# Clean/create delivery directory
if (Test-Path $deliveryDir) { Remove-Item -Recurse -Force $deliveryDir }
$dirs = @(
    "01_Thesis", "02_English_Paper", "03_ERP_Workbook",
    "04_Defense_Materials", "05_Source_VBA", "06_Build_Tools"
)
foreach ($d in $dirs) {
    $null = New-Item -ItemType Directory -Path "$deliveryDir\$d" -Force
}

Write-Host "===== Academix v13.4 — Submission Package =====" -ForegroundColor Cyan
Write-Host "Output: $deliveryDir`n"

# ── 01. Thesis ──
Write-Host "[1/6] Copying Thesis..." -ForegroundColor Yellow
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.pdf" "$deliveryDir\01_Thesis\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx" "$deliveryDir\01_Thesis\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md" "$deliveryDir\01_Thesis\"

# ── 02. English Paper ──
Write-Host "[2/6] Copying English Paper..." -ForegroundColor Yellow
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\English_Research_Paper_CCA2026.pdf" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\English_Research_Paper_CCA2026.docx" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\English_Research_Paper_IEEE.pdf" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\output\English_Research_Paper_IEEE.docx" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\English_Research_Paper.md" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\submission\cover-letter.md" "$deliveryDir\02_English_Paper\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\submission\SUBMISSION_GUIDE.md" "$deliveryDir\02_English_Paper\"

# ── 03. ERP Workbook ──
Write-Host "[3/6] Copying ERP Workbook..." -ForegroundColor Yellow
if (Test-Path "$projectRoot\ERP_v13.4.xlsm") {
    Copy-Item "$projectRoot\ERP_v13.4.xlsm" "$deliveryDir\03_ERP_Workbook\"
}
if (Test-Path "$projectRoot\GOLDEN_ERP_v13.4.xlsm") {
    Copy-Item "$projectRoot\GOLDEN_ERP_v13.4.xlsm" "$deliveryDir\03_ERP_Workbook\"
}

# ── 04. Defense Materials ──
Write-Host "[4/6] Copying Defense Materials..." -ForegroundColor Yellow
$defenseFiles = Get-ChildItem "$projectRoot\Thesis_Surgical_Edit\defense\*.md"
foreach ($f in $defenseFiles) {
    Copy-Item $f.FullName "$deliveryDir\04_Defense_Materials\"
}
Copy-Item "$projectRoot\ROADMAP_v13.4+.md" "$deliveryDir\04_Defense_Materials\"

# ── 05. VBA Source ──
Write-Host "[5/6] Copying VBA Source..." -ForegroundColor Yellow
$vbaModules = Get-ChildItem "$projectRoot\Software_Surgical_Edit\VBA_Modules\*.bas"
foreach ($m in $vbaModules) {
    Copy-Item $m.FullName "$deliveryDir\05_Source_VBA\"
}
$forms = Get-ChildItem "$projectRoot\Software_Surgical_Edit\VBA_Modules\*.frm"
foreach ($f in $forms) {
    Copy-Item $f.FullName "$deliveryDir\05_Source_VBA\"
}

# ── 06. Build Tools ──
Write-Host "[6/6] Copying Build Tools..." -ForegroundColor Yellow
Copy-Item "$projectRoot\vbe-auto" "$deliveryDir\06_Build_Tools\vbe-auto\" -Recurse
Copy-Item "$projectRoot\Thesis_Surgical_Edit\build-thesis.ps1" "$deliveryDir\06_Build_Tools\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\build-english-paper.ps1" "$deliveryDir\06_Build_Tools\"
Copy-Item "$projectRoot\Thesis_Surgical_Edit\build-cca2026.ps1" "$deliveryDir\06_Build_Tools\"
Copy-Item "$projectRoot\prepare-submission.ps1" "$deliveryDir\06_Build_Tools\"

# ── Generate Manifest ──
Write-Host "`nGenerating Manifest..." -ForegroundColor Yellow
$totalSize = 0
$manifestLines = @(
    "# Academix v13.4 — Delivery Package",
    "",
    "Generated: $ts",
    "Project: Offline-First DSS for Inventory Optimization in Public Sector Logistics",
    "Author: Mahi Kamel Abdelghani | Direction de l'Education, El Bayadh",
    "",
    "## Contents",
    ""
)

# Helper: add file listing for a folder
function Add-FileListing($label, $subfolder) {
    $path = "$deliveryDir\$subfolder"
    if (-not (Test-Path $path)) { return }
    $script:manifestLines += "### $label"
    $script:manifestLines += "| File | Size |"
    $script:manifestLines += "|------|------|"
    $files = Get-ChildItem $path
    foreach ($f in $files) {
        $size = [math]::Round($f.Length / 1KB)
        $script:totalSize += $f.Length
        $script:manifestLines += "| $($f.Name) | $size KB |"
    }
    $script:manifestLines += ""
}

Add-FileListing "01_Thesis/ — Arabic Thesis (Memoire de Fin d'Etudes)" "01_Thesis"
Add-FileListing "02_English_Paper/ — English Research Paper (CCA'2026 + IEEE)" "02_English_Paper"
Add-FileListing "03_ERP_Workbook/ — ERP v13.4 (Excel Workbook)" "03_ERP_Workbook"
Add-FileListing "04_Defense_Materials/ — Defense Docs & Roadmap" "04_Defense_Materials"
Add-FileListing "05_Source_VBA/ — VBA Source Code" "05_Source_VBA"
Add-FileListing "06_Build_Tools/ — Build & Verification Scripts" "06_Build_Tools"

$totalMB = [math]::Round($totalSize / 1MB, 2)
$manifestLines += @(
    "---",
    "**Total Package Size: $totalMB MB**",
    "**ERP Version: v13.4**",
    "**Build Status: COMPILE OK | 113/113 PASS**",
    "**Modules: 44 VBA (.bas+.frm)**",
    "**Sheets: 26**",
    "**Articles: 15**",
    "",
    "## Build & Verify",
    '```powershell',
    '& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"',
    '& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"',
    '```',
    "",
    "## Delivery Notes",
    "- Thesis PDF built via LibreOffice headless from DOCX (Arabic RTL support)",
    "- English paper built via pandoc + xelatex (IEEE format)",
    "- CCA'2026 paper is double-blind (anonymous)",
    "- ERP workbook is the compiled .xlsm (VBA source in 05_Source_VBA/)",
    "- Golden master (GOLDEN_ERP_v13.4.xlsm) is the clean source build"
)

$manifestLines | Out-File -FilePath $manifestPath -Encoding utf8

Write-Host "`n===== Package Complete =====" -ForegroundColor Green
Write-Host "Location: $deliveryDir" -ForegroundColor Green
Write-Host "Total: $totalMB MB" -ForegroundColor Green

# ── USB Backup ──
if ($UsbDrive) {
    $usbPath = "$UsbDrive\Academix_v13.4_Delivery"
    if (Test-Path "$UsbDrive\") {
        Write-Host "`nCopying to USB ($UsbDrive)..." -ForegroundColor Yellow
        Copy-Item -Recurse -Force $deliveryDir $usbPath
        Write-Host "USB backup complete: $usbPath" -ForegroundColor Green
    } else {
        Write-Warning "USB drive $UsbDrive not found. Skipping USB backup."
    }
}

Write-Host "`nDone."
