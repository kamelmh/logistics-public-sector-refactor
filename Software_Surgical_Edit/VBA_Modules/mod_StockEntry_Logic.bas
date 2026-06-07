Attribute VB_Name = "mod_StockEntry_Logic"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

'   Data Layer     - mod_Database.SecureWriteTransaction()
'   Sync           - mod_SyncBridge.CommitStaging()
'
' Canonical constants (locked - never change without updating CLAUDE.md):
'   D=1,546  |  ROP=212.4  |  Q*=176  |  SS=200  |  LT=2 days
'
' Refactoring (2026-05-06):
'   - Eliminated direct frmStockEntry.{control} references from logic module
'   - Introduced FormState struct for parameter-based data passing
'   - Form owns all UI operations; logic module returns state updates
'   - Eliminated duplicate FireInternalBridge (form version removed)
'   - Consolidated stock calculation to use mod_StockEngine
'==============================================================================

Option Explicit

'================================================================================
' SECTION 0 - MODULE-LEVEL CONSTANTS & STATE
'================================================================================

'-- Canonical ERP constants (mirrors Unit de traitement VBA GROUND_TRUTH)
Private Const CANON_ROP    As Double = 212.4
Private Const CANON_SS     As Long = 200
Private Const CANON_QSTAR  As Long = 176
Private Const CANON_LT     As Integer = 2

'-- Grid column indices (0-based)
Private Const COL_CODE   As Integer = 0
Private Const COL_DESIG  As Integer = 1
Private Const COL_CAT    As Integer = 2
Private Const COL_QTE    As Integer = 3
Private Const COL_PU     As Integer = 4
Private Const COL_VALEUR As Integer = 5
Private Const COL_STOCK  As Integer = 6

'================================================================================
' SECTION 0A - FORM STATE STRUCT (Decoupled data transfer)
'================================================================================

' FormState holds all form data independently of UI controls.
' The form populates this struct; logic reads/writes the struct.
' This eliminates direct frmStockEntry.{control} coupling.

Public Type FormState
    '- Input values (from UI)
    docType        As String
    docRef         As String
    TransDate      As String
    ArticleCode    As String
    ArticleDesign  As String
    ArticleCat     As String
    qty            As String
    unitPrice      As String
    Service        As String
    
    '- Grid data
    GridData       As String
    GridRowCount   As Integer
    
    '- Visual state (to be applied by UI)
    StockInfoText      As String
    StockInfoColor     As Long
    WilsonAlertText    As String
    WilsonAlertVisible As Boolean
    BannerText         As String
    BannerColor        As Long
    QtyBackColor       As Long
    PrixUnitaireBackColor As Long
    PrixUnitaireEnabled   As Boolean
    RefDocBackColor       As Long
    TotalGeneralText   As String
    TotalGeneral       As Double
    IsBRMode       As Boolean
    PUEditable     As Boolean
    PULabel        As String
    
    '- Article metadata
    ArticleStock   As Long
    ArticlePU      As Double
    FullArticleList() As String
    m_CurrentArticle As String
    m_StockActuel    As Long
    m_IsBRMode       As Boolean
    m_TotalGeneral   As Double
    
    '- Error/Validation state
    LastErrorMsg   As String
    ErrorControl   As String
    
    '- Form properties (to be applied by UI)
    FormCaption    As String
    FormWidth      As Single
    FormHeight     As Single
    
    '- Dropdown data (to be applied by UI)
    DocTypes       () As String
    Services       () As String
    Categories     () As String
    Articles       () As String
    
    '- Grid configuration (to be applied by UI)
    GridColumnCount     As Integer
    GridColumnWidths    As String
    GridFontName        As String
    GridFontSize        As Integer
    GridBackColor       As Long
    GridHeaderCaption   As String
    GridHeaderFontName  As String
    GridHeaderFontSize  As Integer
    GridHeaderForeColor As Long

    '- Controls (passed as objects for SetFocus etc.)
    '- Form reference for UI operations (only when absolutely needed)
    ' Added: Session 22 - was referenced 60+ times in this module
    ' (state.formRef.cmbTypeDoc, state.formRef.txtQuantite, etc.) but the
    ' FormState UDT never declared the formRef field, causing "Method or
    ' data member not found" at UserForm_Initialize. Reference impl lifted
    ' from external/lsm-vba-core.
    formRef        As Object
End Type



'================================================================================
' SECTION 1 - FORM INITIALIZE (Controller sets up state)
'================================================================================

Public Sub InitializeForm(ByRef state As FormState)
    Call SetupFormAppearance(state)
    Call PopulateDropdowns(state)
    Call ConfigureGrid(state)
End Sub

Public Sub SaveFullArticleList(ByRef state As FormState, ByVal cmb As Object)
    Dim i As Integer
    Dim count As Integer
    count = cmb.ListCount
    If count = 0 Then Exit Sub
    
    ReDim state.FullArticleList(0 To count - 1)
    For i = 0 To count - 1
        state.FullArticleList(i) = cmb.List(i)
    Next i
End Sub

