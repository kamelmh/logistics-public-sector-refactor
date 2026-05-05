VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmStockEntry 
    Caption         =   "نموذج إدخال بيانات المخزون - Directorate of Education El Bayadh"
   ClientHeight    =   12210
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   17160
   OleObjectBlob   =   "frmStockEntry.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmStockEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'==============================================================================
' نظام الدعم القرار v13.2
' Author   : ماحي كمال عبد الغني " & Chr(183) & " TAG1801 " & Chr(183) & " CNEPD 2026
' Depends  : mod_StockEntry_Logic_Enhanced.bas | mod_ExportEngine_Enhanced.bas
'            mod_StockCalculations.bas
''
' Architecture:
'   UI Layer       " & Chr(183) & " this form (frmStockEntry)
'   Data Layer     " & Chr(183) & " ProcessTransaction() via VBA Processing Units
'   Ledger         " & Chr(183) & " السجل الرقمي (Digital Ledger via VBA)
''
' Canonical constants (locked " & Chr(183) & " never change without updating CLAUDE.md):
'   D=1,546  |  ROP=205.6  |  Q*=176  |  SS=200  |  LT=2 days
'==============================================================================

Option Explicit

'------------------------------------------------------------------------------
' SECTION 0 " & Chr(183) & " MODULE-LEVEL CONSTANTS & STATE
'------------------------------------------------------------------------------

'- Canonical ERP constants (mirrors Unité de traitement VBA GROUND_TRUTH)
Private Const CANON_ROP    As Double = 205.6
Private Const CANON_SS     As Long = 200
Private Const CANON_QSTAR  As Long = 176
Private Const CANON_LT     As Integer = 2
Private Const MASTER_PWD   As String = "erp_secure_pwd_2026"

'- Me.lstGrid column indices (0-based)
Private Const COL_CODE   As Integer = 0
Private Const COL_DESIG  As Integer = 1
Private Const COL_CAT    As Integer = 2
Private Const COL_QTE    As Integer = 3
Private Const COL_PU     As Integer = 4
Private Const COL_VALEUR As Integer = 5

'- Document type string constants
' Use the public constants from mod_StockEntry_Logic


'- Form state (module-level " & Chr(183) & " persists across event calls)
Private m_TotalGeneral   As Double   ' running sum of all grid lines
Private m_CurrentArticle As String   ' resolved SKU code (e.g. "ART-001")
Private m_StockActuel    As Long     ' live stock for selected article
Private m_IsBRMode       As Boolean  ' True = IN (BR) / False = OUT (BS/DA)


'==============================================================================
' SECTION 1 " & Chr(183) & " FORM INITIALIZE
'==============================================================================
Private Sub UserForm_Initialize()
    Call mod_StockEntry_Logic.InitializeForm
End Sub

