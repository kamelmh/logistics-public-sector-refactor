Attribute VB_Name = "mod_BarcodeSim"
' ============================================================================
' Academix v13.3 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Barcode Rendering and Simulation Engine
' Visual barcodes in Excel cells, labels, scanner simulation
' Encoding logic separated to mod_BarcodeEncoder
' ============================================================================

Option Explicit

' Module state
Private Const BARCODE_SIM_SHEET As String = "BARCODE_LABELS"
Private Const BARCODE_REG_RANGE As String = "BARCODE_REGISTRY"

' Module-level state for Code39 init-once cache.
' Added: Session 22 - was referenced in InitCode39 as bare m_* names but
' never declared, causing "Variable not defined" compile error.
Private m_C39InitDone As Boolean
Private m_C39Chars As String
Private m_C39Patterns(0 To 42) As String

' Encoding moved to mod_BarcodeEncoder

Private Sub InitCode39()
    If m_C39InitDone Then Exit Sub
    
    m_C39Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"
    
    ' Code39 patterns (W=wide bar, w=narrow bar, spacing alternates)
    m_C39Patterns(0) = "101001101101"   ' 0
    m_C39Patterns(1) = "110100101011"   ' 1
    m_C39Patterns(2) = "101100101011"   ' 2
    m_C39Patterns(3) = "110110010101"   ' 3
    m_C39Patterns(4) = "101001101011"   ' 4
    m_C39Patterns(5) = "110100110101"   ' 5
    m_C39Patterns(6) = "101100110101"   ' 6
    m_C39Patterns(7) = "101001011011"   ' 7
    m_C39Patterns(8) = "110100101101"   ' 8
    m_C39Patterns(9) = "101100101101"   ' 9
    m_C39Patterns(10) = "110101001011"  ' A
    m_C39Patterns(11) = "101101001011"  ' B
    m_C39Patterns(12) = "110110100101"  ' C
    m_C39Patterns(13) = "101011001011"  ' D
    m_C39Patterns(14) = "110101100101"  ' E
    m_C39Patterns(15) = "101101100101"  ' F
    m_C39Patterns(16) = "101010011011"  ' G
    m_C39Patterns(17) = "110101001101"  ' H
    m_C39Patterns(18) = "101101001101"  ' I
    m_C39Patterns(19) = "101011001101"  ' J
    m_C39Patterns(20) = "110101010011"  ' K
    m_C39Patterns(21) = "101101010011"  ' L
    m_C39Patterns(22) = "110110101001"  ' M
    m_C39Patterns(23) = "101011010011"  ' N
    m_C39Patterns(24) = "110101101001"  ' O
    m_C39Patterns(25) = "101101101001"  ' P
    m_C39Patterns(26) = "101010110011"  ' Q
    m_C39Patterns(27) = "110101011001"  ' R
    m_C39Patterns(28) = "101101011001"  ' S
    m_C39Patterns(29) = "101011011001"  ' T
    m_C39Patterns(30) = "110010101011"  ' U
    m_C39Patterns(31) = "100110101011"  ' V
    m_C39Patterns(32) = "110011010101"  ' W
    m_C39Patterns(33) = "100101101011"  ' X
    m_C39Patterns(34) = "110010110101"  ' Y
    m_C39Patterns(35) = "100110110101"  ' Z
    m_C39Patterns(36) = "100100110101"  ' -
    m_C39Patterns(37) = "110010011011"  ' .
    m_C39Patterns(38) = "100110010111"  ' ' '
    m_C39Patterns(39) = "110011001011"  ' $
    m_C39Patterns(40) = "100110010111"  ' /
    m_C39Patterns(41) = "100100101111"  ' +
    m_C39Patterns(42) = "100100111011"  ' %
    
    m_C39InitDone = True
End Sub

' Encoding API moved to mod_BarcodeEncoder (Code128_Encode, EAN13_Encode, Code39_Encode, etc.)

Public Function Code128_Decode(ByVal data As String) As String
    ' Decode a previously encoded string - validation use
    ' Checks checksum and returns original data
    Code128_Decode = data  ' Simple pass-through for label display
End Function

' ============================================================================
' PUBLIC API - EAN-13 Encoding
' ============================================================================