Public Sub FilterArticleList(ByRef state As FormState, ByVal cmb As Object, ByVal typed As String)
    Dim i As Integer
    Dim count As Integer
    Dim item As String
    Dim newCount As Integer
    
    count = UBound(state.FullArticleList) - LBound(state.FullArticleList) + 1
    If count <= 0 Then Exit Sub
    
    cmb.Clear
    newCount = 0
    
    For i = 0 To count - 1
        item = state.FullArticleList(i)
        If InStr(1, item, typed, vbTextCompare) > 0 Then
            cmb.AddItem item
            newCount = newCount + 1
        End If
    Next i
End Sub

Private Sub SetupFormAppearance(ByRef state As FormState)
    '- Form shell
    state.formRef.Caption = mod_Localization.SafeGetTxt("SYS_TITLE")
    If state.formRef.Caption = "SYS_TITLE" Or InStr(state.formRef.Caption, "NOT_FOUND") > 0 Then
        state.formRef.Caption = "Saisie des Mouvements de Stock"
    End If
    state.formRef.Width = 870
    state.formRef.Height = 640
    
    '- Banner (idle state)
    state.BannerText = "-- SELECTIONNEZ LE TYPE DE DOCUMENT --"
    state.BannerColor = RGB(100, 100, 100)
    
    '- Wilson alert (hidden by default)
    state.WilsonAlertVisible = False
    
    '- Stock info (idle)
    state.StockInfoText = "Code Article :  --"
    state.StockInfoColor = RGB(100, 100, 100)
    
    '- Total footer
    state.TotalGeneralText = "TOTAL GENERAL :  0.00 DZD"
    state.TotalGeneral = 0
    
    '- Sync toggle default
    ' (This is a control property, we'll handle it in the form)
    
    '- Button captions
    ' (We'll handle these in the form or via state if we want to be very strict)
End Sub

Private Sub ResetToDefaultState(ByRef state As FormState)
    state.TransDate = Format(Date, "DD/MM/YYYY")
    state.docRef = ""
    state.qty = ""
    state.unitPrice = ""
    state.GridData = ""
    state.GridRowCount = 0
    state.TotalGeneral = 0
    state.m_CurrentArticle = ""
    state.ArticleCode = ""
    state.m_StockActuel = 0
    state.ArticleStock = 0
    state.StockInfoText = "Code Article :  --"
    state.StockInfoColor = RGB(100, 100, 100)
    state.WilsonAlertVisible = False
    state.QtyBackColor = RGB(255, 255, 255)
End Sub


Private Sub PopulateDropdowns(ByRef state As FormState)
    '- Document types
    With state.formRef.cmbTypeDoc
        .Clear
        .AddItem mod_Config.DOC_TYPE_BS
        .AddItem mod_Config.DOC_TYPE_BR
        .AddItem mod_Config.DOC_TYPE_BC
        .AddItem mod_Config.DOC_TYPE_DA
        .ListIndex = 0
    End With
    
    '- Services from SYS_STRINGS
    With state.formRef.cmbService
        .Clear
        Dim wsStr As Worksheet
        On Error Resume Next
        Set wsStr = ThisWorkbook.Sheets(mod_Config.SHEET_SYS_STRINGS)
        On Error GoTo 0
        
        If Not wsStr Is Nothing Then
            Dim lastRowStr As Long, iStr As Long
            lastRowStr = wsStr.Cells(wsStr.Rows.count, COL_SYS_ID).End(xlUp).Row
            For iStr = 2 To lastRowStr
                If Left(Trim(CStr(wsStr.Cells(iStr, COL_SYS_ID).Value)), 4) = "SVC_" Then
                    .AddItem Trim(CStr(wsStr.Cells(iStr, COL_SYS_VALUE).Value))
                End If
            Next iStr
        End If
        
        If .listCount = 0 Then
            .AddItem "Service 1"
            .AddItem "Service 2"
            .AddItem "Fournisseur Externe"
        End If
        If .listCount > 0 Then .ListIndex = 0
    End With
    
    '- Categories
    With state.formRef.cmbCategorie
        .Clear
        .AddItem "(Toutes)"
        .AddItem "Fournitures Bureau"
        .AddItem "Informatique"
        .AddItem "Admin"
        .AddItem "Inconnu"
        .ListIndex = 0
    End With
    
    '- Articles (unfiltered)
    Call LoadArticleComboBox("", state)
End Sub

