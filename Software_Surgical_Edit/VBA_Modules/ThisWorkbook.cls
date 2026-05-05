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
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    ' 1. Verify critical sheets exist
    If Not SheetExists(mod_Config.SHEET_ARTICLES) Then
        MsgBox "Feuille " & mod_Config.SHEET_ARTICLES & " introuvable.", vbCritical, "ERP v13.2"
        GoTo Cleanup
    End If
    If Not SheetExists(mod_Config.SHEET_MOUVEMENTS) Then
        MsgBox "Feuille " & mod_Config.SHEET_MOUVEMENTS & " introuvable.", vbCritical, "ERP v13.2"
        GoTo Cleanup
    End If
    
    ' 2. Verify mod_Config constants (ground truth)
    Dim testROP As Double
    testROP = mod_StockCalculations.CalculateROP(1546, 2, 200)
    If Abs(testROP - 205.6) > 0.1 Then
        MsgBox "ALERTE: Constante ROP incorrecte!", vbCritical, "ERP v13.2"
    End If
    
    ' 3. Sync metrics from ledger (CMUP, ABC)
    On Error Resume Next
    Call mod_SyncBridge.SyncMetricsFromLedger
    On Error GoTo InitError
    
    ' 4. Restore MOUVEMENTS headers if corrupted
    On Error Resume Next
    Call mod_Utilities.RestoreMouvementsHeaders
    On Error GoTo InitError
    
    ' 5. Initialize approval workflow columns
    On Error Resume Next
    Call mod_ApprovalWorkflow.InitializeMouvementsColumns
    On Error GoTo InitError
    
    ' 6. Welcome message
    Dim welcomeMsg As String
    welcomeMsg = "ERP Académie " & mod_Config.VERSION & vbCrLf & _
                 "Direction de l'Éducation — El Bayadh" & vbCrLf & vbCrLf & _
                 "D=" & "1,546  |  ROP=" & "205.6  |  Q*=" & "176  |  SS=" & "200"
    MsgBox welcomeMsg, vbInformation, mod_Config.SYS_TITLE
    
Cleanup:
    Application.EnableEvents = True
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Exit Sub
    
InitError:
    MsgBox "Erreur d'initialisation: " & Err.Description, vbCritical, "ERP v13.2"
    GoTo Cleanup
End Sub

Private Function SheetExists(sheetName As String) As Boolean
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(sheetName)
    On Error GoTo 0
    SheetExists = (ws Is Not Nothing)
End Function
