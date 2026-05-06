Attribute VB_Name = "mod_StockEntry_Logic"
'==============================================================================
' mod_StockEntry_Logic.bas  �  ERP Acad" & Chr(233) & "mie v13.2
' Author   : Mahi Kamel Abdelghani � TAG1801 GSL � CNEPD 2026
' Depends  : mod_SyncBridge.bas | mod_StockEngine.bas
'            mod_Database.bas   | mod_AuditTrail.bas
'            mod_ExportEngine.bas
'
' Architecture:
'   UI Layer       ? frmStockEntry (form)
'   Data Layer     ? mod_Database.SecureWriteTransaction()
'   Sync Local     → mod_SyncBridge.CommitStaging() + STAGING_BUFFER sheet
'   Ledger         ? Sجل رقمي (écriture atomique via Unité de traitement VBA)
'
' Canonical constants (locked � never change without updating CLAUDE.md):
'   D=1,546  |  ROP=205.6  |  Q*=176  |  Ss=200  |  LT=2 days
'==============================================================================

Option Explicit

'================================================================================
' SECTION 0 � MODULE-LEVEL CONSTANTS & STATE
'================================================================================

'? Canonical ERP constants (mirrors Unité de traitement VBA GROUND_TRUTH)
Private Const CANON_ROP    As Double  = 205.6
Private Const CANON_SS     As Long    = 200
Private Const CANON_QSTAR  As Long    = 176
Private Const CANON_LT     As Integer = 2

'? frmStockEntry.lstGrid column indices (0-based)
Private Const COL_CODE   As Integer = 0
Private Const COL_DESIG  As Integer = 1
Private Const COL_CAT    As Integer = 2
Private Const COL_QTE    As Integer = 3
Private Const COL_PU     As Integer = 4
Private Const COL_VALEUR As Integer = 5

'? Document type string constants

'? Form state (module-level � persists across event calls)
Private m_TotalGeneral   As Double
Private m_CurrentArticle As String
Private m_StockActuel    As Long
Private m_IsBRMode       As Boolean


'==============================================================================
' SECTION 1 � FORM INITIALIZE (called from form's UserForm_Initialize)
'==============================================================================
Public Sub InitializeForm()
    
    Call SetupFormAppearance
    Call PopulateDropdowns
    Call ConfigureGrid
    Call ResetToDefaultState
End Sub

Private Sub SetupFormAppearance()
    frmStockEntry.Caption = mod_Localization.SafeGetTxt("SYS_TITLE")
    If frmStockEntry.Caption = "SYS_TITLE" Or InStr(frmStockEntry.Caption, "NOT_FOUND") > 0 Then
        frmStockEntry.Caption = "Saisie des Mouvements de Stock"
    End If
    frmStockEntry.Width   = 870
    frmStockEntry.Height  = 640
    
    frmStockEntry.fraDocTypeBanner.BackColor = RGB(100, 100, 100)
    frmStockEntry.lblBannerText.Caption      = "-- SESSIONNEZ LE TYPE DE DOCUMENT --"
    frmStockEntry.lblBannerText.ForeColor    = RGB(255, 255, 255)
    frmStockEntry.lblBannerText.Font.Bold    = True
    frmStockEntry.lblBannerText.TextAlign    = fmTextAlignCenter
    
    frmStockEntry.lblWilsonAlert.Visible     = False
    frmStockEntry.lblWilsonAlert.ForeColor   = RGB(5, 100, 60)
    
    frmStockEntry.lblStockInfo.Caption       = "Code Article :  --"
    frmStockEntry.lblStockInfo.ForeColor     = RGB(100, 100, 100)
    
    frmStockEntry.lblTotalGeneral.Caption    = "TOTAL GENERAL :  0.00 DZD"
    frmStockEntry.lblTotalGeneral.Font.Bold  = True
    frmStockEntry.lblTotalGeneral.ForeColor  = RGB(5, 100, 60)
    
    frmStockEntry.chkSyncInternal.Value        = True
    
    frmStockEntry.btnAjouterLigne.Caption    = "Ajouter Ligne"
    frmStockEntry.btnSupprimerLigne.Caption  = "Supprimer Ligne"
    frmStockEntry.btnEnregistrer.Caption     = "Enregistrer"
    frmStockEntry.btnAutoRef.Caption         = "Auto-Ref"
    frmStockEntry.btnAnnuler.Caption         = "Annuler"
    
    frmStockEntry.txtDate.Value              = Format(Date, "DD/MM/YYYY")
