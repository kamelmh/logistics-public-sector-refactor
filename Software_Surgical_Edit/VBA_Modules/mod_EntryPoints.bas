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
    Dim entries(0 To 19) As EntryPointDef
    entries(0).ModuleName = "mod_Barcode": entries(0).EntryProc = "GenerateBarcode": entries(0).Trigger = TRIGGER_BUTTON: entries(0).Description = "ACCUEIL Barcode button"
    entries(1).ModuleName = "mod_CSVImportExport": entries(1).EntryProc = "ImportCSV": entries(1).Trigger = TRIGGER_BUTTON: entries(1).Description = "ACCUEIL Import CSV button"
    entries(2).ModuleName = "mod_CSVImportExport": entries(2).EntryProc = "ExportCSV": entries(2).Trigger = TRIGGER_BUTTON: entries(2).Description = "ACCUEIL Export CSV button"
    entries(3).ModuleName = "mod_Dashboard": entries(3).EntryProc = "RefreshDashboard": entries(3).Trigger = TRIGGER_BUTTON: entries(3).Description = "ACCUEIL Dashboard button"
    entries(4).ModuleName = "mod_DataValidator": entries(4).EntryProc = "ValidateDataIntegrity": entries(4).Trigger = TRIGGER_BUTTON: entries(4).Description = "ACCUEIL Validate button"
    entries(5).ModuleName = "mod_DemoData": entries(5).EntryProc = "GenerateDemoData": entries(5).Trigger = TRIGGER_BUTTON: entries(5).Description = "ACCUEIL Demo Data button"
    entries(6).ModuleName = "mod_ExportEngine": entries(6).EntryProc = "ExportTransactionToPDF": entries(6).Trigger = TRIGGER_CHAIN: entries(6).Description = "Called after transaction commit"
    entries(7).ModuleName = "mod_ExportEngine": entries(7).EntryProc = "ExportToExcel": entries(7).Trigger = TRIGGER_BUTTON: entries(7).Description = "ACCUEIL Export Excel button"
    entries(8).ModuleName = "mod_ExportEngine": entries(8).EntryProc = "ExportDashboardPDF": entries(8).Trigger = TRIGGER_BUTTON: entries(8).Description = "ACCUEIL Dashboard PDF button"
    entries(9).ModuleName = "mod_InventoryReconciliation": entries(9).EntryProc = "RunInventoryReconciliation": entries(9).Trigger = TRIGGER_BUTTON: entries(9).Description = "ACCUEIL Inventory button"
    entries(10).ModuleName = "mod_Procurement": entries(10).EntryProc = "GenerateOrderReport": entries(10).Trigger = TRIGGER_BUTTON: entries(10).Description = "ACCUEIL Order Report button"
    entries(11).ModuleName = "mod_Reports": entries(11).EntryProc = "GenerateMonthlyReport": entries(11).Trigger = TRIGGER_BUTTON: entries(11).Description = "ACCUEIL Monthly Report button"
    entries(12).ModuleName = "mod_Reports": entries(12).EntryProc = "GenerateStockCard": entries(12).Trigger = TRIGGER_BUTTON: entries(12).Description = "ACCUEIL Stock Card button"
    entries(13).ModuleName = "mod_StockAging": entries(13).EntryProc = "RunStockAgingReport": entries(13).Trigger = TRIGGER_BUTTON: entries(13).Description = "ACCUEIL Aging Report button"
    entries(14).ModuleName = "mod_StockEntry_Logic": entries(14).EntryProc = "InitializeForm": entries(14).Trigger = TRIGGER_FORM_LOAD: entries(14).Description = "frmStockEntry Initialize"
    entries(15).ModuleName = "mod_StockOutPredictor": entries(15).EntryProc = "RunStockOutPrediction": entries(15).Trigger = TRIGGER_BUTTON: entries(15).Description = "ACCUEIL Stockout Predict button"
    entries(16).ModuleName = "mod_SupplierScorecard": entries(16).EntryProc = "RunSupplierScorecard": entries(16).Trigger = TRIGGER_BUTTON: entries(16).Description = "ACCUEIL Scorecard button"
    entries(17).ModuleName = "mod_SyncBridge": entries(17).EntryProc = "SyncMetricsFromLedger": entries(17).Trigger = TRIGGER_CHAIN: entries(17).Description = "Called after transaction commit"
    entries(18).ModuleName = "mod_Utilities": entries(18).EntryProc = "ApplyInventoryHeatmap": entries(18).Trigger = TRIGGER_BUTTON: entries(18).Description = "ACCUEIL Heatmap button"
    entries(19).ModuleName = "mod_Utilities": entries(19).EntryProc = "SetupLocationDropdown": entries(19).Trigger = TRIGGER_BUTTON: entries(19).Description = "ACCUEIL Location dropdown button"
    GetEntryPoints = entries
End Function

Public Sub ListAllEntryPoints()
    Dim entries() As EntryPointDef
    entries = GetEntryPoints
    Dim i As Long
    Dim triggerNames As Variant
    triggerNames = Array("RIBBON", "BUTTON", "FORM_LOAD", "SCHEDULED", "CHAIN", "MANUAL")
    Debug.Print "=== ENTRY POINT REGISTRY ==="
    For i = LBound(entries) To UBound(entries)
        Debug.Print entries(i).ModuleName & " | " & entries(i).EntryProc & " | " & triggerNames(entries(i).Trigger) & " | " & entries(i).Description
    Next i
    Debug.Print "Total: " & (UBound(entries) - LBound(entries) + 1) & " entry points"
End Sub
