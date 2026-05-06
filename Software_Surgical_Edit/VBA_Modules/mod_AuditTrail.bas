Attribute VB_Name = "mod_AuditTrail"
'=======================================================================================
' MODULE: mod_AuditTrail.bas
' PROJECT: ERP Acad" & Chr(233) & "mie v13
' DESCRIPTION: Handles secure, immutable logging of all system transactions.
'=======================================================================================
Option Explicit

' Records a system event to the audit trail.
Public Sub LogTransaction(ByVal ActionType As String, ByVal RefNum As String)
    Dim wsAudit As Worksheet
    Dim nextRow As Long
    Dim userName As String
    
    On Error GoTo ErrorHandler

    On Error Resume Next
    Set wsAudit = ThisWorkbook.Sheets(mod_Config.SHEET_AUDIT_LOG)
    On Error GoTo ErrorHandler
    
    If wsAudit Is Nothing Then
        Err.Raise vbObjectError + 513, "mod_AuditTrail", "Critical Error: AUDIT_LOG sheet not found."
    End If

    userName = Environ("USERNAME")
    wsAudit.Unprotect Password:=mod_Config.MASTER_PWD

    nextRow = wsAudit.Cells(wsAudit.Rows.Count, 1).End(xlUp).Row + 1

    With wsAudit
        .Cells(nextRow, 1).Value = Date
        .Cells(nextRow, 2).Value = Format(Now, "HH:mm:ss")
        .Cells(nextRow, 3).Value = userName
        .Cells(nextRow, 4).Value = ActionType
        .Cells(nextRow, 5).Value = RefNum
        .Cells(nextRow, 1).NumberFormat = "yyyy-mm-dd"
        .Cells(nextRow, 2).NumberFormat = "HH:mm:ss"
    End With

    wsAudit.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True

CleanExit:
    Exit Sub

ErrorHandler:
    If Not wsAudit Is Nothing Then wsAudit.Protect Password:=mod_Config.MASTER_PWD
    MsgBox "Audit Logging Failed: " & Err.Description, vbCritical, mod_Config.SYS_TITLE
    Resume CleanExit
End Sub

' Utility to clear logs (Administrative use only).
Public Sub ClearAuditLogs()
    If MsgBox("WARNING: This will permanently delete the audit trail. Proceed?", vbYesNo + vbCritical, "Admin Access") = vbYes Then
        Dim wsAudit As Worksheet: Set wsAudit = ThisWorkbook.Sheets(mod_Config.SHEET_AUDIT_LOG)
        wsAudit.Unprotect Password:=mod_Config.MASTER_PWD
        wsAudit.Rows("2:" & wsAudit.Rows.Count).ClearContents
        wsAudit.Protect Password:=mod_Config.MASTER_PWD
        MsgBox "Audit logs cleared successfully.", vbInformation
    End If
End Sub
