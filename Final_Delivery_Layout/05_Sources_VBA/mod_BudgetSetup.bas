Attribute VB_Name = "mod_BudgetSetup"
'==============================================================================
' mod_BudgetSetup.bas  |  ERP Academie v13.2
' One-time setup module: Creates and populates BUDGET sheet
'==============================================================================
Option Explicit

Public Sub SetupBudgetSheet()
    Dim ws As Worksheet
    Dim sheetExists As Boolean
    Dim s As Worksheet
    Dim i As Long
    Dim articles As Variant
    Dim budgets As Variant
    Dim spent As Variant
    Dim budgetCodes As Variant
    
    ' Check if BUDGET sheet exists
    sheetExists = False
    For Each s In ThisWorkbook.Sheets
        If s.name = "BUDGET" Then
            sheetExists = True
            Set ws = s
            Exit For
        End If
    Next s
    
    If Not sheetExists Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.count))
        ws.name = "BUDGET"
    End If
    
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    ws.Cells.Clear
    ws.Cells.Interior.ColorIndex = xlNone
    
    ' Row 1: Title
    ws.Range("A1:G1").Merge
    ws.Cells(1, 1).Value = "BUDGET ANNUEL 2026 -- Direction de l'Education El Bayadh"
    ws.Cells(1, 1).Font.Bold = True
    ws.Cells(1, 1).Font.Size = 12
    ws.Cells(1, 1).Font.Color = RGB(0, 70, 127)
    ws.Cells(1, 1).HorizontalAlignment = xlCenter
    ws.Rows(1).RowHeight = 25
    
    ' Row 2: Headers
    ws.Cells(2, 1).Value = "Code Article"
    ws.Cells(2, 2).Value = "Budget Alloue (DZD)"
    ws.Cells(2, 3).Value = "Montant Depense (DZD)"
    ws.Cells(2, 4).Value = "Restant (DZD)"
    ws.Cells(2, 5).Value = "Code Budgetaire"
    ws.Cells(2, 6).Value = "Engagement N"
    ws.Cells(2, 7).Value = "Liquidation N"
    
    For i = 1 To 7
        With ws.Cells(2, i)
            .Font.Bold = True
            .Font.Size = 9
            .HorizontalAlignment = xlCenter
            .Interior.Color = RGB(192, 224, 255)
            .Borders.LineStyle = xlContinuous
            .Borders.Weight = xlMedium
        End With
    Next i
    
    ' Data
    articles = Array("ART-001", "ART-002", "ART-003", "ART-004", "ART-005", "ART-006", _
                     "ART-007", "ART-008", "ART-009", "ART-010", "ART-011", "ART-012")
    budgets = Array(250000, 180000, 120000, 85000, 45000, 65000, _
                    55000, 30000, 70000, 50000, 25000, 35000)
    spent = Array(145000, 92000, 45000, 32000, 18000, 28000, _
                  22000, 12000, 35000, 20000, 10000, 15000)
    budgetCodes = Array("623100", "623100", "623100", "623200", "623200", "623200", _
                        "623300", "623300", "623300", "623300", "623400", "623400")
    
    For i = 0 To 11
        Dim r As Long
        r = i + 3
        
        ws.Cells(r, 1).Value = articles(i)
        ws.Cells(r, 2).Value = budgets(i)
        ws.Cells(r, 3).Value = spent(i)
        ws.Cells(r, 4).Formula = "=B" & r & "-C" & r
        ws.Cells(r, 5).Value = budgetCodes(i)
        ws.Cells(r, 6).Value = "ENG-2026-" & Format(i + 1, "000")
        ws.Cells(r, 7).Value = "LIQ-2026-" & Format(i + 1, "000")
        
        Dim c As Integer
        For c = 1 To 7
            With ws.Cells(r, c)
                .Borders.LineStyle = xlContinuous
                .Borders.Weight = xlThin
                .Font.Size = 9
            End With
        Next c
        
        ' Currency format
        ws.Cells(r, 2).NumberFormat = "#,##0.00"
        ws.Cells(r, 3).NumberFormat = "#,##0.00"
        ws.Cells(r, 4).NumberFormat = "#,##0.00"
        ws.Cells(r, 2).HorizontalAlignment = xlRight
        ws.Cells(r, 3).HorizontalAlignment = xlRight
        ws.Cells(r, 4).HorizontalAlignment = xlRight
        ws.Cells(r, 4).Font.Bold = True
        
        ' Alternating row colors
        If i Mod 2 = 0 Then
            ws.Range("A" & r & ":G" & r).Interior.Color = RGB(245, 245, 255)
        End If
    Next i
    
    ws.Columns("A:G").AutoFit
    
    ' Protect
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    ' MsgBox removed - silent init for auto-creation
    ' MsgBox "BUDGET sheet created and populated successfully!", vbInformation, "ACADEMIX v13.2"
    
    Debug.Print "[BudgetSetup] BUDGET sheet created and populated"
End Sub
