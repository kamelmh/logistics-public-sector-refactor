
Attribute VB_Name = "mod_UI_Setup"
'=======================================================================================
' MODULE: mod_UI_Setup.bas
' PROJECT: ERP Academie v13.2
' PURPOSE: Programmatically creates UI elements on the Dashboard sheet
'=======================================================================================
Option Explicit

Public Sub ShowSystemLog()
    frmSystemLog.Show
End Sub

'--------------------------------------------------------------------------------------
' MAIN ENTRY POINT: SetupDashboardButtons
' Creates professional buttons on the DASHBOARD sheet linked to procurement and sync.
'--------------------------------------------------------------------------------------
Public Sub SetupDashboardButtons()
    Dim ws As Worksheet
    Dim btnProc As Button
    Dim btnSync As Button
    
    ' 1. Get or Create Dashboard Sheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("DASHBOARD")
    On Error GoTo 0
    
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(Before:=ThisWorkbook.Sheets(1))
        ws.Name = "DASHBOARD"
    End If
    
    ' 2. Clear existing buttons to avoid duplicates
    ws.Buttons.Delete
    
    ' 3. Styling the Dashboard surface
    ws.Cells.Interior.Color = RGB(245, 245, 245)
    ws.Columns("A:Z").ColumnWidth = 12
    
    ' 4. Create "GENERATE PROCUREMENT REPORT" Button
    ' Position: Top Left (Row 5, Col 3)
    Set btnProc = ws.Buttons.Add(150, 50, 200, 50)
    With btnProc
        .Caption = "📦 GENERATE ORDER REPORT"
        .OnAction = "mod_Procurement.GenerateOrderReport"
        .Font.Bold = True
    End With
    
    ' 5. Create "SYNC MASTER DATA" Button
    ' Position: Below report button
    Set btnSync = ws.Buttons.Add(150, 110, 200, 50)
    With btnSync
        .Caption = "🔄 SYNC MASTER DATA"
        .OnAction = "mod_SyncBridge.SyncMetricsFromLedger"
        .Font.Bold = True
    End With
    
    ' 6. Create "RESTORE LATEST BACKUP" Button
    ' Position: Below sync button
    Dim btnRestore As Button
    Set btnRestore = ws.Buttons.Add(150, 170, 200, 50)
    With btnRestore
        .Caption = "⚠️ RESTORE LAST BACKUP"
        .OnAction = "mod_SyncBridge.RestoreMasterLedger"
        .Font.Bold = True
    End With
    
    ' 7. Create "VIEW SYSTEM LOGS" Button
    ' Position: Below restore button
    Dim btnLogs As Button
    Set btnLogs = ws.Buttons.Add(150, 230, 200, 50)
    With btnLogs
        .Caption = "📜 VIEW SYSTEM LOGS"
        .OnAction = "ShowSystemLog"
        .Font.Bold = True
    End With
    
    ' 8. Add Instructions
    ws.Range("B2").Value = "MANAGEMENT CONSOLE"
    ws.Range("B2").Font.Size = 16
    ws.Range("B2").Font.Bold = True
    ws.Range("B2").Font.Color = RGB(0, 70, 127)
    
    ws.Range("B4").Value = "Quick Actions:"
    ws.Range("B4").Font.Italic = True
    
    MsgBox "Dashboard buttons created successfully!", vbInformation, "UI Setup"
End Sub