'------------------------------------------------------------------------------
Private Sub SetupFormAppearance()
    '- Form shell
    Caption = mod_Localization.SafeGetTxt("SYS_TITLE")
    If Caption = "SYS_TITLE" Or InStr(Caption, "NOT_FOUND") > 0 Then
        Caption = "Saisie des Mouvements de Stock"
    End If
    Width = 870
    Height = 640
    
    '- Banner (neutral until document type selected)
    fraDocTypeBanner.BackColor = RGB(100, 100, 100)
    lblBannerText.Caption = mod_Localization.SafeGetTxt("LBL_SELECT_DOC")
    If lblBannerText.Caption = "LBL_SELECT_DOC" Then lblBannerText.Caption = "  -- SELECTIONNEZ LE TYPE DE DOCUMENT --"
    lblBannerText.ForeColor = RGB(255, 255, 255)
    lblBannerText.Font.Bold = True
    lblBannerText.TextAlign = fmTextAlignCenter
    
    '- Wilson alert (hidden by default)
    lblWilsonAlert.Visible = False
    lblWilsonAlert.ForeColor = RGB(5, 100, 60)
    
    '- Stock info idle state
    lblStockInfo.Caption = mod_Localization.SafeGetTxt("LBL_STOCK_IDLE")
    If lblStockInfo.Caption = "LBL_STOCK_IDLE" Then lblStockInfo.Caption = "Code Article :  --"
    lblStockInfo.ForeColor = RGB(100, 100, 100)
    
    '- Total footer
    Me.lblTotalGeneral.Caption = mod_Localization.SafeGetTxt("LBL_TOTAL_GENERAL")
    If Me.lblTotalGeneral.Caption = "LBL_TOTAL_GENERAL" Then Me.lblTotalGeneral.Caption = "TOTAL GENERAL :  0.00 DZD"
    Me.lblTotalGeneral.Font.Bold = True
    Me.lblTotalGeneral.ForeColor = RGB(5, 100, 60)
    
    '- Lien Local : activé par défaut
    Me.chkSyncInternal.Value = True
    
    '- Button Captions (Dynamic Tweak)
    btnAjouterLigne.Caption = mod_Localization.SafeGetTxt("BTN_ADD_LINE")
    If btnAjouterLigne.Caption = "BTN_ADD_LINE" Then btnAjouterLigne.Caption = "Ajouter Ligne"
    
    btnSupprimerLigne.Caption = mod_Localization.SafeGetTxt("BTN_DEL_LINE")
    If btnSupprimerLigne.Caption = "BTN_DEL_LINE" Then btnSupprimerLigne.Caption = "Supprimer Ligne"
    
    btnEnregistrer.Caption = mod_Localization.SafeGetTxt("BTN_SAVE")
    If btnEnregistrer.Caption = "BTN_SAVE" Then btnEnregistrer.Caption = "Enregistrer"
    
    btnAutoRef.Caption = mod_Localization.SafeGetTxt("BTN_AUTOREF")
    If btnAutoRef.Caption = "BTN_AUTOREF" Then btnAutoRef.Caption = "Auto-Ref"
    
    '- Report button (Safe check if control exists)
    On Error Resume Next
    Dim ctrlReport As Object
    Set ctrlReport = Me.Controls("btnGenerateReport")
    If Not ctrlReport Is Nothing Then
        ctrlReport.Caption = "Bordereau Commande"
        ctrlReport.ForeColor = RGB(0, 70, 127)
        ctrlReport.Font.Bold = True
    End If
    On Error GoTo 0
    
    btnAnnuler.Caption = mod_Localization.SafeGetTxt("BTN_CANCEL")
    If btnAnnuler.Caption = "BTN_CANCEL" Then btnAnnuler.Caption = "Annuler"
    
    '- Auto-fill today's date
    TxtDate.Value = Format(Date, "DD/MM/YYYY")
End Sub


'------------------------------------------------------------------------------
Private Sub PopulateDropdowns()
    '- Document types
    Me.cmbTypeDoc.Clear
    Me.cmbTypeDoc.AddItem DOC_BS
    Me.cmbTypeDoc.AddItem DOC_BR
    Me.cmbTypeDoc.AddItem DOC_DA
    Me.cmbTypeDoc.ListIndex = 0          ' default to Bon de Sortie

    '- Services / Fournisseurs (LOAD FROM SHEET TO PREVENT ARABIC ??? ERROR)
    Me.cmbService.Clear
    Dim wsStr As Worksheet
    On Error Resume Next
    Set wsStr = ThisWorkbook.Sheets("SYS_STRINGS")
    On Error GoTo 0

    If Not wsStr Is Nothing Then
        Dim lastRowStr As Long, iStr As Long
        lastRowStr = wsStr.Cells(wsStr.Rows.count, 1).End(xlUp).Row
        For iStr = 2 To lastRowStr
            ' Load any string ID that starts with "SVC_"
            If Left(Trim(wsStr.Cells(iStr, 1).Value), 4) = "SVC_" Then
                Me.cmbService.AddItem Trim(wsStr.Cells(iStr, 2).Value)
            End If
        Next iStr
    End If

    ' Fallback if sheet is empty or missing
    If Me.cmbService.listCount = 0 Then
        Me.cmbService.AddItem "Service 1"
        Me.cmbService.AddItem "Service 2"
        Me.cmbService.AddItem "Fournisseur Externe"
    End If

    '- Categories (mirrors ARTICLES sheet Col E values)
    Me.cmbCategorie.Clear
    Me.cmbCategorie.AddItem "(Toutes)"
    Me.cmbCategorie.AddItem "Fournitures Bureau"
    Me.cmbCategorie.AddItem "Informatique"
    Me.cmbCategorie.AddItem "Admin"
    Me.cmbCategorie.AddItem "Inconnu"
    Me.cmbCategorie.ListIndex = 0

    '- Articles (full load, no filter)
    Call LoadArticleComboBox("")
End Sub

