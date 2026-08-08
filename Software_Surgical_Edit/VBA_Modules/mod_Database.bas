Attribute VB_Name = "mod_Database"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Public Sub SecureWriteTransaction(docDate As Date, _
                                  typeSign As String, _
                                  refDoc As String, _
                                  codeArticle As String, _
                                  designation As String, _
                                  quantity As Long, _
                                  unitPrice As Double, _
                                  lineValue As Double, _
                                  thirdParty As String, _
                                  Optional notes As String)
    Dim ws As Worksheet
    Dim nextRow As Long
    
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    
    nextRow = ws.Cells(ws.Rows.count, COL_MOUV_DATE).End(xlUp).Row + 1
    
    ws.Cells(nextRow, COL_MOUV_DATE).Value = docDate
    ws.Cells(nextRow, COL_MOUV_CODE_ARTICLE).Value = codeArticle
    ws.Cells(nextRow, COL_MOUV_DESIGNATION).Value = designation
    ws.Cells(nextRow, COL_MOUV_TYPE).Value = typeSign
    ws.Cells(nextRow, COL_MOUV_QTE).Value = quantity
    ws.Cells(nextRow, COL_MOUV_VALEUR).Value = lineValue
    ws.Cells(nextRow, COL_MOUV_REF_DOC).Value = refDoc
    ws.Cells(nextRow, COL_MOUV_PU).Value = unitPrice
    ws.Cells(nextRow, COL_MOUV_THIRD_PARTY).Value = thirdParty
    ws.Cells(nextRow, 12).Value = notes
    
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
CleanUp:
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    Exit Sub
    
ErrorHandler:
    On Error Resume Next
    If Not ws Is Nothing Then ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    Resume CleanUp
End Sub