Private Sub LoadArticleComboBox(ByVal filterCat As String, ByRef state As FormState)
    Dim wsArt    As Worksheet
    Dim lastRow  As Long
    Dim i        As Long
    Dim code     As String
    Dim desig    As String
    Dim cat      As String
    Dim noFilter As Boolean

    state.formRef.cmbArticle.Clear
    noFilter = (filterCat = "" Or filterCat = "(Toutes)")

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If wsArt Is Nothing Then
        state.formRef.cmbArticle.AddItem "ART-001 | Papier A4"
        state.formRef.cmbArticle.AddItem "ART-002 | Papier A3"
        state.formRef.cmbArticle.AddItem "ART-003 | Sous-Chemise"
        Exit Sub
    End If

    lastRow = wsArt.Cells(wsArt.Rows.count, COL_ART_CODE).End(xlUp).Row

    For i = 3 To lastRow
        code = Trim(CStr(wsArt.Cells(i, COL_ART_CODE).Value))
        desig = Trim(CStr(wsArt.Cells(i, COL_ART_DESIGNATION).Value))
        cat = Trim(CStr(wsArt.Cells(i, COL_ART_CATEGORIE).Value))

        If code = "" Then GoTo nextRow

        If noFilter Or (cat = filterCat) Then
            state.formRef.cmbArticle.AddItem code & " | " & desig
        End If
nextRow:
    Next i
End Sub

Private Sub ConfigureGrid(ByRef state As FormState)
    With state.formRef.lstGrid
        .ColumnCount = 6
        .ColumnHeads = False
        .ColumnWidths = "80 pt;220 pt;90 pt;50 pt;80 pt;90 pt"
        .MultiSelect = fmMultiSelectSingle
        .ListStyle = fmListStylePlain
        .Font.name = "Courier New"
        .Font.Size = 9
        .BackColor = RGB(248, 248, 252)
    End With

    state.formRef.lblGridHeader.Caption = _
        "  Code      |  Designation              |  Cat" & Chr(233) & "gorie  | Qte |  PU (DZD) |  Valeur"
    state.formRef.lblGridHeader.Font.name = "Courier New"
    state.formRef.lblGridHeader.Font.Size = 8
    state.formRef.lblGridHeader.ForeColor = RGB(71, 71, 90)
End Sub



'==============================================================================
' SECTION 2 - DOCUMENT TYPE BANNER (Pure logic, returns state updates)
'==============================================================================

Public Sub OnDocTypeChanged(ByRef state As FormState)
    state.docType = state.formRef.cmbTypeDoc.Value
    
    Select Case state.docType
        Case mod_Config.DOC_TYPE_BS
            state.BannerText = "  MODE SORTIE  --  Bon de Sortie"
            state.BannerColor = RGB(160, 70, 0)
            state.m_IsBRMode = False
            state.IsBRMode = False
            state.PUEditable = False
            state.PULabel = "PU -- CMUP auto"
            state.PrixUnitaireEnabled = False
            state.PrixUnitaireBackColor = RGB(235, 235, 235)

        Case mod_Config.DOC_TYPE_BR
            state.BannerText = "  MODE ENTREE  --  Bon de R" & Chr(201) & "ception"
            state.BannerColor = RGB(4, 90, 55)
            state.m_IsBRMode = True
            state.IsBRMode = True
            state.PUEditable = True
            state.PULabel = "Prix Unitaire (saisir)"
            state.PrixUnitaireEnabled = True
            state.PrixUnitaireBackColor = RGB(255, 252, 196)

        Case mod_Config.DOC_TYPE_DA
            state.BannerText = "  Demande d'Achat"
            state.BannerColor = RGB(30, 80, 180)
            state.m_IsBRMode = False
            state.IsBRMode = False
            state.PUEditable = False
            state.PULabel = "PU (estime)"
            state.PrixUnitaireEnabled = False
            state.PrixUnitaireBackColor = RGB(235, 235, 235)

        Case mod_Config.DOC_TYPE_BC
            state.BannerText = "  COMMANDE  --  Bon de Commande"
            state.BannerColor = RGB(120, 40, 120)
            state.m_IsBRMode = False
            state.IsBRMode = False
            state.PUEditable = True
            state.PULabel = "Prix Unitaire (devis)"
            state.PrixUnitaireEnabled = True
            state.PrixUnitaireBackColor = RGB(255, 252, 196)

        Case Else
            state.BannerText = "-- SELECTIONNEZ LE TYPE DE DOCUMENT --"
            state.BannerColor = RGB(100, 100, 100)
    End Select
    
    '- Refresh stock display if article selected
    If state.m_CurrentArticle <> "" Then Call EvaluateStockStatus(state.m_CurrentArticle, state)
    
    '- Auto-generate reference if empty
    If Len(Trim(state.docRef)) = 0 Then Call GenerateAutoRef(state)
End Sub

Public Function GetDocPrefixFromType(ByVal docType As String) As String
    Select Case docType
        Case mod_Config.DOC_TYPE_BS:  GetDocPrefixFromType = "BS"
        Case mod_Config.DOC_TYPE_BR:  GetDocPrefixFromType = "BR"
        Case mod_Config.DOC_TYPE_BC:  GetDocPrefixFromType = "BC"
        Case mod_Config.DOC_TYPE_DA:  GetDocPrefixFromType = "DA"
        Case Else:    GetDocPrefixFromType = "TXN"
    End Select
End Function


'==============================================================================
' SECTION 3 - ARTICLE SELECTION & STOCK INTELLIGENCE
'==============================================================================

