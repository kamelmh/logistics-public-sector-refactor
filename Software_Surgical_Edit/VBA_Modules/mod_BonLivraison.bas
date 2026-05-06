Attribute VB_Name = "mod_BonLivraison"
Option Explicit

' Persistent named ranges for BL numbering
Const BL_COUNTER_RANGE As String = "BL_CurrentCounter"
Const BL_LAST_YYYYMM_RANGE As String = "BL_LastYYYYMM"

Public Function GenerateBL(Optional ByVal bcReference As String = "") As String
    Dim currentYYYYMM As String
    Dim lastYYYYMM As String
    Dim currentCounter As Long
    Dim nm As Name
    
    currentYYYYMM = Format(Date, "YYYYMM")
    
    On Error Resume Next
    Set nm = ThisWorkbook.Names(BL_COUNTER_RANGE)
    On Error GoTo 0
    
    If nm Is Nothing Then
        ThisWorkbook.Names.Add Name:=BL_LAST_YYYYMM_RANGE, RefersTo:=currentYYYYMM
        ThisWorkbook.Names.Add Name:=BL_COUNTER_RANGE, RefersTo:=1
        currentCounter = 1
    Else
        lastYYYYMM = Replace(ThisWorkbook.Names(BL_LAST_YYYYMM_RANGE).RefersTo, "=", "")
        If lastYYYYMM <> currentYYYYMM Then
            ThisWorkbook.Names(BL_LAST_YYYYMM_RANGE).RefersTo = currentYYYYMM
            ThisWorkbook.Names(BL_COUNTER_RANGE).RefersTo = 1
            currentCounter = 1
        Else
            currentCounter = ThisWorkbook.Names(BL_COUNTER_RANGE).RefersTo
            currentCounter = currentCounter + 1
            ThisWorkbook.Names(BL_COUNTER_RANGE).RefersTo = currentCounter
        End If
    End If
    
    GenerateBL = "BL-" & currentYYYYMM & "-" & Format(currentCounter, "000")
    
    If bcReference <> "" Then
        ThisWorkbook.Names.Add Name:="BL_" & Replace(GenerateBL, "-", "_") & "_BC", RefersTo:=bcReference
    End If
End Function

Public Sub ExportBLToPDF(ByVal blNumber As String, Optional ByVal exportPath As String = "")
    Dim ws As Worksheet
    Dim pdfPath As String
    
    Set ws = ActiveSheet
    ws.PageSetup.CenterHeader = "CNEPD - Bon de Livraison: " & blNumber
    ws.PageSetup.CenterFooter = "Généré le: " & Format(Date, "DD/MM/YYYY")
    
    If exportPath = "" Then
        pdfPath = ThisWorkbook.Path & "\BL_" & Replace(blNumber, "-", "_") & ".pdf"
    Else
        pdfPath = exportPath
    End If
    
    ws.ExportAsFixedFormat Type:=xlTypePDF, Filename:=pdfPath, Quality:=xlQualityStandard
    MsgBox "BL exporté en PDF: " & pdfPath, vbInformation
End Sub
