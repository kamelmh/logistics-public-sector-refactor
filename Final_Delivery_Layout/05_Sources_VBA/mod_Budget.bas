Attribute VB_Name = "mod_Budget"
'==============================================================================
' mod_Budget.bas  -  ERP Académie v13.2
' Purpose: Budget tracking and validation for Algerian public sector
' Author : Mahi Kamel Abdelghani | CNEPD 2026
'
' Features:
'   - Auto-initializes BUDGET sheet on first use (no silent guards)
'   - Budget availability check before transaction save
'   - Automatic spent amount tracking
'   - Remaining budget calculation with formulas
'   - Dashboard KPI hooks (total allocated, total spent, over-budget count)
'   - 623xxx budget codes (public sector chart of accounts)
'==============================================================================

Option Explicit

'================================================================================
' INTERNAL - Auto-initialize BUDGET sheet if missing
'================================================================================

' Ensures BUDGET sheet exists; creates it via mod_BudgetSetup if not
Private Sub EnsureBudgetSheet()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    
    If ws Is Nothing Then
        ' Auto-create using mod_BudgetSetup (no MsgBox - silent init)
        mod_BudgetSetup.SetupBudgetSheet
        ' Suppress the MsgBox from SetupBudgetSheet by replacing it
        ' The SetupBudgetSheet currently shows MsgBox - we handle that separately
    End If
End Sub

' Check if BUDGET sheet exists (read-only, no side effects)
Private Function BudgetSheetExists() As Boolean
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BUDGET")
    On Error GoTo 0
    BudgetSheetExists = (Not ws Is Nothing)
End Function

'================================================================================
' PUBLIC API - Budget operations
'================================================================================

' Checks if requested amount is available in budget for given article code
' Returns True if budget available, False if exceeded
' Auto-creates BUDGET sheet if missing
Public Function CheckBudgetAvailable(ByVal articleCode As String, ByVal amount As Double) As Boolean
    CheckBudgetAvailable = True  ' Default: allow if no budget system
    
    EnsureBudgetSheet
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 3 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            Dim remaining As Double
            remaining = mod_Utilities.SafeVal(ws.Cells(i, 4).Value)
            
            If amount <= remaining Then
                CheckBudgetAvailable = True
            Else
                ' Budget exceeded - block transaction
                CheckBudgetAvailable = False
                ' Log the event (don't show MsgBox - caller handles UI)
                Debug.Print "[Budget] EXCEEDED: " & articleCode & " requested=" & amount & " remaining=" & remaining
            End If
            Exit Function
        End If
    Next i
    
    ' Article not in budget - allow (unbudgeted items are permitted)
    Debug.Print "[Budget] Article not in budget: " & articleCode
End Function

' Updates the spent amount for a given article code
' Adds the amount to the current spent value in Column C
' Auto-creates BUDGET sheet if missing
Public Sub UpdateBudgetSpent(ByVal articleCode As String, ByVal amount As Double)
    If amount <= 0 Then Exit Sub
    
    EnsureBudgetSheet
    
    If Not BudgetSheetExists Then Exit Sub
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim found As Boolean
    Dim i As Long
    
    For i = 3 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            Dim currentSpent As Double
            currentSpent = mod_Utilities.SafeVal(ws.Cells(i, 3).Value)
            
            ' Unprotect, update, re-protect
            ws.Unprotect Password:=mod_Config.MASTER_PWD
            ws.Cells(i, 3).Value = currentSpent + amount
            ws.Cells(i, 4).Formula = "=B" & i & "-C" & i
            ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
            
            found = True
            
            Debug.Print "[Budget] Updated: " & articleCode & " spent=" & (currentSpent + amount)
            Exit For
        End If
    Next i
    
    If Not found Then
        Debug.Print "[Budget] Article not found for update: " & articleCode
    End If
End Sub

' Gets remaining budget for an article code
' Auto-creates BUDGET sheet if missing
Public Function GetBudgetRemaining(ByVal articleCode As String) As Double
    GetBudgetRemaining = 0
    
    EnsureBudgetSheet
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 3 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            GetBudgetRemaining = mod_Utilities.SafeVal(ws.Cells(i, 4).Value)
            Exit For
        End If
    Next i
End Function

' Gets allocated budget for an article code
Public Function GetBudgetAllocated(ByVal articleCode As String) As Double
    GetBudgetAllocated = 0
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 3 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            GetBudgetAllocated = mod_Utilities.SafeVal(ws.Cells(i, 2).Value)
            Exit For
        End If
    Next i
End Function