End Sub

Private Sub PopulateDropdowns()
    frmStockEntry.cmbTypeDoc.Clear
    frmStockEntry.cmbTypeDoc.AddItem mod_Config.DOC_TYPE_BS
    frmStockEntry.cmbTypeDoc.AddItem mod_Config.DOC_TYPE_BR
    frmStockEntry.cmbTypeDoc.AddItem mod_Config.DOC_TYPE_DA
    frmStockEntry.cmbTypeDoc.ListIndex = 0
 
    frmStockEntry.cmbService.Clear
    Dim wsStr As Worksheet
    On Error Resume Next
    Set wsStr = ThisWorkbook.Sheets(mod_Config.SHEET_SYS_STRINGS)
    On Error GoTo 0
 
    If Not wsStr Is Nothing Then
        Dim lastRowStr As Long, iStr As Long
        lastRowStr = wsStr.Cells(wsStr.Rows.count, 1).End(xlUp).Row
        For iStr = 2 To lastRowStr
            If Left(Trim(CStr(wsStr.Cells(iStr, 1).Value)), 4) = "SVC_" Then
                frmStockEntry.cmbService.AddItem Trim(CStr(wsStr.Cells(iStr, 2).Value))
            End If
        Next iStr
    End If
 
    If frmStockEntry.cmbService.listCount = 0 Then
        frmStockEntry.cmbService.AddItem "Service 1"
        frmStockEntry.cmbService.AddItem "Service 2"
        frmStockEntry.cmbService.AddItem "Fournisseur Externe"
    End If
    If frmStockEntry.cmbService.ListCount > 0 Then frmStockEntry.cmbService.ListIndex = 0
 
    frmStockEntry.cmbCategorie.Clear
    frmStockEntry.cmbCategorie.AddItem "(Toutes)"
    frmStockEntry.cmbCategorie.AddItem "Fournitures Bureau"
    frmStockEntry.cmbCategorie.AddItem "Informatique"
    frmStockEntry.cmbCategorie.AddItem "Admin"
    frmStockEntry.cmbCategorie.AddItem "Inconnu"
    frmStockEntry.cmbCategorie.ListIndex = 0
 
    Call LoadArticleComboBox("")
End Sub


Private Sub LoadArticleComboBox(ByVal filterCat As String)
    Dim wsArt    As Worksheet
    Dim lastRow  As Long
    Dim i        As Long
    Dim code     As String
    Dim desig    As String
    Dim cat      As String
    Dim noFilter As Boolean

    frmStockEntry.cmbArticle.Clear
    noFilter = (filterCat = "" Or filterCat = "(Toutes)")

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If wsArt Is Nothing Then
        frmStockEntry.cmbArticle.AddItem "ART-001 | Papier A4"
        frmStockEntry.cmbArticle.AddItem "ART-002 | Papier A3"
        frmStockEntry.cmbArticle.AddItem "ART-003 | Sous-Chemise"
        Exit Sub
    End If

    lastRow = wsArt.Cells(wsArt.Rows.Count, 1).End(xlUp).Row

    For i = 3 To lastRow
        code  = Trim(CStr(wsArt.Cells(i, 1).Value))
        desig = Trim(CStr(wsArt.Cells(i, 2).Value))
        cat   = Trim(CStr(wsArt.Cells(i, 5).Value))

        If code = "" Then GoTo NextRow

        If noFilter Or (cat = filterCat) Then
            frmStockEntry.cmbArticle.AddItem code & " | " & desig
        End If
NextRow:
    Next i
End Sub

Private Sub ConfigureGrid()
    With frmStockEntry.lstGrid
        .ColumnCount   = 6
        .ColumnHeads   = False
        .ColumnWidths  = "80 pt;220 pt;90 pt;50 pt;80 pt;90 pt"
        .MultiSelect   = fmMultiSelectSingle
        .ListStyle     = fmListStylePlain
        .Font.Name     = "Courier New"
        .Font.Size     = 9
        .BackColor     = RGB(248, 248, 252)
    End With

    frmStockEntry.lblGridHeader.Caption  = "  Code      |  Designation              |  Cat" & Chr(233) & "gorie  | Qte |  PU (DZD) |  Valeur"
    frmStockEntry.lblGridHeader.Font.Name = "Courier New"
    frmStockEntry.lblGridHeader.Font.Size = 8
    frmStockEntry.lblGridHeader.ForeColor = RGB(71, 71, 90)
