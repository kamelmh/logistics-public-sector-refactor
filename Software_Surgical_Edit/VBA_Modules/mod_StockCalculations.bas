' VBA Module: mod_StockCalculations.bas
' Purpose: Calculate Reorder Point (ROP) for inventory management
' Institution: Directorate of Education, El Bayadh
' Case Study: Toner G030 (ART-001)

Option Explicit

' ==============================================
' Function: CalculateROP
' Purpose: Calculate Reorder Point given Annual Demand, Lead Time, and Safety Stock
' Formula: ROP = (AnnualDemand / 365 * LeadTime) + SafetyStock
' ==============================================
Public Function CalculateROP(AnnualDemand As Double, LeadTimeDays As Double, SafetyStock As Double) As Double
    On Error GoTo ErrorHandler
    
    Dim DailyDemand As Double
    Dim LeadTimeDemand As Double
    
    ' Validate inputs
    If AnnualDemand < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    If LeadTimeDays < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    If SafetyStock < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    ' Calculate daily demand
    DailyDemand = AnnualDemand / 365
    
    ' Calculate demand during lead time
    LeadTimeDemand = DailyDemand * LeadTimeDays
    
    ' Add safety stock to get ROP
    CalculateROP = LeadTimeDemand + SafetyStock
    
    Exit Function
    
ErrorHandler:
    ' Log error and return 0
    Debug.Print "Error in CalculateROP: " & Err.Description
    CalculateROP = 0
End Function

' ==============================================
' Function: CalculateEOQ
' Purpose: Calculate Economic Order Quantity (Wilson Formula)
' Formula: EOQ = Sqrt((2 * AnnualDemand * OrderCost) / HoldingCostPerUnit)
' ==============================================
Public Function CalculateEOQ(AnnualDemand As Double, OrderCost As Double, HoldingCostPerUnit As Double) As Double
    On Error GoTo ErrorHandler
    
    If AnnualDemand <= 0 Or OrderCost <= 0 Or HoldingCostPerUnit <= 0 Then
        CalculateEOQ = 0
        Exit Function
    End If
    
    CalculateEOQ = Sqr((2 * AnnualDemand * OrderCost) / HoldingCostPerUnit)
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Error in CalculateEOQ: " & Err.Description
    CalculateEOQ = 0
End Function

' ==============================================
' Sub: UpdateStockLedger
' Purpose: Update the stock ledger with new ROP calculation
' ==============================================
Public Sub UpdateStockLedger()
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim LastRow As Long
    Dim ROP As Double
    
    ' Set reference to Stock Ledger sheet
    Set ws = ThisWorkbook.Sheets("StockLedger")
    
    ' Find last row with data
    LastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' Calculate ROP for Toner G030
    ' Constants from thesis: D=1546, LT=2, SS=200
    ROP = CalculateROP(1546, 2, 200)
    
    ' Update cell with ROP value (should be 205.6)
    ws.Range("ROP_Value").Value = ROP
    
    ' Verify calculation
    If Abs(ROP - 205.6) < 0.1 Then
        MsgBox "ROP calculation verified: " & Format(ROP, "0.0"), vbInformation
    Else
        MsgBox "ROP calculation mismatch. Check inputs.", vbExclamation
    End If
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error updating ledger: " & Err.Description, vbCritical
End Sub
