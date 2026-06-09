VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmStockEntry 
   Caption         =   "UserForm1"
   ClientHeight    =   3015
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   4560
   OleObjectBlob   =   "frmStockEntry.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmStockEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'- Module-level state
Private m_State As FormState
Private m_Initialized As Boolean
Private m_IsFiltering As Boolean       ' Prevent recursive filtering

'==============================================================================
' FORM LIFECYCLE
'==============================================================================

Private Sub UserForm_Initialize()
    '- Build all controls programmatically
    Call BuildUI
    
    '- Initialize FormState struct
    Set m_State.formRef = Me
    m_State.IsBRMode = False
    
    '- Delegate to controller
    Call mod_StockEntry_Logic.InitializeForm(m_State)
    
    m_Initialized = True
End Sub

'==============================================================================
' PROGRAMMATIC UI BUILDER
' Creates all 25 controls at runtime - no designer needed
'==============================================================================

Private Sub BuildUI()
    Dim ctrl As Object
    Dim i As Integer
    
    '- Set form dimensions
    Me.Width = 870
    Me.Height = 640
    Me.Caption = "ERP Acad" & Chr(233) & "mie - Saisie des Mouvements"
    Me.StartUpPosition = 1  ' CenterOwner
    
    '--------------------------------------------------------------------------
    ' 1. DOCUMENT TYPE BANNER (Frame + Label)
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Frame.1", "fraDocTypeBanner", True)
    With ctrl
        .Left = 10
        .Top = 10
        .Width = 840
        .Height = 50
        .BackColor = RGB(4, 90, 55)  ' Theme green
        .BorderStyle = 0
    End With
    
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblBannerText", True)
    With ctrl
        .Left = 20
        .Top = 18
        .Width = 820
        .Height = 35
        .Caption = "-- S" & Chr(233) & "LECTIONNEZ LE TYPE DE DOCUMENT --"
        .ForeColor = RGB(255, 255, 255)
        .Font.Bold = True
        .Font.Size = 14
        .Font.Name = "Segoe UI"
        .TextAlign = fmTextAlignCenter
        .BackStyle = fmBackStyleTransparent
    End With
    
    '--------------------------------------------------------------------------
    ' 2. DOCUMENT TYPE DROPDOWN
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.ComboBox.1", "cmbTypeDoc", True)
    With ctrl
        .Left = 10
        .Top = 70
        .Width = 200
        .Height = 24
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Style = fmStyleDropDownList
    End With
    
    '--------------------------------------------------------------------------
    ' 3. SERVICE DROPDOWN
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.ComboBox.1", "cmbService", True)
    With ctrl
        .Left = 220
        .Top = 70
        .Width = 200
        .Height = 24
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Style = fmStyleDropDownList
    End With
    
    '--------------------------------------------------------------------------
    ' 4. CATEGORY FILTER
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.ComboBox.1", "cmbCategorie", True)
    With ctrl
        .Left = 430
        .Top = 70
        .Width = 150
        .Height = 24
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Style = fmStyleDropDownList
    End With
    
    '--------------------------------------------------------------------------
    ' 5. DATE FIELD
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.TextBox.1", "TxtDate", True)
    With ctrl
        .Left = 590
        .Top = 70
        .Width = 100
        .Height = 24
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .TextAlign = fmTextAlignCenter
        .BackColor = RGB(240, 240, 240)
        .Locked = True
    End With
    
    '--------------------------------------------------------------------------
    ' 6. AUTO-REF BUTTON (hidden - auto-generated on doc type change)
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnAutoRef", True)
    With ctrl
        .Left = 700
        .Top = 70
        .Width = 150
        .Height = 24
        .Caption = "Auto-Ref"
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Font.Bold = True
        .Visible = False  ' Ref auto-generated on doc type change
    End With
    
    '--------------------------------------------------------------------------
    ' 7. ARTICLE SELECTION
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.ComboBox.1", "cmbArticle", True)
    With ctrl
        .Left = 10
        .Top = 110
        .Width = 500
        .Height = 24
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Style = fmStyleDropDownCombo
    End With
    
    '--------------------------------------------------------------------------
    ' 8. STOCK INFO LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblStockInfo", True)
    With ctrl
        .Left = 520
        .Top = 110
        .Width = 330
        .Height = 24
        .Caption = "Code Article :  --"
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .ForeColor = RGB(100, 100, 100)
    End With
    
    '--------------------------------------------------------------------------
    ' 9. WILSON ALERT LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblWilsonAlert", True)
    With ctrl
        .Left = 10
        .Top = 140
        .Width = 840
        .Height = 20
        .Caption = ""
        .Font.Size = 8
        .Font.Name = "Segoe UI"
        .Font.Bold = True
        .ForeColor = RGB(4, 90, 55)
        .Visible = False
    End With
    
    '--------------------------------------------------------------------------
    ' 9a. SHORTCUT HINTS LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblShortcutHints", True)
    With ctrl
        .Left = 10
        .Top = 162
        .Width = 840
        .Height = 14
        .Caption = "Raccourcis: [Enter]=Ajouter   [Esc]=Annuler   [Ctrl+S]=Enregistrer"
        .Font.Size = 7
        .Font.Name = "Segoe UI"
        .ForeColor = RGB(150, 150, 150)
        .BackStyle = fmBackStyleTransparent
    End With

    '--------------------------------------------------------------------------
    ' 10. GRID HEADER LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblGridHeader", True)
    With ctrl
        .Left = 10
        .Top = 170
        .Width = 660
        .Height = 20
        .Caption = "  Code  |  D" & Chr(233) & "signation  |  Cat" & Chr(233) & "gorie  | Qte | Stock |  PU (DZD) |  Valeur"
        .Font.name = "Courier New"
        .Font.Size = 8
        .ForeColor = RGB(71, 71, 90)
        .BackStyle = fmBackStyleTransparent
    End With
    
    '--------------------------------------------------------------------------
    ' 11. TRANSACTION GRID (ListBox)
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.ListBox.1", "lstGrid", True)
    With ctrl
        .Left = 10
        .Top = 195
        .Width = 660
        .Height = 250
        .Font.name = "Courier New"
        .Font.Size = 9
        .BackColor = RGB(248, 248, 252)
        .ColumnCount = 7
        .ColumnHeads = False
        .ColumnWidths = "80;200;75;50;55;70;80"
        .MultiSelect = fmMultiSelectSingle
        .ListStyle = fmListStylePlain
    End With
    
    '--------------------------------------------------------------------------
    ' 12. QUANTITY FIELD
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.TextBox.1", "txtQuantite", True)
    With ctrl
        .Left = 630
        .Top = 195
        .Width = 100
        .Height = 24
        .Font.Size = 11
        .Font.Name = "Segoe UI"
        .TextAlign = fmTextAlignRight
        .BackColor = RGB(255, 255, 255)
    End With
    
    '--------------------------------------------------------------------------
    ' 13a. QUICK QTY BUTTONS
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnQty1", True)
    With ctrl
        .Left = 740
        .Top = 195
        .Width = 30
        .Height = 24
        .Caption = "+1"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With

    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnQty5", True)
    With ctrl
        .Left = 772
        .Top = 195
        .Width = 30
        .Height = 24
        .Caption = "+5"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With

    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnQty10", True)
    With ctrl
        .Left = 804
        .Top = 195
        .Width = 36
        .Height = 24
        .Caption = "+10"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With

    '--------------------------------------------------------------------------
    ' 14. UNIT PRICE FIELD
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.TextBox.1", "txtPrixUnitaire", True)
    With ctrl
        .Left = 630
        .Top = 230
        .Width = 100
        .Height = 24
        .Font.Size = 11
        .Font.Name = "Segoe UI"
        .TextAlign = fmTextAlignRight
        .Enabled = False
        .BackColor = RGB(235, 235, 235)
    End With
    
    '--------------------------------------------------------------------------
    ' 14. PU LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblPU", True)
    With ctrl
        .Left = 740
        .Top = 232
        .Width = 110
        .Height = 20
        .Caption = "PU -- CMUP auto"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
        .ForeColor = RGB(128, 128, 128)
    End With
    
    '--------------------------------------------------------------------------
    ' 15. DOCUMENT REFERENCE
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.TextBox.1", "txtRefDoc", True)
    With ctrl
        .Left = 630
        .Top = 265
        .Width = 220
        .Height = 24
        .Font.Size = 9
        .Font.name = "Courier New"
        .TextAlign = fmTextAlignCenter
        .BackColor = RGB(255, 252, 196)
        .Font.Bold = True
    End With
    
    '--------------------------------------------------------------------------
    ' 16. AJOUTER LIGNE BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnAjouterLigne", True)
    With ctrl
        .Left = 630
        .Top = 300
        .Width = 100
        .Height = 28
        .Caption = "+ Ajouter"
        .Font.Size = 9
        .Font.Name = "Segoe UI"
        .Font.Bold = True
        .BackColor = RGB(198, 239, 206)
    End With
    
    '--------------------------------------------------------------------------
    ' 17. SUPPRIMER LIGNE BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnSupprimerLigne", True)
    With ctrl
        .Left = 740
        .Top = 300
        .Width = 110
        .Height = 28
        .Caption = "- Supprimer"
        .Font.Size = 9
        .Font.Name = "Segoe UI"
    End With
    
    '--------------------------------------------------------------------------
    ' 18. TOTAL GENERAL LABEL
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblTotalGeneral", True)
    With ctrl
        .Left = 10
        .Top = 450
        .Width = 610
        .Height = 28
        .Caption = "TOTAL GENERAL :  0.00 DZD"
        .Font.Size = 12
        .Font.Name = "Segoe UI"
        .Font.Bold = True
        .ForeColor = RGB(5, 100, 60)
    End With
    
    '--------------------------------------------------------------------------
    ' 19. ENREGISTRER BUTTON (primary action)
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnEnregistrer", True)
    With ctrl
        .Left = 630
        .Top = 450
        .Width = 110
        .Height = 32
        .Caption = "Enregistrer"
        .Font.Size = 10
        .Font.Name = "Segoe UI"
        .Font.Bold = True
        .BackColor = RGB(0, 102, 204)
        .ForeColor = RGB(255, 255, 255)
    End With
    
    '--------------------------------------------------------------------------
    ' 20. ANNULER BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnAnnuler", True)
    With ctrl
        .Left = 750
        .Top = 450
        .Width = 100
        .Height = 32
        .Caption = "Annuler"
        .Font.Size = 10
        .Font.Name = "Segoe UI"
    End With
    
    '--------------------------------------------------------------------------
    ' 21. SYNC MASTER DATA BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnSyncMasterData", True)
    With ctrl
        .Left = 10
        .Top = 490
        .Width = 180
        .Height = 24
        .Caption = "Sync Donn" & Chr(233) & "es"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With
    
    '--------------------------------------------------------------------------
    ' 22. GENERATE REPORT BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnGenerateReport", True)
    With ctrl
        .Left = 200
        .Top = 490
        .Width = 150
        .Height = 24
        .Caption = "G" & Chr(233) & "n" & Chr(233) & "rer Rapport"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With
    
    '--------------------------------------------------------------------------
    ' 23. IMPRIMER BON BUTTON
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CommandButton.1", "btnImprimerBon", True)
    With ctrl
        .Left = 360
        .Top = 490
        .Width = 150
        .Height = 24
        .Caption = "Imprimer Bon"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
    End With
    
    '--------------------------------------------------------------------------
    ' 24. SYNC INTERNAL CHECKBOX
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.CheckBox.1", "chkSyncInternal", True)
    With ctrl
        .Left = 520
        .Top = 492
        .Width = 180
        .Height = 20
        .Caption = "Sync interne automatique"
        .Font.Size = 8
        .Font.Name = "Segoe UI"
        .Value = True
    End With
    
    '--------------------------------------------------------------------------
    ' 25. SEPARATOR LINE (using Label)
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblSeparator", True)
    With ctrl
        .Left = 10
        .Top = 485
        .Width = 840
        .Height = 2
        .BackStyle = fmBackStyleOpaque
        .BackColor = RGB(200, 200, 200)
    End With

    '--------------------------------------------------------------------------
    ' 26. STATUS BAR
    '--------------------------------------------------------------------------
    Set ctrl = Me.Controls.Add("Forms.Label.1", "lblStatusBar", True)
    With ctrl
        .Left = 10
        .Top = 525
        .Width = 840
        .Height = 20
        .Caption = "ERP Acad" & Chr(233) & "mie " & mod_Config.APP_VERSION & "  |  15 articles  |  Session: " & Format(Now, "DD/MM/YYYY HH:MM")
        .Font.Size = 8
        .Font.Name = "Segoe UI"
        .ForeColor = RGB(150, 150, 150)
        .BackStyle = fmBackStyleOpaque
        .BackColor = RGB(240, 240, 245)
        .TextAlign = fmTextAlignCenter
    End With

    Debug.Print "BuildUI complete - " & Me.Controls.count & " controls created"
    
    ' Apply professional theme
    Call ApplyProfessionalTheme