End Sub

Private Sub ResetToDefaultState()
    frmStockEntry.txtDate.Value          = Format(Date, "DD/MM/YYYY")
    frmStockEntry.txtRefDoc.Value        = ""
    frmStockEntry.txtQuantite.Value      = ""
    frmStockEntry.txtPrixUnitaire.Value  = ""
    frmStockEntry.cmbArticle.ListIndex   = -1
    frmStockEntry.lstGrid.Clear

    m_TotalGeneral         = 0
    m_CurrentArticle       = ""
    m_StockActuel          = 0

    frmStockEntry.lblStockInfo.Caption   = "Code Article :  --"
    frmStockEntry.lblStockInfo.ForeColor = RGB(100, 100, 100)
    frmStockEntry.lblWilsonAlert.Visible = False
    frmStockEntry.txtQuantite.BackColor  = RGB(255, 255, 255)

    Call UpdateTotalDisplay
End Sub


'==============================================================================
' SECTION 2  DOCUMENT TYPE BANNER
'==============================================================================
Public Sub cmbTypeDoc_Change()
    Select Case frmStockEntry.cmbTypeDoc.Value


        Case mod_Config.DOC_TYPE_BS
            frmStockEntry.fraDocTypeBanner.BackColor = RGB(160, 70, 0)
            frmStockEntry.lblBannerText.Caption = "  MODE SORTIE  --  Bon de Sortie"
            m_IsBRMode = False
            frmStockEntry.txtPrixUnitaire.Enabled = False
            frmStockEntry.txtPrixUnitaire.BackColor = RGB(235, 235, 235)
            frmStockEntry.lblPU.Caption = "PU -- CMUP auto"

        Case mod_Config.DOC_TYPE_BR
            frmStockEntry.fraDocTypeBanner.BackColor = RGB(4, 90, 55)
            frmStockEntry.lblBannerText.Caption = "  MODE ENTREE  --  Bon de R" & Chr(201) & "ception"
            m_IsBRMode = True
            frmStockEntry.txtPrixUnitaire.Enabled = True
            frmStockEntry.txtPrixUnitaire.BackColor = RGB(255, 252, 196)
            frmStockEntry.lblPU.Caption = "Prix Unitaire (saisir)"

        Case mod_Config.DOC_TYPE_DA
            frmStockEntry.fraDocTypeBanner.BackColor = RGB(30, 80, 180)
            frmStockEntry.lblBannerText.Caption = "  Demande d'Achat"
            m_IsBRMode = False
            frmStockEntry.txtPrixUnitaire.Enabled = False
            frmStockEntry.txtPrixUnitaire.BackColor = RGB(235, 235, 235)
            frmStockEntry.lblPU.Caption = "PU (estime)"

        Case Else
            frmStockEntry.fraDocTypeBanner.BackColor = RGB(100, 100, 100)
            frmStockEntry.lblBannerText.Caption = "-- SESSIONNEZ LE TYPE DE DOCUMENT --"
    End Select

    If m_CurrentArticle <> "" Then Call EvaluateStockStatus(m_CurrentArticle)
    If Len(Trim(frmStockEntry.txtRefDoc.Value)) = 0 Then Call GenerateAutoRef
End Sub

Private Function GetDocPrefix() As String
    Select Case frmStockEntry.cmbTypeDoc.Value
        Case mod_Config.DOC_TYPE_BS:  GetDocPrefix = "BS"
        Case mod_Config.DOC_TYPE_BR:  GetDocPrefix = "BR"
        Case mod_Config.DOC_TYPE_DA:  GetDocPrefix = "DA"
        Case Else:    GetDocPrefix = "TXN"
    End Select
End Function


'==============================================================================
' SECTION 3  ARTICLE SELECTION & STOCK INTELLIGENCE ENGINE
'==============================================================================
 
'  Fires on every keystroke / selection in Me.cmbArticle
Public Sub cmbArticle_Change()
    Dim raw As String

    If frmStockEntry.cmbArticle.ListIndex < 0 Then Exit Sub
    raw = Trim(frmStockEntry.cmbArticle.Text)
    If Len(raw) = 0 Then Exit Sub

    Dim parts() As String
    parts = Split(raw, "|")
    m_CurrentArticle = Trim(parts(0))

    Call EvaluateStockStatus(m_CurrentArticle)
