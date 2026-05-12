Attribute VB_Name = "mod_UI_Setup"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Private Const BTN_W As Long = 240
Private Const BTN_H As Long = 28
Private Const COL1 As Long = 50
Private Const COL2 As Long = 340
Private Const COL3 As Long = 630

Public Sub SetupAccueilSheet()
    Dim ws As Worksheet
    Dim rowCur As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_ACCUEIL)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(Before:=ThisWorkbook.Sheets(1))
        ws.Name = mod_Config.SHEET_ACCUEIL
    End If

    ws.Buttons.Delete
    ws.Cells.Clear
    ws.Cells.Interior.Color = RGB(245, 245, 250)

    ws.Columns("A").ColumnWidth = 3
    ws.Columns("B").ColumnWidth = 32
    ws.Columns("C").ColumnWidth = 32
    ws.Columns("D").ColumnWidth = 32

    rowCur = 3
    Call DrawHeader(ws, rowCur)

    rowCur = rowCur + 8
    Call FillKpiRow(ws, rowCur)

    rowCur = rowCur + 15
    Call DrawSectionHeader(ws, rowCur, 1, "SAISIE", "Saisie des mouvements de stock", RGB(0, 102, 204))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[ENTRY] Formulaire de Saisie", "mod_Navigation.OpenStockForm"
    AddAccueilButton ws, COL2, rowCur, "[BARCODE] Scanner Article", "mod_Barcode.ScanBarcode"
    AddAccueilButton ws, COL3, rowCur, "[CSV] Importer Mouvements", "mod_CSVImportExport.ImportMouvementsFromCSV"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 2, "TABLEAU DE BORD", "KPIs, alertes et visualisation", RGB(4, 90, 55))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[DASHBOARD] Actualiser les KPIs", "mod_Dashboard.RefreshDashboard"
    AddAccueilButton ws, COL2, rowCur, "[HEATMAP] Appliquer Heatmap", "mod_Utilities.ApplyInventoryHeatmap"
    AddAccueilButton ws, COL3, rowCur, "[PDF] Exporter Dashboard", "mod_ExportEngine.ExportDashboardPDF"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 3, "ANALYSE", "Calculs EOQ, CMUP, ABC, pr" & Chr(233) & "visions", RGB(120, 40, 120))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[ABC] Classement ABC", "mod_StockEngine.UpdateAllABCClassifications"
    AddAccueilButton ws, COL2, rowCur, "[CMUP] Rafraichir CMUP", "mod_StockEngine.RefreshAllCMUP"
    AddAccueilButton ws, COL3, rowCur, "[FORECAST] Pr" & Chr(233) & "vision Rupture", "mod_StockOutPredictor.RunStockOutPrediction"

    rowCur = rowCur + 4
    AddAccueilButton ws, COL1, rowCur, "[RECONCILE] Inventaire", "mod_InventoryReconciliation.RunInventoryReconciliation"
    AddAccueilButton ws, COL2, rowCur, "[SCORECARD] Fournisseurs", "mod_SupplierScorecard.RunSupplierScorecard"
    AddAccueilButton ws, COL3, rowCur, "[AGING] Vieillissement Stock", "mod_StockAging.RunStockAgingReport"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 4, "RAPPORTS", "G" & Chr(233) & "n" & Chr(233) & "ration de documents", RGB(160, 70, 0))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[REPORT] Rapport Mensuel", "mod_Reports.GenerateMonthlyReport"
    AddAccueilButton ws, COL2, rowCur, "[CARD] Fiche de Stock", "mod_Reports.GenerateStockCard"
    AddAccueilButton ws, COL3, rowCur, "[ORDER] Rapport Approvisionnement", "mod_Procurement.GenerateOrderReport"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 5, "UTILITAIRES", "Outils de maintenance et validation", RGB(100, 100, 100))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[VALIDATE] Int" & Chr(233) & "grit" & Chr(233) & " Donn" & Chr(233) & "es", "mod_DataValidator.RunDataValidation"
    AddAccueilButton ws, COL2, rowCur, "[SYNC] Synchronisation", "mod_SyncBridge.SyncMetricsFromLedger"
    AddAccueilButton ws, COL3, rowCur, "[LOCATION] Config. Emplacements", "mod_Utilities.SetupLocationDropdown"

    rowCur = rowCur + 4
    AddAccueilButton ws, COL1, rowCur, "[CSV] Exporter Mouvements", "mod_CSVImportExport.ExportMouvementsToCSV"
    AddAccueilButton ws, COL2, rowCur, "[EXCEL] Export Rapport", "mod_ExportEngine.ExportToExcel"
    AddAccueilButton ws, COL3, rowCur, "[DEMO] G" & Chr(233) & "n" & Chr(233) & "rer Donn" & Chr(233) & "es Test", "mod_DemoData.GenerateDemoData"

    rowCur = rowCur + 12
    Call DrawFooter(ws, rowCur)
End Sub