End Sub

'==============================================================================
' PROFESSIONAL THEME APPLICATION
'==============================================================================

Private Sub ApplyProfessionalTheme()
    On Error Resume Next
    
    ' Form-level styling
    Me.BackColor = RGB(245, 245, 250)
    
    ' Banner -- theme green (matching ERP dashboard)
    With Me.Controls("fraDocTypeBanner")
        .BackColor = RGB(4, 90, 55)
        .BorderStyle = 0
    End With
    
    With Me.Controls("lblBannerText")
        .Font.Name = "Segoe UI"
        .Font.Size = 14
        .Font.Bold = True
        .ForeColor = RGB(255, 255, 255)
    End With
    
    ' Text inputs
    ApplyTextboxTheme "TxtDate"
    ApplyTextboxTheme "txtRefDoc"
    ApplyTextboxTheme "txtQuantite"
    ApplyTextboxTheme "txtPrixUnitaire"
    
    ' Comboboxes
    ApplyComboboxTheme "cmbTypeDoc"
    ApplyComboboxTheme "cmbArticle"
    ApplyComboboxTheme "cmbService"
    ApplyComboboxTheme "cmbCategorie"
    
    ' Listbox
    With Me.Controls("lstGrid")
        .BorderStyle = 1
        .BorderColor = RGB(192, 192, 192)
        .BackColor = RGB(255, 255, 255)
        .Font.Name = "Courier New"
        .Font.Size = 9
    End With
    
    ' Labels
    ApplyLabelTheme "lblStockInfo", RGB(70, 70, 70), 9, False
    ApplyLabelTheme "lblWilsonAlert", RGB(40, 100, 40), 8, True
    ApplyLabelTheme "lblGridHeader", RGB(100, 100, 100), 8, False
    ApplyLabelTheme "lblTotalGeneral", RGB(5, 100, 60), 12, True
    ApplyLabelTheme "lblPU", RGB(128, 128, 128), 8, False
    
    ' Buttons
    With Me.Controls("btnEnregistrer")
        .BackColor = RGB(4, 90, 55)  ' Theme green
        .ForeColor = RGB(255, 255, 255)
        .Font.Name = "Segoe UI"
        .Font.Size = 11
        .Font.Bold = True
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnAjouterLigne")
        .BackColor = RGB(232, 245, 233)
        .ForeColor = RGB(4, 90, 55)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
        .Font.Bold = True
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnSupprimerLigne")
        .BackColor = RGB(252, 228, 236)
        .ForeColor = RGB(204, 0, 0)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
        .Font.Bold = True
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnAnnuler")
        .BackColor = RGB(245, 245, 250)
        .ForeColor = RGB(70, 70, 70)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnAutoRef")
        .BackColor = RGB(245, 245, 250)
        .ForeColor = RGB(4, 90, 55)
        .Font.Name = "Segoe UI"
        .Font.Size = 9
        .Font.Bold = True
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnImprimerBon")
        .BackColor = RGB(245, 245, 250)
        .ForeColor = RGB(0, 102, 204)
        .Font.Name = "Segoe UI"
        .Font.Size = 9
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnSyncMasterData")
        .BackColor = RGB(245, 245, 250)
        .ForeColor = RGB(70, 70, 70)
        .Font.Name = "Segoe UI"
        .Font.Size = 8
        .BorderStyle = 0
    End With
    
    With Me.Controls("btnGenerateReport")
        .BackColor = RGB(245, 245, 250)
        .ForeColor = RGB(70, 70, 70)
        .Font.Name = "Segoe UI"
        .Font.Size = 8
        .BorderStyle = 0
    End With
    
    ' Checkbox
    With Me.Controls("chkSyncInternal")
        .Font.Name = "Segoe UI"
        .Font.Size = 9
        .ForeColor = RGB(70, 70, 70)
    End With
    
    ' Quick qty buttons
    ApplySmallButtonTheme "btnQty1", RGB(232, 245, 233), RGB(40, 100, 40)
    ApplySmallButtonTheme "btnQty5", RGB(232, 245, 233), RGB(40, 100, 40)
    ApplySmallButtonTheme "btnQty10", RGB(232, 245, 233), RGB(40, 100, 40)
    
    ' Status bar
    With Me.Controls("lblStatusBar")
        .Font.Name = "Segoe UI"
        .Font.Size = 8
        .ForeColor = RGB(120, 120, 120)
        .BackColor = RGB(236, 236, 242)
    End With
    
    ' Shortcut hints
    With Me.Controls("lblShortcutHints")
        .Font.Name = "Segoe UI"
        .Font.Size = 7
        .ForeColor = RGB(160, 160, 160)
    End With
    
    ' Separator
    With Me.Controls("lblSeparator")
        .BackColor = RGB(224, 224, 224)
    End With
    
    Debug.Print "Professional theme applied"