End Sub

Private Sub EvaluateStockStatus(ByVal artCode As String)
    Dim wsArt    As Worksheet
    Dim foundRow As Variant
    Dim stock    As Long
    Dim pu       As Double
    Dim cat      As String
    Dim ropVal   As Double
    Dim ssVal    As Long

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If wsArt Is Nothing Then
        frmStockEntry.lblStockInfo.Caption   = "Code Article :  " & artCode & "  |  [Feuille ARTICLES introuvable]"
        frmStockEntry.lblStockInfo.ForeColor = RGB(180, 0, 0)
        Exit Sub
    End If

    foundRow = Application.Match(artCode, wsArt.Range("A:A"), 0)

    If IsError(foundRow) Then
        frmStockEntry.lblStockInfo.Caption   = "Code Article :  " & artCode & "  |  Article introuvable"
        frmStockEntry.lblStockInfo.ForeColor = RGB(180, 0, 0)
        m_StockActuel          = -1
        frmStockEntry.lblWilsonAlert.Visible = False
        Exit Sub
    End If

    pu    = CDbl(mod_Utilities.SafeVal(wsArt.Cells(foundRow, 8).Value))
    cat   = Trim(CStr(wsArt.Cells(foundRow, 11).Value))

    Dim wsMouv As Worksheet
    On Error Resume Next
    Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    On Error GoTo 0

    If wsMouv Is Nothing Then
        stock = 0
    Else
        Dim totalIn As Double, totalOut As Double
        totalIn = WorksheetFunction.SumIfs(wsMouv.Range("E:E"), wsMouv.Range("B:B"), artCode, wsMouv.Range("D:D"), "IN")
        totalOut = WorksheetFunction.SumIfs(wsMouv.Range("E:E"), wsMouv.Range("B:B"), artCode, wsMouv.Range("D:D"), "OUT")
        stock = CLng(totalIn - totalOut)
    End If

    m_StockActuel = stock

    If artCode = "ART-001" Then
        ropVal = CANON_ROP
        ssVal  = CANON_SS
    Else
        ssVal = 50
        ropVal = ssVal + CANON_LT
    End If

    Dim statusText  As String
    Dim statusColor As Long

    If stock <= 0 Then
        statusText  = "[RUPTURE]"
        statusColor = RGB(200, 30, 30)
    ElseIf stock <= ssVal Then
        statusText  = "[CRITIQUE]"
        statusColor = RGB(200, 30, 30)
    ElseIf stock <= ropVal Then
        statusText  = "[ALERTE]"
        statusColor = RGB(160, 70, 0)
    Else
        statusText  = "[OK]"
        statusColor = RGB(4, 90, 55)
    End If

    frmStockEntry.lblStockInfo.Caption  = "Code Article :  " & artCode & "   |   Stock :  " & stock & " u" & "   |   " & statusText
    frmStockEntry.lblStockInfo.ForeColor = statusColor

    If Not m_IsBRMode And pu > 0 Then
        frmStockEntry.txtPrixUnitaire.Value = Format(pu, "0.00")
    End If

    If artCode = "ART-001" Then
        frmStockEntry.lblWilsonAlert.Caption  = "Wilson EOQ -- Q* = " & CANON_QSTAR & " u  |  SS = " & CANON_SS & " u"
        frmStockEntry.lblWilsonAlert.ForeColor = RGB(4, 90, 55)
        frmStockEntry.lblWilsonAlert.Visible   = True
    Else
        frmStockEntry.lblWilsonAlert.Visible   = False
    End If
End Sub

Public Sub cmbCategorie_Change()
    Dim prevSKU As String
    prevSKU = m_CurrentArticle

    Call LoadArticleComboBox(Trim(frmStockEntry.cmbCategorie.Value))

    If prevSKU <> "" Then
        Dim j As Integer
        For j = 0 To frmStockEntry.cmbArticle.ListCount - 1
            If Left(frmStockEntry.cmbArticle.List(j), Len(prevSKU)) = prevSKU Then
                frmStockEntry.cmbArticle.ListIndex = j
                Exit For
            End If
        Next j
    End If
End Sub


