Attribute VB_Name = "mod_EntryPoints"
Option Explicit

Public Enum EntryTrigger
    TRIGGER_RIBBON
    TRIGGER_BUTTON
    TRIGGER_FORM_LOAD
    TRIGGER_SCHEDULED
    TRIGGER_CHAIN
    TRIGGER_MANUAL
End Enum

Public Type EntryPointDef
    ModuleName As String
    EntryProc  As String
    Trigger    As EntryTrigger
    Description As String
End Type

Public Function GetEntryPoints() As EntryPointDef()
    Dim entries(0 To 30) As EntryPointDef
    entries(0).ModuleName = "mod_UI_Setup": entries(0).EntryProc = "SetupAccueilSheet": entries(0).Trigger = TRIGGER_RIBBON: entries(0).Description = "ACCUEIL navigation builder (Workbook_Open)"
    entries(1).ModuleName = "mod_Barcode": entries(1).EntryProc = "ScanBarcode": entries(1).Trigger = TRIGGER_BUTTON: entries(1).Description = "ACCUEIL Barcode scan button"
    entries(2).ModuleName = "mod_Barcode": entries(2).EntryProc = "ScanBarcodeStockIn": entries(2).Trigger = TRIGGER_BUTTON: entries(2).Description = "ACCUEIL Scan barcode ENTREE direct"
    entries(3).ModuleName = "mod_Barcode": entries(3).EntryProc = "ScanBarcodeStockOut": entries(3).Trigger = TRIGGER_BUTTON: entries(3).Description = "ACCUEIL Scan barcode SORTIE direct"
    entries(4).ModuleName = "mod_CSVImportExport": entries(4).EntryProc = "ImportMouvementsFromCSV": entries(4).Trigger = TRIGGER_BUTTON: entries(4).Description = "ACCUEIL Import CSV button"
    entries(5).ModuleName = "mod_CSVImportExport": entries(5).EntryProc = "ExportMouvementsToCSV": entries(5).Trigger = TRIGGER_BUTTON: entries(5).Description = "ACCUEIL Export CSV button"
    entries(6).ModuleName = "mod_Dashboard": entries(6).EntryProc = "RefreshDashboard": entries(6).Trigger = TRIGGER_BUTTON: entries(6).Description = "ACCUEIL Dashboard button"
    entries(7).ModuleName = "mod_DataValidator": entries(7).EntryProc = "RunDataValidation": entries(7).Trigger = TRIGGER_BUTTON: entries(7).Description = "ACCUEIL Validate button"
    entries(8).ModuleName = "mod_DemoData": entries(8).EntryProc = "GenerateDemoData": entries(8).Trigger = TRIGGER_BUTTON: entries(8).Description = "ACCUEIL Demo Data button"
    entries(9).ModuleName = "mod_ExportEngine": entries(9).EntryProc = "ExportTransactionToPDF": entries(9).Trigger = TRIGGER_CHAIN: entries(9).Description = "Called after transaction commit"
    entries(10).ModuleName = "mod_ExportEngine": entries(10).EntryProc = "ExportToExcel": entries(10).Trigger = TRIGGER_BUTTON: entries(10).Description = "ACCUEIL Export Excel button"
    entries(11).ModuleName = "mod_ExportEngine": entries(11).EntryProc = "ExportDashboardPDF": entries(11).Trigger = TRIGGER_BUTTON: entries(11).Description = "ACCUEIL Dashboard PDF button"
    entries(12).ModuleName = "mod_InventoryReconciliation": entries(12).EntryProc = "RunInventoryReconciliation": entries(12).Trigger = TRIGGER_BUTTON: entries(12).Description = "ACCUEIL Inventory button"
    entries(13).ModuleName = "mod_Procurement": entries(13).EntryProc = "GenerateOrderReport": entries(13).Trigger = TRIGGER_BUTTON: entries(13).Description = "ACCUEIL Order Report button"
    entries(14).ModuleName = "mod_Reports": entries(14).EntryProc = "GenerateMonthlyReport": entries(14).Trigger = TRIGGER_BUTTON: entries(14).Description = "ACCUEIL Monthly Report button"
    entries(15).ModuleName = "mod_Reports": entries(15).EntryProc = "GenerateStockCard": entries(15).Trigger = TRIGGER_BUTTON: entries(15).Description = "ACCUEIL Stock Card button"
    entries(16).ModuleName = "mod_StockAging": entries(16).EntryProc = "RunStockAgingReport": entries(16).Trigger = TRIGGER_BUTTON: entries(16).Description = "ACCUEIL Aging Report button"
    entries(17).ModuleName = "mod_StockEntry_Logic": entries(17).EntryProc = "InitializeForm": entries(17).Trigger = TRIGGER_FORM_LOAD: entries(17).Description = "frmStockEntry Initialize"
    entries(18).ModuleName = "mod_StockOutPredictor": entries(18).EntryProc = "RunStockOutPrediction": entries(18).Trigger = TRIGGER_BUTTON: entries(18).Description = "ACCUEIL Stockout Predict button"
    entries(19).ModuleName = "mod_SupplierScorecard": entries(19).EntryProc = "RunSupplierScorecard": entries(19).Trigger = TRIGGER_BUTTON: entries(19).Description = "ACCUEIL Scorecard button"
    entries(20).ModuleName = "mod_SyncBridge": entries(20).EntryProc = "SyncMetricsFromLedger": entries(20).Trigger = TRIGGER_CHAIN: entries(20).Description = "Called after transaction commit"
    entries(21).ModuleName = "mod_Utilities": entries(21).EntryProc = "ApplyInventoryHeatmap": entries(21).Trigger = TRIGGER_BUTTON: entries(21).Description = "ACCUEIL Heatmap button"
    entries(22).ModuleName = "mod_Utilities": entries(22).EntryProc = "SetupLocationDropdown": entries(22).Trigger = TRIGGER_BUTTON: entries(22).Description = "ACCUEIL Location dropdown button"
    entries(23).ModuleName = "mod_Forecasting": entries(23).EntryProc = "RefreshForecastSheet": entries(23).Trigger = TRIGGER_BUTTON: entries(23).Description = "ACCUEIL Refresh forecast button"
    entries(24).ModuleName = "mod_ThemingEngine": entries(24).EntryProc = "InitThemeColors": entries(24).Trigger = TRIGGER_RIBBON: entries(24).Description = "Initialize theme colors (Workbook_Open)"
    entries(25).ModuleName = "mod_ReceiptTag": entries(25).EntryProc = "GenerateReceiptTagPDF": entries(25).Trigger = TRIGGER_BUTTON: entries(25).Description = "ACCUEIL Receipt tag PDF button"
    entries(26).ModuleName = "mod_Analysis": entries(26).EntryProc = "UpdateABC_Classification": entries(26).Trigger = TRIGGER_BUTTON: entries(26).Description = "ACCUEIL ABC analysis button"
    entries(27).ModuleName = "mod_Navigation": entries(27).EntryProc = "OpenStockForm": entries(27).Trigger = TRIGGER_BUTTON: entries(27).Description = "ACCUEIL Open stock form button"
    entries(28).ModuleName = "mod_Budget": entries(28).EntryProc = "GenerateBudgetReport": entries(28).Trigger = TRIGGER_BUTTON: entries(28).Description = "ACCUEIL Budget report button"
    entries(29).ModuleName = "mod_ApprovalWorkflow": entries(29).EntryProc = "InitializeMouvementsColumns": entries(29).Trigger = TRIGGER_RIBBON: entries(29).Description = "Initialize approval columns"
    entries(30).ModuleName = "mod_SheetSetup": entries(30).EntryProc = "CreateAllSheets": entries(30).Trigger = TRIGGER_RIBBON: entries(30).Description = "Create/verify all ERP sheets"
    GetEntryPoints = entries
End Function

Public Sub ListBarcodeEntries()
    Debug.Print "=== BARCODE ENTRY POINTS ==="
    Debug.Print "1. ScanBarcode (form) - opens frmStockEntry after scan"
    Debug.Print "2. ScanBarcodeStockIn - scan + qty = direct ENTREE"
    Debug.Print "3. ScanBarcodeStockOut - scan + qty = direct SORTIE"
    Debug.Print "Call: mod_Barcode.ScanBarcodeStockIn  (or StockOut)"
End Sub

Public Sub ListAllEntryPoints()
    Dim entries() As EntryPointDef
    entries = GetEntryPoints
    Dim i As Long
    Dim triggerNames As Variant
    triggerNames = Array("RIBBON", "BUTTON", "FORM_LOAD", "SCHEDULED", "CHAIN", "MANUAL")
    Debug.Print "=== ENTRY POINT REGISTRY (" & (UBound(entries) - LBound(entries) + 1) & " entries) ==="
    For i = LBound(entries) To UBound(entries)
        Debug.Print entries(i).ModuleName & " | " & entries(i).EntryProc & " | " & triggerNames(entries(i).Trigger) & " | " & entries(i).Description
    Next i
End Sub