End Sub

Private Sub ApplyTextboxTheme(ByVal ctrlName As String)
    On Error Resume Next
    With Me.Controls(ctrlName)
        .BorderStyle = 1
        .BorderColor = RGB(192, 192, 192)
        .BackColor = RGB(255, 255, 255)
        .ForeColor = RGB(70, 70, 70)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
    End With
End Sub

Private Sub ApplyComboboxTheme(ByVal ctrlName As String)
    On Error Resume Next
    With Me.Controls(ctrlName)
        .BorderStyle = 1
        .BorderColor = RGB(192, 192, 192)
        .BackColor = RGB(255, 255, 255)
        .ForeColor = RGB(70, 70, 70)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
    End With
End Sub

Private Sub ApplyLabelTheme(ByVal ctrlName As String, ByVal foreColor As Long, ByVal fontSize As Integer, ByVal isBold As Boolean)
    On Error Resume Next
    With Me.Controls(ctrlName)
        .ForeColor = foreColor
        .Font.Name = "Segoe UI"
        .Font.Size = fontSize
        .Font.Bold = isBold
    End With
End Sub

Private Sub ApplySmallButtonTheme(ByVal ctrlName As String, ByVal bgColor As Long, ByVal fgColor As Long)
    On Error Resume Next
    With Me.Controls(ctrlName)
        .BackColor = bgColor
        .ForeColor = fgColor
        .Font.Name = "Segoe UI"
        .Font.Size = 9
        .Font.Bold = True
        .BorderStyle = 0
    End With