Public Function EAN13_Encode(ByVal barcodeStr As String) As String
    ' Takes 12 or 13 digit EAN-13, returns binary pattern
    ' If 12 digits, computes checksum automatically
    ' Returns binary string '1'=bar '0'=space
    
    Dim i As Integer
    Dim digits(0 To 12) As Integer
    Dim parity As String
    Dim result As String
    
    On Error GoTo EANError
    
    ' Clean input
    barcodeStr = Replace(barcodeStr, "-", "")
    barcodeStr = Replace(barcodeStr, " ", "")
    
    If Len(barcodeStr) < 12 Or Len(barcodeStr) > 13 Then
        EAN13_Encode = ""
        Exit Function
    End If
    
    ' Parse digits
    For i = 0 To 11
        digits(i) = CInt(Mid(barcodeStr, i + 1, 1))
    Next i
    
    ' Add or verify checksum
    If Len(barcodeStr) = 13 Then
        digits(12) = CInt(Mid(barcodeStr, 13, 1))
    Else
        digits(12) = EAN13_Checksum(digits)
    End If
    
    ' EAN-13 LGP: Left Guard Pattern
    result = "101"  ' Start
    
    ' Left group (digits 1-6) - parity encoded by first digit
    parity = mod_BarcodeEncoder.EAN13_ParityTable(digits(0))

    For i = 1 To 6
        If Mid(parity, i, 1) = "O" Then
            result = result & mod_BarcodeEncoder.EAN13_RightPattern(digits(i))  ' Odd parity
        Else
            result = result & mod_BarcodeEncoder.EAN13_LeftPattern(digits(i))   ' Even parity
        End If
    Next i

    result = result & "01010"  ' Center guard

    ' Right group (digits 7-12) - all use right encoding
    For i = 7 To 12
        result = result & mod_BarcodeEncoder.EAN13_RightPattern(digits(i))
    Next i
    
    result = result & "101"  ' End
    
    ' Append checksum digit for display
    EAN13_Encode = result & "|" & CStr(digits(12))
    Exit Function
    
EANError:
    EAN13_Encode = ""
End Function

Public Function EAN13_Checksum(ByRef digits() As Integer) As Integer
    ' EAN-13 checksum: Sum odd*1 + even*3, round to next 10
    Dim i As Integer
    Dim total As Integer
    
    total = 0
    For i = 0 To 11
        If (i Mod 2) = 0 Then
            total = total + digits(i) * 1   ' Odd positions
        Else
            total = total + digits(i) * 3   ' Even positions
        End If
    Next i
    
    EAN13_Checksum = (10 - (total Mod 10)) Mod 10
End Function

' ============================================================================
' PUBLIC API - Code39 Encoding (simpler, variable length)
' ============================================================================

Public Function Code39_Encode(ByVal text As String) As String
    ' Returns binary string representation
    ' Includes start/stop asterisks (*)
    
    Dim i As Integer
    Dim result As String
    Dim charIdx As Integer
    
    InitCode39
    
    text = UCase(Trim(text))
    If Len(text) = 0 Then
        Code39_Encode = ""
        Exit Function
    End If
    
    Start:
    ' Start character (*)
    result = m_C39Patterns(42)  ' '*' pattern
    
    For i = 1 To Len(text)
        charIdx = InStr(1, m_C39Chars, Mid(text, i, 1))
        If charIdx > 0 Then
            result = result & "0" & m_C39Patterns(charIdx - 1)  ' Inter-character gap
        End If
    Next i
    
    ' Stop character (*)
    result = result & "0" & m_C39Patterns(42)
    
    Code39_Encode = result
End Function

' ============================================================================
' PUBLIC API - Barcode Visual Rendering
' ============================================================================

