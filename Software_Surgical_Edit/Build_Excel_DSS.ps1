# Build_Excel_DSS.ps1
# Purpose: Build Decision_Support_System.xlsm with CNEPD-compliant structure
# Institution: Direction de l'Éducation, El Bayadh
# Version: v13.2

param(
    [string]$OutputPath = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\Decision_Support_System.xlsm"
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Building CNEPD Decision Support System" -ForegroundColor Cyan
Write-Host "  Version: v13.2" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Excel is available
try {
    $excel = New-Object -ComObject Excel.Application
    Write-Host "✓ Excel COM object created" -ForegroundColor Green
} catch {
    Write-Host "✗ Excel not available. Please install Excel or run manually." -ForegroundColor Red
    exit 1
}

$excel.Visible = $false
$excel.DisplayAlerts = $false

# Create new workbook
$workbook = $excel.Workbooks.Add()
Write-Host "✓ New workbook created" -ForegroundColor Green

# Define sheet structure (CNEPD Standard)
$sheets = @(
    "ACCUEIL",
    "ARTICLES",
    "FOURNISSEURS",
    "CONVENTIONS",
    "MOUVEMENTS",
    "TABLEAU DE BORD",
    "ALERTE_DASHBOARD",
    "INVENTAIRE"
)

# Remove default sheets
try {
    while ($workbook.Worksheets.Count -gt 1) {
        $workbook.Worksheets.Item(2).Delete()
    }
} catch {}

# Rename first sheet
$workbook.Worksheets.Item(1).Name = $sheets[0]
Write-Host "✓ Sheet created: $($sheets[0])" -ForegroundColor Green

# Add remaining sheets in correct order
for ($i = 1; $i -lt $sheets.Count; $i++) {
    # Add new sheet after the last existing sheet
    $lastSheet = $workbook.Worksheets.Item($workbook.Worksheets.Count)
    $newSheet = $workbook.Worksheets.Add([System.Reflection.Missing]::Value, $lastSheet)
    $newSheet.Name = $sheets[$i]
    Write-Host "✓ Sheet created: $($sheets[$i])" -ForegroundColor Green
}

# Setup ACCUEIL sheet
$accueil = $workbook.Worksheets.Item("ACCUEIL")
$accueil.Cells.Item(1, 1) = "نظام دعم القرار - الإدارة العامة للتربية - البيض"
$accueil.Cells.Item(1, 1).Font.Size = 16
$accueil.Cells.Item(1, 1).Font.Bold = $true
$accueil.Cells.Item(3, 1) = "Decision Support System v13.2"
$accueil.Cells.Item(3, 1).Font.Size = 12
$accueil.Cells.Item(5, 1) = "Case Study: Toner G030 (ART-001)"
$accueil.Cells.Item(5, 1).Font.Bold = $true
$accueil.Cells.Item(6, 1) = "ROP Target: 205.6 units"
$accueil.Cells.Item(7, 1) = "Annual Demand (D): 1546 units"
$accueil.Cells.Item(8, 1) = "Lead Time (LT): 2 days"
$accueil.Cells.Item(9, 1) = "Safety Stock (SS): 200 units"
Write-Host "✓ ACCUEIL sheet configured" -ForegroundColor Green

# Setup ARTICLES sheet (12 articles)
$articles = $workbook.Worksheets.Item("ARTICLES")
$articles.Cells.Item(1, 1) = "Code Article"
$articles.Cells.Item(1, 2) = "Désignation"
$articles.Cells.Item(1, 3) = "Catégorie ABC"
$articles.Cells.Item(1, 4) = "Demande Annuelle"
$articles.Cells.Item(1, 5) = "ROP"
$articles.Cells.Item(1, 6) = "Stock Actuel"
$articles.Cells.Item(1, 7) = "CMUP"

# Header style
$headerRange = $articles.Range("A1:G1")
$headerRange.Font.Bold = $true
$headerRange.Interior.Color = 65280

# Add ART-001 (Toner G030) as case study
$articles.Cells.Item(2, 1) = "ART-001"
$articles.Cells.Item(2, 2) = "Toner G030"
$articles.Cells.Item(2, 3) = "A"
$articles.Cells.Item(2, 4) = 1546
$articles.Cells.Item(2, 5) = 205.6
$articles.Cells.Item(2, 6) = 300
$articles.Cells.Item(2, 7) = 2500

# Add remaining 11 articles (sample data)
$articleData = @(
    @("ART-002", "Rame Papier A4", "A", 1200, 180.5, 250, 450),
    @("ART-003", "Cartouches Encre Noir", "B", 800, 120.3, 150, 1800),
    @("ART-004", "Clips 19mm", "C", 600, 90.2, 100, 50),
    @("ART-005", "Cahier 100 pages", "B", 950, 140.8, 200, 120),
    @("ART-006", "Stylo Bille Bleu", "C", 400, 60.1, 80, 30),
    @("ART-007", "Dossier Suspendu", "B", 700, 105.4, 120, 350),
    @("ART-008", "Agrafeuse", "C", 300, 45.6, 50, 800),
    @("ART-009", "Ruban Adhésif", "C", 250, 37.8, 40, 60),
    @("ART-010", "Sac Poubelle 50L", "B", 880, 132.6, 180, 90),
    @("ART-011", "Marqueur Tableau", "C", 350, 52.9, 60, 250),
    @("ART-012", "Trombones", "C", 200, 30.2, 30, 25)
)

for ($i = 0; $i -lt $articleData.Count; $i++) {
    for ($j = 0; $j -lt $articleData[$i].Count; $j++) {
        $articles.Cells.Item($i + 3, $j + 1) = $articleData[$i][$j]
    }
}

$articles.Columns.AutoFit()
Write-Host "✓ ARTICLES sheet configured with 12 articles" -ForegroundColor Green

# Setup MOUVEMENTS sheet
$mouvements = $workbook.Worksheets.Item("MOUVEMENTS")
$mouvements.Cells.Item(1, 1) = "Date"
$mouvements.Cells.Item(1, 2) = "Code Article"
$mouvements.Cells.Item(1, 3) = "Type"
$mouvements.Cells.Item(1, 4) = "Quantité"
$mouvements.Cells.Item(1, 5) = "Valeur"
$mouvements.Cells.Item(1, 6) = "Référence"
$mouvements.Range("A1:F1").Font.Bold = $true
$mouvements.Range("A1:F1").Interior.Color = 65280
$mouvements.Columns.AutoFit()
Write-Host "✓ MOUVEMENTS sheet configured" -ForegroundColor Green

# Setup TABLEAU DE BORD sheet
$dashboard = $workbook.Worksheets.Item("TABLEAU DE BORD")
$dashboard.Cells.Item(1, 1) = "سجل المخزون الرقمي - Direction de l'Éducation, El Bayadh"
$dashboard.Cells.Item(1, 1).Font.Size = 14
$dashboard.Cells.Item(1, 1).Font.Bold = $true
$dashboard.Cells.Item(3, 1) = "Indicateur"
$dashboard.Cells.Item(3, 2) = "Valeur"
$dashboard.Cells.Item(3, 3) = "Unité"
$dashboard.Range("A3:C3").Font.Bold = $true
$dashboard.Range("A3:C3").Interior.Color = 65280

# Add KPIs
$dashboard.Cells.Item(4, 1) = "ROP (ART-001)"
$dashboard.Cells.Item(4, 2) = 205.6
$dashboard.Cells.Item(4, 3) = "units"

$dashboard.Cells.Item(5, 1) = "EOQ (ART-001)"
$dashboard.Cells.Item(5, 2) = 176
$dashboard.Cells.Item(5, 3) = "units"

$dashboard.Cells.Item(6, 1) = "CMUP (ART-001)"
$dashboard.Cells.Item(6, 2) = 2500
$dashboard.Cells.Item(6, 3) = "DA/unit"

$dashboard.Cells.Item(7, 1) = "Taux de Rotation"
$dashboard.Cells.Item(7, 2) = "=1546/300"
$dashboard.Cells.Item(7, 3) = "turns/year"

$dashboard.Cells.Item(8, 1) = "Durée de Stock"
$dashboard.Cells.Item(8, 2) = "=300/(1546/365)"
$dashboard.Cells.Item(8, 3) = "days"

$dashboard.Columns.AutoFit()
Write-Host "✓ TABLEAU DE BORD sheet configured" -ForegroundColor Green

# Save as XLSM (macro-enabled)
try {
    $workbook.SaveAs($OutputPath, 52)  # 52 = xlOpenXMLWorkbookMacroEnabled
    Write-Host ""
    Write-Host "✓ Workbook saved: $OutputPath" -ForegroundColor Green
} catch {
    Write-Host "✗ Error saving workbook: $_" -ForegroundColor Red
}

# Cleanup
$workbook.Close()
$excel.Quit()

# Release COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Build Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open $OutputPath in Excel" -ForegroundColor Yellow
Write-Host "2. Import VBA modules:" -ForegroundColor Yellow
Write-Host "   - mod_StockCalculations.bas" -ForegroundColor Yellow
Write-Host "   - mod_ExportEngine_Enhanced.bas" -ForegroundColor Yellow
Write-Host "   - mod_StockEntry_Logic_Enhanced.bas" -ForegroundColor Yellow
Write-Host "3. Import UserForms:" -ForegroundColor Yellow
Write-Host "   - frmSystemLog.frm" -ForegroundColor Yellow
Write-Host "   - frmStockEntry.frm" -ForegroundColor Yellow
Write-Host "   - frmDashboard.frm" -ForegroundColor Yellow
Write-Host "4. Run UpdateStockLedger to verify ROP=205.6" -ForegroundColor Yellow
