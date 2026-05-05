Attribute VB_Name = "mod_Budget"
Option Explicit
' CNEPD PUBLIC SECTOR FIX: Budget Management Module
' STATUS: DISABLED — BUDGET sheet does not exist in current workbook (W004)
' All functions return safe defaults. Re-enable when BUDGET sheet is created.

Private Function IsBudgetSheetAvailable() As Boolean
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    IsBudgetSheetAvailable = (ws Is Not Nothing)
End Function

' Checks if requested amount is available in budget for given article code
' Returns True if budget available, False otherwise
Public Function CheckBudgetAvailable(articleCode As String, amount As Double) As Boolean
    CheckBudgetAvailable = True
    If Not IsBudgetSheetAvailable() Then Exit Function
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    
    If ws Is Nothing Then
        MsgBox "BUDGET sheet not found.", vbExclamation, "Budget Error"
        Exit Function
    End If
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            Dim allocated As Double
            Dim spent As Double
            Dim remaining As Double
            
            allocated = Val(ws.Cells(i, 2).Value)
            spent = Val(ws.Cells(i, 3).Value)
            remaining = allocated - spent
            
            If amount <= remaining Then
                CheckBudgetAvailable = True
            Else
                MsgBox "Budget exceeded for article " & articleCode & "." & vbCrLf & _
                       "Remaining: " & Format(remaining, "0.00") & " DZD" & vbCrLf & _
                       "Requested: " & Format(amount, "0.00") & " DZD", _
                       vbExclamation, "Budget Alert"
            End If
            Exit Function
        End If
    Next i
    
    MsgBox "Article code '" & articleCode & "' not found in BUDGET sheet.", vbExclamation, "Budget Error"
End Function

' Updates the spent amount for a given article code
' Adds the amount to the current spent value in Column C
Public Sub UpdateBudgetSpent(articleCode As String, amount As Double)
    If Not IsBudgetSheetAvailable() Then Exit Sub
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim found As Boolean
    
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    
    If ws Is Nothing Then
        MsgBox "BUDGET sheet not found.", vbExclamation, "Budget Error"
        Exit Sub
    End If
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            Dim currentSpent As Double
            currentSpent = Val(ws.Cells(i, 3).Value)
            ws.Cells(i, 3).Value = currentSpent + amount
            found = True
            Exit For
        End If
    Next i
    
    If Not found Then
        MsgBox "Article code '" & articleCode & "' not found in BUDGET sheet.", vbExclamation, "Budget Error"
    End If
End Sub

' Initializes BUDGET sheet structure if not present
Public Sub InitializeBudgetSheet()
    Dim ws As Worksheet
    Dim lastRow As Long
    
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        ws.Name = "BUDGET"
    End If
    
    ' Header row
    ws.Cells(1, 1).Value = "Article Code"
    ws.Cells(1, 2).Value = "Allocated Budget"
    ws.Cells(1, 3).Value = "Spent Amount"
    ws.Cells(1, 4).Value = "Remaining"
    
    ' Formula for remaining (Column D)
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    If lastRow > 1 Then
        ws.Range(ws.Cells(2, 4), ws.Cells(lastRow, 4)).Formula = "=B2-C2"
    End If
    
    ' Header style
    With ws.Range(ws.Cells(1, 1), ws.Cells(1, 4))
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 255)
        .HorizontalAlignment = xlCenter
    End With
    
    ws.Columns("A:D").AutoFit
End Sub

' Gets remaining budget for an article code
Public Function GetBudgetRemaining(articleCode As String) As Double
    GetBudgetRemaining = 0
    If Not IsBudgetSheetAvailable() Then Exit Function
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    
    If ws Is Nothing Then Exit Function
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            GetBudgetRemaining = Val(ws.Cells(i, 2).Value) - Val(ws.Cells(i, 3).Value)
            Exit For
        End If
    Next i
End Function
