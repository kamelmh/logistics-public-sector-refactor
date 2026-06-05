Attribute VB_Name = "mod_StockEngine"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' ============================================================================

Option Explicit

Public Type ArticleDetails
    Code        As String
    Designation As String
    Category    As String
    PU          As Double
    Stock       As Long
End Type

' ... (existing code)


' ================================================================================
' CONSTANTS ? Synchronized with Unit� de traitement VBA GROUND_TRUTH
' ================================================================================
Private Const ORDER_COST_S  As Double = 801.45 ' DZD ? full order cycle cost (field-refined from 500)
Private Const HOLDING_RATE  As Double = 0.2    ' 20% of unit price per year
Private Const LEAD_TIME_DEFAULT As Integer = 2 ' Default delivery days

' Article-specific safety stocks ? mirrors Unit� de traitement VBA GROUND_TRUTH
Public Function GetSafetyStock(ByVal sku As String) As Double
    Select Case UCase(Trim(sku))
        Case "ART-001": GetSafetyStock = 200
        Case "ART-005": GetSafetyStock = 10
        Case "ART-002": GetSafetyStock = 50
        Case "ART-003": GetSafetyStock = 20
        Case Else:      GetSafetyStock = 50
    End Select
End Function

' ================================================================================
' FUNCTION: ComputeEOQ
' Formula: Q* = SQRT(2 x D x S / (P x t))
' ================================================================================
Public Function ComputeEOQ(ByVal AnnualDemand As Double, _
                            ByVal unitPrice As Double) As Double
    If unitPrice <= 0 Or AnnualDemand <= 0 Then
        ComputeEOQ = 0
        Exit Function
    End If

    Dim holdingCostH As Double
    holdingCostH = unitPrice * HOLDING_RATE

    ComputeEOQ = Sqr((2 * AnnualDemand * ORDER_COST_S) / holdingCostH)
End Function

' ================================================================================
' FUNCTION: GetServices
' Returns a list of services from the SYS_STRINGS sheet.
' ================================================================================
Public Function GetServices() As Collection
    Dim services As New Collection
    Dim wsStr As Worksheet
    Dim lastRow As Long, i As Long
    
    On Error Resume Next
    Set wsStr = ThisWorkbook.Sheets(mod_Config.SHEET_SYS_STRINGS)
    On Error GoTo 0
    
    If Not wsStr Is Nothing Then
        lastRow = wsStr.Cells(wsStr.Rows.count, COL_SYS_ID).End(xlUp).Row
        For i = 2 To lastRow
            If Left(Trim(CStr(wsStr.Cells(i, COL_SYS_ID).Value)), 4) = "SVC_" Then
                services.Add Trim(CStr(wsStr.Cells(i, COL_SYS_VALUE).Value))
            End If
        Next i
    End If
    
    If services.count = 0 Then
        services.Add "Service 1"
        services.Add "Service 2"
        services.Add "Fournisseur Externe"
    End If
    
    Set GetServices = services
End Function

' ================================================================================
' FUNCTION: GetArticles
' Returns a list of articles (Code | Designation) from the ARTICLES sheet.
' ================================================================================
Public Function GetArticles(ByVal filterCat As String) As Collection
    Dim articles As New Collection
    Dim wsArt As Worksheet
    Dim lastRow As Long, i As Long
    Dim code As String, desig As String, cat As String
    Dim noFilter As Boolean

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If wsArt Is Nothing Then
        articles.Add "ART-001 | Papier A4"
        articles.Add "ART-002 | Papier A3"
        articles.Add "ART-003 | Sous-Chemise"
        Set GetArticles = articles
        Exit Function
    End If

    noFilter = (filterCat = "" Or filterCat = "(Toutes)")
    lastRow = wsArt.Cells(wsArt.Rows.count, COL_ART_CODE).End(xlUp).Row

    For i = 3 To lastRow
        code = Trim(CStr(wsArt.Cells(i, COL_ART_CODE).Value))
        desig = Trim(CStr(wsArt.Cells(i, COL_ART_DESIGNATION).Value))
        cat = Trim(CStr(wsArt.Cells(i, COL_ART_CATEGORIE).Value))

        If code <> "" Then
            If noFilter Or (cat = filterCat) Then
                articles.Add code & " | " & desig
            End If
        End If
    Next i

    Set GetArticles = articles
