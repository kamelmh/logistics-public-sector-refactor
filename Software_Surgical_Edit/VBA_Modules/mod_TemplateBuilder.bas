Attribute VB_Name = "mod_TemplateBuilder"
Option Explicit

'================================================================================
' TEMPLATE INITIALIZATION
'================================================================================
Public Function InitializeTemplate(ByRef wsTpl As Worksheet, ByVal compact As Boolean) As Long
    Application.ScreenUpdating = False
    wsTpl.Unprotect Password:=mod_Config.MASTER_PWD
    wsTpl.Cells.Clear
    wsTpl.Cells.Interior.ColorIndex = xlNone

    With wsTpl.PageSetup
        .Orientation = xlPortrait
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .RightFooter = "ERP Acad" & Chr(233) & "mie v13.2  |  " & _
                       Format(Now, "DD/MM/YYYY HH:MM")
        If compact Then
            .PaperSize = xlPaperA5
            .LeftMargin = Application.CentimetersToPoints(1)
            .RightMargin = Application.CentimetersToPoints(0.8)
            .TopMargin = Application.CentimetersToPoints(1)
            .BottomMargin = Application.CentimetersToPoints(1)
        Else
            .PaperSize = xlPaperA4
            .LeftMargin = Application.CentimetersToPoints(2)
            .RightMargin = Application.CentimetersToPoints(1.5)
            .TopMargin = Application.CentimetersToPoints(2)
            .BottomMargin = Application.CentimetersToPoints(2)
        End If
    End With
    
    InitializeTemplate = 1 ' Starting row
End Function

