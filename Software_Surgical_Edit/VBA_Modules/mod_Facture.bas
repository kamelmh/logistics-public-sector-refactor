Attribute VB_Name = "mod_Facture"
Option Explicit

Const FACT_COUNTER_RANGE As String = "FACT_CurrentCounter"
Const FACT_LAST_YYYYMM_RANGE As String = "FACT_LastYYYYMM"

Public Function GenerateFacture(ByVal blReference As String, ByVal amount As Double) As String
    Dim currentYYYYMM As String
    Dim lastYYYYMM As String
    Dim currentCounter As Long
    Dim nm As Name
    
    currentYYYYMM = Format(Date, "YYYYMM")
    
    On Error Resume Next
    Set nm = ThisWorkbook.Names(FACT_COUNTER_RANGE)
    On Error GoTo 0
    
    If nm Is Nothing Then
        ThisWorkbook.Names.Add Name:=FACT_LAST_YYYYMM_RANGE, RefersTo:=currentYYYYMM
        ThisWorkbook.Names.Add Name:=FACT_COUNTER_RANGE, RefersTo:=1
        currentCounter = 1
    Else
        lastYYYYMM = Replace(ThisWorkbook.Names(FACT_LAST_YYYYMM_RANGE).RefersTo, "=", "")
        If lastYYYYMM <> currentYYYYMM Then
            ThisWorkbook.Names(FACT_LAST_YYYYMM_RANGE).RefersTo = currentYYYYMM
            ThisWorkbook.Names(FACT_COUNTER_RANGE).RefersTo = 1
            currentCounter = 1
        Else
            currentCounter = ThisWorkbook.Names(FACT_COUNTER_RANGE).RefersTo
            currentCounter = currentCounter + 1
            ThisWorkbook.Names(FACT_COUNTER_RANGE).RefersTo = currentCounter
        End If
    End If
    
    GenerateFacture = "FACT-" & currentYYYYMM & "-" & Format(currentCounter, "000")
    ThisWorkbook.Names.Add Name:="FACT_" & Replace(GenerateFacture, "-", "_") & "_BL", RefersTo:=blReference
    CreateAccountingEntries GenerateFacture, amount
End Function

Private Sub CreateAccountingEntries(ByVal factureNumber As String, ByVal amount As Double)
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
    ws.Name = "ECR_" & Replace(factureNumber, "-", "_")
    
    ws.Range("A1").Value = "Numéro Facture"
    ws.Range("B1").Value = factureNumber
    ws.Range("A2").Value = "Compte"
    ws.Range("B2").Value = "Débit"
    ws.Range("C2").Value = "Crédit"
    ws.Range("A3").Value = "401"
    ws.Range("B3").Value = amount
    ws.Range("A4").Value = "701"
    ws.Range("C4").Value = amount
End Sub
