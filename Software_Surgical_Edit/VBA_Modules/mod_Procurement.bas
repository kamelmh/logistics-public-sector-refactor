Attribute VB_Name = "mod_Procurement"
Option Explicit

'=======================================================================================
' MODULE: mod_Procurement.bas
' PROJECT: ERP Academie v13.2
' PURPOSE: Procurement Intelligence & Order Suggestion Engine
'
' This module translates current stock levels and computed ROP/EOQ metrics from the
' ARTICLES sheet into an actionable "Bordereau de Commande" (Order Report).
'=======================================================================================

'--------------------------------------------------------------------------------------
' MAIN ENTRY POINT: GenerateOrderReport
' Scans the ARTICLES sheet for items in ALERT or RUPTURE status and
' generates a formatted procurement sheet.
'--------------------------------------------------------------------------------------
Public Sub GenerateOrderReport()
    Dim wsArt As Worksheet: Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    Dim wsOrder As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim rowNum As Long
    
    lastRow = wsArt.Cells(wsArt.Rows.count, COL_ART_CODE).End(xlUp).Row
    If lastRow < 2 Then
        MsgBox "Aucun article trouvé dans le catalogue.", vbExclamation, "ACADEMIX v13"
        Exit Sub
    End If
    
    ' 1. Setup / Clear Order Sheet
    Set wsOrder = GetOrCreateSheet("BORDEREAU_COMMANDE")
    wsOrder.Cells.Clear
    wsOrder.Cells.Interior.ColorIndex = xlNone
    
    ' 2. Header Setup
    Dim headers As Variant
    headers = Array("SKU", "Designation", "Stock Actuel", "Seuil ROP", "Suggestion (EOQ)", "Prix Unit.", "Total Estime (DZD)")
    
    With wsOrder.Range("A1:G1")
        .Value = headers
        .Font.Bold = True
        .Font.Color = RGB(255, 255, 255)
        .Interior.Color = RGB(0, 70, 127)
        .HorizontalAlignment = xlCenter
        .Borders.LineStyle = xlContinuous
    End With
    
    rowNum = 2
    
    ' 3. Process Articles
    wsArt.Unprotect Password:=mod_Config.MASTER_PWD
    
    For i = 2 To lastRow
        Dim sku As String: sku = Trim(wsArt.Cells(i, COL_ART_CODE).Value)
        If sku = "" Then GoTo NextArticle
        
        Dim desig As String: desig = wsArt.Cells(i, COL_ART_DESIGNATION).Value
        Dim stock As Long: stock = Val(wsArt.Cells(i, COL_ART_STOCK).Value)
        Dim pu As Double: pu = Val(wsArt.Cells(i, COL_ART_PU).Value) ' Col H: PU/CMUP
        
        ' Calculate ROP and EOQ locally
        Dim AnnualDemand As Double: AnnualDemand = mod_StockEngine.GetAnnualDemandFromHistory(sku)
        Dim avgDaily As Double: avgDaily = AnnualDemand / mod_Config.WORKING_DAYS_PER_YEAR
        Dim rop As Double: rop = mod_StockEngine.ComputeROP(avgDaily, sku)
        Dim eoq As Double: eoq = mod_StockEngine.ComputeEOQ(AnnualDemand, pu)
        
        ' Check if item is in ALERT or RUPTURE
        If stock <= rop Then
            ' Only suggest if EOQ > 0
            If eoq > 0 Then
                wsOrder.Cells(rowNum, 1).Value = sku
                wsOrder.Cells(rowNum, 2).Value = desig
                wsOrder.Cells(rowNum, 3).Value = stock
                wsOrder.Cells(rowNum, 4).Value = Round(rop, 1)
                wsOrder.Cells(rowNum, 5).Value = Round(eoq, 0)
                wsOrder.Cells(rowNum, 6).Value = pu
                wsOrder.Cells(rowNum, 7).Value = Round(eoq * pu, 2)
                
                ' Color coding: Red for Rupture, Yellow for Alert
                If stock <= 0 Then
                    wsOrder.Range("A" & rowNum & ":G" & rowNum).Interior.Color = RGB(255, 200, 200)
                Else
                    wsOrder.Range("A" & rowNum & ":G" & rowNum).Interior.Color = RGB(255, 255, 200)
                End If
                
                rowNum = rowNum + 1
            End If
        End If
NextArticle:
    Next i
    
    wsArt.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    ' 4. Final Formatting
    If rowNum > 2 Then
        With wsOrder.Range("A2:G" & rowNum - 1)
            .Borders.LineStyle = xlContinuous
            .Borders.Weight = xlThin
        End With
        wsOrder.Range("F2:G" & rowNum - 1).NumberFormat = "#,##0.00 ""DZD"""
        wsOrder.Columns("A:G").AutoFit
        
        ' Total Calculation
        wsOrder.Cells(rowNum, 6).Value = "TOTAL ESTIMÉ :"
        wsOrder.Cells(rowNum, 6).Font.Bold = True
        wsOrder.Cells(rowNum, 7).Formula = "=SUM(G2:G" & rowNum - 1 & ")"
        wsOrder.Cells(rowNum, 7).Font.Bold = True
        wsOrder.Cells(rowNum, 7).NumberFormat = "#,##0.00 ""DZD"""
    Else
        MsgBox "Aucun article ne nécessite de réapprovisionnement.", vbInformation, "ACADEMIX v13"
    End If
    
    MsgBox "Bordereau de commande généré avec succès !", vbInformation, "ACADEMIX v13"
End Sub

'--------------------------------------------------------------------------------------
' HELPER: Get or Create Worksheet
'--------------------------------------------------------------------------------------
Private Function GetOrCreateSheet(sheetName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(sheetName)
    On Error GoTo 0
    
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.count))
        ws.name = sheetName
    End If
    Set GetOrCreateSheet = ws
End Function