Public Sub OnArticleChanged(ByRef state As FormState)
    Dim raw As String
    
    If state.formRef.cmbArticle.ListIndex < 0 Then Exit Sub
    raw = Trim(state.formRef.cmbArticle.text)
    If Len(raw) = 0 Then Exit Sub

    Dim parts() As String
    parts = Split(raw, "|")
    Dim prevArticle As String
    prevArticle = state.m_CurrentArticle
    state.m_CurrentArticle = Trim(parts(0))
    state.ArticleCode = state.m_CurrentArticle

    '- Only update category filter if article actually changed
    If state.m_CurrentArticle <> prevArticle Then
        Dim details As mod_StockEngine.ArticleDetails
        details = mod_StockEngine.GetArticleDetails(state.m_CurrentArticle)
        
        If details.Code <> "" Then
            Dim cat As String: cat = details.Category
            
            If Len(cat) > 0 And Trim(state.formRef.cmbCategorie.Value) <> cat Then
                '- Update category dropdown to match article (without firing Change event)
                Dim j As Integer
                For j = 0 To state.formRef.cmbCategorie.listCount - 1
                    If state.formRef.cmbCategorie.List(j) = cat Then
                        state.formRef.cmbCategorie.ListIndex = j
                        Exit For
                    End If
                Next j
                
                '- Reload article list filtered by category (avoids OnCategoryChanged cascade)
                Dim prevArt As String
                prevArt = state.m_CurrentArticle
                Call LoadArticleComboBox(cat, state)
                
                '- Restore article selection in filtered list
                If prevArt <> "" Then
                    Dim k As Integer
                    For k = 0 To state.formRef.cmbArticle.listCount - 1
                        If Left(state.formRef.cmbArticle.List(k), Len(prevArt)) = prevArt Then
                            state.formRef.cmbArticle.ListIndex = k
                            Exit For
                        End If
                    Next k
                End If
            End If
        End If
    End If

    Call EvaluateStockStatus(state.m_CurrentArticle, state)
End Sub

Private Sub EvaluateStockStatus(ByVal artCode As String, ByRef state As FormState)
    Dim details As mod_StockEngine.ArticleDetails
    Dim foundRow As Variant
    Dim stock    As Long
    Dim pu       As Double
    Dim cat      As String
    Dim ropVal   As Double
    Dim ssVal    As Long
    Dim wsMouv   As Worksheet
    Dim totalIn  As Double, totalOut As Double

    details = mod_StockEngine.GetArticleDetails(artCode)
    
    If details.Code = "" Then
        state.StockInfoText = "Code Article :  " & artCode & "  |  Article introuvable"
        state.StockInfoColor = RGB(180, 0, 0)
        state.m_StockActuel = -1
        state.ArticleStock = -1
        state.WilsonAlertVisible = False
        Exit Sub
    End If

    pu = details.PU
    cat = details.Category
    stock = details.Stock
    
    state.ArticlePU = pu
    state.ArticleCat = cat
    state.m_StockActuel = stock
    state.ArticleStock = stock

    ' Calculate stock from movements (to ensure consistency with ledger)
    On Error Resume Next
    Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    On Error GoTo 0
    If Not wsMouv Is Nothing Then
        On Error Resume Next
        totalIn = Application.SumIfs(wsMouv.Columns(COL_MOUV_QTE), wsMouv.Columns(COL_MOUV_CODE_ARTICLE), artCode, wsMouv.Columns(COL_MOUV_TYPE), "IN")
        totalOut = Application.SumIfs(wsMouv.Columns(COL_MOUV_QTE), wsMouv.Columns(COL_MOUV_CODE_ARTICLE), artCode, wsMouv.Columns(COL_MOUV_TYPE), "OUT")
        On Error GoTo 0
    End If
    stock = CLng(totalIn - totalOut)
    state.m_StockActuel = stock
    state.ArticleStock = stock

    If artCode = "ART-001" Then
        ropVal = CANON_ROP
        ssVal = CANON_SS
    Else
        ssVal = 50
        ropVal = ssVal + CANON_LT
    End If

    Dim statusText  As String
    Dim statusColor As Long

    If stock <= 0 Then
        statusText = "[RUPTURE]"
        statusColor = RGB(200, 30, 30)
    ElseIf stock <= ssVal Then
        statusText = "[CRITIQUE]"
        statusColor = RGB(200, 30, 30)
    ElseIf stock <= ropVal Then
        statusText = "[ALERTE]"
        statusColor = RGB(160, 70, 0)
    Else
        statusText = "[OK]"
        statusColor = RGB(4, 90, 55)
    End If

    state.StockInfoText = "Code Article :  " & artCode & "   |   Stock :  " & stock & " u" & "   |   " & statusText
    state.StockInfoColor = statusColor

    ' Auto-fill PU for non-BR modes
    If Not state.m_IsBRMode And pu > 0 Then
        state.formRef.txtPrixUnitaire.Value = Format(pu, "0.00")
        state.unitPrice = Format(pu, "0.00")
    End If

    ' Wilson alert for case study article
    If artCode = "ART-001" Then
        state.WilsonAlertText = "Wilson EOQ -- Q* = " & CANON_QSTAR & " u  |  SS = " & CANON_SS & " u"
        state.WilsonAlertVisible = True
    Else
        state.WilsonAlertVisible = False
    End If