End Sub


'==============================================================================
' EVENT HANDLERS (All delegate to controller)
'==============================================================================

'-- Document type changed
Private Sub cmbTypeDoc_Change()
    If Not m_Initialized Then Exit Sub
    Call mod_StockEntry_Logic.OnDocTypeChanged(m_State)
    Call ApplyStateToUI(m_State)
End Sub

'-- Article selection changed (with fuzzy search filtering)
Private Sub cmbArticle_Change()
    If Not m_Initialized Then Exit Sub
    If m_IsFiltering Then Exit Sub
    
    Dim cmb As MSForms.ComboBox
    Set cmb = Me.Controls("cmbArticle")
    
    ' If user selected from dropdown (ListIndex >= 0), process as normal selection
    If cmb.ListIndex >= 0 Then
        Call mod_StockEntry_Logic.OnArticleChanged(m_State)
        Call ApplyStateToUI(m_State)
        Exit Sub
    End If
    
    ' Otherwise, user is typing - filter the list
    Dim typed As String
    typed = Trim(cmb.text)
    
    ' Save full list on first keystroke
    If Len(typed) > 0 And Not m_IsFiltering Then
        Call mod_StockEntry_Logic.SaveFullArticleList(m_State, cmb)
    End If
    
    ' Filter and repopulate
    m_IsFiltering = True
    Call mod_StockEntry_Logic.FilterArticleList(m_State, cmb, typed)
    m_IsFiltering = False
    
    ' Show dropdown if filtering produced results
    If cmb.listCount > 0 And Len(typed) > 0 Then
        cmb.DropDown
    End If
