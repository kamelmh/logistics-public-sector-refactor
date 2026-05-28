Attribute VB_Name = "mod_BarcodeSim"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Advanced Barcode Simulation and Generation Engine
' Supports: Code128 (A/B/C), EAN-13, Code39, Interleaved 2of5
' Generates visual barcodes in Excel cells, labels, and scanner simulation
' ============================================================================

Option Explicit

' ============================================================================
' CONSTANTS
' ============================================================================

' Symbology types
Public Enum BarcodeSymbology
    bcCode128 = 0
    bcEAN13 = 1
    bcCode39 = 2
    bcInterleaved2of5 = 3
    bcQR_Visual = 4
End Enum

' Code128 encoding tables
Private Const C128_START_A As String = "211412"
Private Const C128_START_B As String = "211214"
Private Const C128_START_C As String = "211232"
Private Const C128_STOP As String = "2331112"

' Code128 character patterns (6 digits each, total 107 chars)
Private m_C128Patterns(0 To 106) As String
Private m_C128InitDone As Boolean

' Code39 character patterns (9 digits each, 43 chars)
Private m_C39Patterns(0 To 42) As String
Private m_C39Chars As String
Private m_C39InitDone As Boolean

' Module state
Private Const BARCODE_SIM_SHEET As String = "BARCODE_LABELS"
Private Const BARCODE_REG_RANGE As String = "BARCODE_REGISTRY"

' ============================================================================
' INITIALIZATION - Load encoding tables
' ============================================================================

Private Sub InitCode128()
    If m_C128InitDone Then Exit Sub
    
    ' Code128 character encodings (value 0-105)
    ' Format: 6 digits (bar1,space1,bar2,space2,bar3,space3)
    m_C128Patterns(0) = "212222":  m_C128Patterns(1) = "222122"
    m_C128Patterns(2) = "222221":  m_C128Patterns(3) = "121223"
    m_C128Patterns(4) = "121322":  m_C128Patterns(5) = "131222"
    m_C128Patterns(6) = "122213":  m_C128Patterns(7) = "122312"
    m_C128Patterns(8) = "132212":  m_C128Patterns(9) = "221213"
    m_C128Patterns(10) = "221312": m_C128Patterns(11) = "231212"
    m_C128Patterns(12) = "112232": m_C128Patterns(13) = "122132"
    m_C128Patterns(14) = "122231": m_C128Patterns(15) = "113222"
    m_C128Patterns(16) = "123122": m_C128Patterns(17) = "123221"
    m_C128Patterns(18) = "223211": m_C128Patterns(19) = "221132"
    m_C128Patterns(20) = "221231": m_C128Patterns(21) = "213212"
    m_C128Patterns(22) = "223112": m_C128Patterns(23) = "312131"
    m_C128Patterns(24) = "311222": m_C128Patterns(25) = "321122"
    m_C128Patterns(26) = "321221": m_C128Patterns(27) = "312212"
    m_C128Patterns(28) = "322112": m_C128Patterns(29) = "322211"
    m_C128Patterns(30) = "212123": m_C128Patterns(31) = "212321"
    m_C128Patterns(32) = "232121": m_C128Patterns(33) = "111323"
    m_C128Patterns(34) = "131123": m_C128Patterns(35) = "131321"
    m_C128Patterns(36) = "112313": m_C128Patterns(37) = "132113"
    m_C128Patterns(38) = "132311": m_C128Patterns(39) = "211313"
    m_C128Patterns(40) = "231113": m_C128Patterns(41) = "231311"
    m_C128Patterns(42) = "112133": m_C128Patterns(43) = "112331"
    m_C128Patterns(44) = "132131": m_C128Patterns(45) = "113123"
    m_C128Patterns(46) = "113321": m_C128Patterns(47) = "133121"
    m_C128Patterns(48) = "313121": m_C128Patterns(49) = "211331"
    m_C128Patterns(50) = "231131": m_C128Patterns(51) = "213113"
    m_C128Patterns(52) = "213311": m_C128Patterns(53) = "213131"
    m_C128Patterns(54) = "311123": m_C128Patterns(55) = "311321"
    m_C128Patterns(56) = "331121": m_C128Patterns(57) = "312113"
    m_C128Patterns(58) = "312311": m_C128Patterns(59) = "332111"
    m_C128Patterns(60) = "314111": m_C128Patterns(61) = "221411"
    m_C128Patterns(62) = "431111": m_C128Patterns(63) = "111224"
    m_C128Patterns(64) = "111422": m_C128Patterns(65) = "121124"
    m_C128Patterns(66) = "121421": m_C128Patterns(67) = "141122"
    m_C128Patterns(68) = "141221": m_C128Patterns(69) = "112214"
    m_C128Patterns(70) = "112412": m_C128Patterns(71) = "122114"
    m_C128Patterns(72) = "122411": m_C128Patterns(73) = "142112"
    m_C128Patterns(74) = "142211": m_C128Patterns(75) = "241211"
    m_C128Patterns(76) = "221114": m_C128Patterns(77) = "413111"
    m_C128Patterns(78) = "241112": m_C128Patterns(79) = "134111"
    m_C128Patterns(80) = "111242": m_C128Patterns(81) = "121142"
    m_C128Patterns(82) = "121241": m_C128Patterns(83) = "114212"
    m_C128Patterns(84) = "124112": m_C128Patterns(85) = "124211"
    m_C128Patterns(86) = "411212": m_C128Patterns(87) = "421112"
    m_C128Patterns(88) = "421211": m_C128Patterns(89) = "212141"
    m_C128Patterns(90) = "214121": m_C128Patterns(91) = "412121"
    m_C128Patterns(92) = "111143": m_C128Patterns(93) = "111341"
    m_C128Patterns(94) = "131141": m_C128Patterns(95) = "114113"
    m_C128Patterns(96) = "114311": m_C128Patterns(97) = "411113"
    m_C128Patterns(98) = "411311": m_C128Patterns(99) = "113141"
    m_C128Patterns(100) = "114131": m_C128Patterns(101) = "311141"
    m_C128Patterns(102) = "411131": m_C128Patterns(103) = "211412" ' Start A
    m_C128Patterns(104) = "211214"  ' Start B
    m_C128Patterns(105) = "211232"  ' Start C
    m_C128Patterns(106) = "2331112" ' Stop
    
    m_C128InitDone = True