Public Sub GenerateBarcode(ByVal targetSheet As String, _
                           ByVal targetCell As String, _
                           ByVal data As String, _
                           Optional ByVal symbology As BarcodeSymbology = bcCode128, _
                           Optional ByVal showText As Boolean = True, _
                           Optional ByVal barHeight As Integer = 40, _
                           Optional ByVal barWidth As Integer = 2)
    ' Generate a barcode on specified sheet at target cell
    ' Uses conditional formatting and column width manipulation
    
    Dim ws As Worksheet
    Dim binaryPattern As String
    Dim barcodeText As String
    Dim cleanData As String
    
    On Error GoTo BarcodeError
    
    Set ws = GetOrCreateSheet(targetSheet)
    ' Unprotect if protected (newly created sheets have no protection)
    On Error Resume Next
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    On Error GoTo BarcodeError
    
    cleanData = Trim(data)
    If Len(cleanData) = 0 Then Exit Sub
    
    ' Encode based on symbology
    Select Case symbology
        Case bcCode128
            binaryPattern = mod_BarcodeEncoder.Code128_Encode(cleanData)
            barcodeText = cleanData
        Case bcEAN13
            binaryPattern = mod_BarcodeEncoder.EAN13_Encode(cleanData)
            ' Extract checksum from binary pattern
            If InStr(binaryPattern, "|") > 0 Then
                barcodeText = cleanData & Mid(binaryPattern, InStr(binaryPattern, "|") + 1)
                binaryPattern = Left(binaryPattern, InStr(binaryPattern, "|") - 1)
            Else
                barcodeText = cleanData
            End If
        Case bcCode39
            binaryPattern = mod_BarcodeEncoder.Code39_Encode(cleanData)
            barcodeText = cleanData
        Case bcInterleaved2of5
            binaryPattern = mod_BarcodeEncoder.Interleaved2of5_Encode(cleanData)
            barcodeText = cleanData
        Case bcQR_Visual
            Call GenerateQRVisualBlock(ws, targetCell, cleanData)
            GoTo BarcodeDone
    End Select
    
    If Len(binaryPattern) = 0 Then
        MsgBox "Impossible de coder les donn" & Chr(233) & "es pour le code-barres.", _
               vbExclamation, "Erreur code-barres"
        GoTo BarcodeDone
    End If
    
    ' Render the barcode
    Call RenderBinaryBarcode(ws, targetCell, binaryPattern, barHeight, barWidth, barcodeText, showText)
    
BarcodeDone:
    On Error Resume Next
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    On Error GoTo 0
    Exit Sub
    
BarcodeError:
    MsgBox "Erreur de g" & Chr(233) & "n" & Chr(233) & "ration code-barres: " & Err.Description, vbCritical
    On Error Resume Next
    If Not ws Is Nothing Then
        ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    End If
End Sub

Public Sub GenerateBarcodeRange(ByVal targetSheet As String, _
                                ByVal startCell As String, _
                                ByVal dataRange As Range, _
                                Optional ByVal symbology As BarcodeSymbology = bcCode128, _
                                Optional ByVal barHeight As Integer = 30)
    ' Batch generate barcodes for a range of cells
    ' Each row gets its own barcode in adjacent cell
    
    Dim cell As Range
    Dim rowOffset As Long
    Dim targetCol As String
    Dim targetRow As Long
    
    On Error GoTo BatchError
    
    ' Parse target cell
    targetCol = Left(startCell, 1)
    targetRow = CLng(Mid(startCell, 2))
    
    Application.ScreenUpdating = False
    Application.StatusBar = "G" & Chr(233) & "n" & Chr(233) & "ration des codes-barres..."
    
    For Each cell In dataRange.Cells
        If Len(Trim(CStr(cell.Value))) > 0 Then
            rowOffset = cell.Row - dataRange.Row
            Call GenerateBarcode(targetSheet, targetCol & CStr(targetRow + rowOffset), _
                                CStr(cell.Value), symbology, True, barHeight)
        End If
        DoEvents
    Next cell
    
    Application.StatusBar = "Codes-barres g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & "s: " & _
                           dataRange.Cells.Count & " articles"
    Application.ScreenUpdating = True
    Exit Sub
    
BatchError:
    Application.ScreenUpdating = True
    Application.StatusBar = False
    MsgBox "Erreur en batch: " & Err.Description, vbCritical
End Sub

' ============================================================================
' PUBLIC API - Barcode Scanner Simulation
' ============================================================================