'------------------------------------------------------------------------------
'  Load ARTICLES sheet into Me.cmbArticle, filtered by category
'  Format: "ART-001 | ??? ????? A4"
'------------------------------------------------------------------------------
Private Sub LoadArticleComboBox(ByVal filterCat As String)
    Dim wsArt    As Worksheet
    Dim lastRow  As Long
    Dim i        As Long
    Dim code     As String
    Dim desig    As String
    Dim cat      As String
    Dim noFilter As Boolean

    Debug.Print "LoadArticleComboBox called with filter: '" & filterCat & "'"
    Me.cmbArticle.Clear
    noFilter = (filterCat = "" Or filterCat = "(Toutes)")

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    '  Graceful fallback if sheet missing
    If wsArt Is Nothing Then
        Debug.Print "ARTICLES sheet not found - using fallback items"
        Me.cmbArticle.AddItem "ART-001 | ??? ????? A4"
        Me.cmbArticle.AddItem "ART-002 | ??? ????? A3"
        Me.cmbArticle.AddItem "ART-003 | ??? ??? (Sous-Chemise)"
        Me.cmbArticle.AddItem "ART-004 | ??? (Chemise)"
        Me.cmbArticle.AddItem "ART-005 | ??? ??????? G030"
        Me.cmbArticle.AddItem "ART-006 | ????? ??? (Stylos Bille)"
        Debug.Print "Added 6 fallback items to cmbArticle"
        Exit Sub
    End If

    lastRow = wsArt.Cells(wsArt.Rows.count, 1).End(xlUp).Row
    Debug.Print "ARTICLES sheet found - lastRow: " & lastRow

    For i = 3 To lastRow
        code = Trim(CStr(wsArt.Cells(i, 1).Value))
        desig = Trim(CStr(wsArt.Cells(i, 2).Value))
        cat = Trim(CStr(wsArt.Cells(i, 5).Value))

        If code = "" Then GoTo nextRow

        If noFilter Or (cat = filterCat) Then
            Me.cmbArticle.AddItem code & " | " & desig
        End If
nextRow:
    Next i
    Debug.Print "LoadArticleComboBox done - items in cmbArticle: " & Me.cmbArticle.listCount
End Sub

'------------------------------------------------------------------------------
'  Configure Me.lstGrid: 6 columns matching Data Lake columns
'  Code | D?signation | Cat" & Chr(233) & "gorie | Qt" & Chr(233) & " | PU | Valeur
'------------------------------------------------------------------------------
Private Sub ConfigureGrid()
    With Me.lstGrid
        .ColumnCount = 6
        .ColumnHeads = False
        .ColumnWidths = "80 pt;220 pt;90 pt;50 pt;80 pt;90 pt"
        .MultiSelect = fmMultiSelectSingle
        .ListStyle = fmListStylePlain
        .Font.name = "Courier New"
        .Font.Size = 9
        .BackColor = RGB(248, 248, 252)
    End With

    '  Pseudo-header label above the grid
    Me.lblGridHeader.Caption = "  Code      " & Chr(183) & "  D?signation              " & Chr(183) & "  Cat" & Chr(233) & "gorie  " & Chr(183) & " Qt" & Chr(233) & " " & Chr(183) & "  PU (DZD) " & Chr(183) & "  Valeur"
    Me.lblGridHeader.Font.name = "Courier New"
    Me.lblGridHeader.Font.Size = 8
    Me.lblGridHeader.ForeColor = RGB(71, 71, 90)
End Sub

'------------------------------------------------------------------------------
Private Sub ResetToDefaultState()
    Me.TxtDate.Value = Format(Date, "DD/MM/YYYY")
    Me.txtRefDoc.Value = ""
    Me.txtQuantite.Value = ""
    Me.txtPrixUnitaire.Value = ""
    Me.cmbArticle.ListIndex = -1
    Me.lstGrid.Clear

    m_TotalGeneral = 0
    m_CurrentArticle = ""
    m_StockActuel = 0

lblStockInfo.Caption = "Code Article :  " & Chr(183) & Chr(183)
    Me.lblStockInfo.ForeColor = RGB(100, 100, 100)
    Me.lblWilsonAlert.Visible = False
    Me.txtQuantite.BackColor = RGB(255, 255, 255)

    Call UpdateTotalDisplay
End Sub


'==============================================================================
' SECTION 2  DOCUMENT TYPE BANNER
'==============================================================================
Private Sub cmbTypeDoc_Change()
    Call mod_StockEntry_Logic.cmbTypeDoc_Change
End Sub