End Function


' ================================================================================
' SUB: ValidateStockLevel
' Fires a UI alert if current stock breaches ROP.
' ================================================================================
Public Sub ValidateStockLevel(ByVal sku As String, _
                               ByVal CurrentStock As Double, _
                               ByVal AnnualDemand As Double, _
                               ByVal unitPrice As Double)
    If AnnualDemand <= 0 Then Exit Sub

    Dim avgDaily As Double: avgDaily = AnnualDemand / mod_Config.WORKING_DAYS_PER_YEAR
    Dim rop As Double: rop = ComputeROP(avgDaily, sku)
    Dim ss As Double: ss = GetSafetyStock(sku)

    If CurrentStock <= rop Then
        Dim eoq As Double: eoq = ComputeEOQ(AnnualDemand, unitPrice)
        Dim alertLevel As String: alertLevel = IIf(CurrentStock <= ss, "RUPTURE IMMINENTE", "SEUIL D'ALERTE ATTEINT")

        MsgBox alertLevel & vbCrLf & vbCrLf & _
               "Article  : " & sku & vbCrLf & _
               "Stock    : " & CurrentStock & " unites" & vbCrLf & _
               "ROP      : " & Round(rop, 1) & " unites" & vbCrLf & _
               "SS       : " & ss & " unites" & vbCrLf & _
               "EOQ (Q*) : " & Round(eoq, 0) & " unites a commander", _
               vbExclamation, mod_Config.SYS_TITLE
    End If
End Sub

' ================================================================================
' FUNCTION: GetArticleDetails
' Returns a complete ArticleDetails struct for a given SKU.
' ================================================================================
Public Function GetArticleDetails(ByVal sku As String) As ArticleDetails
    Dim details As ArticleDetails
    Dim wsArt As Worksheet
    Dim foundRow As Variant
    
    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0
    
    If wsArt Is Nothing Then
        details.Code = sku
        GetArticleDetails = details
        Exit Function
    End If
    
    foundRow = Application.Match(sku, wsArt.Columns(COL_ART_CODE), 0)
    
    If IsError(foundRow) Then
        details.Code = sku
        details.Stock = 0
        GetArticleDetails = details
        Exit Function
    End If
    
    details.Code = Trim(CStr(wsArt.Cells(foundRow, COL_ART_CODE).Value))
    details.Designation = Trim(CStr(wsArt.Cells(foundRow, COL_ART_DESIGNATION).Value))
    details.Category = Trim(CStr(wsArt.Cells(foundRow, COL_ART_CATEGORIE).Value))
    details.PU = CDbl(mod_Utilities.SafeVal(wsArt.Cells(foundRow, COL_ART_PU).Value))
    details.Stock = CLng(mod_Utilities.SafeVal(wsArt.Cells(foundRow, COL_ART_STOCK).Value))
    
    GetArticleDetails = details
End Function

' ================================================================================
' SUB: UpdateArticleStockBalance
' Directly updates the stock quantity in the ARTICLES sheet based on movements.
' ================================================================================
Public Sub UpdateArticleStockBalance(ByVal artCode As String, ByVal mvtSign As String, ByVal qty As Long)
    Dim wsArt As Worksheet
    Dim foundRow As Variant
    
    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0
    
    If wsArt Is Nothing Then Exit Sub
    
    foundRow = Application.Match(artCode, wsArt.Columns(COL_ART_CODE), 0)
    
    If Not IsError(foundRow) Then
        wsArt.Unprotect Password:=mod_Config.MASTER_PWD
        
        Dim currentQty As Double: currentQty = Val(wsArt.Cells(foundRow, COL_ART_STOCK).Value) ' Column C: Stock
        
        If mvtSign = "IN" Then
            wsArt.Cells(foundRow, COL_ART_STOCK).Value = currentQty + qty
        Else
            wsArt.Cells(foundRow, COL_ART_STOCK).Value = currentQty - qty
        End If
        
        wsArt.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    End If
