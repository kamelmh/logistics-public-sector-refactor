Attribute VB_Name = "ThisWorkbook"
'==============================================================================
' ThisWorkbook.cls — ERP Académie v13.2
' Workbook-level event handlers
' Created: 2026-05-06 (W010: Add Workbook_Open event handler)
'==============================================================================
Option Explicit

Private Sub Workbook_Open()
    On Error GoTo InitError
    
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    
    ' 1. Welcome message
    Dim welcomeMsg As String
    Dim versionStr As String
    Dim titleStr As String
    
    On Error Resume Next
    versionStr = mod_Config.VERSION
    titleStr = mod_Config.SYS_TITLE
    On Error GoTo InitError
    
    If versionStr = "" Then versionStr = "v13.2"
    If titleStr = "" Then titleStr = "ERP Académie"
    
    welcomeMsg = "ERP Académie " & versionStr & vbCrLf & _
                 "Direction de l'Éducation — El Bayadh" & vbCrLf & vbCrLf & _
                 "D=1,546  |  ROP=205.6  |  Q*=176  |  SS=200"
    MsgBox welcomeMsg, vbInformation, titleStr
    
    ' 2. Sync metrics from ledger
    On Error Resume Next
    Call mod_SyncBridge.SyncMetricsFromLedger
    
    ' 3. Restore MOUVEMENTS headers if corrupted
    Call mod_Utilities.RestoreMouvementsHeaders
    
    ' 4. Initialize approval workflow columns
    Call mod_ApprovalWorkflow.InitializeMouvementsColumns
    On Error GoTo InitError
    
Cleanup:
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    Exit Sub
    
InitError:
    MsgBox "Erreur d'initialisation: " & Err.Description, vbCritical, titleStr
    GoTo Cleanup
End Sub