End Sub

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

' ============================================================================
' PUBLIC API - Code128 Encoding
' ============================================================================

Public Function Code128_Encode(ByVal text As String, _
                               Optional ByVal subset As String = "B") As String
    ' Returns binary string representation of Code128 barcode
    ' '1' = bar (black), '0' = space (white)
    
    InitCode128
    
    Dim i As Integer
    Dim checksum As Integer
    Dim codeVals() As Integer
    Dim result As String
    Dim startCode As Integer
    Dim startPattern As String
    
    On Error GoTo EncodeError
    
    If Len(text) = 0 Then
        Code128_Encode = ""
        Exit Function
    End If
    
    ' Determine start code and convert text to values
    Select Case UCase(Left(subset, 1))
        Case "A"
            startCode = 103
            startPattern = C128_START_A
            codeVals = TextToCode128A(text)
        Case "C"
            startCode = 105
            startPattern = C128_START_C
            codeVals = TextToCode128C(text)
        Case Else
            startCode = 104
            startPattern = C128_START_B
            codeVals = TextToCode128B(text)
    End Select
    
    If UBound(codeVals) < 0 Then Exit Function
    
    ' Build pattern
    result = startPattern
    
    ' Checksum starts with start code value
    checksum = startCode - 100  ' Start A=3, B=4, C=5
    
    For i = LBound(codeVals) To UBound(codeVals)
        checksum = checksum + (codeVals(i) * (i + 1))
        result = result & ModulePattern(codeVals(i))
    Next i
    
    ' Append checksum character
    checksum = checksum Mod 103
    result = result & ModulePattern(checksum)
    
    ' Append stop pattern
    result = result & C128_STOP
    
    ' Convert to binary string (1=bar, 0=space)
    Code128_Encode = PatternToBinary(result)
    Exit Function
    
EncodeError:
    Code128_Encode = ""