'------------------------------------------------------------------------------
Private Function GetDocPrefix() As String
    Select Case Me.cmbTypeDoc.Value
        Case DOC_BS:  GetDocPrefix = "BS"
        Case DOC_BR:  GetDocPrefix = "BR"
        Case DOC_DA:  GetDocPrefix = "DA"
        Case Else:    GetDocPrefix = "TXN"
    End Select
End Function


'==============================================================================
' SECTION 3  ARTICLE SELECTION & STOCK INTELLIGENCE ENGINE
'==============================================================================
 
'  Fires on every keystroke / selection in Me.cmbArticle
Private Sub cmbArticle_Change()
    Call mod_StockEntry_Logic.cmbArticle_Change
End Sub


'==============================================================================
' SECTION 8  PRINTING
'==============================================================================



'------------------------------------------------------------------------------
'  Category filter " & Chr(183) & " reload article combobox + try to restore selection
'------------------------------------------------------------------------------
Private Sub cmbCategorie_Change()
    Call mod_StockEntry_Logic.cmbCategorie_Change
End Sub



'==============================================================================
' SECTION 4  QUANTITY FIELD: LIVE PROJECTION + WILSON NUDGE UPDATE
'==============================================================================
Private Sub txtQuantite_Change()
    Call mod_StockEntry_Logic.txtQuantite_Change
End Sub




'==============================================================================
' SECTION 5 " & Chr(183) & " AUTO REFERENCE GENERATOR
'==============================================================================
Private Sub btnAutoRef_Click()
    Call GenerateAutoRef
End Sub

'------------------------------------------------------------------------------
Private Sub GenerateAutoRef()
    Dim prefix  As String
    Dim dateStr As String
    Dim seq     As Long

    prefix = GetDocPrefix()
    dateStr = Format(Date, "DDMM")
    seq = GetNextSequence(prefix)

    Me.txtRefDoc.Value = prefix & "-" & Format(Date, "YYYY") & "-" & dateStr & "-" & Format(seq, "000")
End Sub

'------------------------------------------------------------------------------
'  Scans MOUVEMENTS!F column for highest matching sequence number
'------------------------------------------------------------------------------
Private Function GetNextSequence(ByVal prefix As String) As Long
    Dim wsMov   As Worksheet
    Dim lastRow As Long
    Dim i       As Long
    Dim maxSeq  As Long
    Dim refStr  As String

    maxSeq = 0

    On Error Resume Next
    Set wsMov = ThisWorkbook.Sheets("MOUVEMENTS")
    On Error GoTo 0

    If wsMov Is Nothing Then
        GetNextSequence = 1
        Exit Function
    End If

    lastRow = wsMov.Cells(wsMov.Rows.count, 6).End(xlUp).Row

    For i = 2 To lastRow
        refStr = CStr(wsMov.Cells(i, 6).Value)
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
' SECTION 6 " & Chr(183) & " GRID OPERATIONS: ADD LINE / DELETE LINE / TOTAL
'==============================================================================

'------------------------------------------------------------------------------
'  AJOUTER LIGNE " & Chr(183) & " 8-guard validation chain before writing to grid
'------------------------------------------------------------------------------
Private Sub btnAjouterLigne_Click()
    Call mod_StockEntry_Logic.btnAjouterLigne_Click
End Sub


'------------------------------------------------------------------------------
Private Sub btnSupprimerLigne_Click()
    Call mod_StockEntry_Logic.btnSupprimerLigne_Click
End Sub


'------------------------------------------------------------------------------
'  Recompute TOTAL G?N?RAL from grid (avoids float drift from incremental adds)
'------------------------------------------------------------------------------
Private Sub UpdateTotalDisplay()
    Dim runningTotal As Double
    Dim i            As Integer
    runningTotal = 0

    For i = 0 To Me.lstGrid.listCount - 1
        On Error Resume Next
        Dim rawVal As String
        rawVal = Me.lstGrid.List(i, COL_VALEUR)
        rawVal = Replace(rawVal, ",", "")     ' strip thousands separator
        If IsNumeric(rawVal) Then runningTotal = runningTotal + CDbl(rawVal)
        On Error GoTo 0
    Next i

    m_TotalGeneral = runningTotal
    Me.lblTotalGeneral.Caption = "TOTAL G" & Chr(201) & "N" & Chr(201) & "RAL :  " & Format(m_TotalGeneral, "#,##0.00") & " DZD"

End Sub

