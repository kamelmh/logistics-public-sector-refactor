Attribute VB_Name = "MAIN_MACROS"
'==============================================================================
' MAIN_MACROS.bas — ERP Académie v13.2
' Entry points / macro shortcuts
'==============================================================================
Option Explicit

Public Sub AjouterMouvement()
    On Error GoTo ErrorHandler
    Dim frmName As String
    frmName = "frmStockEntry"

    If FormExists(frmName) Then
        VBA.UserForms.Add(frmName).Show
    Else
        MsgBox "Erreur: Le formulaire '" & frmName & "' n'existe pas." & vbCrLf & _
               "Veuillez vérifier que le fichier n'est pas corrompu.", _
               vbCritical, "ERP Académie v13.2"
    End If
    Exit Sub

ErrorHandler:
    MsgBox "Erreur lors de l'ouverture du formulaire: " & Err.Description, _
           vbCritical, "ERP Académie v13.2"
End Sub

Public Sub ShowMainMenu()
    On Error GoTo ErrorHandler
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_ACCUEIL)
    If Not ws Is Nothing Then
        ws.Activate
    Else
        MsgBox "Erreur: Feuille d'accueil introuvable.", vbCritical, "ERP Académie v13.2"
    End If
    Exit Sub

ErrorHandler:
    MsgBox "Erreur: " & Err.Description, vbCritical, "ERP Académie v13.2"
End Sub

Private Function FormExists(ByVal formName As String) As Boolean
    Dim vbComp As Object
    On Error Resume Next
    Set vbComp = ThisWorkbook.VBProject.VBComponents(formName)
    FormExists = Not (vbComp Is Nothing)
    On Error GoTo 0
End Function