End Sub


'-- Category filter changed
Private Sub cmbCategorie_Change()
    If Not m_Initialized Then Exit Sub
    Call mod_StockEntry_Logic.OnCategoryChanged(m_State)
    Call ApplyStateToUI(m_State)
End Sub

'-- Quantity field changed (live validation)
Private Sub txtQuantite_Change()
    If Not m_Initialized Then Exit Sub
    
    Dim tb As MSForms.TextBox
    Set tb = Me.Controls("txtQuantite")
    
    Dim cleaned As String
    cleaned = mod_Utilities.CleanNumericString(tb.Value)
    
    If tb.Value <> cleaned Then
        tb.Value = cleaned
        tb.SelStart = Len(tb.Value)
    End If
    
    Call mod_StockEntry_Logic.OnQuantityChanged(m_State)
    Call ApplyStateToUI(m_State)
End Sub

Private Sub txtPrixUnitaire_Change()
    If Not m_Initialized Then Exit Sub
    
    Dim tb As MSForms.TextBox
    Set tb = Me.Controls("txtPrixUnitaire")
    
    Dim cleaned As String
    cleaned = mod_Utilities.CleanNumericString(tb.Value)
    
    If tb.Value <> cleaned Then
        tb.Value = cleaned
        tb.SelStart = Len(tb.Value)
    End If
    
    ' Update state
    m_State.unitPrice = cleaned
    
    ' Update state for visual feedback
    If Len(cleaned) > 0 And IsNumeric(cleaned) And CDbl(cleaned) > 0 Then
        m_State.PrixUnitaireBackColor = RGB(220, 255, 220)
    Else
        m_State.PrixUnitaireBackColor = RGB(255, 252, 196)
    End If
    
    Call ApplyStateToUI(m_State)
