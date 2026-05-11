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
    
    ' 1. Check for concurrent workbook access
    On Error Resume Next
    Call mod_SharedEnvironment.CheckWorkbookAccess
    
    ' 2. Initialize user session (role-based tracking)
    Call mod_SharedEnvironment.InitUserSession
    
    ' 3. Check for incomplete transactions (crash recovery)
    Call mod_TransactionSafety.CheckCrashRecovery
    On Error GoTo InitError
    
    ' 4. Welcome message (skip when opened via COM automation)
    Dim welcomeMsg As String
    Dim versionStr As String
    Dim titleStr As String
    
    On Error Resume Next
    versionStr = mod_Config.APP_VERSION
    titleStr = mod_Config.SYS_TITLE
    On Error GoTo InitError
    
    If versionStr = "" Then versionStr = "v13.2"
    If titleStr = "" Then titleStr = "ERP Académie"
    
    If Application.UserControl Then
        welcomeMsg = "ERP Académie " & versionStr & vbCrLf & _
                     "Direction de l'Éducation — El Bayadh" & vbCrLf & vbCrLf & _
                     "D=1,546  |  ROP=205.6  |  Q*=176  |  SS=200"
        MsgBox welcomeMsg, vbInformation, titleStr
    End If
    
    ' 5. Sync metrics from ledger (skip when opened via COM automation)
    If Application.UserControl Then
        On Error Resume Next
        Call mod_SyncBridge.SyncMetricsFromLedger
    End If
    
    ' 6. Restore MOUVEMENTS headers if corrupted
    Call mod_Utilities.RestoreMouvementsHeaders(silent:=True)
    
    ' 7. Initialize approval workflow columns
    Call mod_ApprovalWorkflow.InitializeMouvementsColumns
    
    ' 8. Auto-backup on open (timestamped copy)
    On Error Resume Next
    Call mod_SharedEnvironment.AutoBackup
    On Error GoTo InitError

    ' 9. Setup ACCUEIL navigation sheet
    If Application.UserControl Then
        On Error Resume Next
        Call mod_UI_Setup.SetupAccueilSheet
        On Error GoTo InitError
    End If
    
Cleanup:
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    Exit Sub
    
InitError:
    MsgBox "Erreur d'initialisation: " & Err.Description, vbCritical, titleStr
    GoTo Cleanup
End Sub