'================================================================================
' TEMPLATE HEADER POPULATION
'================================================================================
Public Function PopulateHeader(ByRef wsTpl As Worksheet, ByVal r As Long, _
                               ByVal docRef As String, ByVal docDate As String, _
                               ByVal docType As String, ByVal mvtSign As String, _
                               ByVal thirdParty As String, ByVal compact As Boolean) As Long
    Dim c As Integer
    Dim curR As Long: curR = r

    With wsTpl
        If compact Then
            ' ROW 1: Combined ministry + direction
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "MINIST" & Chr(200) & "RE DE L'" & Chr(201) & _
                                    "DUCATION NATIONALE  |  Dir. El Bayadh"
            With .Cells(curR, 1)
                .Font.Bold = True: .Font.Size = 8: .Font.Name = "Tahoma"
                .HorizontalAlignment = xlCenter
            End With
            .Rows(curR).RowHeight = 14: curR = curR + 1
            
            ' ROW 2: Compact separator
            .Range("A" & curR & ":G" & curR).Borders(xlEdgeBottom).LineStyle = xlContinuous
            .Range("A" & curR & ":G" & curR).Borders(xlEdgeBottom).Weight = xlThin
            .Rows(curR).RowHeight = 4: curR = curR + 1
        Else
            ' ROW 1: Ministry header
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "MINIST" & Chr(200) & "RE DE L'" & Chr(201) & _
                                    "DUCATION NATIONALE"
            With .Cells(curR, 1)
                .Font.Bold = True: .Font.Size = 11
                .HorizontalAlignment = xlCenter
            End With
            .Rows(curR).RowHeight = 22: curR = curR + 1
            
            ' ROW 2: Direction (bilingual FR/AR)
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "Direction de l'" & Chr(201) & "ducation  " & _
                                   Chr(8212) & "  El Bayadh  |  " & _
                                   Chr(1605) & Chr(1583) & Chr(1610) & Chr(1585) & _
                                   Chr(1610) & Chr(1577) & " " & Chr(1575) & _
                                   Chr(1604) & Chr(1578) & Chr(1585) & Chr(1575) & _
                                   Chr(1610) & Chr(1577) & " " & Chr(1575) & _
                                   Chr(1604) & Chr(1576) & Chr(1610) & Chr(1590)
            With .Cells(curR, 1)
                .Font.Size = 9: .Font.Italic = True
                .HorizontalAlignment = xlCenter: .Font.Name = "Tahoma"
            End With
            .Rows(curR).RowHeight = 18: curR = curR + 1
            
            ' ROW 3: Double separator
            .Range("A" & curR & ":G" & curR).Borders(xlEdgeBottom).LineStyle = xlDouble
            .Range("A" & curR & ":G" & curR).Borders(xlEdgeBottom).Weight = xlThick
            .Rows(curR).RowHeight = 6: curR = curR + 1
            
            ' ROW 4: Spacer
            .Rows(curR).RowHeight = 10: curR = curR + 1
        End If
        
        ' ROW 5: Document title banner
        .Range("A" & curR & ":G" & curR).Merge
        .Cells(curR, 1).Value = docType
        With .Cells(curR, 1)
            .Font.Bold = True: .Font.Size = IIf(compact, 14, 20)
            .HorizontalAlignment = xlCenter: .VerticalAlignment = xlCenter
            .Interior.Color = RGB(0, 70, 127): .Font.Color = RGB(255, 255, 255)
        End With
        .Rows(curR).RowHeight = IIf(compact, 24, 40): curR = curR + 1
        
        ' ROW 6: Spacer
        .Rows(curR).RowHeight = IIf(compact, 4, 10): curR = curR + 1
        
        ' ROW 7: Metadata - Ref, Date, Type
        If compact Then
            .Cells(curR, 1).Value = "N" & Chr(176) & " Ref :"
            .Cells(curR, 2).Value = docRef
            .Cells(curR, 2).Font.Color = RGB(0, 70, 127)
            .Cells(curR, 4).Value = "Date :"
            .Cells(curR, 5).Value = docDate
            .Cells(curR, 6).Value = IIf(mvtSign = "IN", "ENTREE", "SORTIE")
            .Cells(curR, 6).Font.Color = IIf(mvtSign = "IN", RGB(4, 90, 55), RGB(160, 70, 0))
            For c = 1 To 7: .Cells(curR, c).Font.Size = 8: .Cells(curR, c).Font.Bold = True: Next c
            .Rows(curR).RowHeight = 13: curR = curR + 1
        Else
            .Cells(curR, 1).Value = "N" & Chr(176) & " R" & Chr(233) & "f" & Chr(233) & "rence :"
            .Cells(curR, 1).Font.Bold = True
            .Cells(curR, 2).Value = docRef
            .Cells(curR, 2).Font.Bold = True: .Cells(curR, 2).Font.Color = RGB(0, 70, 127)
            .Cells(curR, 4).Value = "Date :"
            .Cells(curR, 4).Font.Bold = True
            .Cells(curR, 5).Value = docDate
            .Cells(curR, 6).Value = "Type :"
            .Cells(curR, 6).Font.Bold = True
            .Cells(curR, 7).Value = IIf(mvtSign = "IN", "ENTR" & Chr(201) & "E", "SORTIE")
            .Cells(curR, 7).Font.Bold = True: .Cells(curR, 7).Font.Color = IIf(mvtSign = "IN", RGB(4, 90, 55), RGB(160, 70, 0))
            .Rows(curR).RowHeight = 18: curR = curR + 1
        End If
        
        ' ROW 8: Service / Fournisseur
        If Len(thirdParty) > 0 Then
            .Cells(curR, 1).Value = "Service / Fournisseur :"
            .Cells(curR, 1).Font.Bold = True
            .Range("B" & curR & ":G" & curR).Merge
            .Cells(curR, 2).Value = thirdParty
            .Rows(curR).RowHeight = IIf(compact, 12, 16): curR = curR + 1
        End If
        
        ' ROW 9: Spacer
        .Rows(curR).RowHeight = IIf(compact, 3, 8): curR = curR + 1
    End With
    
    PopulateHeader = curR
End Function

'================================================================================
' TEMPLATE COLUMN HEADERS
'================================================================================
Public Function PopulateColumnHeaders(ByRef wsTpl As Worksheet, ByVal r As Long, ByVal compact As Boolean) As Long
    Dim hdrs(5) As String
    Dim c As Integer
    Dim curR As Long: curR = r
    Dim colFontSize As Integer

    hdrs(0) = "Code Article"
    hdrs(1) = "D" & Chr(233) & "signation"
    hdrs(2) = "Unit" & Chr(233)
    hdrs(3) = "Qt" & Chr(233)
    hdrs(4) = "PU (DZD)"
    hdrs(5) = "Valeur (DZD)"
    
    colFontSize = IIf(compact, 7, 9)
    With wsTpl
        For c = 0 To 5
            With .Cells(curR, c + 1)
                .Value = hdrs(c)
                .Font.Bold = True
                .Font.Size = colFontSize
                .Font.Color = RGB(255, 255, 255)
                .Interior.Color = RGB(0, 70, 127)
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .WrapText = True
                .Borders.LineStyle = xlContinuous
                .Borders.Weight = xlThin
            End With
        Next c
        .Rows(curR).RowHeight = IIf(compact, 18, 28)
    End With
    
    PopulateColumnHeaders = curR + 1
