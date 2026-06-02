Attribute VB_Name = "mod_UI_Setup"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
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
    ' Ensure ACCUEIL bilingual strings exist in SYS_STRINGS
    mod_Localization.PopulateAccueilSysStrings

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
    Call DrawStockoutBanner(ws, rowCur)
    rowCur = rowCur + 4
    Call DrawSectionHeader(ws, rowCur, 1, "SAISIE", "Saisie des mouvements de stock", "ACC_SEC_SAISIE", RGB(0, 102, 204))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[ENTRY] Formulaire de Saisie", "ACC_BTN_SAISIE", "mod_Navigation.OpenStockForm"
    AddAccueilButton ws, COL2, rowCur, "[BARCODE] Scanner Article", "ACC_BTN_BARCODE", "mod_Barcode.ScanBarcode"
    AddAccueilButton ws, COL3, rowCur, "[SCAN-IN] Entree par Code", "ACC_BTN_SCANIN", "mod_Barcode.ScanBarcodeStockIn"
    rowCur = rowCur + 3
    AddAccueilButton ws, COL1, rowCur, "[SCAN-OUT] Sortie par Code", "ACC_BTN_SCANOUT", "mod_Barcode.ScanBarcodeStockOut"
    AddAccueilButton ws, COL2, rowCur, "[CSV] Importer Mouvements", "ACC_BTN_CSV_IMPORT", "mod_CSVImportExport.ImportMouvementsFromCSV"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 2, "TABLEAU DE BORD", "KPIs, alertes et visualisation", "ACC_SEC_TABLEAU_BORD", RGB(4, 90, 55))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[DASHBOARD] Actualiser les KPIs", "ACC_BTN_DASHBOARD", "mod_Dashboard.RefreshDashboard"
    AddAccueilButton ws, COL2, rowCur, "[HEATMAP] Appliquer Heatmap", "ACC_BTN_HEATMAP", "mod_Utilities.ApplyInventoryHeatmap"
    AddAccueilButton ws, COL3, rowCur, "[STOCKOUT] Prevision Ruptures", "ACC_BTN_STOCKOUT", "mod_StockOutPredictor.RunStockOutPrediction"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 3, "ANALYSE", "Calculs EOQ, CMUP, ABC, pr" & Chr(233) & "visions", "ACC_SEC_ANALYSE", RGB(120, 40, 120))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[ABC] Classement ABC", "ACC_BTN_ABC", "mod_Analysis.UpdateABC_Classification"
    AddAccueilButton ws, COL2, rowCur, "[CMUP] Rafraichir CMUP", "ACC_BTN_CMUP", "mod_StockEngine.RefreshAllCMUP"
    AddAccueilButton ws, COL3, rowCur, "[FORECAST] Pr" & Chr(233) & "vision Rupture", "ACC_BTN_FORECAST", "mod_Analysis.RunStockOutAnalysis"

    rowCur = rowCur + 4
    AddAccueilButton ws, COL1, rowCur, "[FULL] Analyse Complete", "ACC_BTN_FULL_ANALYSIS", "mod_Analysis.RunFullAnalysis"
    AddAccueilButton ws, COL2, rowCur, "[AGING] Vieillissement Stock", "ACC_BTN_AGING", "mod_Analysis.RunStockAgingAnalysis"
    AddAccueilButton ws, COL3, rowCur, "[RECONCILE] Inventaire", "ACC_BTN_RECONCILE", "mod_InventoryReconciliation.RunInventoryReconciliation"

    rowCur = rowCur + 4
    AddAccueilButton ws, COL1, rowCur, "[SCORECARD] Fournisseurs", "ACC_BTN_SCORECARD", "mod_SupplierScorecard.RunSupplierScorecard"
    AddAccueilButton ws, COL2, rowCur, "[BUDGET] Rapport Budget", "ACC_BTN_BUDGET", "mod_Budget.GenerateBudgetReport"
    AddAccueilButton ws, COL3, rowCur, "[IMPORT] Importer CSV", "ACC_BTN_IMPORT_CSV", "mod_CSVImportExport.ExportMouvementsToCSV"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 4, "RAPPORTS", "G" & Chr(233) & "n" & Chr(233) & "ration de documents", "ACC_SEC_RAPPORTS", RGB(160, 70, 0))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[REPORT] Rapport Mensuel", "ACC_BTN_REPORT", "mod_Reports.GenerateMonthlyReport"
    AddAccueilButton ws, COL2, rowCur, "[CARD] Fiche de Stock", "ACC_BTN_STOCK_CARD", "mod_Reports.GenerateStockCard"
    AddAccueilButton ws, COL3, rowCur, "[ORDER] Rapport Approvisionnement", "ACC_BTN_ORDER", "mod_Procurement.GenerateOrderReport"
    rowCur = rowCur + 3
    AddAccueilButton ws, COL1, rowCur, "[PRINT] Config. Impression", "ACC_BTN_PRINT_CFG", "mod_Reports.ConfigurerImpression"
    AddAccueilButton ws, COL2, rowCur, "[PRINT] Aper" & Chr(133) & "u RAPPORTS", "ACC_BTN_PREVIEW_RAPPORTS", "mod_Reports.PreviewRapports"
    AddAccueilButton ws, COL3, rowCur, "[PRINT] Aper" & Chr(133) & "u INVENTAIRE", "ACC_BTN_PREVIEW_INVENTAIRE", "mod_Reports.PreviewInventaire"

    rowCur = rowCur + 10
    Call DrawSectionHeader(ws, rowCur, 5, "UTILITAIRES", "Outils de maintenance et validation", "ACC_SEC_UTILITAIRES", RGB(100, 100, 100))
    rowCur = rowCur + 2
    AddAccueilButton ws, COL1, rowCur, "[VALIDATE] Int" & Chr(233) & "grit" & Chr(233) & " Donn" & Chr(233) & "es", "ACC_BTN_VALIDATE", "mod_DataValidator.RunDataValidation"
    AddAccueilButton ws, COL2, rowCur, "[SYNC] Synchronisation", "ACC_BTN_SYNC", "mod_SyncBridge.SyncMetricsFromLedger"
    AddAccueilButton ws, COL3, rowCur, "[LOCATION] Config. Emplacements", "ACC_BTN_LOCATION", "mod_Utilities.SetupLocationDropdown"

    rowCur = rowCur + 4
    AddAccueilButton ws, COL1, rowCur, "[CSV] Exporter Mouvements", "ACC_BTN_EXPORT_CSV", "mod_CSVImportExport.ExportMouvementsToCSV"
    AddAccueilButton ws, COL2, rowCur, "[EXCEL] Export Rapport", "ACC_BTN_EXPORT_XLS", "mod_ExportEngine.ExportToExcel"
    AddAccueilButton ws, COL3, rowCur, "[DEMO] G" & Chr(233) & "n" & Chr(233) & "rer Donn" & Chr(233) & "es Test", "ACC_BTN_DEMO", "mod_DemoData.GenerateDemoData"

    rowCur = rowCur + 12
    Call DrawFooter(ws, rowCur)