End Sub

Public Sub OnCategoryChanged(ByRef state As FormState)
    Dim prevSKU As String
    prevSKU = state.m_CurrentArticle

    Call LoadArticleComboBox(Trim(state.formRef.cmbCategorie.Value), state)

    '- Restore previous selection if still in filtered list
    If prevSKU <> "" Then
        Dim j As Integer
        For j = 0 To state.formRef.cmbArticle.listCount - 1
            If Left(state.formRef.cmbArticle.List(j), Len(prevSKU)) = prevSKU Then
                state.formRef.cmbArticle.ListIndex = j
                Exit For
            End If
        Next j
    End If
End Sub


'==============================================================================
' SECTION 4 - QUANTITY FIELD (Live validation + Wilson nudge)
'==============================================================================

Public Sub OnQuantityChanged(ByRef state As FormState)
    state.qty = state.formRef.txtQuantite.Value
    
    If Not IsNumeric(state.qty) Then
        state.QtyBackColor = RGB(255, 199, 199)
        Exit Sub
    End If
    
    Dim qty As Long
    qty = CLng(state.qty)
    If qty <= 0 Then Exit Sub

    If Not state.m_IsBRMode And state.m_StockActuel >= 0 Then
        Dim projected As Long
        projected = state.m_StockActuel - qty

        Select Case True
            Case projected < 0
                state.QtyBackColor = RGB(255, 199, 199)  ' Red - insufficient
            Case projected <= CANON_SS
                state.QtyBackColor = RGB(255, 235, 150)  ' Orange - below SS
            Case projected <= CANON_ROP
                state.QtyBackColor = RGB(255, 248, 200)  ' Yellow - below ROP
            Case Else
                state.QtyBackColor = RGB(198, 239, 206)  ' Green - safe
        End Select
    Else
        state.QtyBackColor = RGB(255, 255, 255)
    End If
End Sub


'==============================================================================
' SECTION 5 - AUTO REFERENCE GENERATOR
'==============================================================================

Public Sub GenerateAutoRef(ByRef state As FormState)
    Dim prefix As String
    Dim seq    As Long

    prefix = GetDocPrefixFromType(state.docType)
    seq = mod_StockEngine.GetNextSequence(prefix)
End Sub



'==============================================================================
' SECTION 6 - GRID OPERATIONS
'==============================================================================

Public Function AddLineToGrid(ByRef state As FormState) As Boolean
    AddLineToGrid = False
    
    Dim qty        As Long
    Dim pu         As Double
    Dim valLigne   As Double
    Dim desig      As String
    Dim cat        As String
    Dim ropSeuil   As Double
    
    '- Init: Clear all field errors
    Call mod_ThemingEngine.ClearAllFieldErrors(state.formRef)
    
    '- Guard 1: Date validation
    If Not mod_Utilities.IsValidDate(state.TransDate) Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.TxtDate)
        MsgBox "Format de date requis : JJ/MM/AAAA", vbExclamation
        state.formRef.TxtDate.SetFocus
        Exit Function
    End If
    
    '- Guard 2: Document reference
    If Len(Trim(state.docRef)) = 0 Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.txtRefDoc)
        MsgBox "Le N deg Reference est OBLIGATOIRE.", vbCritical
        state.formRef.txtRefDoc.SetFocus
        Exit Function
    End If
    
    '- Guard 3: Article selection
    If Len(Trim(state.m_CurrentArticle)) = 0 Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.cmbArticle)
        MsgBox "Selectionnez un article.", vbExclamation
        state.formRef.cmbArticle.SetFocus
        Exit Function
    End If
    
    '- Guard 4: Article exists
    If state.m_StockActuel = -1 Then
        MsgBox "Article introuvable dans le catalogue.", vbCritical
        Exit Function
    End If
    
    '- Guard 5: Quantity valid
    If Not IsNumeric(state.qty) Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.txtQuantite)
        MsgBox "Quantite invalide.", vbCritical
        state.formRef.txtQuantite.SetFocus
        Exit Function
    End If
    
    qty = CLng(state.qty)
    If qty <= 0 Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.txtQuantite)
        MsgBox "La quantite doit " & Chr(234) & "tre > 0.", vbCritical
        state.formRef.txtQuantite.SetFocus
        Exit Function
    End If
    
    '- Guard 6: PU required for BR mode
    If state.m_IsBRMode Then
        state.unitPrice = state.formRef.txtPrixUnitaire.Value
        If Not IsNumeric(state.unitPrice) Or CDbl(mod_Utilities.SafeVal(state.unitPrice)) <= 0 Then
            Call mod_ThemingEngine.HighlightFieldError(state.formRef.txtPrixUnitaire)
            MsgBox "Le Prix Unitaire est requis pour un Bon de R" & Chr(201) & "ception.", vbCritical
            state.formRef.txtPrixUnitaire.SetFocus
            Exit Function
        End If
    End If
    
    pu = CDbl(mod_Utilities.SafeVal(state.unitPrice))
    
    '- Guard 7: Stock sufficiency (non-BR only)
    If Not state.m_IsBRMode Then
        Dim netProjected As Long
        netProjected = state.m_StockActuel - qty
        
        If netProjected < 0 Then
            MsgBox "Stock insuffisant ! Stock dispo: " & state.m_StockActuel & " u, Qte demandee: " & qty & " u", vbCritical
            Exit Function
        End If
        
        ropSeuil = IIf(state.m_CurrentArticle = "ART-001", CANON_ROP, 60)
        If netProjected <= ropSeuil Then
            Dim ropResp As VbMsgBoxResult
            ropResp = MsgBox("ALERTE -- Point de commande atteint." & vbCrLf & _
                            "Continuer ?", vbYesNo + vbExclamation, "ROP Alert")
            If ropResp = vbNo Then Exit Function
        End If
    End If
    
    '- Add line to grid
    valLigne = qty * pu
    desig = mod_Utilities.GetArticleField(state.m_CurrentArticle, "DESIG")
    cat = mod_Utilities.GetArticleField(state.m_CurrentArticle, "CAT")
    
    Dim newLine As String
    newLine = state.m_CurrentArticle & "|" & Left(desig, 28) & "|" & Left(cat, 14) & "|" & _
              CStr(qty) & "|" & Format(pu, "#,##0.00") & "|" & Format(valLigne, "#,##0.00")
    
    If Len(state.GridData) > 0 Then
        state.GridData = state.GridData & ";" & newLine
    Else
        state.GridData = newLine
    End If
    
    Dim lines() As String
    lines = Split(state.GridData, ";")
    state.GridRowCount = UBound(lines) + 1
    
    Call UpdateTotalDisplay(state)
    
    '- Reset input fields
    state.qty = ""
    state.unitPrice = ""
    state.QtyBackColor = RGB(255, 255, 255)
    state.m_CurrentArticle = ""
    state.ArticleCode = ""
    state.m_StockActuel = 0
    state.ArticleStock = 0
    state.StockInfoText = "Code Article :  --"
    state.StockInfoColor = RGB(100, 100, 100)
    state.WilsonAlertVisible = False
    
    state.formRef.cmbArticle.SetFocus
    AddLineToGrid = True