' Gets budget code (623xxx) for an article
Public Function GetBudgetCode(ByVal articleCode As String) As String
    GetBudgetCode = ""
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 3 To lastRow
        If CStr(ws.Cells(i, 1).Value) = articleCode Then
            GetBudgetCode = CStr(ws.Cells(i, 5).Value)
            Exit For
        End If
    Next i
End Function

'================================================================================
' DASHBOARD KPIs - Budget summary for mod_Dashboard
'================================================================================

' Total budget allocated across all articles
Public Function GetTotalBudgetAllocated() As Double
    GetTotalBudgetAllocated = 0
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
    
    If lastRow >= 3 Then
        Dim i As Long
        For i = 3 To lastRow
            GetTotalBudgetAllocated = GetTotalBudgetAllocated + mod_Utilities.SafeVal(ws.Cells(i, 2).Value)
        Next i
    End If
End Function

' Total budget spent across all articles
Public Function GetTotalBudgetSpent() As Double
    GetTotalBudgetSpent = 0
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "C").End(xlUp).Row
    
    If lastRow >= 3 Then
        Dim i As Long
        For i = 3 To lastRow
            GetTotalBudgetSpent = GetTotalBudgetSpent + mod_Utilities.SafeVal(ws.Cells(i, 3).Value)
        Next i
    End If
End Function

' Budget utilization rate (spent / allocated * 100)
Public Function GetBudgetUtilizationRate() As Double
    Dim allocated As Double
    allocated = GetTotalBudgetAllocated()
    
    If allocated > 0 Then
        GetBudgetUtilizationRate = (GetTotalBudgetSpent / allocated) * 100
    Else
        GetBudgetUtilizationRate = 0
    End If
End Function

' Count of articles over budget (spent > allocated)
Public Function GetOverBudgetCount() As Long
    GetOverBudgetCount = 0
    
    If Not BudgetSheetExists Then Exit Function
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BUDGET")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 3 To lastRow
        Dim remaining As Double
        remaining = mod_Utilities.SafeVal(ws.Cells(i, 4).Value)
        If remaining < 0 Then
            GetOverBudgetCount = GetOverBudgetCount + 1
        End If
    Next i
End Function

' Budget summary string for dashboard display
Public Function GetBudgetSummary() As String
    Dim allocated As Double
    Dim spent As Double
    Dim remaining As Double
    Dim rate As Double
    
    allocated = GetTotalBudgetAllocated()
    spent = GetTotalBudgetSpent()
    remaining = allocated - spent
    rate = GetBudgetUtilizationRate()
    
    GetBudgetSummary = "Budget: " & Format(allocated, "#,##0") & " DZD | " & _
                       "Depense: " & Format(spent, "#,##0") & " DZD | " & _
                       "Restant: " & Format(remaining, "#,##0") & " DZD | " & _
                       "Utilisation: " & Format(rate, "0.0") & "%"
End Function

'================================================================================
' BUDGET REPORT - Generate budget status report
'================================================================================

