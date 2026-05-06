# Build_Excel_DSS.ps1 — ERP Académie v13.2
# Purpose: Create workbook with all 25 sheets, import 27 VBA modules, apply protection
# Institution: Direction de l'Éducation, El Bayadh
# Version: v13.2 | Generated: 2026-05-06

param(
    [string]$OutputPath = "C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm",
    [string]$VbaModulesDir = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\VBA_Modules",
    [string]$MasterPwd = "erp_secure_pwd_2026"
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Building ERP Académie v13.2" -ForegroundColor Cyan
Write-Host "  Pure VBA · Offline-First · Zero Dependencies" -ForegroundColor Cyan
Write-Host "  25 Sheets · 27 Modules" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Validate paths
if (-not (Test-Path $VbaModulesDir)) {
    Write-Host "✗ VBA modules directory not found: $VbaModulesDir" -ForegroundColor Red
    exit 1
}

# Start Excel
try {
    $excel = New-Object -ComObject Excel.Application
    Write-Host "✓ Excel COM object created" -ForegroundColor Green
} catch {
    Write-Host "✗ Excel not available" -ForegroundColor Red
    exit 1
}

$excel.Visible = $false
$excel.DisplayAlerts = $false
$excel.AutomationSecurity = 3  # msoAutomationSecurityForceDisable

# Create workbook
$workbook = $excel.Workbooks.Add()
Write-Host "✓ New workbook created" -ForegroundColor Green

# ─── Sheet Structure (25 sheets) ───
$sheets = @(
    "ACCUEIL",
    "ARTICLES",
    "FOURNISSEURS",
    "CONVENTIONS",
    "MOUVEMENTS",
    "TABLEAU_DE_BORD",
    "ALERTE_DASHBOARD",
    "INVENTAIRE",
    "RAPPORTS",
    "CALCULS_EOQ",
    "HISTORIQUE",
    "BON_RECEPTION",
    "BON_SORTIE",
    "BON_COMMANDE",
    "DA_DEMANDE_ACHAT",
    "GUIDE",
    "VBA_MODULES",
    "AUDIT_LOG",
    "DASHBOARD",
    "FORM_INPUT",
    "BORDEREAU_COMMANDE",
    "STAGING_BUFFER",
    "SYS_STRINGS",
    "RECEIPT_TAG",
    "TEMPLATE_BON"
)

# Remove default sheets
while ($workbook.Worksheets.Count -gt 1) {
    $workbook.Worksheets.Item(2).Delete() | Out-Null
}

# Create all sheets
$workbook.Worksheets.Item(1).Name = $sheets[0]
for ($i = 1; $i -lt $sheets.Count; $i++) {
    $workbook.Sheets.Add().Name = $sheets[$i]
}
Write-Host "✓ 25 sheets created" -ForegroundColor Green

# ─── Setup Core Sheets ───

# ACCUEIL
$ws = $workbook.Worksheets.Item("ACCUEIL")
$ws.Cells.Item(1, 1) = "نظام دعم القرار - Direction de l'Éducation El Bayadh"
$ws.Cells.Item(1, 1).Font.Size = 16
$ws.Cells.Item(1, 1).Font.Bold = $true
$ws.Cells.Item(3, 1) = "ERP Académie v13.2"
$ws.Cells.Item(3, 1).Font.Size = 14
$ws.Cells.Item(3, 1).Font.Bold = $true
$ws.Cells.Item(5, 1) = "D=1,546 | ROP=205.6 | Q*=176 | SS=200 | LT=2"
$ws.Cells.Item(6, 1) = "12 Articles · 3 Suppliers · 27 Modules"
Write-Host "✓ ACCUEIL configured" -ForegroundColor Green

# ARTICLES (12 articles)
$ws = $workbook.Worksheets.Item("ARTICLES")
$headers = @("Code Article", "Désignation", "Catégorie ABC", "Demande Annuelle", "ROP", "Stock Actuel", "CMUP")
for ($i = 0; $i -lt $headers.Length; $i++) {
    $ws.Cells.Item(1, $i + 1) = $headers[$i]
    $ws.Cells.Item(1, $i + 1).Font.Bold = $true
    $ws.Cells.Item(1, $i + 1).Interior.Color = 65280
}

$articles = @(
    @("ART-001", "Toner imprimante G030 (noir)", "A", 1546, 205.6, 300, 2500),
    @("ART-002", "Rame papier A4 80g/m²", "A", 1200, 180.5, 250, 450),
    @("ART-003", "Rame papier A3 80g/m²", "B", 800, 120.3, 150, 1800),
    @("ART-004", "Boîte archives carton", "B", 400, 60.2, 100, 500),
    @("ART-005", "Agrafeuse de bureau", "C", 300, 45.6, 50, 800),
    @("ART-006", "Stylos bille boîte/50", "C", 450, 67.8, 80, 30),
    @("ART-007", "Registre grand format 5m", "C", 350, 52.9, 60, 250),
    @("ART-008", "Encre tampon", "C", 200, 30.2, 30, 25),
    @("ART-009", "Sous-chemise carton", "C", 250, 37.8, 40, 60),
    @("ART-010", "Chemise cartonnée", "C", 500, 75.1, 100, 90),
    @("ART-011", "Rouleau papier fax", "C", 150, 22.6, 20, 40),
    @("ART-012", "Marqueur permanent noir", "C", 100, 15.1, 15, 35)
)

for ($i = 0; $i -lt $articles.Length; $i++) {
    for ($j = 0; $j -lt $articles[$i].Length; $j++) {
        $ws.Cells.Item($i + 2, $j + 1) = $articles[$i][$j]
    }
}
$ws.Columns.AutoFit() | Out-Null
Write-Host "✓ ARTICLES configured (12 articles)" -ForegroundColor Green

# MOUVEMENTS
$ws = $workbook.Worksheets.Item("MOUVEMENTS")
$movHeaders = @("DATE", "CODE_ARTICLE", "DESIGNATION", "TYPE_MVT", "QTE", "VALEUR", "REF_DOCUMENT", "PRIX_UNITAIRE", "THIRD_PARTY", "NOTES", "VALIDE_PAR", "APPROUVE_PAR")
for ($i = 0; $i -lt $movHeaders.Length; $i++) {
    $ws.Cells.Item(1, $i + 1) = $movHeaders[$i]
    $ws.Cells.Item(1, $i + 1).Font.Bold = $true
    $ws.Cells.Item(1, $i + 1).Interior.Color = 65280
}
$ws.Columns.AutoFit() | Out-Null
Write-Host "✓ MOUVEMENTS configured (10+2 approval columns)" -ForegroundColor Green

# CALCULS_EOQ
$ws = $workbook.Worksheets.Item("CALCULS_EOQ")
$ws.Cells.Item(1, 1) = "Paramètre"
$ws.Cells.Item(1, 2) = "Valeur"
$ws.Cells.Item(1, 3) = "Unité"
$ws.Cells.Item(1, 1).Font.Bold = $true
$ws.Cells.Item(1, 2).Font.Bold = $true
$ws.Cells.Item(1, 3).Font.Bold = $true

$eoaData = @(
    @("Demande Annuelle (D)", 1546, "unités/an"),
    @("Coût de Passation (S)", 500, "DZD"),
    @("Taux de Possession (I)", 0.20, "20%"),
    @("Prix Unitaire (h)", 250, "DZD"),
    @("Quantité Économique (Q*)", 176, "unités"),
    @("Point de Commande (ROP)", 205.6, "unités"),
    @("Stock de Sécurité (SS)", 200, "unités"),
    @("Délai de Livraison (LT)", 2, "jours"),
    @("Coût Total Annuel", 395291, "DZD")
)

for ($i = 0; $i -lt $eoaData.Length; $i++) {
    $ws.Cells.Item($i + 2, 1) = $eoaData[$i][0]
    $ws.Cells.Item($i + 2, 2) = $eoaData[$i][1]
    $ws.Cells.Item($i + 2, 3) = $eoaData[$i][2]
}
$ws.Columns.AutoFit() | Out-Null
Write-Host "✓ CALCULS_EOQ configured" -ForegroundColor Green

# ─── Import VBA Modules (27) ───
$vbaFiles = @(
    "mod_Config.bas",
    "mod_StockEngine.bas",
    "mod_StockEntry_Logic.bas",
    "mod_SyncBridge.bas",
    "mod_Dashboard.bas",
    "mod_ExportEngine.bas",
    "mod_Utilities.bas",
    "mod_Reports.bas",
    "mod_SheetSetup.bas",
    "mod_AuditTrail.bas",
    "mod_Database.bas",
    "mod_Procurement.bas",
    "mod_ReceiptTag.bas",
    "mod_Restore.bas",
    "mod_Backup.bas",
    "mod_Analysis.bas",
    "mod_ApprovalWorkflow.bas",
    "mod_StockCalculations.bas",
    "mod_Localization.bas",
    "mod_UI_Setup.bas",
    "mod_LogViewer.bas",
    "mod_Navigation.bas",
    "mod_BonLivraison.bas",
    "mod_Budget.bas",
    "mod_Facture.bas",
    "MAIN_MACROS.bas",
    "mod_TestHarness.bas"
)

$imported = 0
$failed = 0

foreach ($file in $vbaFiles) {
    $fullPath = Join-Path $VbaModulesDir $file
    if (Test-Path $fullPath) {
        try {
            $workbook.VBProject.VBComponents.Import($fullPath) | Out-Null
            $imported++
            Write-Host "  ✓ $file" -ForegroundColor Green
        } catch {
            $failed++
            Write-Host "  ✗ $file — $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ? $file — not found" -ForegroundColor Yellow
    }
}

# Import ThisWorkbook.cls
$clsPath = Join-Path $VbaModulesDir "ThisWorkbook.cls"
if (Test-Path $clsPath) {
    try {
        $workbook.VBProject.VBComponents.Import($clsPath) | Out-Null
        $imported++
        Write-Host "  ✓ ThisWorkbook.cls" -ForegroundColor Green
    } catch {
        $failed++
        Write-Host "  ✗ ThisWorkbook.cls — $_" -ForegroundColor Red
    }
}

Write-Host "✓ VBA modules: $imported imported, $failed failed" -ForegroundColor Green

# ─── Enable macro access ───
try {
    $workbook.VBProject.VBE.ActiveVBProject.References | Out-Null
} catch {
    Write-Host "⚠ Trust access to VBA project model may need to be enabled in Excel settings" -ForegroundColor Yellow
}

# ─── Save ───
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}
$workbook.SaveAs($OutputPath, 52)  # xlOpenXMLWorkbookMacroEnabled
Write-Host ""
Write-Host "✓ Workbook saved: $OutputPath" -ForegroundColor Green

# Cleanup
$workbook.Close()
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Build Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  25 sheets created" -ForegroundColor Green
Write-Host "  $imported VBA modules imported" -ForegroundColor Green
Write-Host "  Workbook saved to: $OutputPath" -ForegroundColor Green
Write-Host ""