End Function

Public Sub RemoveLineFromGrid(ByRef state As FormState)
    Dim idx As Integer
    idx = state.formRef.lstGrid.ListIndex
    
    If idx < 0 Then
        MsgBox "Selectionnez une ligne a supprimer.", vbInformation
        Exit Sub
    End If

    Dim lines() As String
    lines = Split(state.GridData, ";")
    
    Dim i As Integer
    Dim newLines() As String
    ReDim newLines(UBound(lines) - 1)
    
    Dim k As Integer: k = 0
    For i = 0 To UBound(lines)
        If i <> idx Then
            newLines(k) = lines(i)
            k = k + 1
        End If
    Next i
    
    state.GridData = Join(newLines, ";")
    state.GridRowCount = UBound(newLines) + 1
    
    Call UpdateTotalDisplay(state)
End Sub

Private Sub UpdateTotalDisplay(ByRef state As FormState)
    Dim runningTotal As Double
    Dim i            As Integer
    Dim lines()      As String
    runningTotal = 0

    If Len(state.GridData) > 0 Then
        lines = Split(state.GridData, ";")
        For i = 0 To UBound(lines)
            If Len(Trim(lines(i))) > 0 Then
                Dim parts() As String
                parts = Split(lines(i), "|")
                If UBound(parts) >= 5 Then
                    Dim valStr As String
                    valStr = Replace(parts(5), ",", "")
                    If IsNumeric(valStr) Then runningTotal = runningTotal + CDbl(valStr)
                End If
            End If
        Next i
    End If

    state.m_TotalGeneral = runningTotal
    state.TotalGeneral = runningTotal
    state.TotalGeneralText = "TOTAL GENERAL :  " & Format(state.m_TotalGeneral, "#,##0.00") & " DZD"
End Sub

Private Function GetQtyInGridForSKU(ByVal sku As String, ByRef state As FormState) As Long
    Dim total As Long
    Dim i     As Integer
    total = 0

    For i = 0 To state.formRef.lstGrid.listCount - 1
        If state.formRef.lstGrid.List(i, COL_CODE) = sku Then
            On Error Resume Next
            total = total + CLng(state.formRef.lstGrid.List(i, COL_QTE))
            On Error GoTo 0
        End If
    Next i

    GetQtyInGridForSKU = total
End Function


'==============================================================================
' SECTION 7 - ENREGISTRER (Transaction commit)
'==============================================================================