' Generate budget status report on a new sheet
Public Sub GenerateBudgetReport()
    EnsureBudgetSheet
    
    If Not BudgetSheetExists Then Exit Sub
    
    Dim wsSource As Worksheet
    Set wsSource = ThisWorkbook.Sheets("BUDGET")
    
    Dim wsReport As Worksheet
    On Error Resume Next
    Set wsReport = ThisWorkbook.Sheets("BUDGET_REPORT")
    On Error GoTo 0
    
    If wsReport Is Nothing Then
        Set wsReport = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        wsReport.Name = "BUDGET_REPORT"
    End If
    
    wsReport.Cells.Clear
    
    ' Title
    wsReport.Range("A1:G1").Merge
    wsReport.Cells(1, 1).Value = "RAPPORT BUDGETAIRE 2026 - Direction de l'Education El Bayadh"
    wsReport.Cells(1, 1).Font.Bold = True
    wsReport.Cells(1, 1).Font.Size = 12
    wsReport.Cells(1, 1).Font.Color = RGB(0, 70, 127)
    wsReport.Cells(1, 1).HorizontalAlignment = xlCenter
    wsReport.Rows(1).RowHeight = 25
    
    ' KPI summary
    wsReport.Cells(3, 1).Value = "Total Alloue"
    wsReport.Cells(3, 2).Value = GetTotalBudgetAllocated()
    wsReport.Cells(3, 2).NumberFormat = "#,##0.00 ""DZD"""
    
    wsReport.Cells(3, 4).Value = "Total Depense"
    wsReport.Cells(3, 5).Value = GetTotalBudgetSpent()
    wsReport.Cells(3, 5).NumberFormat = "#,##0.00 ""DZD"""
    
    wsReport.Cells(3, 7).Value = "Taux Utilisation"
    wsReport.Cells(3, 8).Value = GetBudgetUtilizationRate() / 100
    wsReport.Cells(3, 8).NumberFormat = "0.0%"
    
    ' Copy detailed data from BUDGET sheet
    Dim lastRow As Long
    lastRow = wsSource.Cells(wsSource.Rows.Count, "A").End(xlUp).Row
    
    wsReport.Cells(5, 1).Value = "Code Article"
    wsReport.Cells(5, 2).Value = "Budget Alloue"
    wsReport.Cells(5, 3).Value = "Depense"
    wsReport.Cells(5, 4).Value = "Restant"
    wsReport.Cells(5, 5).Value = "Code Budgetaire"
    wsReport.Cells(5, 6).Value = "Statut"
    
    ' Style headers
    Dim h As Integer
    For h = 1 To 6
        With wsReport.Cells(5, h)
            .Font.Bold = True
            .Font.Size = 9
            .HorizontalAlignment = xlCenter
            .Interior.Color = RGB(192, 224, 255)
            .Borders.LineStyle = xlContinuous
            .Borders.Weight = xlMedium
        End With
    Next h
    
    ' Copy data rows
    Dim i As Long
    For i = 3 To lastRow
        Dim r As Long
        r = i - 3 + 6
        
        wsReport.Cells(r, 1).Value = wsSource.Cells(i, 1).Value
        wsReport.Cells(r, 2).Value = wsSource.Cells(i, 2).Value
        wsReport.Cells(r, 3).Value = wsSource.Cells(i, 3).Value
        wsReport.Cells(r, 4).Value = wsSource.Cells(i, 4).Value
        wsReport.Cells(r, 5).Value = wsSource.Cells(i, 5).Value
        
        ' Status
        Dim remaining As Double
        remaining = mod_Utilities.SafeVal(wsSource.Cells(i, 4).Value)
        
        If remaining < 0 Then
            wsReport.Cells(r, 6).Value = "EXCEDE"
            wsReport.Cells(r, 6).Interior.Color = RGB(255, 220, 220)
            wsReport.Cells(r, 6).Font.Color = RGB(204, 0, 0)
        ElseIf remaining < wsSource.Cells(i, 2).Value * 0.2 Then
            wsReport.Cells(r, 6).Value = "CRITIQUE"
            wsReport.Cells(r, 6).Interior.Color = RGB(255, 243, 224)
            wsReport.Cells(r, 6).Font.Color = RGB(255, 140, 0)
        Else
            wsReport.Cells(r, 6).Value = "NORMAL"
            wsReport.Cells(r, 6).Interior.Color = RGB(211, 240, 224)
            wsReport.Cells(r, 6).Font.Color = RGB(40, 100, 40)
        End If
        
        ' Formatting
        Dim c As Integer
        For c = 1 To 6
            wsReport.Cells(r, c).Font.Size = 9
            wsReport.Cells(r, c).Borders.LineStyle = xlContinuous
            wsReport.Cells(r, c).Borders.Weight = xlThin
        Next c
        
        wsReport.Cells(r, 2).NumberFormat = "#,##0.00"
        wsReport.Cells(r, 3).NumberFormat = "#,##0.00"
        wsReport.Cells(r, 4).NumberFormat = "#,##0.00"
        wsReport.Cells(r, 2).HorizontalAlignment = xlRight
        wsReport.Cells(r, 3).HorizontalAlignment = xlRight
        wsReport.Cells(r, 4).HorizontalAlignment = xlRight
        
        ' Alternating rows
        If (i - 3) Mod 2 = 0 Then
            wsReport.Range("A" & r & ":F" & r).Interior.Color = RGB(245, 245, 255)
        End If
    Next i
    
    wsReport.Columns("A:F").AutoFit
    
    ' Protect
    wsReport.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    Debug.Print "[Budget] Report generated on BUDGET_REPORT sheet"
End Sub

'================================================================================
' AUDIT - Log budget operations
'================================================================================

Public Sub LogBudgetOperation(ByVal articleCode As String, ByVal amount As Double, ByVal operation As String)
    If Not mod_AuditTrail.AuditLogInitialized Then Exit Sub
    
    mod_AuditTrail.LogAction "BUDGET", _
        operation & ": " & articleCode & " amount=" & Format(amount, "#,##0.00"), _
        "mod_Budget", _
        operation
End Sub

'==============================================================================
' END -- mod_Budget.bas
'==============================================================================