End Sub

Private Sub DrawHeader(ByVal ws As Worksheet, ByVal row As Long)
    With ws.Range("B" & row & ":D" & row)
        .Merge
        .Value = "ERP Acad" & Chr(233) & "mie  v13.2"
        .Font.Name = "Segoe UI"
        .Font.Size = 20
        .Font.Bold = True
        .Font.Color = RGB(0, 70, 127)
        .HorizontalAlignment = xlCenter
        .RowHeight = 30
    End With
    ws.Range("B" & row + 1 & ":D" & row + 1).Merge
    ws.Range("B" & row + 1).Value = mod_Localization.GetBilingualLabel( _
        "Direction de l'Education - El Bayadh  |  Syst" & Chr(232) & "me de Gestion des Stocks", "ACC_HDR_SUBTITLE")
    ws.Range("B" & row + 1).Font.Name = "Segoe UI"
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

    DrawKpiCard ws, COL1, row, "Articles", CStr(totalSKUs), "ACC_KPI_ARTICLES", RGB(0, 102, 204), RGB(232, 240, 254)
    On Error Resume Next
    countAlert = Application.WorksheetFunction.CountIf(wsArt.Columns(COL_ART_STOCK_ACTUEL), "<=" & 205)
    On Error GoTo 0
    DrawKpiCard ws, COL2, row, "Alertes Stock", IIf(countAlert > 0, CStr(countAlert), "0"), "ACC_KPI_ALERTES", RGB(200, 30, 30), RGB(255, 235, 235)
    DrawKpiCard ws, COL3, row, "Mis " & Chr(224) & " jour", Format(Now, "HH:MM"), "ACC_KPI_MIS_A_JOUR", RGB(4, 90, 55), RGB(232, 245, 233)