End Function

'================================================================================
' TEMPLATE DATA ROWS
'================================================================================
Public Function PopulateDataRows(ByRef wsTpl As Worksheet, ByRef wsMouv As Worksheet, ByRef wsArt As Worksheet, _
                                ByVal r As Long, ByVal docRef As String, _
                                ByVal colCode As Integer, ByVal colDesig As Integer, ByVal colQte As Integer, _
                                ByVal colPU As Integer, ByVal colRef As Integer, ByVal compact As Boolean, _
                                ByRef totalVal As Double) As Long
    Dim j As Long, lastRow As Long, curR As Long: curR = r
    Dim artCode As String, artDesig As String, artUnit As String
    Dim qty As Double, pu As Double, valLigne As Double
    Dim rowBg As Long, dataFontSize As Integer

    lastRow = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row
    dataFontSize = IIf(compact, 7, 9)

    For j = 2 To lastRow
        If Trim(CStr(wsMouv.Cells(j, colRef).Value)) = docRef Then
            artCode = Trim(CStr(wsMouv.Cells(j, colCode).Value))
            artDesig = Trim(CStr(wsMouv.Cells(j, colDesig).Value))
            artUnit = "unit" & Chr(233)
            qty = mod_Utilities.SafeVal(wsMouv.Cells(j, colQte).Value)
            pu = mod_Utilities.SafeVal(wsMouv.Cells(j, colPU).Value)
            valLigne = qty * pu
            
            If Not wsArt Is Nothing Then
                Dim artMatchRow As Variant
                artMatchRow = Application.Match(artCode, wsArt.Columns(COL_ART_CODE), 0)
                If Not IsError(artMatchRow) Then
                    Dim arLabel As String: arLabel = Trim(CStr(wsArt.Cells(artMatchRow, COL_ART_DESIGNATION).Value))
                    Dim unitLabel As String: unitLabel = Trim(CStr(wsArt.Cells(artMatchRow, COL_ART_SEUIL_MIN).Value))
                    If Len(arLabel) > 0 Then artDesig = arLabel
                    If Len(unitLabel) > 0 Then artUnit = unitLabel
                End If
            End If
            
            rowBg = IIf((curR Mod 2) = 0, RGB(235, 242, 250), RGB(255, 255, 255))
            
            With wsTpl
                With .Cells(curR, 1)
                    .Value = artCode: .Interior.Color = rowBg: .HorizontalAlignment = xlCenter
                    .Font.Name = "Courier New": .Font.Size = dataFontSize
                    .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                With .Cells(curR, 2)
                    .Value = artDesig: .Interior.Color = rowBg: .Font.Name = "Tahoma": .Font.Size = dataFontSize
                    .HorizontalAlignment = xlRight: .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                With .Cells(curR, 3)
                    .Value = artUnit: .Interior.Color = rowBg: .Font.Name = "Tahoma": .Font.Size = dataFontSize
                    .HorizontalAlignment = xlCenter: .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                With .Cells(curR, 4)
                    .Value = qty: .NumberFormat = "#,##0": .Interior.Color = rowBg: .HorizontalAlignment = xlCenter
                    .Font.Bold = True: .Font.Size = dataFontSize: .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                With .Cells(curR, 5)
                    .Value = pu: .NumberFormat = "#,##0.00": .Interior.Color = rowBg: .HorizontalAlignment = xlRight
                    .Font.Size = dataFontSize: .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                With .Cells(curR, 6)
                    .Value = valLigne: .NumberFormat = "#,##0.00": .Interior.Color = rowBg: .HorizontalAlignment = xlRight
                    .Font.Bold = True: .Font.Size = dataFontSize: .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin
                End With
                .Rows(curR).RowHeight = IIf(compact, 14, 20)
            End With
            totalVal = totalVal + valLigne
            curR = curR + 1
        End If
    Next j
    PopulateDataRows = curR