Private Sub DrawHeader(ByVal ws As Worksheet, ByVal row As Long)
    With ws.Range("B" & row & ":D" & row)
        .Merge
        .Value = "ERP Acad" & Chr(233) & "mie  v13.2"
        .Font.Size = 20
        .Font.Bold = True
        .Font.Color = RGB(0, 70, 127)
        .HorizontalAlignment = xlCenter
        .RowHeight = 30
    End With
    ws.Range("B" & row + 1 & ":D" & row + 1).Merge
    ws.Range("B" & row + 1).Value = "Direction de l'Education - El Bayadh  |  Syst" & Chr(232) & "me de Gestion des Stocks"
    ws.Range("B" & row + 1).Font.Size = 10
    ws.Range("B" & row + 1).Font.Italic = True
    ws.Range("B" & row + 1).Font.Color = RGB(100, 100, 100)
    ws.Range("B" & row + 1).HorizontalAlignment = xlCenter
End Sub

Private Sub FillKpiRow(ByVal ws As Worksheet, ByVal row As Long)
    Dim totalSKUs As Long
    Dim countAlert As Long

    On Error Resume Next
    Dim wsArt As Worksheet
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    If Not wsArt Is Nothing Then
        totalSKUs = wsArt.Cells(wsArt.Rows.Count, mod_Config.COL_ART_CODE).End(xlUp).Row - 2
        If totalSKUs < 0 Then totalSKUs = 0
    End If
    On Error GoTo 0

    DrawKpiCard ws, COL1, row, "Articles", CStr(totalSKUs), RGB(0, 102, 204), RGB(232, 240, 254)
    On Error Resume Next
    countAlert = Application.WorksheetFunction.CountIf(wsArt.Range("G:G"), "<=" & 205)
    On Error GoTo 0
    DrawKpiCard ws, COL2, row, "Alertes Stock", IIf(countAlert > 0, CStr(countAlert), "0"), RGB(200, 30, 30), RGB(255, 235, 235)
    DrawKpiCard ws, COL3, row, "Mis " & Chr(224) & " jour", Format(Now, "HH:MM"), RGB(4, 90, 55), RGB(232, 245, 233)
End Sub

Private Sub DrawKpiCard(ByVal ws As Worksheet, ByVal leftCol As Long, ByVal row As Long, _
                         ByVal label As String, ByVal value As String, _
                         ByVal accentColor As Long, ByVal bgColor As Long)
    Dim rng As Range
    Set rng = ws.Range(ws.Cells(row, leftCol), ws.Cells(row + 4, leftCol + 1))
    With rng
        .Interior.Color = bgColor
        .BorderAround xlContinuous, xlMedium, accentColor
    End With

    ws.Cells(row + 1, leftCol).Value = label
    ws.Cells(row + 1, leftCol).Font.Size = 9
    ws.Cells(row + 1, leftCol).Font.Color = RGB(120, 120, 120)
    ws.Cells(row + 1, leftCol).Font.Bold = False
    ws.Cells(row + 1, leftCol).HorizontalAlignment = xlCenter

    ws.Range(ws.Cells(row + 2, leftCol), ws.Cells(row + 3, leftCol + 1)).Merge
    ws.Cells(row + 2, leftCol).Value = value
    ws.Cells(row + 2, leftCol).Font.Size = 24
    ws.Cells(row + 2, leftCol).Font.Bold = True
    ws.Cells(row + 2, leftCol).Font.Color = accentColor
    ws.Cells(row + 2, leftCol).HorizontalAlignment = xlCenter
    ws.Cells(row + 2, leftCol).VerticalAlignment = xlCenter
    ws.Rows(row + 2).RowHeight = 35
End Sub

Private Sub DrawSectionHeader(ByVal ws As Worksheet, ByVal row As Long, _
                               ByVal sectionNum As Integer, ByVal title As String, _
                               ByVal subtitle As String, ByVal color As Long)
    Dim rng As Range
    Set rng = ws.Range("B" & row & ":D" & row)
    With rng
        .Merge
        .Value = "  " & sectionNum & ". " & title & "  -  " & subtitle
        .Font.Size = 11
        .Font.Bold = True
        .Font.Color = RGB(255, 255, 255)
        .Interior.Color = color
        .HorizontalAlignment = xlLeft
        .VerticalAlignment = xlCenter
        .RowHeight = 30
        .BorderAround xlContinuous, xlMedium, color
    End With
End Sub

Private Sub AddAccueilButton(ByVal ws As Worksheet, ByVal leftPosCol As Long, _
                              ByVal topRow As Long, ByVal caption As String, _
                              ByVal action As String)
    Dim leftPx As Long
    leftPx = (leftPosCol - 1) * 55 + 15

    Dim btn As Button
    Set btn = ws.Buttons.Add(leftPx, topRow * 15, BTN_W, BTN_H)
    With btn
        .Caption = caption
        .OnAction = action
        .Font.Bold = True
        .Font.Size = 9
        .Font.Name = "Calibri"
    End With
End Sub

Private Sub DrawFooter(ByVal ws As Worksheet, ByVal row As Long)
    With ws.Range("B" & row & ":D" & row)
        .Merge
        .Value = "Derni" & Chr(232) & "re actualisation : " & Format(Now, "DD/MM/YYYY HH:MM:SS")
        .Font.Size = 8
        .Font.Italic = True
        .Font.Color = RGB(150, 150, 150)
        .HorizontalAlignment = xlCenter
    End With
End Sub