End Sub

Private Sub DrawKpiCard(ByVal ws As Worksheet, ByVal leftCol As Long, ByVal row As Long, _
                         ByVal label As String, ByVal value As String, _
                         ByVal arKey As String, _
                         ByVal accentColor As Long, ByVal bgColor As Long)
    Dim rng As Range
    Set rng = ws.Range(ws.Cells(row, leftCol), ws.Cells(row + 4, leftCol + 1))
    With rng
        .Interior.Color = bgColor
        .BorderAround xlContinuous, xlMedium, accentColor
    End With

    ws.Cells(row + 1, leftCol).Value = mod_Localization.GetBilingualLabel(label, arKey)
    ws.Cells(row + 1, leftCol).Font.Name = "Segoe UI"
    ws.Cells(row + 1, leftCol).Font.Size = 9
    ws.Cells(row + 1, leftCol).Font.Color = RGB(120, 120, 120)
    ws.Cells(row + 1, leftCol).Font.Bold = False
    ws.Cells(row + 1, leftCol).HorizontalAlignment = xlCenter

    ws.Range(ws.Cells(row + 2, leftCol), ws.Cells(row + 3, leftCol + 1)).Merge
    ws.Cells(row + 2, leftCol).Value = value
    ws.Cells(row + 2, leftCol).Font.Name = "Segoe UI"
    ws.Cells(row + 2, leftCol).Font.Size = 24
    ws.Cells(row + 2, leftCol).Font.Bold = True
    ws.Cells(row + 2, leftCol).Font.Color = accentColor
    ws.Cells(row + 2, leftCol).HorizontalAlignment = xlCenter
    ws.Cells(row + 2, leftCol).VerticalAlignment = xlCenter
    ws.Rows(row + 2).RowHeight = 35
End Sub

Private Sub DrawSectionHeader(ByVal ws As Worksheet, ByVal row As Long, _
                               ByVal sectionNum As Integer, ByVal title As String, _
                               ByVal subtitleFR As String, ByVal subtitleARKey As String, _
                               ByVal color As Long)
    Dim rng As Range
    Set rng = ws.Range("B" & row & ":D" & row)
    Dim subtitle As String
    subtitle = mod_Localization.GetBilingualLabel(subtitleFR, subtitleARKey)
    With rng
        .Merge
        .Value = "  " & sectionNum & ". " & title & "  -  " & subtitle
        .Font.Name = "Segoe UI"
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
                              ByVal arKey As String, ByVal action As String)
    Dim leftPx As Long
    leftPx = (leftPosCol - 1) * 55 + 15

    Dim bilingualCaption As String
    bilingualCaption = mod_Localization.GetBilingualLabel(caption, arKey)

    Dim btn As Button
    Set btn = ws.Buttons.Add(leftPx, topRow * 15, BTN_W, BTN_H)
    With btn
        .Caption = bilingualCaption
        .OnAction = action
        .Font.Bold = True
        .Font.Size = 9
        .Font.Name = "Segoe UI"
    End With
End Sub