'==============================================================================
' SECTION 4  QUANTITY FIELD
'==============================================================================
Public Sub txtQuantite_Change()

    If Not IsNumeric(frmStockEntry.txtQuantite.Value) Then
        frmStockEntry.txtQuantite.BackColor = RGB(255, 199, 199)
        Exit Sub
    End If

    Dim qty As Long
    qty = CLng(frmStockEntry.txtQuantite.Value)
    If qty <= 0 Then Exit Sub

    If Not m_IsBRMode And m_StockActuel >= 0 Then
        Dim projected As Long
        projected = m_StockActuel - qty

        Select Case True
            Case projected < 0
                frmStockEntry.txtQuantite.BackColor = RGB(255, 199, 199)
            Case projected <= CANON_SS
                frmStockEntry.txtQuantite.BackColor = RGB(255, 235, 150)
            Case projected <= CANON_ROP
                frmStockEntry.txtQuantite.BackColor = RGB(255, 248, 200)
            Case Else
                frmStockEntry.txtQuantite.BackColor = RGB(198, 239, 206)
        End Select
    Else
        frmStockEntry.txtQuantite.BackColor = RGB(255, 255, 255)
    End If
End Sub


'==============================================================================
' SECTION 5 � AUTO REFERENCE GENERATOR
'==============================================================================
Public Sub GenerateAutoRef()
    Dim prefix  As String
    Dim dateStr As String
    Dim seq    As Long

    prefix  = GetDocPrefix()
    dateStr = Format(Date, "DDMM")
    seq     = GetNextSequence(prefix)

    frmStockEntry.txtRefDoc.Value = prefix & "-" & Format(Date, "YYYY") & "-" & dateStr & "-" & Format(seq, "000")
End Sub

Private Function GetNextSequence(ByVal prefix As String) As Long
    Dim wsMouv   As Worksheet
    Dim lastRow As Long
    Dim i       As Long
    Dim maxSeq  As Long
    Dim refStr  As String

    maxSeq = 0

    On Error Resume Next
    Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    On Error GoTo 0

    If wsMouv Is Nothing Then
        GetNextSequence = 1
        Exit Function
    End If

    lastRow = wsMouv.Cells(wsMouv.Rows.Count, 7).End(xlUp).Row
    
    For i = 3 To lastRow
        refStr = CStr(wsMouv.Cells(i, 7).Value)
        If Left(refStr, Len(prefix)) = prefix Then
            Dim parts() As String
            parts = Split(refStr, "-")
            If UBound(parts) >= 3 Then
                Dim seqNum As Long
                On Error Resume Next
                seqNum = CLng(parts(UBound(parts)))
                If Err.Number = 0 And seqNum > maxSeq Then maxSeq = seqNum
                On Error GoTo 0
            End If
        End If
    Next i

    GetNextSequence = maxSeq + 1
End Function


'==============================================================================
' SECTION 6  GRID OPERATIONS
'==============================================================================
 