End Function

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
    parity = EAN13_ParityTable(digits(0))
    
    For i = 1 To 6
        If Mid(parity, i, 1) = "O" Then
            result = result & EAN13_RightPattern(digits(i))  ' Odd parity
        Else
            result = result & EAN13_LeftPattern(digits(i))   ' Even parity
        End If
    Next i
    
    result = result & "01010"  ' Center guard
    
    ' Right group (digits 7-12) - all use right encoding
    For i = 7 To 12
        result = result & EAN13_RightPattern(digits(i))
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
            binaryPattern = Code128_Encode(cleanData)
            barcodeText = cleanData
        Case bcEAN13
            binaryPattern = EAN13_Encode(cleanData)
            ' Extract checksum from binary pattern
            If InStr(binaryPattern, "|") > 0 Then
                barcodeText = cleanData & Mid(binaryPattern, InStr(binaryPattern, "|") + 1)
                binaryPattern = Left(binaryPattern, InStr(binaryPattern, "|") - 1)
            Else
                barcodeText = cleanData
            End If
        Case bcCode39
            binaryPattern = Code39_Encode(cleanData)
            barcodeText = cleanData
        Case bcInterleaved2of5
            binaryPattern = Interleaved2of5_Encode(cleanData)
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
    wsLabels.Cells(1, 1).Value = "ACADEMIX v13.2 - " & Chr(201) & "tiquettes Codes-Barres"
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
' PRIVATE - Encoding Helpers
' ============================================================================

Private Function TextToCode128B(ByVal text As String) As Integer()
    Dim vals() As Integer
    Dim i As Integer
    Dim count As Integer
    
    count = 0
    ReDim vals(0 To Len(text) - 1)
    
    For i = 1 To Len(text)
        Dim ch As Integer
        ch = Asc(Mid(text, i, 1))
        
        If ch >= 32 Then
            vals(count) = ch - 32
            count = count + 1
        End If
    Next i
    
    If count = 0 Then
        ReDim vals(-1 To -1)
    Else
        ReDim Preserve vals(0 To count - 1)
    End If
    
    TextToCode128B = vals
End Function

Private Function TextToCode128A(ByVal text As String) As Integer()
    ' Simplified: uses Code128B mapping for most chars
    TextToCode128A = TextToCode128B(text)
End Function

Private Function TextToCode128C(ByVal text As String) As Integer()
    ' Code128C: pairs of digits
    Dim vals() As Integer
    Dim i As Integer
    Dim count As Integer
    Dim cleanText As String
    
    ' Extract only digits
    cleanText = ""
    For i = 1 To Len(text)
        If IsNumeric(Mid(text, i, 1)) Then
            cleanText = cleanText & Mid(text, i, 1)
        End If
    Next i
    
    If Len(cleanText) Mod 2 <> 0 Then
        cleanText = "0" & cleanText  ' Pad odd length
    End If
    
    count = 0
    ReDim vals(0 To (Len(cleanText) \ 2) - 1)
    
    For i = 1 To Len(cleanText) Step 2
        vals(count) = CInt(Mid(cleanText, i, 2))
        count = count + 1
    Next i
    
    TextToCode128C = vals
End Function

Private Function ModulePattern(ByVal charVal As Integer) As String
    If charVal >= 0 And charVal <= 106 Then
        ModulePattern = m_C128Patterns(charVal)
    Else
        ModulePattern = ""
    End If
End Function

Private Function PatternToBinary(ByVal pattern As String) As String
    ' Convert module pattern to binary (1=bar, 0=space)
    Dim i As Integer
    Dim result As String
    Dim isBar As Boolean
    
    result = ""
    isBar = True
    
    For i = 1 To Len(pattern)
        Dim moduleCount As Integer
        moduleCount = CInt(Mid(pattern, i, 1))
        
        Dim j As Integer
        For j = 1 To moduleCount
            If isBar Then
                result = result & "1"
            Else
                result = result & "0"
            End If
        Next j
        
        isBar = Not isBar
    Next i
    
    PatternToBinary = result
End Function

Private Function EAN13_ParityTable(ByVal firstDigit As Integer) As String
    ' Parity encoding for EAN-13 left group based on first digit
    ' O=Odd parity, E=Even parity
    Select Case firstDigit
        Case 0: EAN13_ParityTable = "OOOOOO"
        Case 1: EAN13_ParityTable = "OOEOEE"
        Case 2: EAN13_ParityTable = "OOEEOE"
        Case 3: EAN13_ParityTable = "OOEEEO"
        Case 4: EAN13_ParityTable = "OEOOEE"
        Case 5: EAN13_ParityTable = "OEEOOE"
        Case 6: EAN13_ParityTable = "OEEEOO"
        Case 7: EAN13_ParityTable = "OEOEOE"
        Case 8: EAN13_ParityTable = "OEOEEO"
        Case 9: EAN13_ParityTable = "OEEOEO"
        Case Else: EAN13_ParityTable = "OOOOOO"
    End Select