End Function

'================================================================================
' TEMPLATE TOTALS & FOOTER
'================================================================================
Public Function PopulateTotalsAndFooter(ByRef wsTpl As Worksheet, ByVal r As Long, _
                                        ByVal totalVal As Double, ByVal compact As Boolean, _
                                        ByVal thirdParty As String, ByVal docRef As String, _
                                        ByVal docType As String, ByVal docDate As String) As Long
    Dim curR As Long: curR = r
    With wsTpl
        .Range("A" & curR & ":E" & curR).Merge
        With .Cells(curR, 1)
            .Value = "TOTAL G" & Chr(201) & "N" & Chr(201) & "RAL"
            .Font.Bold = True: .Font.Size = IIf(compact, 8, 10): .HorizontalAlignment = xlRight
            .Interior.Color = RGB(215, 228, 244): .Borders.LineStyle = xlContinuous: .Borders.Weight = xlMedium
        End With
        With .Cells(curR, 6)
            .Value = totalVal: .NumberFormat = "#,##0.00 DZD"
            .Font.Bold = True: .Font.Size = IIf(compact, 9, 11): .Font.Color = RGB(0, 70, 127)
            .Interior.Color = RGB(215, 228, 244): .HorizontalAlignment = xlRight
            .Borders.LineStyle = xlContinuous: .Borders.Weight = xlMedium
        End With
        .Rows(curR).RowHeight = IIf(compact, 18, 24): curR = curR + 1
        
        If Not compact Then
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "TVA non applicable -- Secteur Public (Instruction 09-2018 / Article 5)"
            With .Cells(curR, 1): .Font.Size = 8: .Font.Italic = True: .Font.Color = RGB(100, 100, 100): .HorizontalAlignment = xlRight: End With
            .Rows(curR).RowHeight = 14: curR = curR + 1
        End If
        
        If compact Then
            .Range("A" & curR & ":C" & curR).Merge: .Cells(curR, 1).Value = "ORIGINAL -- Magasin"
            With .Cells(curR, 1): .Font.Bold = True: .Font.Size = 7: .Font.Color = RGB(0, 70, 127): .HorizontalAlignment = xlCenter: .Interior.Color = RGB(230, 240, 250): .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin: End With
            .Range("D" & curR & ":G" & curR).Merge: .Cells(curR, 4).Value = "COPIE -- Service"
            With .Cells(curR, 4): .Font.Bold = True: .Font.Size = 7: .Font.Color = RGB(160, 70, 0): .HorizontalAlignment = xlCenter: .Interior.Color = RGB(250, 240, 230): .Borders.LineStyle = xlContinuous: .Borders.Weight = xlThin: End With
            .Rows(curR).RowHeight = 14: curR = curR + 1
        Else
            .Range("A" & curR & ":G" & curR).Merge: .Cells(curR, 1).Value = "ORIGINAL -- Exemplaire du Magasin"
            With .Cells(curR, 1): .Font.Bold = True: .Font.Size = 9: .Font.Color = RGB(0, 70, 127): .HorizontalAlignment = xlCenter: .Interior.Color = RGB(230, 240, 250): End With
            .Rows(curR).RowHeight = 16: curR = curR + 1
        End If
        .Rows(curR).RowHeight = IIf(compact, 4, 10): curR = curR + 1
    End With
    PopulateTotalsAndFooter = curR
End Function

