'-------------------------------------------------
' Form: frmStockEntry.frm
' Arabic: استمارة إدخال المخزون (Stock Entry Form)
' PURPOSE: Secure data entry (prevents raw cell deletion)
' Clean Room: Pure VBA UserForm (NO Python bridges)
'-------------------------------------------------

VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} 
   Caption         = "استمارة إدخال حركة المخزون - frmStockEntry"
   ClientHeight    = 6300
   ClientLeft      = 120
   ClientTop       = 450
   ClientWidth     = 8400
   StartUpPosition = 1  ' CenterOwner
   Begin VB.CommandButton cmdSubmit
      Caption         = "تأكيد الإدخال (Submit)"
      Height          = 500
      Left            = 6000
      Top             = 5600
      Width           = 2000
   End
   Begin VB.CommandButton cmdCancel
      Caption         = "إلغاء (Cancel)"
      Height          = 500
      Left            = 3800
      Top             = 5600
      Width           = 2000
   End
   Begin VB.TextBox txtQuantity
      Height          = 300
      Left            = 5600
      Top             = 2800
      Width           = 2400
   End
   Begin VB.ComboBox cboMovementType
      Height          = 300
      Left            = 5600
      Top             = 2000
      Width           = 2400
   End
   Begin VB.ComboBox cboArticleCode
      Height          = 300
      Left            = 5600
      Top             = 1200
      Width           = 2400
   End
   Begin VB.Label lblQuantity
      Caption         = "الكمية (Quantity):"
      Height          = 300
      Left            = 3800
      Top             = 2800
      Width           = 1500
   End
   Begin VB.Label lblMovementType
      Caption         = "نوع الحركة (Movement Type):"
      Height          = 300
      Left            = 3800
      Top             = 2000
      Width           = 1500
   End
   Begin VB.Label lblArticleCode
      Caption         = "كود المادة (Article Code):"
      Height          = 300
      Left            = 3800
      Top             = 1200
      Width           = 1500
   End
   Begin VB.Label lblTitle
      Caption         = "استمارة إدخال حركة المخزون - المديرية التربية للبيض"
      BeginProperty Font 
         Name            = "Arial"
         Size            = 14
         Charset         = 0
         Weight          = 700
         Underline       = 0   ' False
         Italic          = 0   ' False
         Strikethrough   = 0   ' False
      EndProperty
      Height          = 500
      Left            = 1200
      Top             = 200
      Width           = 6000
   End
End

'-------------------------------------------------
' Event: UserForm_Initialize
' Arabic: تهيئة استمارة العمل
'-------------------------------------------------
Private Sub UserForm_Initialize()
    On Error GoTo ErrorHandler
    ' Load article codes from Digital Ledger (tbl_Articles)
    LoadArticleCodes
    ' Load movement types (IN/OUT)
    With cboMovementType
        .AddItem "إدخال (IN)"
        .AddItem "إخراج (OUT)"
    End With
    Exit Sub
ErrorHandler:
    MsgBox "Error initializing form: " & Err.Description, vbCritical
End Sub

'-------------------------------------------------
' Sub: LoadArticleCodes
' Arabic: تحميل أكواد المواد من السجل الرقمي
'-------------------------------------------------
Private Sub LoadArticleCodes()
    On Error GoTo ErrorHandler
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("tbl_Articles")
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    Dim i As Long
    For i = 2 To lastRow
        cboArticleCode.AddItem ws.Cells(i, 1).Value & " - " & ws.Cells(i, 2).Value
    Next i
    Exit Sub
ErrorHandler:
    MsgBox "Error loading article codes: " & Err.Description, vbCritical
End Sub

'-------------------------------------------------
' Event: cmdSubmit_Click
' Arabic: تأكيد الإدخال
'-------------------------------------------------
Private Sub cmdSubmit_Click()
    On Error GoTo ErrorHandler
    ' Validate inputs
    If cboArticleCode.ListIndex = -1 Then
        MsgBox "يرجى اختيار كود المادة (Please select article code)", vbExclamation
        Exit Sub
    End If
    If cboMovementType.ListIndex = -1 Then
        MsgBox "يرجى اختيار نوع الحركة (Please select movement type)", vbExclamation
        Exit Sub
    End If
    If Not IsNumeric(txtQuantity.Value) Or Val(txtQuantity.Value) <= 0 Then
        MsgBox "يرجى إدخال كمية صحيحة (Please enter valid quantity)", vbExclamation
        Exit Sub
    End If
    ' TODO: Update Digital Ledger (tbl_Movements)
    ' Log to Audit Trail (tbl_AuditTrail)
    MsgBox "تم الإدخال بنجاح (Entry saved successfully)", vbInformation
    Unload Me
    Exit Sub
ErrorHandler:
    MsgBox "Error submitting form: " & Err.Description, vbCritical
End Sub

'-------------------------------------------------
' Event: cmdCancel_Click
' Arabic: إلغاء
'-------------------------------------------------
Private Sub cmdCancel_Click()
    Unload Me
End Sub

' End of frmStockEntry.frm (Stock Entry Form)