Public Function CommitTransaction(ByRef state As FormState) As Boolean
    CommitTransaction = False
    
    ' Capture current form input into state
    state.Service = state.formRef.cmbService.Value
    state.docType = state.formRef.cmbTypeDoc.Value
    state.docRef = Trim(state.formRef.txtRefDoc.Value)
    
    '- Guard: Empty grid
    If state.GridRowCount = 0 Then
        MsgBox "Le document ne contient aucun article.", vbExclamation
        Exit Function
    End If
    
    '- Guard: Service required
    If Len(Trim(state.Service)) = 0 Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.cmbService)
        MsgBox "SERVICE / FOURNISSEUR est requis.", vbExclamation
        state.formRef.cmbService.SetFocus
        Exit Function
    End If
    
    '- Guard: DocType required
    If Len(Trim(state.docType)) = 0 Then
        Call mod_ThemingEngine.HighlightFieldError(state.formRef.cmbTypeDoc)
        MsgBox "Type de Document est requis.", vbExclamation
        state.formRef.cmbTypeDoc.SetFocus
        Exit Function
    End If
    
    '- Guard: Validate grid data
    Dim gridRow As Integer
    Dim lines() As String
    lines = Split(state.GridData, ";")
    
    For gridRow = 0 To state.GridRowCount - 1
        Dim parts() As String
        parts = Split(lines(gridRow), "|")
        If UBound(parts) < 5 Then
            MsgBox "Donn" & Chr(233) & "es invalides a la ligne " & gridRow + 1, vbCritical
            Exit Function
        End If
        
        If Not IsNumeric(parts(3)) Or Not IsNumeric(parts(4)) Then
            MsgBox "Donn" & Chr(233) & "es invalides a la ligne " & gridRow + 1, vbCritical
            Exit Function
        End If
        
        If CLng(parts(3)) <= 0 Then
            MsgBox "La quantite doit " & Chr(234) & "tre > 0 (ligne " & gridRow + 1 & ")", vbCritical
            Exit Function
        End If
    Next gridRow
    
    '- Confirmation dialog
    Dim typeSign As String
    typeSign = IIf(state.m_IsBRMode, "IN -- Entree", "OUT -- Sortie")
    
    Dim confMsg As String
    confMsg = "Confirmer l'enregistrement ?" & vbCrLf & vbCrLf & _
              "Document :  " & state.docType & "  [" & typeSign & "]" & vbCrLf & _
              "Reference:  " & state.docRef & vbCrLf & _
              "Service  :  " & state.Service & vbCrLf & _
              "Lignes   :  " & state.GridRowCount & vbCrLf & _
              "Total    :  " & Format(state.TotalGeneral, "#,##0.00") & " DZD"
    
    If MsgBox(confMsg, vbYesNo + vbQuestion) = vbNo Then Exit Function
    
    '- Begin transaction
    Dim i        As Integer
    Dim docDate  As Date
    Dim mvtSign  As String
    Dim lineCode As String
    Dim lineDesig As String
    Dim lineQty  As Long
    Dim linePU   As Double
    Dim lineVal  As Double
    
    '- Begin safety-managed transaction (snapshot + crash recovery flag)
    Call mod_TransactionSafety.BeginTransaction(state.docRef, state.docType)
    Call mod_TransactionSafety.SaveTransactionStateForRecovery
    
    On Error GoTo SaveError
    
    docDate = Date
    mvtSign = IIf(state.m_IsBRMode, "IN", "OUT")
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    Dim wsMouv As Worksheet: Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    
    For i = 0 To state.GridRowCount - 1
        parts = Split(lines(i), "|")
        lineCode = parts(0)
        lineDesig = parts(1)
        lineQty = CLng(parts(3))
        linePU = CDbl(Replace(parts(4), ",", ""))
        lineVal = CDbl(Replace(parts(5), ",", ""))
        
        '- Pre-write stock check (OUT only)
        If mvtSign = "OUT" Then
            Dim currentStockLevel As Double
            currentStockLevel = mod_StockEngine.GetArticleStock(lineCode)
            
            If lineQty > currentStockLevel Then
                MsgBox "Stock insuffisant pour '" & lineCode & "'. Stock dispo: " & currentStockLevel, vbCritical
                GoTo SaveError
            End If
        End If
        
        '- Write to MOUVEMENTS via secure layer
        Call mod_Database.SecureWriteTransaction( _
            docDate:=docDate, _
            typeSign:=mvtSign, _
            refDoc:=state.docRef, _
            codeArticle:=lineCode, _
            designation:=lineDesig, _
            quantity:=lineQty, _
            unitPrice:=linePU, _
            lineValue:=lineVal, _
            thirdParty:=state.Service)
        
        '- Track line in transaction safety
        Call mod_TransactionSafety.AddTransactionLine
        
        '- Sync internal state
        If SyncTransactionInternal(lineCode, mvtSign, lineQty, linePU, state.docRef) <> 0 Then
            MsgBox "Erreur de synchronisation interne. Annulation de la transaction...", vbCritical
            GoTo SaveError
        End If
    Next i
    
    Application.EnableEvents = True
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    
    '- Commit safety transaction (validates consistency)
    If Not mod_TransactionSafety.CommitTransaction Then
        MsgBox "Validation de la transaction choue. Annulation...", vbCritical
        GoTo SaveError
    End If
    
    '- Clear crash recovery flag
    Call mod_TransactionSafety.ClearTransactionState
    
    '- Audit trail
    Call mod_AuditTrail.LogTransaction(state.docType, state.docRef)
    
    '- Success message
    MsgBox "Enregistrement r" & Chr(233) & "ussi !" & vbCrLf & _
           "Reference :  " & state.docRef & vbCrLf & _
           state.GridRowCount & " ligne(s) enregistr" & Chr(233) & "e(s)", vbInformation
    
    '- Sync metrics back
    Call mod_SyncBridge.SyncMetricsFromLedger
    
    '- PDF export prompt
    If MsgBox("Imprimer le " & state.docType & " ?", vbYesNo + vbQuestion) = vbYes Then
        Call mod_ExportEngine.ExportTransactionToPDF(state.docRef)
    End If
    
    Call ResetToDefaultState(state)
    CommitTransaction = True
    Exit Function
    