End Sub


'-- Auto-generate reference
Private Sub btnAutoRef_Click()
    Call mod_StockEntry_Logic.GenerateAutoRef(m_State)
End Sub

'-- Add line to grid
Private Sub btnAjouterLigne_Click()
    Call mod_StockEntry_Logic.AddLineToGrid(m_State)
End Sub

'-- Remove line from grid
Private Sub btnSupprimerLigne_Click()
    Call mod_StockEntry_Logic.RemoveLineFromGrid(m_State)
End Sub

'-- Enregistrer (commit transaction)
Private Sub btnEnregistrer_Click()
    Call mod_StockEntry_Logic.CommitTransaction(m_State)
End Sub

'-- Quick qty buttons
Private Sub btnQty1_Click()
    Call SetQty(1)
End Sub

Private Sub btnQty5_Click()
    Call SetQty(5)
End Sub

Private Sub btnQty10_Click()
    Call SetQty(10)
End Sub

Private Sub SetQty(ByVal qty As Long)
    Me.Controls("txtQuantite").Value = CStr(qty)
    Call mod_StockEntry_Logic.OnQuantityChanged(m_State)
    Me.Controls("txtQuantite").SetFocus
End Sub

'-- Cancel / Annuler
Private Sub btnAnnuler_Click()
    Call mod_StockEntry_Logic.CancelTransaction(m_State)
End Sub

