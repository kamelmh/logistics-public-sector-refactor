Attribute VB_Name = "MAIN_MACROS"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Public Sub AjouterMouvement()
    On Error GoTo ErrorHandler
    Dim frmName As String
    frmName = "frmStockEntry"

    If MainMacrosFormExists(frmName) Then
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

Public Sub RunGenerateDemoData()
    On Error Resume Next
    Call mod_DemoData.GenerateDemoData
    If Err.Number <> 0 Then
        MsgBox "Erreur: " & Err.Description, vbCritical, "ACADEMIX v13.2"
    End If
    On Error GoTo 0
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

Private Function MainMacrosFormExists(ByVal formName As String) As Boolean
    Dim vbComp As Object
    On Error Resume Next
    Set vbComp = ThisWorkbook.VBProject.VBComponents(formName)
    MainMacrosFormExists = Not (vbComp Is Nothing)
    On Error GoTo 0
End Function