'------------------------------------------------------------------------------
'  Sum grid qty for a given SKU " & Chr(183) & " used by GUARD 7 to detect multi-line abuse
'------------------------------------------------------------------------------
Private Function GetQtyInGridForSKU(ByVal sku As String) As Long
    Dim total As Long
    Dim i     As Integer
    total = 0

    For i = 0 To Me.lstGrid.listCount - 1
        If Me.lstGrid.List(i, COL_CODE) = sku Then
            On Error Resume Next
            total = total + CLng(Me.lstGrid.List(i, COL_QTE))
            On Error GoTo 0
        End If
    Next i

    GetQtyInGridForSKU = total
End Function


'==============================================================================
' SECTION 7  ENREGISTRER LE MOUVEMENT
'==============================================================================
Private Sub btnEnregistrer_Click()
    Call mod_StockEntry_Logic.btnEnregistrer_Click
End Sub


'------------------------------------------------------------------------------
'  Manual trigger to sync Excel ARTICLES sheet with Sجل رقمي Master
'------------------------------------------------------------------------------
Private Sub btnSyncMasterData_Click()
    On Error Resume Next
    Call mod_SyncBridge.SyncMetricsFromLedger
    If Err.Number = 0 Then
        MsgBox "Synchronisation réussie : Les données internes ont été importées.", vbInformation, "Sync Master"
    Else
        MsgBox "Erreur lors de la synchronisation : " & Err.Description, vbCritical, "Sync Error"
    End If
    On Error GoTo 0
End Sub

'------------------------------------------------------------------------------
Private Sub btnGenerateReport_Click()
    Call mod_Procurement.GenerateOrderReport
End Sub

'==============================================================================
' SECTION 9 " & Chr(183) & " CANCEL + KEYBOARD SHORTCUTS

'==============================================================================
Private Sub btnAnnuler_Click()
    Call mod_StockEntry_Logic.btnAnnuler_Click
End Sub


'  ESC " & Chr(183) & " Cancel     ENTER " & Chr(183) & " Add line
Private Sub UserForm_KeyDown(ByVal KeyCode As MSForms.ReturnInteger, _
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
' HELPER: FireInternalBridge
' Wrapper to send transaction to VBA and handle the initial trigger
'==============================================================================
Private Sub FireInternalBridge(ByVal sku As String, ByVal mvtType As String, _
                             ByVal qty As Long, ByVal pu As Double, _
                             ByVal refDoc As String)
    
    Dim result As Integer
    ' Call the authoritative bridge module
    result = mod_SyncBridge.SyncTransactionInternal(sku, mvtType, qty, pu, refDoc)
    
    If result <> 0 Then
        MsgBox "Erreur de communication avec le moteur VBA.", vbCritical, "Erreur de Lien"
    End If
End Sub

'==============================================================================
' SECTION 8 " & Chr(183) & " PRINTING
'==============================================================================
Private Sub btnImprimerBon_Click()
    Dim docRef As String
    docRef = Trim(Me.txtRefDoc.Value)
    
    If docRef = "" Then
        MsgBox "Veuillez s" & Chr(233) & "saisir une r" & Chr(233) & "f" & Chr(233) & "rence avant d'imprimer.", _
               vbExclamation, "R" & Chr(233) & "f manquante"
        Exit Sub
    End If
    
    ' Check if this reference exists in MOUVEMENTS sheet
    Dim wsMouv As Worksheet: Set wsMouv = ThisWorkbook.Sheets("MOUVEMENTS")
    Dim found As Variant
    found = Application.Match(docRef, wsMouv.Range("G:G"), 0)
    
    If IsError(found) Then
        If MsgBox("Ce document n'a pas encore été enregistré dans la base de données." & vbCrLf & _
                  "Voulez-vous l'enregistrer maintenant avant l'impression ?", _
                  vbYesNo + vbQuestion, "Document non enregistré") = vbYes Then
            
            ' Trigger the save process
            Call btnEnregistrer_Click
            ' If save succeeded, proceed to print
            Call mod_ExportEngine.ExportTransactionToPDF(docRef)
        End If
    Else
        ' Already saved, just print
        Call mod_ExportEngine.ExportTransactionToPDF(docRef)
    End If
End Sub

'==============================================================================
' END " & Chr(183) & " Me.bas
' Next: wire Me.btnAutoRef, Me.fraDocTypeBanner, Me.lblGridHeader as controls
'       in the UserForm designer using the property table in ?1
'==============================================================================