Public Sub btnAjouterLigne_Click()
    Dim qty        As Long

    Dim pu         As Double
    Dim valLigne   As Double
    Dim desig      As String
    Dim cat        As String
    Dim ropSeuil   As Double
    Dim rowIdx     As Integer

    If Not mod_Utilities.IsValidDate(frmStockEntry.txtDate.Value) Then
        MsgBox "Format de date requis : JJ/MM/AAAA", vbExclamation
        frmStockEntry.txtDate.SetFocus
        Exit Sub
    End If

    If Len(Trim(frmStockEntry.txtRefDoc.Value)) = 0 Then
        MsgBox "Le N-- Reference est OBLIGATOIRE.", vbCritical
        frmStockEntry.txtRefDoc.SetFocus
        Exit Sub
    End If

    If Len(Trim(m_CurrentArticle)) = 0 Then
        MsgBox "Selectionnez un article.", vbExclamation
        frmStockEntry.cmbArticle.SetFocus
        Exit Sub
    End If

    If m_StockActuel = -1 Then
        MsgBox "Article introuvable dans le catalogue.", vbCritical
        Exit Sub
    End If

    If Not IsNumeric(frmStockEntry.txtQuantite.Value) Then
        MsgBox "Quantite invalide.", vbCritical
        frmStockEntry.txtQuantite.SetFocus
        Exit Sub
    End If

    qty = CLng(frmStockEntry.txtQuantite.Value)

    If qty <= 0 Then
        MsgBox "La quantite doit " & Chr(234) & "tre > 0.", vbCritical
        frmStockEntry.txtQuantite.SetFocus
        Exit Sub
    End If

    If m_IsBRMode Then
        If Not IsNumeric(frmStockEntry.txtPrixUnitaire.Value) Or _
           CDbl(mod_Utilities.SafeVal(frmStockEntry.txtPrixUnitaire.Value)) <= 0 Then
            MsgBox "Le Prix Unitaire est requis pour un Bon de R" & Chr(201) & "ception.", vbCritical
            frmStockEntry.txtPrixUnitaire.SetFocus
            Exit Sub
        End If
    End If

    pu = CDbl(mod_Utilities.SafeVal(frmStockEntry.txtPrixUnitaire.Value))

    If Not m_IsBRMode Then
        Dim netProjected As Long
        netProjected = m_StockActuel - qty

        If netProjected < 0 Then
            MsgBox "Stock insuffisant ! Stock dispo: " & m_StockActuel & " u, Qte demandee: " & qty & " u", vbCritical
            Exit Sub
        End If

        ropSeuil = IIf(m_CurrentArticle = "ART-001", CANON_ROP, 60)

        If netProjected <= ropSeuil Then
            Dim ropResp As VbMsgBoxResult
            ropResp = MsgBox("ALERTE -- Point de commande atteint." & vbCrLf & _
                            "Continuer ?", vbYesNo + vbExclamation, "ROP Alert")
            If ropResp = vbNo Then Exit Sub
        End If
    End If

    valLigne = qty * pu
    desig    = mod_Utilities.GetArticleField(m_CurrentArticle, "DESIG")
    cat      = mod_Utilities.GetArticleField(m_CurrentArticle, "CAT")

    frmStockEntry.lstGrid.AddItem ""
    rowIdx = frmStockEntry.lstGrid.ListCount - 1

    frmStockEntry.lstGrid.List(rowIdx, COL_CODE)   = m_CurrentArticle
    frmStockEntry.lstGrid.List(rowIdx, COL_DESIG)  = Left(desig, 28)
    frmStockEntry.lstGrid.List(rowIdx, COL_CAT)    = Left(cat, 14)
    frmStockEntry.lstGrid.List(rowIdx, COL_QTE)    = CStr(qty)
    frmStockEntry.lstGrid.List(rowIdx, COL_PU)     = Format(pu, "#,##0.00")
    frmStockEntry.lstGrid.List(rowIdx, COL_VALEUR) = Format(valLigne, "#,##0.00")

    Call UpdateTotalDisplay

    frmStockEntry.cmbArticle.ListIndex   = -1
    frmStockEntry.txtQuantite.Value      = ""
    frmStockEntry.txtPrixUnitaire.Value  = ""
    frmStockEntry.txtQuantite.BackColor  = RGB(255, 255, 255)
    m_CurrentArticle       = ""
    m_StockActuel          = 0
    frmStockEntry.lblStockInfo.Caption   = "Code Article :  --"
    frmStockEntry.lblWilsonAlert.Visible = False

    frmStockEntry.cmbArticle.SetFocus
End Sub

Public Sub btnSupprimerLigne_Click()
    If frmStockEntry.lstGrid.ListIndex < 0 Then
        MsgBox "Selectionnez une ligne a supprimer.", vbInformation
        Exit Sub
    End If

    frmStockEntry.lstGrid.RemoveItem frmStockEntry.lstGrid.ListIndex
    Call UpdateTotalDisplay
End Sub

Private Sub UpdateTotalDisplay()
    Dim runningTotal As Double
    Dim i            As Integer
    runningTotal = 0

    For i = 0 To frmStockEntry.lstGrid.ListCount - 1
        On Error Resume Next
        Dim rawVal As String
        rawVal = frmStockEntry.lstGrid.List(i, COL_VALEUR)
        rawVal = Replace(rawVal, ",", "")
        If IsNumeric(rawVal) Then runningTotal = runningTotal + CDbl(rawVal)
        On Error GoTo 0
    Next i

    m_TotalGeneral             = runningTotal
    frmStockEntry.lblTotalGeneral.Caption    = "TOTAL GENERAL :  " & _
                                  Format(m_TotalGeneral, "#,##0.00") & " DZD"
End Sub

Private Function GetQtyInGridForSKU(ByVal sku As String) As Long
    Dim total As Long
    Dim i     As Integer
    total = 0

    For i = 0 To frmStockEntry.lstGrid.ListCount - 1
        If frmStockEntry.lstGrid.List(i, COL_CODE) = sku Then
            On Error Resume Next
            total = total + CLng(frmStockEntry.lstGrid.List(i, COL_QTE))
            On Error GoTo 0
        End If
    Next i

    GetQtyInGridForSKU = total