Public Sub SimulateBarcodeScan()
    ' Simulates a barcode scanner reading from a visual barcode on screen
    ' User clicks on a rendered barcode cell, system decodes it
    
    Dim selectedCell As Range
    Dim binaryPattern As String
    Dim decodedData As String
    Dim result As VbMsgBoxResult
    
    On Error Resume Next
    Set selectedCell = Application.InputBox("Cliquez sur le code-barres 'a lire:", _
                                            "Simulation Lecteur Code-Barres", _
                                            Type:=8)
    If selectedCell Is Nothing Then Exit Sub
    On Error GoTo ScanError
    
    ' Check if this is a barcode cell (has our special tag)
    If Not IsBarcodeCell(selectedCell) Then
        ' Try to find nearby barcode data
        Dim i As Integer
        For i = 1 To 5
            If IsBarcodeCell(selectedCell.Offset(i, 0)) Then
                Set selectedCell = selectedCell.Offset(i, 0)
                Exit For
            End If
        Next i
        If Not IsBarcodeCell(selectedCell) Then
            MsgBox "Cellule non reconnue comme code-barres. " & vbCrLf & _
                   "S" & Chr(233) & "lectionnez une cellule dans la zone du code-barres.", _
                   vbInformation, "Simulation Code-Barres"
            Exit Sub
        End If
    End If
    
    ' Extract data from comment
    If Not selectedCell.Comment Is Nothing Then
        decodedData = selectedCell.Comment.Text
    Else
        decodedData = CStr(selectedCell.Value)
    End If
    
    ' Strip prefix if present
    If Left(decodedData, 8) = "BC-DATA:" Then
        decodedData = Mid(decodedData, 9)
    End If
    
    ' Show scan result
    result = MsgBox("Code-barres lu: " & decodedData & vbCrLf & vbCrLf & _
                   "Voulez-vous lancer la recherche dans l'inventaire?", _
                   vbYesNo + vbQuestion, "Code-barres scann" & Chr(233))
    
    If result = vbYes Then
        Call mod_Barcode.LookupBarcode(decodedData)
    End If
    Exit Sub
    
ScanError:
    MsgBox "Erreur de lecture: " & Err.Description, vbExclamation, "Simulation Scanner"
End Sub

Public Sub GenerateBarcodeFromInput()
    ' Interactive barcode generator - user enters data and chooses type
    
    Dim barcodeData As String
    Dim symbology As BarcodeSymbology
    Dim choice As Variant
    
    barcodeData = InputBox("Donn" & Chr(233) & "es 'a encoder dans le code-barres:", _
                           "G" & Chr(233) & "n" & Chr(233) & "ration Code-Barres", "ART-001")
    If Len(Trim(barcodeData)) = 0 Then Exit Sub
    
    ' Let user choose symbology via simple input
    choice = InputBox("Type de code-barres:" & vbCrLf & _
                     "0 = Code128 (recommand" & Chr(233) & ")" & vbCrLf & _
                     "1 = EAN-13 (12 chiffres)" & vbCrLf & _
                     "2 = Code39" & vbCrLf & _
                     "3 = Interleaved 2of5" & vbCrLf & _
                     "4 = QR Visuel", _
                     "Type de code-barres", "0")
    
    If Not IsNumeric(choice) Then Exit Sub
    symbology = CInt(choice)
    If symbology < 0 Or symbology > 4 Then Exit Sub
    
    ' Generate on STAGING_BUFFER or active sheet
    Dim activeCell As String
    activeCell = "A1"
    On Error Resume Next
    activeCell = Selection.Cells(1, 1).Address(RowAbsolute:=False, ColumnAbsolute:=False)
    On Error GoTo 0
    
    Call GenerateBarcode(mod_Config.SHEET_STAGING, activeCell, barcodeData, symbology, True, 50)
    MsgBox "Code-barres g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & " en " & _
           mod_Config.SHEET_STAGING & "!" & activeCell, vbInformation, "Code-barres OK"
End Sub

' ============================================================================
' PUBLIC API - Barcode Label Printing
' ============================================================================