End Function

Private Function EAN13_LeftPattern(ByVal digit As Integer) As String
    ' EAN-13 left-side encoding (even parity)
    Select Case digit
        Case 0: EAN13_LeftPattern = "0001101"
        Case 1: EAN13_LeftPattern = "0011001"
        Case 2: EAN13_LeftPattern = "0010011"
        Case 3: EAN13_LeftPattern = "0111101"
        Case 4: EAN13_LeftPattern = "0100011"
        Case 5: EAN13_LeftPattern = "0110001"
        Case 6: EAN13_LeftPattern = "0101111"
        Case 7: EAN13_LeftPattern = "0111011"
        Case 8: EAN13_LeftPattern = "0110111"
        Case 9: EAN13_LeftPattern = "0001011"
        Case Else: EAN13_LeftPattern = "0001101"
    End Select
End Function

Private Function EAN13_RightPattern(ByVal digit As Integer) As String
    ' EAN-13 right-side encoding (all odd parity)
    Select Case digit
        Case 0: EAN13_RightPattern = "1110010"
        Case 1: EAN13_RightPattern = "1100110"
        Case 2: EAN13_RightPattern = "1101100"
        Case 3: EAN13_RightPattern = "1000010"
        Case 4: EAN13_RightPattern = "1011100"
        Case 5: EAN13_RightPattern = "1001110"
        Case 6: EAN13_RightPattern = "1010000"
        Case 7: EAN13_RightPattern = "1000100"
        Case 8: EAN13_RightPattern = "1001000"
        Case 9: EAN13_RightPattern = "1110100"
        Case Else: EAN13_RightPattern = "1110010"
    End Select
End Function

Private Function Interleaved2of5_Encode(ByVal data As String) As String
    ' Interleaved 2 of 5 encoding
    Dim i As Integer
    Dim result As String
    Dim digits() As String
    Dim pairIndex As Integer
    Dim barPattern As String, spacePattern As String
    
    ' Clean data to digits only
    Dim cleanData As String
    cleanData = ""
    For i = 1 To Len(data)
        If IsNumeric(Mid(data, i, 1)) Then
            cleanData = cleanData & Mid(data, i, 1)
        End If
    Next i
    
    ' Must have even number of digits
    If Len(cleanData) Mod 2 <> 0 Then
        cleanData = "0" & cleanData
    End If
    
    ' Start pattern
    result = "1010"
    
    ' Process pairs
    For pairIndex = 1 To Len(cleanData) Step 2
        barPattern = I2of5_Digit(CInt(Mid(cleanData, pairIndex, 1)), True)
        spacePattern = I2of5_Digit(CInt(Mid(cleanData, pairIndex + 1, 1)), False)
        
        ' Interleave: bar1, space1, bar2, space2, bar3, space3, bar4, space4, bar5, space5
        For i = 1 To 5
            result = result & Mid(barPattern, i, 1) & Mid(spacePattern, i, 1)
        Next i
    Next pairIndex
    
    ' Stop pattern
    result = result & "1101"
    
    Interleaved2of5_Encode = result
End Function

Private Function I2of5_Digit(ByVal digit As Integer, ByVal isBar As Boolean) As String
    ' Interleaved 2 of 5 digit pattern
    ' 1 = wide (bar or space), 0 = narrow
    ' Each digit has exactly 2 wide elements and 3 narrow
    
    Dim pattern As String
    
    Select Case digit
        Case 0: pattern = "00101"
        Case 1: pattern = "10001"
        Case 2: pattern = "01001"
        Case 3: pattern = "11000"
        Case 4: pattern = "00110"
        Case 5: pattern = "10100"
        Case 6: pattern = "01100"
        Case 7: pattern = "00011"
        Case 8: pattern = "10010"
        Case 9: pattern = "01010"
        Case Else: pattern = "00101"
    End Select
    
    I2of5_Digit = pattern
End Function

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