End Function


'==============================================================================
' SECTION 7  ENREGISTRER
'==============================================================================
Public Sub btnEnregistrer_Click()
    If frmStockEntry.lstGrid.ListCount = 0 Then

        MsgBox "Le document ne contient aucun article.", vbExclamation
        Exit Sub
    End If
    
    If Len(Trim(frmStockEntry.cmbService.Value)) = 0 Then
        MsgBox "SERVICE / FOURNISSEUR est requis.", vbExclamation
        frmStockEntry.cmbService.SetFocus
        Exit Sub
    End If
    
    If Len(Trim(frmStockEntry.cmbTypeDoc.Value)) = 0 Then
        MsgBox "Type de Document est requis.", vbExclamation
        frmStockEntry.cmbTypeDoc.SetFocus
        Exit Sub
    End If

    Dim gridRow As Integer
    For gridRow = 0 To frmStockEntry.lstGrid.ListCount - 1
        If Not IsNumeric(frmStockEntry.lstGrid.List(gridRow, COL_QTE)) Or _
           Not IsNumeric(frmStockEntry.lstGrid.List(gridRow, COL_PU)) Then
            MsgBox "Donn" & Chr(233) & "es invalides a la ligne " & gridRow + 1, vbCritical
            Exit Sub
        End If
        If CLng(frmStockEntry.lstGrid.List(gridRow, COL_QTE)) <= 0 Then
            MsgBox "La quantite doit " & Chr(234) & "tre > 0 (ligne " & gridRow + 1 & ")", vbCritical
            Exit Sub
        End If
    Next gridRow

    Dim nLines   As Integer
    Dim typeSign As String
    nLines   = frmStockEntry.lstGrid.ListCount
    typeSign = IIf(m_IsBRMode, "IN -- Entree", "OUT -- Sortie")
    
    Dim confMsg As String
    confMsg = "Confirmer l'enregistrement ?" & vbCrLf & vbCrLf & _
              "Document :  " & frmStockEntry.cmbTypeDoc.Value & "  [" & typeSign & "]" & vbCrLf & _
              "Reference:  " & frmStockEntry.txtRefDoc.Value & vbCrLf & _
              "Service  :  " & frmStockEntry.cmbService.Value & vbCrLf & _
              "Lignes   :  " & nLines & vbCrLf & _
              "Total    :  " & Format(m_TotalGeneral, "#,##0.00") & " DZD"
    
    If MsgBox(confMsg, vbYesNo + vbQuestion) = vbNo Then
        Exit Sub
    End If
    
    Dim i        As Integer
    Dim docDate  As Date
    Dim mvtSign  As String
    Dim lineCode As String
    Dim lineQty  As Long
    Dim linePU   As Double
    Dim lineVal  As Double
    Dim lineDesig As String
    
    On Error GoTo SaveError
    
    docDate = Date
    mvtSign = IIf(m_IsBRMode, "IN", "OUT")
    
    Application.ScreenUpdating = False
    Application.Calculation    = xlCalculationManual
    Application.EnableEvents   = False

    Dim wsMouv As Worksheet: Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    Dim startRow As Long: startRow = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row + 1
    
    For i = 0 To frmStockEntry.lstGrid.ListCount - 1
        lineCode  = frmStockEntry.lstGrid.List(i, COL_CODE)
        lineDesig = frmStockEntry.lstGrid.List(i, COL_DESIG)
        lineQty   = CLng(frmStockEntry.lstGrid.List(i, COL_QTE))
        linePU    = CDbl(Replace(frmStockEntry.lstGrid.List(i, COL_PU), ",", ""))
        lineVal   = CDbl(Replace(frmStockEntry.lstGrid.List(i, COL_VALEUR), ",", ""))
        
        If mvtSign = "OUT" Then
            Dim currentStockLevel As Double
            Dim totalIn As Double
            Dim totalOut As Double
            totalIn = WorksheetFunction.SumIfs(wsMouv.Range("E:E"), wsMouv.Range("B:B"), lineCode, wsMouv.Range("D:D"), "IN")
            totalOut = WorksheetFunction.SumIfs(wsMouv.Range("E:E"), wsMouv.Range("B:B"), lineCode, wsMouv.Range("D:D"), "OUT")
            currentStockLevel = totalIn - totalOut
            
            If lineQty > currentStockLevel Then
                MsgBox "Stock insuffisant pour '" & lineCode & "'. Stock dispo: " & currentStockLevel, vbCritical
                GoTo SaveError
            End If
        End If
        
        Call mod_Database.SecureWriteTransaction( _
            docDate    := docDate, _
            typeSign   := mvtSign, _
            refDoc     := Trim(frmStockEntry.txtRefDoc.Value), _
            codeArticle:= lineCode, _
            designation:= lineDesig, _
            quantity   := lineQty, _
            unitPrice  := linePU, _
            lineValue  := lineVal, _
            thirdParty := frmStockEntry.cmbService.Value)
        
        If FireInternalBridge(lineCode, mvtSign, lineQty, linePU, Trim(frmStockEntry.txtRefDoc.Value)) <> 0 Then
            MsgBox "Erreur de synchronisation interne. Annulation de la transaction...", vbCritical
            ' Rollback: Delete rows written in this session
            Dim endRow As Long: endRow = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row
            If endRow >= startRow Then
                wsMouv.Rows(startRow & ":" & endRow).Delete
            End If
            GoTo SaveError
        End If
    Next i

    
    Application.EnableEvents   = True
    Application.Calculation    = xlCalculationAutomatic
    Application.ScreenUpdating = True
    
    Call mod_AuditTrail.LogTransaction(frmStockEntry.cmbTypeDoc.Value, Trim(frmStockEntry.txtRefDoc.Value))
    
    MsgBox "Enregistrement r" & Chr(233) & "ussi !" & vbCrLf & _
            "Reference :  " & frmStockEntry.txtRefDoc.Value & vbCrLf & _
            nLines & " ligne(s) enregistr" & Chr(233) & "e(s)", vbInformation
    
    ' Sync updated metrics from Sجل رقمي back to Articles sheet
    Call mod_SyncBridge.SyncMetricsFromLedger
    
    If MsgBox("Imprimer le " & frmStockEntry.cmbTypeDoc.Value & " ?", vbYesNo + vbQuestion) = vbYes Then
        Call mod_ExportEngine.ExportTransactionToPDF(Trim(frmStockEntry.txtRefDoc.Value))
    End If

    
    Call ResetToDefaultState
    Exit Sub
    
