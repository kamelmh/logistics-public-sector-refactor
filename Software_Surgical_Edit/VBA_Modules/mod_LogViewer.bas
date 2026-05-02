
Attribute VB_Name = "mod_LogViewer"
'=======================================================================================
' MODULE: mod_LogViewer.bas
' PROJECT: ERP Academie v13.2
' PURPOSE: Log retrieval engine for the System Log Viewer
'=======================================================================================
Option Explicit

'--------------------------------------------------------------------------------------
' Returns the last N lines of the erp_engine.log file.
'--------------------------------------------------------------------------------------
Public Function GetLastLogEntries(ByVal numLines As Integer) As String
    Dim logPath As String
    Dim fileNum As Integer
    Dim lineStr As String
    Dim allLines As New Collection
    
    logPath = mod_SyncBridge.GetHubRoot() & "\v13_Master\data\erp_engine.log"
    
    If Dir(logPath) = "" Then
        GetLastLogEntries = "Log file not found at: " & logPath
        Exit Function
    End If
    
    fileNum = FreeFile
    Open logPath For Input As #fileNum
    
    Do While Not EOF(fileNum)
        Line Input #fileNum, lineStr
        allLines.Add lineStr
    Loop
    Close #fileNum
    
    ' Get only the last N lines
    Dim result As String
    Dim i As Long
    Dim startIdx As Long
    
    startIdx = allLines.count - numLines + 1
    If startIdx < 1 Then startIdx = 1
    
    For i = startIdx To allLines.count
        result = result & allLines(i) & vbCrLf
    Next i
    
    GetLastLogEntries = result
End Function