End Sub

' ================================================================================
' FUNCTION: GetAnnualDemandFromHistory
' Aggregates annual demand from MOUVEMENTS sheet for a given SKU.
' ================================================================================
Public Function GetAnnualDemandFromHistory(ByVal sku As String) As Double
    On Error Resume Next
    Dim wsMouv As Worksheet: Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    If wsMouv Is Nothing Then GetAnnualDemandFromHistory = 0: Exit Function
    Dim currentYear As Integer: currentYear = Year(Date)
    
    wsMouv.Unprotect Password:=mod_Config.MASTER_PWD
    GetAnnualDemandFromHistory = WorksheetFunction.SumIfs( _
        wsMouv.Columns(COL_MOUV_QTE), _
        wsMouv.Columns(COL_MOUV_CODE_ARTICLE), sku, _
        wsMouv.Columns(COL_MOUV_TYPE), "OUT", _
        wsMouv.Columns(COL_MOUV_DATE), ">=" & DateSerial(currentYear, 1, 1))
    wsMouv.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    On Error GoTo 0
End Function

' ================================================================================
' FUNCTION: CalculateCMUP
' Formula: CMUP = Total IN Value / Total IN Quantity
' ================================================================================
Public Function CalculateCMUP(ByVal sku As String) As Double
    On Error Resume Next
    Dim wsMouv As Worksheet: Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    Dim wsArt As Worksheet: Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    If wsMouv Is Nothing Or wsArt Is Nothing Then CalculateCMUP = 0: Exit Function

    Dim totalInQty As Double, TotalINValue As Double
    wsMouv.Unprotect Password:=mod_Config.MASTER_PWD
    totalInQty = WorksheetFunction.SumIfs(wsMouv.Columns(COL_MOUV_QTE), wsMouv.Columns(COL_MOUV_CODE_ARTICLE), sku, wsMouv.Columns(COL_MOUV_TYPE), "IN")
    TotalINValue = WorksheetFunction.SumIfs(wsMouv.Columns(COL_MOUV_VALEUR), wsMouv.Columns(COL_MOUV_CODE_ARTICLE), sku, wsMouv.Columns(COL_MOUV_TYPE), "IN")

    ' CMUP = Total IN Value / Total IN Quantity (standard weighted average cost)
    If totalInQty > 0 Then
        CalculateCMUP = TotalINValue / totalInQty
    Else
        CalculateCMUP = 0
    End If
    On Error GoTo 0
End Function

' ================================================================================
' SUB: RefreshAllCMUP
' Recalculates CMUP for all articles in ARTICLES sheet
' ================================================================================
Public Sub RefreshAllCMUP()
    Dim wsArt As Worksheet: Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    Dim lastRow As Long: lastRow = wsArt.Cells(wsArt.Rows.count, COL_ART_CODE).End(xlUp).Row
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    Dim i As Long, cmup As Double
    For i = 2 To lastRow
        Dim sku As String: sku = Trim(wsArt.Cells(i, COL_ART_CODE).Value)
        If sku <> "" Then
            cmup = CalculateCMUP(sku)
            If cmup > 0 Then wsArt.Cells(i, COL_ART_CMUP).Value = cmup
        End If
    Next i
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    If Application.UserControl Then
        MsgBox "CMUP (Prix Moyen) mis " & Chr(233) & " jour.", vbInformation, mod_Config.SYS_TITLE
    End If
End Sub

' ================================================================================
' FUNCTION: GetArticleStock
' Returns current stock quantity for an article (reads from ARTICLES column C)
' ================================================================================
Public Function GetArticleStock(ByVal sku As String) As Double
    Dim wsArt As Worksheet
    Dim foundRow As Variant
    
    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0
    
    If wsArt Is Nothing Then
        GetArticleStock = 0
        Exit Function
    End If
    
    foundRow = Application.Match(sku, wsArt.Columns(COL_ART_CODE), 0)
    
    If IsError(foundRow) Then
        GetArticleStock = 0
        Exit Function
    End If
    
    GetArticleStock = mod_Utilities.SafeVal(wsArt.Cells(foundRow, COL_ART_STOCK).Value)
End Function

