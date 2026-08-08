Attribute VB_Name = "mod_AuditTrail"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

' Records a system event to the audit trail.
Public Sub LogTransaction(ByVal ActionType As String, ByVal RefNum As String)
    Dim wsAudit As Worksheet
    Dim nextRow As Long
    Dim userName As String
    
    On Error GoTo ErrorHandler

    On Error Resume Next
    Set wsAudit = ThisWorkbook.Sheets("AUDIT_LOG")
    On Error GoTo ErrorHandler
    
    If wsAudit Is Nothing Then
        Err.Raise vbObjectError + 513, "mod_AuditTrail", "Critical Error: AUDIT_LOG sheet not found."
    End If

    userName = mod_SharedEnvironment.GetCurrentUserName
    If Len(userName) = 0 Then userName = Environ("USERNAME")  ' Fallback if session not initialized
    wsAudit.Unprotect Password:=mod_Config.MASTER_PWD

    nextRow = wsAudit.Cells(wsAudit.Rows.count, 1).End(xlUp).Row + 1

    Dim ts As Date: ts = Now()

    With wsAudit
        .Cells(nextRow, 1).Value = ts
        .Cells(nextRow, 2).Value = userName
        .Cells(nextRow, 3).Value = ActionType
        .Cells(nextRow, 4).Value = RefNum
        .Cells(nextRow, 1).NumberFormat = "yyyy-mm-dd HH:mm:ss"
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
        Dim wsAudit As Worksheet: Set wsAudit = ThisWorkbook.Sheets("AUDIT_LOG")
        wsAudit.Unprotect Password:=mod_Config.MASTER_PWD
        wsAudit.Rows("2:" & wsAudit.Rows.count).ClearContents
        wsAudit.Protect Password:=mod_Config.MASTER_PWD
        MsgBox "Audit logs cleared successfully.", vbInformation
    End If
End Sub

' Returns True if AUDIT_LOG sheet exists and is accessible
Public Function AuditLogInitialized() As Boolean
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("AUDIT_LOG")
    AuditLogInitialized = Not (ws Is Nothing)
    On Error GoTo 0
End Function

' Standard audit log entry with full context
Public Sub LogAction(ByVal category As String, ByVal details As String, Optional ByVal moduleName As String = "", Optional ByVal procName As String = "")
    On Error Resume Next
    Dim wsAudit As Worksheet
    Set wsAudit = ThisWorkbook.Sheets("AUDIT_LOG")
    If wsAudit Is Nothing Then Exit Sub

    Dim nextRow As Long
    wsAudit.Unprotect Password:=mod_Config.MASTER_PWD
    nextRow = wsAudit.Cells(wsAudit.Rows.count, 1).End(xlUp).Row + 1

    Dim userName As String
    userName = mod_SharedEnvironment.GetCurrentUserName
    If Len(userName) = 0 Then userName = Environ("USERNAME")

    Dim ts As Date: ts = Now()

    With wsAudit
        .Cells(nextRow, 1).Value = ts
        .Cells(nextRow, 2).Value = userName
        .Cells(nextRow, 3).Value = IIf(moduleName <> "", moduleName & "." & procName, category)
        .Cells(nextRow, 4).Value = details
        .Cells(nextRow, 1).NumberFormat = "yyyy-mm-dd HH:mm:ss"
    End With

    wsAudit.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    On Error GoTo 0
End Sub

' ================================================================================
' TASK CALLBACK STUB - Added Session 22
' Referenced by mod_TaskOrchestrator.DefineTask("BACKUP-CLEAN", "mod_AuditTrail.CleanOldLogs")
' as a runtime Application.Run callback. Wrapper that delegates to existing
' ClearAuditLogs to keep the orchestrator task working.
' ================================================================================
Public Sub CleanOldLogs()
    Call ClearAuditLogs
End Sub