SaveError:
    ' Rollback: Delete any rows written in this session
    Dim rollbackRow As Long
    rollbackRow = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row
    If rollbackRow >= startRow Then
        wsMouv.Rows(startRow & ":" & rollbackRow).Delete
    End If
    Application.EnableEvents   = True
    Application.Calculation    = xlCalculationAutomatic
    Application.ScreenUpdating = True
    MsgBox "Une erreur s'est produite lors de l'enregistrement. Transaction annul" & Chr(233) & "e.", vbCritical
End Sub

Private Function FireInternalBridge(ByVal artCode As String, _
                                      ByVal mvtType   As String, _
                                      ByVal qty       As Long, _
                                      ByVal unitPrice As Double, _
                                      ByVal refDoc    As String) As Integer
    On Error Resume Next
    FireInternalBridge = mod_SyncBridge.SyncTransactionInternal(artCode, mvtType, qty, unitPrice, refDoc)
    If Err.Number <> 0 Then FireInternalBridge = -1
    On Error GoTo 0
End Function



'==============================================================================
'==============================================================================
' SECTION 8  CANCEL
'==============================================================================
Public Sub btnAnnuler_Click()
    If frmStockEntry.lstGrid.ListCount > 0 Then

        If MsgBox("Des lignes sont en attente. Annuler quand meme ?", _
                  vbYesNo + vbExclamation) = vbNo Then
            Exit Sub
        End If
    End If
    Unload frmStockEntry
End Sub

Private Sub UserForm_KeyDown(ByVal KeyCode As Integer, _
                              ByVal Shift As Integer)
    Select Case KeyCode
        Case 27: Call btnAnnuler_Click
        Case 13: Call btnAjouterLigne_Click
    End Select
End Sub

Private Sub UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)
    If CloseMode = vbFormControlMenu Then
        Cancel = True
        Call btnAnnuler_Click
    End If
End Sub


'==============================================================================
' END -- mod_StockEntry_Logic.bas
'==============================================================================