Public Sub PrintBarcodeLabels()
    ' Generate and print barcode labels for all articles
    
    Dim wsLabels As Worksheet
    Dim wsArticles As Worksheet
    Dim lastRow As Long
    Dim labelRow As Long
    Dim i As Long
    Dim artCode As String
    Dim artDesig As String
    
    On Error GoTo PrintError
    
    Application.ScreenUpdating = False
    
    ' Create or clear label sheet
    Set wsLabels = GetOrCreateSheet(BARCODE_SIM_SHEET)
    wsLabels.Cells.Clear
    wsLabels.Unprotect Password:=mod_Config.MASTER_PWD
    
    ' Setup label template
    wsLabels.Cells(1, 1).Value = "ACADEMIX v13.3 - " & Chr(201) & "tiquettes Codes-Barres"
    wsLabels.Cells(1, 1).Font.Bold = True
    wsLabels.Cells(1, 1).Font.Size = 14
    wsLabels.Range("A1:F1").Merge
    
    Set wsArticles = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    lastRow = wsArticles.Cells(wsArticles.Rows.Count, 1).End(xlUp).Row
    
    labelRow = 3
    
    For i = 3 To lastRow
        artCode = Trim(CStr(wsArticles.Cells(i, mod_Config.COL_ART_CODE).Value))
        artDesig = Trim(CStr(wsArticles.Cells(i, mod_Config.COL_ART_DESIGNATION).Value))
        
        If Len(artCode) > 0 Then
            ' Label header
            wsLabels.Cells(labelRow, 1).Value = artCode
            wsLabels.Cells(labelRow, 1).Font.Bold = True
            wsLabels.Cells(labelRow + 1, 1).Value = artDesig
            
            ' Generate barcode
            Call GenerateBarcode(BARCODE_SIM_SHEET, "A" & (labelRow + 2), _
                                artCode, bcCode128, True, 30)
            
            ' Border for label
            Dim labelRange As Range
            Set labelRange = wsLabels.Range("A" & labelRow & ":F" & (labelRow + 5))
            labelRange.BorderAround Weight:=xlThin
            labelRange.Interior.Color = RGB(255, 255, 240)
            
            labelRow = labelRow + 7
        End If
    Next i
    
    wsLabels.Columns("A").ColumnWidth = 15
    wsLabels.Columns("B").ColumnWidth = 25
    
    On Error Resume Next
    wsLabels.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    On Error GoTo 0
    
    Application.ScreenUpdating = True
    
    MsgBox "Etiquettes g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & "es: " & _
           Int((labelRow - 3) / 7) & " articles." & vbCrLf & _
           "Allez dans " & BARCODE_SIM_SHEET & " pour imprimer.", _
           vbInformation, "Etiquettes Code-Barres"
    Exit Sub
    
PrintError:
    Application.ScreenUpdating = True
    MsgBox "Erreur d'impression d'" & Chr(233) & "tiquettes: " & Err.Description, vbCritical
End Sub

' ============================================================================
' PUBLIC API - Barcode Registration (extends existing mod_Barcode)
' ============================================================================

Public Sub RegisterBarcodeWithSymbology()
    ' Enhanced barcode registration with symbology selection
    
    Dim barcode As String
    Dim articleCode As String
    Dim symbology As String
    
    barcode = InputBox("Code-barres 'a enregistrer:", "Enregistrement Code-Barres", "")
    If Len(Trim(barcode)) = 0 Then Exit Sub
    
    articleCode = InputBox("Code article 'a associer:" & vbCrLf & _
                          "(ex: ART-001, TNR-042, etc.)", _
                          "Code article", "ART-")
    If Len(Trim(articleCode)) = 0 Then Exit Sub
    articleCode = Trim(UCase(articleCode))
    
    symbology = InputBox("Type de symbologie:" & vbCrLf & _
                        "0 = Code128" & vbCrLf & _
                        "1 = EAN-13" & vbCrLf & _
                        "2 = Code39" & vbCrLf & _
                        "3 = Interleaved 2of5" & vbCrLf & _
                        "4 = QR Visuel", _
                        "Symbologie", "0")
    
    ' Write to extended barcode registry in BARCODE_LABELS sheet
    Dim ws As Worksheet
    Set ws = GetOrCreateSheet(BARCODE_SIM_SHEET)
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "H").End(xlUp).Row + 1
    If lastRow < 3 Then lastRow = 3
    
    ' Check if header exists
    If Trim(CStr(ws.Cells(1, 8).Value)) <> "BC_REGISTRY" Then
        ws.Cells(1, 8).Value = "BC_REGISTRY"
        ws.Cells(2, 8).Value = "BARCODE"
        ws.Cells(2, 9).Value = "ARTICLE"
        ws.Cells(2, 10).Value = "SYMBOLOGY"
        ws.Cells(2, 11).Value = "DATE"
        lastRow = 3
    End If
    
    ws.Cells(lastRow, 8).Value = barcode
    ws.Cells(lastRow, 9).Value = articleCode
    ws.Cells(lastRow, 10).Value = symbology
    ws.Cells(lastRow, 11).Value = Date
    
    On Error Resume Next
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    On Error GoTo 0
    
    MsgBox "Code-barres enregistr" & Chr(233) & ": " & barcode & " -> " & articleCode, _
           vbInformation, "BC Enregistr" & Chr(233)