'-- Sync master data
Private Sub btnSyncMasterData_Click()
    On Error Resume Next
    Call mod_SyncBridge.SyncMetricsFromLedger
    If Err.Number = 0 Then
        MsgBox "Synchronisation r�ussie.", vbInformation, "Sync Master"
    Else
        MsgBox "Erreur: " & Err.Description, vbCritical, "Sync Error"
    End If
    On Error GoTo 0
End Sub

'-- Generate report
Private Sub btnGenerateReport_Click()
    Call mod_Procurement.GenerateOrderReport
End Sub

'-- Print bon
Private Sub btnImprimerBon_Click()
    Dim docRef As String
    docRef = Trim(Me.Controls("txtRefDoc").Value)
    If Len(docRef) > 0 Then
        Call mod_ExportEngine.ExportTransactionToPDF(docRef)
    Else
        MsgBox "Veuillez g�n�rer une r�f�rence d'abord.", vbExclamation
    End If
End Sub


'==============================================================================
' KEYBOARD SHORTCUTS
'==============================================================================

'==============================================================================
' FOCUS EVENTS - highlight active input
'==============================================================================
Private Sub TxtDate_Enter()
    Call mod_ThemingEngine.ApplyInputFocus(Me.Controls("TxtDate"))
End Sub
Private Sub TxtDate_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    Call mod_ThemingEngine.ApplyInputBlur(Me.Controls("TxtDate"))
End Sub
Private Sub txtRefDoc_Enter()
    Call mod_ThemingEngine.ApplyInputFocus(Me.Controls("txtRefDoc"))
End Sub
Private Sub txtRefDoc_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    Call mod_ThemingEngine.ApplyInputBlur(Me.Controls("txtRefDoc"))
End Sub
Private Sub txtRefDoc_Change()
    If Not m_Initialized Then Exit Sub
    
    Dim tb As MSForms.TextBox
    Set tb = Me.Controls("txtRefDoc")
    
    Call mod_StockEntry_Logic.FormatRefDoc(m_State, tb)
    
    ' Update state for live format hint
    If Len(tb.Value) = 13 Then
        m_State.RefDocBackColor = RGB(220, 255, 220)
    ElseIf Len(tb.Value) > 3 Then
        m_State.RefDocBackColor = RGB(255, 252, 196)
    Else
        m_State.RefDocBackColor = RGB(255, 252, 196)
    End If
    
    Call ApplyStateToUI(m_State)
End Sub

' ================================================================================
' MouseMove hover effect for btnAjouterLigne
' Added: Session 22 - Sub declaration was missing, leaving body code orphan
' between L937 (close of txtRefDoc_Change) and L939 (orphan End Sub).
' Caused: "Only comments may appear after End Sub" at compile.
' Pattern matches adjacent btnXxx_MouseMove handlers below.
' ================================================================================
Private Sub btnAjouterLigne_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnAjouterLigne"), RGB(200, 230, 200), RGB(20, 90, 40)
End Sub

Private Sub btnSupprimerLigne_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnSupprimerLigne"), RGB(255, 200, 200), RGB(160, 20, 20)
End Sub

Private Sub btnAnnuler_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnAnnuler"), RGB(220, 220, 225), RGB(30, 30, 30)
End Sub

Private Sub btnAutoRef_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnAutoRef"), RGB(220, 220, 225), RGB(30, 30, 30)
End Sub

Private Sub btnImprimerBon_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnImprimerBon"), RGB(220, 220, 225), RGB(30, 30, 30)
End Sub

Private Sub btnQty1_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnQty1"), RGB(200, 230, 200), RGB(20, 90, 40)
End Sub

Private Sub btnQty5_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnQty5"), RGB(200, 230, 200), RGB(20, 90, 40)
End Sub

Private Sub btnQty10_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    HoverButton Me.Controls("btnQty10"), RGB(200, 230, 200), RGB(20, 90, 40)
End Sub

