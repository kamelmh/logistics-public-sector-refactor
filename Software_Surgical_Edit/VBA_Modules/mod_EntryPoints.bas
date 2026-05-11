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
    Dim entries(0 To 20) As EntryPointDef
    entries(0).ModuleName = "mod_UI_Setup": entries(0).EntryProc = "SetupAccueilSheet": entries(0).Trigger = TRIGGER_RIBBON: entries(0).Description = "ACCUEIL navigation builder (Workbook_Open)"
    entries(1).ModuleName = "mod_Barcode": entries(1).EntryProc = "ScanBarcode": entries(1).Trigger = TRIGGER_BUTTON: entries(1).Description = "ACCUEIL Barcode button"
    entries(2).ModuleName = "mod_CSVImportExport": entries(2).EntryProc = "ImportMouvementsFromCSV": entries(2).Trigger = TRIGGER_BUTTON: entries(2).Description = "ACCUEIL Import CSV button"
    entries(3).ModuleName = "mod_CSVImportExport": entries(3).EntryProc = "ExportMouvementsToCSV": entries(3).Trigger = TRIGGER_BUTTON: entries(3).Description = "ACCUEIL Export CSV button"
    entries(4).ModuleName = "mod_Dashboard": entries(4).EntryProc = "RefreshDashboard": entries(4).Trigger = TRIGGER_BUTTON: entries(4).Description = "ACCUEIL Dashboard button"
    entries(5).ModuleName = "mod_DataValidator": entries(5).EntryProc = "RunDataValidation": entries(5).Trigger = TRIGGER_BUTTON: entries(5).Description = "ACCUEIL Validate button"
    entries(6).ModuleName = "mod_DemoData": entries(6).EntryProc = "GenerateDemoData": entries(6).Trigger = TRIGGER_BUTTON: entries(6).Description = "ACCUEIL Demo Data button"
    entries(7).ModuleName = "mod_ExportEngine": entries(7).EntryProc = "ExportTransactionToPDF": entries(7).Trigger = TRIGGER_CHAIN: entries(7).Description = "Called after transaction commit"
    entries(8).ModuleName = "mod_ExportEngine": entries(8).EntryProc = "ExportToExcel": entries(8).Trigger = TRIGGER_BUTTON: entries(8).Description = "ACCUEIL Export Excel button"
    entries(9).ModuleName = "mod_ExportEngine": entries(9).EntryProc = "ExportDashboardPDF": entries(9).Trigger = TRIGGER_BUTTON: entries(9).Description = "ACCUEIL Dashboard PDF button"
    entries(10).ModuleName = "mod_InventoryReconciliation": entries(10).EntryProc = "RunInventoryReconciliation": entries(10).Trigger = TRIGGER_BUTTON: entries(10).Description = "ACCUEIL Inventory button"
    entries(11).ModuleName = "mod_Procurement": entries(11).EntryProc = "GenerateOrderReport": entries(11).Trigger = TRIGGER_BUTTON: entries(11).Description = "ACCUEIL Order Report button"
    entries(12).ModuleName = "mod_Reports": entries(12).EntryProc = "GenerateMonthlyReport": entries(12).Trigger = TRIGGER_BUTTON: entries(12).Description = "ACCUEIL Monthly Report button"
    entries(13).ModuleName = "mod_Reports": entries(13).EntryProc = "GenerateStockCard": entries(13).Trigger = TRIGGER_BUTTON: entries(13).Description = "ACCUEIL Stock Card button"
    entries(14).ModuleName = "mod_StockAging": entries(14).EntryProc = "RunStockAgingReport": entries(14).Trigger = TRIGGER_BUTTON: entries(14).Description = "ACCUEIL Aging Report button"
    entries(15).ModuleName = "mod_StockEntry_Logic": entries(15).EntryProc = "InitializeForm": entries(15).Trigger = TRIGGER_FORM_LOAD: entries(15).Description = "frmStockEntry Initialize"
    entries(16).ModuleName = "mod_StockOutPredictor": entries(16).EntryProc = "RunStockOutPrediction": entries(16).Trigger = TRIGGER_BUTTON: entries(16).Description = "ACCUEIL Stockout Predict button"
    entries(17).ModuleName = "mod_SupplierScorecard": entries(17).EntryProc = "RunSupplierScorecard": entries(17).Trigger = TRIGGER_BUTTON: entries(17).Description = "ACCUEIL Scorecard button"
    entries(18).ModuleName = "mod_SyncBridge": entries(18).EntryProc = "SyncMetricsFromLedger": entries(18).Trigger = TRIGGER_CHAIN: entries(18).Description = "Called after transaction commit"
    entries(19).ModuleName = "mod_Utilities": entries(19).EntryProc = "ApplyInventoryHeatmap": entries(19).Trigger = TRIGGER_BUTTON: entries(19).Description = "ACCUEIL Heatmap button"
    entries(20).ModuleName = "mod_Utilities": entries(20).EntryProc = "SetupLocationDropdown": entries(20).Trigger = TRIGGER_BUTTON: entries(20).Description = "ACCUEIL Location dropdown button"
    GetEntryPoints = entries
End Function

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