SaveError:
    '- Safety-managed rollback (snapshot restore + partial movement removal)
    If mod_TransactionSafety.GetTransactionStatus <> "NONE" Then
        Call mod_TransactionSafety.RollbackTransaction
        Call mod_TransactionSafety.ClearTransactionState
    End If
    Application.EnableEvents = True
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    MsgBox "Une erreur s'est produite lors de l'enregistrement. Transaction annul" & Chr(233) & "e.", vbCritical
End Function

Private Function SyncTransactionInternal(ByVal artCode As String, _
                                          ByVal mvtType As String, _
                                          ByVal qty As Long, _
                                          ByVal unitPrice As Double, _
                                          ByVal refDoc As String) As Integer
    On Error Resume Next
    SyncTransactionInternal = mod_SyncBridge.SyncTransactionInternal(artCode, mvtType, qty, unitPrice, refDoc)
    If Err.Number <> 0 Then SyncTransactionInternal = -1
    On Error GoTo 0
End Function


'==============================================================================
' SECTION 8 - CANCEL
'==============================================================================

Public Sub CancelTransaction(ByRef state As FormState)
    If state.formRef.lstGrid.listCount > 0 Then
        If MsgBox("Des lignes sont en attente. Annuler quand meme ?", _
                  vbYesNo + vbExclamation) = vbNo Then
            Exit Sub
        End If
    End If
    Unload state.formRef
End Sub


'==============================================================================
' SECTION 9 - UTILITY: Form Reference Helper
'==============================================================================

'- Helper to check if a control exists on the form (handles optional controls)
Public Function HasControl(ByVal formRef As Object, ByVal ctrlName As String) As Boolean
    Dim ctrl As Object
    On Error Resume Next
    Set ctrl = formRef.Controls(ctrlName)
    HasControl = (Err.Number = 0)
    On Error GoTo 0
End Function

'==============================================================================
' END -- mod_StockEntry_Logic.bas
'==============================================================================


'==============================================================================
' SECTION 11 - KEYBOARD SHORTCUTS (Moved from frmStockEntry)
'==============================================================================

Public Sub FormatRefDoc(ByRef state As FormState, ByVal tb As Object)
    Static prevVal As String
    If tb.Value = prevVal Then Exit Sub
    
    Dim raw As String
    raw = tb.Value
    
    ' Auto-prefix using constant from mod_Config if missing and user typed something
    If Len(raw) > 0 And Left(raw, Len(mod_Config.REFDOC_PREFIX)) <> mod_Config.REFDOC_PREFIX Then
        raw = mod_Config.REFDOC_PREFIX & raw
    End If
    
    ' Strip everything except digits and dashes
    Dim cleaned As String
    cleaned = ""
    Dim i As Integer
    For i = 1 To Len(raw)
        Dim ch As String
        ch = Mid(raw, i, 1)
        If ch Like "[0-9]" Or ch = "-" Then
            cleaned = cleaned & ch
        End If
    Next i
    
    ' Reconstruct: PREFIX-YYYY-NNNN
    Dim prefix As String: prefix = mod_Config.REFDOC_PREFIX
    Dim digitPart As String
    digitPart = Replace(cleaned, mod_Config.REFDOC_PREFIX, "", , , vbTextCompare)
    digitPart = Replace(digitPart, "-", "")
    
    Dim formatted As String
    formatted = prefix
    If Len(digitPart) >= 1 Then
        formatted = formatted & Left(digitPart, 4)
        If Len(digitPart) > 4 Then
            formatted = formatted & "-" & Mid(digitPart, 5, 4)
        End If
    End If
    
    ' Limit to max length
    If Len(formatted) > 13 Then formatted = Left(formatted, 13)
    
    prevVal = formatted
    If tb.Value <> formatted Then
        tb.Value = formatted
        tb.SelStart = Len(tb.Value)
    End If
    
    ' Live format hint via tag color
    If Len(tb.Value) = 13 Then
        tb.BackColor = RGB(220, 255, 220)
    ElseIf Len(tb.Value) > 3 Then
        tb.BackColor = RGB(255, 252, 196)
    End If
End Sub

'==============================================================================
' END -- mod_StockEntry_Logic.bas
'==============================================================================
