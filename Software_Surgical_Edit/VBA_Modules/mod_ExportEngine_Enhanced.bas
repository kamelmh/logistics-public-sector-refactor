' VBA Module: mod_ExportEngine_Enhanced.bas
' Purpose: Generate official PDF reports for Directorate of Education, El Bayadh
' Features: Bon de Réception, Bon de Sortie, Stock Ledger export
' CNEPD Compliant: Uses proper administrative terminology

Option Explicit

' =============================================
' Sub: ExportToPDF
' Purpose: Export current sheet to PDF with official formatting
' =============================================
Public Sub ExportToPDF(sheetName As String, Optional fileName As String = "")
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim exportPath As String
    Dim defaultName As String
    
    Set ws = ThisWorkbook.Sheets(sheetName)
    
    ' Generate default file name if not provided
    If fileName = "" Then
        defaultName = "Rapport_" & sheetName & "_" & Format(Now(), "YYYYMMDD_HHMMSS") & ".pdf"
    Else
        defaultName = fileName
        If Right(defaultName, 4) <> ".pdf" Then
            defaultName = defaultName & ".pdf"
        End If
    End If
    
    ' Set export path to Desktop
    exportPath = Environ("USERPROFILE") & "\Desktop\" & defaultName
    
    ' Export sheet to PDF
    ws.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        FileName:=exportPath, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=True, _
        IgnorePrintAreas:=False
        
    ' Confirm export
    MsgBox "Document exporté avec succès!" & vbCrLf & _
           "Emplacement: " & exportPath, _
           vbInformation, "Export PDF Réussi"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de l'export PDF: " & Err.Description, vbCritical, "Erreur Export"
End Sub

' =============================================
' Sub: GenerateBondeReception
' Purpose: Generate official Receipt Voucher (Bon de Réception)
' =============================================
Public Sub GenerateBondeReception(articleName As String, quantity As Double, supplier As String)
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim nextRow As Long
    
    ' Set reference to Bon de Réception sheet
    Set ws = ThisWorkbook.Sheets("Bon_de_Reception")
    
    ' Find next empty row
    nextRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row + 1
    
    ' Populate official document fields
    ws.Cells(nextRow, 1).Value = "BDR-" & Format(Now(), "YYYYMM") & "-" & nextRow - 1
    ws.Cells(nextRow, 2).Value = Now()
    ws.Cells(nextRow, 3).Value = articleName
    ws.Cells(nextRow, 4).Value = quantity
    ws.Cells(nextRow, 5).Value = supplier
    ws.Cells(nextRow, 6).Value = "En attente de validation"
    
    ' Auto-fit columns
    ws.Columns.AutoFit
    
    ' Export to PDF automatically
    ExportToPDF "Bon_de_Reception", "Bon_de_Reception_" & Format(Now(), "YYYYMMDD") & ".pdf"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de la génération du Bon de Réception: " & Err.Description, vbCritical
End Sub

' =============================================
' Sub: GenerateStockDashboard
' Purpose: Create automated stock critique dashboard
' =============================================
Public Sub GenerateStockDashboard()
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim ledge As Worksheet
    Dim dashboard As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim alertCount As Long
    
    Set ledge = ThisWorkbook.Sheets("StockLedger")
    Set dashboard = ThisWorkbook.Sheets("Dashboard")
    
    ' Clear previous alerts
    dashboard.Range("A2:E100").ClearContents
    
    ' Find items below reorder point
    lastRow = ledge.Cells(ledge.Rows.Count, 1).End(xlUp).Row
    alertCount = 0
    
    For i = 2 To lastRow
        Dim currentStock As Double
        Dim rop As Double
        
        currentStock = ledge.Cells(i, 4).Value ' Column D = Current Stock
        rop = ledge.Cells(i, 5).Value ' Column E = ROP
        
        If currentStock <= rop Then
            alertCount = alertCount + 1
            dashboard.Cells(alertCount + 1, 1).Value = ledge.Cells(i, 1).Value ' Article
            dashboard.Cells(alertCount + 1, 2).Value = currentStock
            dashboard.Cells(alertCount + 1, 3).Value = rop
            dashboard.Cells(alertCount + 1, 4).Value = "ALERTE: Réapprovisionnement requis!"
            dashboard.Cells(alertCount + 1, 5).Value = Format(Now(), "DD/MM/YYYY")
        End If
    Next i
    
    ' Update dashboard summary
    dashboard.Range("H2").Value = "Total Alertes: " & alertCount
    dashboard.Range("H3").Value = "Date: " & Format(Now(), "DD/MM/YYYY")
    
    MsgBox "Tableau de bord mis à jour: " & alertCount & " alerte(s) générée(s).", vbInformation
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de la génération du dashboard: " & Err.Description, vbCritical
End Sub