'================================================================================
' TEMPLATE SIGNATURES & VERIFICATION
'================================================================================
Public Function PopulateSignaturesAndVerify(ByRef wsTpl As Worksheet, ByVal r As Long, _
                                            ByVal thirdParty As String, ByVal compact As Boolean, _
                                            ByVal docRef As String, ByVal docType As String, _
                                            ByVal docDate As String, ByVal totalVal As Double) As Long
    Dim curR As Long: curR = r
    Dim sigFontSize As Integer: sigFontSize = IIf(compact, 7, 8)
    Dim verifyCode As String
    
    With wsTpl
        If compact Then
            .Range("A" & curR & ":B" & curR).Merge: .Cells(curR, 1).Value = "Fournisseur"
            .Cells(curR, 1).Font.Bold = True: .Cells(curR, 1).Font.Size = sigFontSize: .Cells(curR, 1).HorizontalAlignment = xlCenter
            .Range("C" & curR & ":D" & curR).Merge: .Cells(curR, 3).Value = "Comptable"
            .Cells(curR, 3).Font.Bold = True: .Cells(curR, 3).Font.Size = sigFontSize: .Cells(curR, 3).HorizontalAlignment = xlCenter
            .Range("E" & curR & ":F" & curR).Merge: .Cells(curR, 5).Value = "Responsable"
            .Cells(curR, 5).Font.Bold = True: .Cells(curR, 5).Font.Size = sigFontSize: .Cells(curR, 5).HorizontalAlignment = xlCenter
            .Cells(curR, 7).Value = "Directeur"
            .Cells(curR, 7).Font.Bold = True: .Cells(curR, 7).Font.Size = sigFontSize: .Cells(curR, 7).HorizontalAlignment = xlCenter
            .Rows(curR).RowHeight = 12: curR = curR + 1
            
            .Rows(curR).RowHeight = 24
            .Range("A" & curR & ":B" & curR).Merge: .Range("A" & curR).Borders.LineStyle = xlContinuous: .Range("A" & curR).Borders.Weight = xlThin: .Range("A" & curR).Interior.Color = RGB(250, 250, 250)
            .Range("C" & curR & ":D" & curR).Merge: .Range("C" & curR).Borders.LineStyle = xlContinuous: .Range("C" & curR).Borders.Weight = xlThin: .Range("C" & curR).Interior.Color = RGB(250, 250, 250)
            .Range("E" & curR & ":F" & curR).Merge: .Range("E" & curR).Borders.LineStyle = xlContinuous: .Range("E" & curR).Borders.Weight = xlThin: .Range("E" & curR).Interior.Color = RGB(250, 250, 250)
            .Cells(curR, 7).Borders.LineStyle = xlContinuous: .Cells(curR, 7).Borders.Weight = xlThin: .Cells(curR, 7).Interior.Color = RGB(250, 250, 250)
            curR = curR + 1
            
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "N" & Chr(176) & " Engagement : _______  N" & Chr(176) & " Liquidation : _______  NIF: " & thirdParty
            With .Cells(curR, 1): .Font.Size = 6: .Font.Italic = True: .Font.Color = RGB(80, 80, 80): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 10: curR = curR + 1
        Else
            .Range("A" & curR & ":B" & curR).Merge: .Cells(curR, 1).Value = "Le Fournisseur"
            .Cells(curR, 1).Font.Bold = True: .Cells(curR, 1).Font.Size = sigFontSize: .Cells(curR, 1).HorizontalAlignment = xlCenter
            .Range("C" & curR & ":D" & curR).Merge: .Cells(curR, 3).Value = "Le Comptable"
            .Cells(curR, 3).Font.Bold = True: .Cells(curR, 3).Font.Size = sigFontSize: .Cells(curR, 3).HorizontalAlignment = xlCenter
            .Range("E" & curR & ":F" & curR).Merge: .Cells(curR, 5).Value = "Le Responsable"
            .Cells(curR, 5).Font.Bold = True: .Cells(curR, 5).Font.Size = sigFontSize: .Cells(curR, 5).HorizontalAlignment = xlCenter
            .Cells(curR, 7).Value = "Le Directeur"
            .Cells(curR, 7).Font.Bold = True: .Cells(curR, 7).Font.Size = sigFontSize: .Cells(curR, 7).HorizontalAlignment = xlCenter
            .Rows(curR).RowHeight = 14: curR = curR + 1
            
            .Rows(curR).RowHeight = 40
            .Range("A" & curR & ":B" & curR).Merge: .Range("A" & curR).Borders.LineStyle = xlContinuous: .Range("A" & curR).Borders.Weight = xlThin: .Range("A" & curR).Interior.Color = RGB(250, 250, 250)
            .Range("C" & curR & ":D" & curR).Merge: .Range("C" & curR).Borders.LineStyle = xlContinuous: .Range("C" & curR).Borders.Weight = xlThin: .Range("C" & curR).Interior.Color = RGB(250, 250, 250)
            .Range("E" & curR & ":F" & curR).Merge: .Range("E" & curR).Borders.LineStyle = xlContinuous: .Range("E" & curR).Borders.Weight = xlThin: .Range("E" & curR).Interior.Color = RGB(250, 250, 250)
            .Cells(curR, 7).Borders.LineStyle = xlContinuous: .Cells(curR, 7).Borders.Weight = xlThin: .Cells(curR, 7).Interior.Color = RGB(250, 250, 250)
            curR = curR + 1
            
            .Range("A" & curR & ":B" & curR).Merge: .Cells(curR, 1).Value = "Signature & Cachet"
            With .Cells(curR, 1): .Font.Size = 7: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Range("C" & curR & ":D" & curR).Merge: .Cells(curR, 3).Value = "Visa du Comptable"
            With .Cells(curR, 3): .Font.Size = 7: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Range("E" & curR & ":F" & curR).Merge: .Cells(curR, 5).Value = "Visa du Responsable"
            With .Cells(curR, 5): .Font.Size = 7: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Cells(curR, 7).Value = "Visa du Directeur"
            With .Cells(curR, 7): .Font.Size = 7: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 12: curR = curR + 1
            
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "N" & Chr(176) & " Engagement : _______________  |  N" & Chr(176) & " Liquidation : _______________  |  Code Budg" & Chr(233) & "taire : _______________"
            With .Cells(curR, 1): .Font.Size = 8: .Font.Italic = True: .Font.Color = RGB(80, 80, 80): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 14: curR = curR + 1
            
            Dim taxIDs As String: taxIDs = mod_SupplierRegistry.GetSupplierTaxIDsForPDF(thirdParty)
            .Range("A" & curR & ":G" & curR).Merge: .Cells(curR, 1).Value = taxIDs
            With .Cells(curR, 1): .Font.Size = 8: .Font.Italic = True: .Font.Color = RGB(80, 80, 80): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 14: curR = curR + 1
        End If
        
        .Rows(curR).RowHeight = IIf(compact, 3, 8): curR = curR + 1
        
        verifyCode = mod_Utilities.GenerateVerifyCode(docRef & docType & docDate & Format(totalVal, "0.00") & mod_Config.APP_VERSION)
        .Range("A" & curR & ":G" & curR).Merge: .Cells(curR, 1).Value = "Code v" & Chr(233) & "rification : " & verifyCode
        With .Cells(curR, 1): .Font.Name = "Courier New": .Font.Size = IIf(compact, 7, 8): .Font.Bold = True: .Font.Color = RGB(0, 70, 127): .HorizontalAlignment = xlCenter: End With
        .Rows(curR).RowHeight = IIf(compact, 10, 14): curR = curR + 1
        
        .Range("F" & curR & ":G" & curR).Merge: .Cells(curR, 6).Value = "[QR]"
        With .Cells(curR, 6): .Font.Size = IIf(compact, 7, 8): .Font.Color = RGB(180, 180, 180): .HorizontalAlignment = xlCenter: .VerticalAlignment = xlCenter: .Interior.Color = RGB(245, 245, 245): .BorderAround Color:=RGB(200, 200, 200), Weight:=xlThin: End With
        .Rows(curR).RowHeight = IIf(compact, 18, 30): curR = curR + 1
        
        If compact Then
            .Rows(curR).RowHeight = 3: curR = curR + 1
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "ERP Acad" & Chr(233) & "mie v13.2  |  " & Format(Now, "DD/MM/YYYY HH:MM") & "  |  " & verifyCode
            With .Cells(curR, 1): .Font.Size = 6: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 10
        Else
            .Rows(curR).RowHeight = 6: curR = curR + 1
            .Range("A" & curR & ":G" & curR).Merge
            .Cells(curR, 1).Value = "Document g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & " par ERP Acad" & Chr(233) & "mie v13.2  |  " & Format(Now, "DD/MM/YYYY HH:MM") & "  |  Syst" & Chr(232) & "me de Gestion Minist" & Chr(232) & "re " & Chr(201) & "ducation  |  " & verifyCode
            With .Cells(curR, 1): .Font.Size = 7: .Font.Italic = True: .Font.Color = RGB(128, 128, 128): .HorizontalAlignment = xlCenter: End With
            .Rows(curR).RowHeight = 12
        End If
    End With
    PopulateSignaturesAndVerify = curR
End Function