'--------------------------------------------------------------------------------------
' HELPER: Draw Stockout Alert Banner
' Scans ARTICLES for low-stock items and displays a warning banner on ACCUEIL.
' Articles with stock <= ROP are listed. Color = orange (alerts) or red (rupture).
'--------------------------------------------------------------------------------------
Private Sub DrawStockoutBanner(ByVal ws As Worksheet, ByVal row As Long)
    Dim wsArt As Worksheet
    Dim lastRow As Long, i As Long
    Dim artCode As String, designation As String
    Dim stock As Double, pu As Double
    Dim ss As Double, rop As Double
    Dim atRiskCount As Long, ruptureCount As Long
    Dim atRiskList As String
    
    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0
    If wsArt Is Nothing Then Exit Sub
    
    lastRow = wsArt.Cells(wsArt.Rows.Count, mod_Config.COL_ART_CODE).End(xlUp).Row
    atRiskCount = 0
    ruptureCount = 0
    atRiskList = ""
    
    For i = 3 To lastRow
        artCode = Trim(wsArt.Cells(i, mod_Config.COL_ART_CODE).Value)
        If artCode <> "" Then
            stock = mod_Utilities.SafeVal(wsArt.Cells(i, mod_Config.COL_ART_STOCK_ACTUEL).Value)
            pu = mod_Utilities.SafeVal(wsArt.Cells(i, mod_Config.COL_ART_PU).Value)
            
            ' Get safety stock and ROP
            ss = mod_StockEngine.GetSafetyStock(artCode)
            Dim annualDemand As Double
            annualDemand = mod_StockEngine.GetAnnualDemandFromHistory(artCode)
            rop = mod_StockEngine.ComputeROP(annualDemand / mod_Config.WORKING_DAYS_PER_YEAR, artCode)
            
            If stock <= 0 Then
                ruptureCount = ruptureCount + 1
                atRiskList = atRiskList & artCode & " (RUPTURE), "
            ElseIf stock <= rop Then
                atRiskCount = atRiskCount + 1
                designation = Left(Trim(wsArt.Cells(i, mod_Config.COL_ART_DESIGNATION).Value), 20)
                atRiskList = atRiskList & artCode & " [" & stock & " u], "
            End If
        End If
    Next i
    
    ' Trim trailing comma
    If Len(atRiskList) > 2 Then atRiskList = Left(atRiskList, Len(atRiskList) - 2)
    
    ' Draw banner
    Dim bannerColor As Long
    Dim bannerText As String
    Dim totalCount As Long
    totalCount = ruptureCount + atRiskCount
    
    If totalCount = 0 Then
        ' All clear - green banner
        bannerColor = RGB(232, 245, 233)
        bannerText = "  AUCUNE ALERTE - Stock OK pour tous les articles"
        With ws.Range("B" & row & ":D" & row + 2)
            .Merge
            .Value = bannerText
            .Font.Name = "Segoe UI"
            .Font.Size = 10
            .Font.Bold = True
            .Font.Color = RGB(4, 90, 55)
            .Interior.Color = bannerColor
            .VerticalAlignment = xlCenter
            .BorderAround xlContinuous, xlThin, RGB(4, 90, 55)
        End With
    ElseIf ruptureCount > 0 Then
        ' Rupture - red banner
        bannerColor = RGB(255, 220, 220)
        bannerText = "  RUPTURE: " & ruptureCount & " article(s) en rupture  |  " & atRiskList
        With ws.Range("B" & row & ":D" & row + 2)
            .Merge
            .Value = bannerText
            .Font.Name = "Segoe UI"
            .Font.Size = 9
            .Font.Bold = True
            .Font.Color = RGB(180, 0, 0)
            .Interior.Color = bannerColor
            .VerticalAlignment = xlCenter
            .BorderAround xlContinuous, xlMedium, RGB(180, 0, 0)
        End With
    Else
        ' Alerts only - orange banner
        bannerColor = RGB(255, 243, 224)
        bannerText = "  ALERTES: " & atRiskCount & " article(s) sous le seuil  |  " & atRiskList
        With ws.Range("B" & row & ":D" & row + 2)
            .Merge
            .Value = bannerText
            .Font.Name = "Segoe UI"
            .Font.Size = 9
            .Font.Bold = True
            .Font.Color = RGB(160, 70, 0)
            .Interior.Color = bannerColor
            .VerticalAlignment = xlCenter
            .BorderAround xlContinuous, xlThin, RGB(160, 70, 0)
        End With
    End If
End Sub

Private Sub DrawFooter(ByVal ws As Worksheet, ByVal row As Long)
    With ws.Range("B" & row & ":D" & row)
        .Merge
        .Value = mod_Localization.GetBilingualLabel("Derni" & Chr(232) & "re actualisation", "ACC_FOOTER_LAST_UPD") & " : " & Format(Now, "DD/MM/YYYY HH:MM:SS")
        .Font.Name = "Segoe UI"
        .Font.Size = 8
        .Font.Italic = True
        .Font.Color = RGB(150, 150, 150)
        .HorizontalAlignment = xlCenter
    End With
End Sub