Private Sub UserForm_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    ResetButtonHover Me.Controls("btnEnregistrer"), RGB(0, 102, 204), RGB(255, 255, 255)
    ResetButtonHover Me.Controls("btnAjouterLigne"), RGB(232, 245, 233), RGB(32, 120, 60)
    ResetButtonHover Me.Controls("btnSupprimerLigne"), RGB(252, 228, 236), RGB(192, 32, 32)
    ResetButtonHover Me.Controls("btnAnnuler"), RGB(245, 245, 250), RGB(51, 51, 51)
    ResetButtonHover Me.Controls("btnAutoRef"), RGB(245, 245, 250), RGB(51, 51, 51)
    ResetButtonHover Me.Controls("btnImprimerBon"), RGB(245, 245, 250), RGB(51, 51, 51)
    ResetButtonHover Me.Controls("btnQty1"), RGB(232, 245, 233), RGB(40, 100, 40)
    ResetButtonHover Me.Controls("btnQty5"), RGB(232, 245, 233), RGB(40, 100, 40)
    ResetButtonHover Me.Controls("btnQty10"), RGB(232, 245, 233), RGB(40, 100, 40)
End Sub

Private Sub HoverButton(ByRef ctrl As Object, ByVal hoverBg As Long, ByVal hoverFg As Long)
    ctrl.BackColor = hoverBg
    ctrl.ForeColor = hoverFg
End Sub

Private Sub ResetButtonHover(ByRef ctrl As Object, ByVal origBg As Long, ByVal origFg As Long)
    ctrl.BackColor = origBg
    ctrl.ForeColor = origFg
End Sub

Public Sub ApplyStateToUI(ByRef state As FormState)
    On Error Resume Next
    
    ' 1. Banner
    With Me.Controls("lblBannerText")
        .Caption = state.BannerText
        .BackColor = state.BannerColor
    End With
    
    ' 2. Wilson Alert
    With Me.Controls("lblWilsonAlert")
        .Visible = state.WilsonAlertVisible
        If state.WilsonAlertVisible Then
            .Caption = state.WilsonAlertText
            .ForeColor = RGB(4, 90, 55)
        End If
    End With
    
    ' 3. Stock Info
    With Me.Controls("lblStockInfo")
        .Caption = state.StockInfoText
        .ForeColor = state.StockInfoColor
    End With
    
    ' 4. Total General
    Me.Controls("lblTotalGeneral").Caption = state.TotalGeneralText
    
    ' 5. Inputs
    Me.Controls("TxtDate").Value = state.TransDate
    Me.Controls("txtRefDoc").Value = state.docRef
    Me.Controls("txtRefDoc").BackColor = state.RefDocBackColor
    Me.Controls("txtQuantite").Value = state.qty
    Me.Controls("txtQuantite").BackColor = state.QtyBackColor
    Me.Controls("txtPrixUnitaire").Value = state.unitPrice
    Me.Controls("txtPrixUnitaire").BackColor = state.PrixUnitaireBackColor
    Me.Controls("txtPrixUnitaire").Enabled = state.PrixUnitaireEnabled
    
    ' 6. Dropdowns
    Me.Controls("cmbTypeDoc").Value = state.docType
    Me.Controls("cmbService").Value = state.Service
    Me.Controls("cmbCategorie").Value = state.ArticleCat
    Me.Controls("cmbArticle").Value = state.ArticleCode
    
    ' 7. Grid (Rebuild from GridData)
    Dim lst As Object
    Set lst = Me.Controls("lstGrid")
    lst.Clear
    If Len(state.GridData) > 0 Then
        Dim gridLines() As String
        gridLines = Split(state.GridData, ";")
        Dim i As Integer, parts() As String
        For i = 0 To UBound(gridLines)
            If Len(Trim(gridLines(i))) > 0 Then
                parts = Split(gridLines(i), "|")
                If UBound(parts) >= 5 Then
                    lst.AddItem parts(0)
                    lst.List(lst.ListCount - 1, 1) = parts(1)
                    lst.List(lst.ListCount - 1, 2) = parts(2)
                    lst.List(lst.ListCount - 1, 3) = parts(3)
                    lst.List(lst.ListCount - 1, 4) = parts(4)
                    lst.List(lst.ListCount - 1, 5) = parts(5)
                End If
            End If
        Next i
    End If
    
    On Error GoTo 0
End Sub