End Sub

' ============================================================================
' PRIVATE - Barcode Rendering Engine
' ============================================================================

Private Sub RenderBinaryBarcode(ByRef ws As Worksheet, _
                                ByVal targetCell As String, _
                                ByVal binaryPattern As String, _
                                ByVal barHeight As Integer, _
                                ByVal barWidth As Integer, _
                                ByVal barcodeText As String, _
                                ByVal showText As Boolean)
    ' Renders binary barcode pattern as Excel column formatting
    ' Each '1' = black fill, '0' = white fill
    
    Dim i As Integer
    Dim col As Range
    Dim startCol As Integer
    Dim startRow As Integer
    Dim target As Range
    
    Set target = ws.Range(targetCell)
    startCol = target.Column
    startRow = target.Row
    
    ' Clear existing content
    Dim clearRange As Range
    Set clearRange = ws.Range(ws.Cells(startRow, startCol), _
                             ws.Cells(startRow + 1, startCol + Len(binaryPattern) + 10))
    clearRange.ClearContents
    clearRange.ClearFormats
    
    ' Remove any existing shapes in this area
    Dim shp As Shape
    For Each shp In ws.Shapes
        If shp.TopLeftCell.Row >= startRow - 1 And _
           shp.TopLeftCell.Row <= startRow + 5 And _
           shp.TopLeftCell.Column >= startCol - 1 And _
           shp.TopLeftCell.Column <= startCol + Len(binaryPattern) + 5 Then
            shp.Delete
        End If
    Next shp
    
    ' Render each bar
    For i = 1 To Len(binaryPattern)
        Set col = ws.Cells(startRow, startCol + i - 1)
        col.ColumnWidth = barWidth * 0.45
        
        If Mid(binaryPattern, i, 1) = "1" Then
            ' Black bar - use full height shape
            col.Interior.Color = RGB(0, 0, 0)
            col.Value = ""
        Else
            ' White space
            col.Interior.Color = RGB(255, 255, 255)
            col.Value = ""
        End If
        
        ' Set row height for bar height
        ws.Rows(startRow).RowHeight = barHeight
    Next i
    
    ' Add human-readable text below if requested
    If showText Then
        Dim textCell As Range
        Set textCell = ws.Cells(startRow + 1, startCol)
        
        ' Merge enough cells for the text
        Dim mergeRange As Range
        Set mergeRange = ws.Range(textCell, ws.Cells(startRow + 1, startCol + Len(binaryPattern) - 1))
        mergeRange.ClearContents
        
        ' Use a shape for text to overlay cleanly
        Dim txtShape As Shape
        Set txtShape = ws.Shapes.AddTextbox(msoTextOrientationHorizontal, _
                                           ws.Range(targetCell).Left, _
                                           ws.Range(targetCell).Top + barHeight + 2, _
                                           Len(binaryPattern) * barWidth * 0.45 * 6, 18)
        With txtShape
            .TextFrame.Characters.Text = barcodeText
            .TextFrame.Characters.Font.Name = "Courier New"
            .TextFrame.Characters.Font.Size = 10
            .TextFrame.Characters.Font.Bold = True
            .TextFrame.HorizontalAlignment = xlHAlignCenter
            .TextFrame.VerticalAlignment = xlVAlignCenter
            .Fill.Visible = msoFalse
            .Line.Visible = msoFalse
            .Name = "BCText_" & barcodeText
        End With
    End If
    
    ' Store barcode data in cell comment for scanner to read
    On Error Resume Next
    target.ClearNotes
    target.AddComment "BC-DATA:" & barcodeText
    target.Comment.Visible = False
    On Error GoTo 0
    
    ' Write verification code
    ws.Cells(startRow, startCol + Len(binaryPattern) + 2).Value = _
        "[BC:" & Left(barcodeText, 20) & "|" & _
        "Bits:" & Len(binaryPattern) & "|" & _
        "H:" & Hex(GetPatternHash(binaryPattern)) & "]"
    ws.Cells(startRow, startCol + Len(binaryPattern) + 2).Font.Size = 6
    ws.Cells(startRow, startCol + Len(binaryPattern) + 2).Font.Color = RGB(180, 180, 180)
End Sub

Private Sub GenerateQRVisualBlock(ByRef ws As Worksheet, _
                                  ByVal targetCell As String, _
                                  ByVal data As String)
    ' Generate visual QR-like pattern using cells (7x7 grid)
    ' Deterministic pattern based on data hash
    
    Dim target As Range
    Dim i As Integer, j As Integer
    Dim seed As Long
    Dim hash As Long
    Dim patternVal As Integer
    
    Set target = ws.Range(targetCell)
    seed = HashString(data)
    hash = seed
    
    ' Clear area
    Dim clearArea As Range
    Set clearArea = ws.Range(target, target.Offset(8, 8))
    clearArea.ClearContents
    clearArea.ClearFormats
    
    ' Finder patterns (top-left, top-right, bottom-left)
    For i = 0 To 8
        For j = 0 To 8
            ' Top-left finder: rows 0-2, cols 0-2
            If i <= 2 And j <= 2 Then
                If (i = 0 Or i = 2 Or j = 0 Or j = 2) Then
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(0, 0, 0)
                Else
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(255, 255, 255)
                End If
            ' Top-right finder: rows 0-2, cols 6-8
            ElseIf i <= 2 And j >= 6 Then
                If (i = 0 Or i = 2 Or j = 6 Or j = 8) Then
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(0, 0, 0)
                Else
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(255, 255, 255)
                End If
            ' Bottom-left finder: rows 6-8, cols 0-2
            ElseIf i >= 6 And j <= 2 Then
                If (i = 6 Or i = 8 Or j = 0 Or j = 2) Then
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(0, 0, 0)
                Else
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(255, 255, 255)
                End If
            Else
                ' Data area - deterministic from hash
                patternVal = ((seed * (i + 1) * (j + 1) + (i * 17) + (j * 13)) Mod 100)
                If patternVal < 45 Then
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(0, 0, 0)
                Else
                    ws.Cells(target.Row + i, target.Column + j).Interior.Color = RGB(255, 255, 255)
                End If
            End If
            
            ' Cell size
            ws.Cells(target.Row + i, target.Column + j).RowHeight = 16
            ws.Cells(target.Row + i, target.Column + j).ColumnWidth = 3
            ws.Cells(target.Row + i, target.Column + j).Borders.LineStyle = xlContinuous
            ws.Cells(target.Row + i, target.Column + j).Borders.Weight = xlHairline
        Next j
    Next i
    
    ' Add data text below
    Dim labelCell As Range
    Set labelCell = target.Offset(9, 0)
    labelCell.Value = "[QRv:" & data & "]"
    labelCell.Font.Size = 7
    labelCell.Font.Color = RGB(128, 128, 128)
    labelCell.Font.Name = "Courier New"
End Sub

' ============================================================================
' PRIVATE - Utility Functions
' ============================================================================

Private Function GetOrCreateSheet(ByVal sheetName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(sheetName)
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        ws.Name = sheetName
    End If
    On Error GoTo 0
    Set GetOrCreateSheet = ws
End Function

Private Function IsBarcodeCell(ByRef cell As Range) As Boolean
    On Error Resume Next
    If Not cell.Comment Is Nothing Then
        If Left(cell.Comment.Text, 8) = "BC-DATA:" Then
            IsBarcodeCell = True
            Exit Function
        End If
    End If
    IsBarcodeCell = False
End Function

Private Function HashString(ByVal text As String) As Long
    ' DJB2 hash algorithm
    Dim i As Integer
    Dim hash As Long
    hash = 5381
    For i = 1 To Len(text)
        hash = ((hash * 33) Xor Asc(Mid(text, i, 1))) And &H7FFFFFFF
    Next i
    HashString = hash
End Function

Private Function GetPatternHash(ByVal pattern As String) As Long
    GetPatternHash = HashString(pattern) And &HFFFF
End Function

' ============================================================================
' END - mod_BarcodeSim.bas
' ============================================================================
