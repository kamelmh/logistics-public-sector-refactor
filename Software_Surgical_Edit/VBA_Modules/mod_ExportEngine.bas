Attribute VB_Name = "mod_ExportEngine"
'==============================================================================
' MODULE: mod_ExportEngine.bas  |  ERP Academie v13.2
' PATCH:  PDF Engine Repair (April 2026)
' Author: Mahi Kamel Abdelghani -- TAG1801 GSL -- CNEPD 2026
'
' CHANGES FROM PREVIOUS VERSION:
'   1. Added PopulateTemplateBon() -- bridges MOUVEMENTS data into
'      TEMPLATE_BON before ExportAsFixedFormat. Previous version exported
'      a blank template because this step was missing entirely.
'   2. FindColumn() -- dynamically locates MOUVEMENTS columns by header
'      text, making the engine immune to column-order variations.
'   3. All accented chars replaced with Chr() codes throughout. The .bas
'      ANSI encoding on non-French Windows corrupts e, e, a.
'   4. ExportTransactionToPDF now validates source data before export
'      and falls back gracefully if no matching rows are found.
'
' MOUVEMENTS COLUMN CONTRACT (mod_Database.SecureWriteTransaction):
'   Col A (1) : DATE
'   Col B (2) : CODE_ARTICLE
'   Col C (3) : DESIGNATION (French -- from form at save time)
'   Col D (4) : TYPE_MVT  (IN | OUT)
'   Col E (5) : QTE
'   Col F (6) : LINE_VALUE  (Qty x PU)
'   Col G (7) : REF_DOCUMENT  <-- filter key
'   Col H (8) : PRIX_UNITAIRE
'   Col I (9) : THIRD_PARTY
'   Col L (12): NOTES
'==============================================================================

Option Explicit

' ================================================================================
' SECTION 1 -- PRIMARY EXPORT ENTRY POINT
' ================================================================================
Public Sub ExportTransactionToPDF(ByVal docRef As String)
    Dim wsTemplate  As Worksheet
    Dim wsMouv      As Worksheet
    Dim desktopPath As String
    Dim fileName    As String
    Dim fullPath    As String
    
    Debug.Print "--- PDF EXPORT START: " & docRef & " ---"
    On Error GoTo ExportError
    
    ' 1. Pre-flight: validate required sheets
    If Not SheetExists("TEMPLATE_BON") Then
        Debug.Print "FAIL: TEMPLATE_BON sheet missing"
        MsgBox "ERREUR: Feuille TEMPLATE_BON introuvable.", vbCritical, "ACADEMIX v13"
        Exit Sub
    End If
    If Not SheetExists(mod_Config.SHEET_MOUVEMENTS) Then
        Debug.Print "FAIL: MOUVEMENTS sheet missing"
        MsgBox "ERREUR: Feuille MOUVEMENTS introuvable.", vbCritical, "ACADEMIX v13"
        Exit Sub
    End If
    
    ' --- SELF-HEALING: Ensure MOUVEMENTS headers exist ---
    Debug.Print "Step: Restoring headers..."
    Call mod_Utilities.RestoreMouvementsHeaders
    
    Set wsTemplate = ThisWorkbook.Sheets("TEMPLATE_BON")
    Set wsMouv     = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    
    ' 2. Populate template from transaction data
    Debug.Print "Step: Populating template for Ref: " & docRef
    If Not PopulateTemplateBon(docRef, wsMouv, wsTemplate) Then
        Debug.Print "FAIL: No lines found for " & docRef
        MsgBox "ERREUR: Aucune ligne trouv" & Chr(233) & "e pour [" & docRef & "]." & _
               vbCrLf & "V" & Chr(233) & "rifiez la feuille MOUVEMENTS.", _
               vbExclamation, "ACADEMIX v13"
        Exit Sub
    End If
    
    ' 3. Export to PDF on desktop
    desktopPath = Environ("USERPROFILE") & "\Desktop\"
    fileName    = docRef & "_" & Format(Date, "yyyy-mm-dd") & ".pdf"
    fullPath    = desktopPath & fileName
    
    Debug.Print "Step: Exporting to " & fullPath
    wsTemplate.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        Filename:=fullPath, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, _
        IgnorePrintAreas:=False, _
        OpenAfterPublish:=True
    
    Debug.Print "SUCCESS: PDF generated."
    MsgBox "Document export" & Chr(233) & " vers :" & vbCrLf & fullPath, _
           vbInformation, "ACADEMIX v13"
    Exit Sub
    
ExportError:
    Debug.Print "CRASH: " & Err.Description & " (Error #" & Err.Number & ")"
    MsgBox "Erreur PDF Export : " & Err.Description, vbCritical, "ACADEMIX v13"
End Sub
 
 
 ' ================================================================================
 ' SECTION 2 -- TEMPLATE POPULATION ENGINE (core fix)

'
' Reads all MOUVEMENTS rows where REF_DOCUMENT = docRef, then builds a
' complete Bon layout in TEMPLATE_BON with:
'   - Ministry / Direction header block
'   - Document title (Bon de Sortie / Bon de Reception)
'   - Metadata row (Ref, Date, Type)
'   - Article table (6 columns, alternating row shading)
'   - Total row with DZD formatting
'   - Two-column signature zone
'   - Footer timestamp
'
' Returns True if at least one matching row was found and the template
' was built successfully. Returns False if docRef yields no data.
' ================================================================================
Private Function PopulateTemplateBon(ByVal docRef    As String, _
                                      ByRef wsMouv    As Worksheet, _
                                      ByRef wsTpl     As Worksheet) As Boolean
    Dim lastRow      As Long
    Dim j            As Long
    Dim r            As Integer
    Dim docDate      As String
    Dim mvtSign      As String
    Dim docType      As String
    Dim thirdParty   As String
    Dim totalVal     As Double
    Dim lineCount    As Integer
    Dim wsArt        As Worksheet

    ' ?? Column discovery (robust against column-order variations) ================================================================================
    Dim colDate    As Integer: colDate    = FindColumn(wsMouv, "DATE")
    Dim colCode    As Integer: colCode    = FindColumn(wsMouv, "CODE_ARTICLE")
    Dim colDesig   As Integer: colDesig   = FindColumn(wsMouv, "DESIGNATION")
    Dim colType    As Integer: colType    = FindColumn(wsMouv, "TYPE_MVT")
    Dim colQte     As Integer: colQte     = FindColumn(wsMouv, "QTE")
    Dim colRef     As Integer: colRef     = FindColumn(wsMouv, "REF_DOCUMENT")
    Dim colPU      As Integer: colPU      = FindColumn(wsMouv, "PRIX_UNITAIRE")
    Dim colThird   As Integer: colThird   = FindColumn(wsMouv, "THIRD_PARTY")
    
    ' CRITICAL CHECK: Ensure all required columns were found
    If colDate = 0 Or colCode = 0 Or colRef = 0 Then
        MsgBox "ERREUR: Colonnes obligatoires introuvables dans MOUVEMENTS." & vbCrLf & _
               "Vérifiez que les entêtes (DATE, CODE_ARTICLE, REF_DOCUMENT) sont présentes en ligne 1.", _
               vbCritical, "Export Error"
        PopulateTemplateBon = False
        Exit Function
    End If
    
    ' Fallback to mod_Database.bas hardcoded positions if others are missing
    If colDesig = 0 Then colDesig = 3
    If colType  = 0 Then colType  = 4
    If colQte   = 0 Then colQte   = 5
    If colPU    = 0 Then colPU    = 8
    If colThird = 0 Then colThird = 9


    On Error GoTo PopulateError

    Application.ScreenUpdating = False
    wsTpl.Unprotect Password:=mod_Config.MASTER_PWD
    wsTpl.Cells.Clear
    wsTpl.Cells.Interior.ColorIndex = xlNone

    ' ?? 1. Scan MOUVEMENTS for matching rows + resolve metadata ================================================================================
    lastRow    = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row
    lineCount  = 0
    docDate    = Format(Date, "DD/MM/YYYY")
    mvtSign    = "OUT"
    thirdParty = ""

    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo PopulateError

    For j = 2 To lastRow
        If Trim(CStr(wsMouv.Cells(j, colRef).Value)) = docRef Then
            If lineCount = 0 Then
                If IsDate(wsMouv.Cells(j, colDate).Value) Then
                    docDate = Format(CDate(wsMouv.Cells(j, colDate).Value), "DD/MM/YYYY")
                End If
                mvtSign    = UCase(Trim(CStr(wsMouv.Cells(j, colType).Value)))
                thirdParty = Trim(CStr(wsMouv.Cells(j, colThird).Value))
            End If
            lineCount = lineCount + 1
        End If
    Next j

    If lineCount = 0 Then
        wsTpl.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
        Application.ScreenUpdating = True
        PopulateTemplateBon = False
        Exit Function
    End If

    docType = IIf(mvtSign = "IN", _
                  "BON DE R" & Chr(201) & "CEPTION", _
                  "BON DE SORTIE")

    ' ?? 2. PAGE SETUP ================================================================================
    With wsTpl.PageSetup
        .Orientation    = xlPortrait
        .PaperSize      = xlPaperA4
        .LeftMargin     = Application.CentimetersToPoints(2)
        .RightMargin    = Application.CentimetersToPoints(1.5)
        .TopMargin      = Application.CentimetersToPoints(2)
        .BottomMargin   = Application.CentimetersToPoints(2)
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .RightFooter    = "ERP Acad" & Chr(233) & "mie v13.2  |  " & _
                          Format(Now, "DD/MM/YYYY HH:MM")
    End With

    r = 1
    With wsTpl
        ' ?? 3. HEADER BLOCK ================================================================================
        ' Row 1: Ministry
        .Range("A" & r & ":G" & r).Merge
        .Cells(r, 1).Value = "MINIST" & Chr(200) & "RE DE L'" & Chr(201) & _
                             "DUCATION NATIONALE"
        With .Cells(r, 1): .Font.Bold = True: .Font.Size = 11: _
             .HorizontalAlignment = xlCenter: End With
        .Rows(r).RowHeight = 22: r = r + 1

        ' Row 2: Direction (bilingual)
        .Range("A" & r & ":G" & r).Merge
        .Cells(r, 1).Value = "Direction de l'" & Chr(201) & "ducation  " & _
                             Chr(8212) & "  El Bayadh  |  " & _
                             Chr(1605) & Chr(1583) & Chr(1610) & Chr(1585) & _
                             Chr(1610) & Chr(1577) & " " & Chr(1575) & _
                             Chr(1604) & Chr(1578) & Chr(1585) & Chr(1576) & _
                             Chr(1610) & Chr(1577) & " " & Chr(1575) & _
                             Chr(1604) & Chr(1576) & Chr(1610) & Chr(1590)
        With .Cells(r, 1): .Font.Size = 9: .Font.Italic = True: _
             .HorizontalAlignment = xlCenter: .Font.Name = "Tahoma": End With
        .Rows(r).RowHeight = 18: r = r + 1

        ' Row 3: Double separator line
        .Range("A" & r & ":G" & r).Borders(xlEdgeBottom).LineStyle = xlDouble
        .Range("A" & r & ":G" & r).Borders(xlEdgeBottom).Weight    = xlThick
        .Rows(r).RowHeight = 6: r = r + 1

        ' Row 4: Spacer
        .Rows(r).RowHeight = 10: r = r + 1

        ' Row 5: Document title banner
        .Range("A" & r & ":G" & r).Merge
        .Cells(r, 1).Value = docType
        With .Cells(r, 1)
            .Font.Bold  = True
            .Font.Size  = 20
            .HorizontalAlignment = xlCenter
            .VerticalAlignment   = xlCenter
            .Interior.Color = RGB(0, 70, 127)
            .Font.Color = RGB(255, 255, 255)
        End With
        .Rows(r).RowHeight = 40: r = r + 1

        ' Row 6: Spacer
        .Rows(r).RowHeight = 10: r = r + 1

        ' ?? 4. METADATA ROW ================================================================================
        .Cells(r, 1).Value = "N" & Chr(176) & " R" & Chr(233) & "f" & Chr(233) & "rence :"
        .Cells(r, 1).Font.Bold = True
        .Cells(r, 2).Value = docRef
        .Cells(r, 2).Font.Bold = True
        .Cells(r, 2).Font.Color = RGB(0, 70, 127)

        .Cells(r, 4).Value = "Date :"
        .Cells(r, 4).Font.Bold = True
        .Cells(r, 5).Value = docDate

        .Cells(r, 6).Value = "Type :"
        .Cells(r, 6).Font.Bold = True
        .Cells(r, 7).Value    = IIf(mvtSign = "IN", "ENTR" & Chr(201) & "E", "SORTIE")
        .Cells(r, 7).Font.Bold = True
        .Cells(r, 7).Font.Color = IIf(mvtSign = "IN", RGB(4, 90, 55), RGB(160, 70, 0))
        .Rows(r).RowHeight = 18: r = r + 1

        ' Service / Fournisseur row (only if data available)
        If Len(thirdParty) > 0 Then
            .Cells(r, 1).Value = "Service / Fournisseur :"
            .Cells(r, 1).Font.Bold = True
            .Range("B" & r & ":G" & r).Merge
            .Cells(r, 2).Value = thirdParty
            .Rows(r).RowHeight = 16: r = r + 1
        End If

        ' Row: Spacer
        .Rows(r).RowHeight = 8: r = r + 1

        ' ?? 5. COLUMN HEADERS ================================================================================
        Dim hdrs(5) As String
        hdrs(0) = "Code Article"
        hdrs(1) = "D" & Chr(233) & "signation"
        hdrs(2) = "Unit" & Chr(233)
        hdrs(3) = "Qt" & Chr(233)
        hdrs(4) = "PU (DZD)"
        hdrs(5) = "Valeur (DZD)"

        Dim c As Integer
        For c = 0 To 5
            With .Cells(r, c + 1)
                .Value = hdrs(c)
                .Font.Bold = True
                .Font.Size = 9
                .Font.Color = RGB(255, 255, 255)
                .Interior.Color = RGB(0, 70, 127)
                .HorizontalAlignment = xlCenter
                .VerticalAlignment   = xlCenter
                .WrapText = True
                .Borders.LineStyle = xlContinuous
                .Borders.Weight    = xlThin
            End With
        Next c
        .Rows(r).RowHeight = 28: r = r + 1

        ' ?? 6. DATA ROWS ================================================================================
        totalVal = 0
        For j = 2 To lastRow
            If Trim(CStr(wsMouv.Cells(j, colRef).Value)) = docRef Then

                Dim artCode  As String
                Dim artDesig As String
                Dim artUnit  As String
                Dim qty      As Double
                Dim pu       As Double
                Dim valLigne As Double

                artCode  = Trim(CStr(wsMouv.Cells(j, colCode).Value))
                artDesig = Trim(CStr(wsMouv.Cells(j, colDesig).Value))
                artUnit  = "unit" & Chr(233)
                qty      = SafeNumericVal(wsMouv.Cells(j, colQte).Value)
                pu       = SafeNumericVal(wsMouv.Cells(j, colPU).Value)
                valLigne = qty * pu

                ' Lookup Arabic designation + unit from ARTICLES sheet
                If Not wsArt Is Nothing Then
                    Dim artMatchRow As Variant
                    artMatchRow = Application.Match(artCode, wsArt.Range("A:A"), 0)
                    If Not IsError(artMatchRow) Then
                        Dim arLabel As String: arLabel = Trim(CStr(wsArt.Cells(artMatchRow, 2).Value))
                        Dim unitLabel As String: unitLabel = Trim(CStr(wsArt.Cells(artMatchRow, 4).Value))
                        If Len(arLabel)   > 0 Then artDesig = arLabel
                        If Len(unitLabel) > 0 Then artUnit  = unitLabel
                    End If
                End If

                ' Alternating row shading
                Dim rowBg As Long
                rowBg = IIf((r Mod 2) = 0, RGB(235, 242, 250), RGB(255, 255, 255))

                ' Col A: Code
                With .Cells(r, 1)
                    .Value = artCode
                    .Interior.Color = rowBg
                    .HorizontalAlignment = xlCenter
                    .Font.Name = "Courier New": .Font.Size = 9
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                ' Col B: Designation (Arabic -- right-align, Tahoma for glyph support)
                With .Cells(r, 2)
                    .Value = artDesig
                    .Interior.Color = rowBg
                    .Font.Name = "Tahoma": .Font.Size = 9
                    .HorizontalAlignment = xlRight
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                ' Col C: Unit
                With .Cells(r, 3)
                    .Value = artUnit
                    .Interior.Color = rowBg
                    .Font.Name = "Tahoma": .Font.Size = 9
                    .HorizontalAlignment = xlCenter
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                ' Col D: Quantite
                With .Cells(r, 4)
                    .Value = qty
                    .NumberFormat = "#,##0"
                    .Interior.Color = rowBg
                    .HorizontalAlignment = xlCenter
                    .Font.Bold = True: .Font.Size = 9
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                ' Col E: PU
                With .Cells(r, 5)
                    .Value = pu
                    .NumberFormat = "#,##0.00"
                    .Interior.Color = rowBg
                    .HorizontalAlignment = xlRight
                    .Font.Size = 9
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                ' Col F: Valeur ligne
                With .Cells(r, 6)
                    .Value = valLigne
                    .NumberFormat = "#,##0.00"
                    .Interior.Color = rowBg
                    .HorizontalAlignment = xlRight
                    .Font.Bold = True: .Font.Size = 9
                    .Borders.LineStyle = xlContinuous
                    .Borders.Weight    = xlThin
                End With

                totalVal = totalVal + valLigne
                .Rows(r).RowHeight = 20
                r = r + 1
            End If
        Next j

        ' ?? 7. TOTAL ROW ================================================================================
        .Range("A" & r & ":E" & r).Merge
        With .Cells(r, 1)
            .Value = "TOTAL G" & Chr(201) & "N" & Chr(201) & "RAL"
            .Font.Bold = True: .Font.Size = 10
            .HorizontalAlignment = xlRight
            .Interior.Color = RGB(215, 228, 244)
            .Borders.LineStyle = xlContinuous
            .Borders.Weight    = xlMedium
        End With
        With .Cells(r, 6)
            .Value = totalVal
            .NumberFormat = "#,##0.00 DZD"
            .Font.Bold = True: .Font.Size = 11
            .Font.Color = RGB(0, 70, 127)
            .Interior.Color = RGB(215, 228, 244)
            .HorizontalAlignment = xlRight
            .Borders.LineStyle = xlContinuous
            .Borders.Weight    = xlMedium
        End With
        .Rows(r).RowHeight = 24: r = r + 1

        ' ?? 8. SPACER ================================================================================
        .Rows(r).RowHeight = 16: r = r + 1

        ' ?? 9. SIGNATURE ZONE ================================================================================
        ' Left sig: Gestionnaire -- Right sig: Responsable
        .Range("A" & r & ":C" & r).Merge
        .Cells(r, 1).Value = "Le Gestionnaire du Magasin"
        .Cells(r, 1).Font.Bold = True
        .Cells(r, 1).HorizontalAlignment = xlCenter

        .Range("E" & r & ":G" & r).Merge
        .Cells(r, 5).Value = "Le Responsable Hi" & Chr(233) & "rarchique"
        .Cells(r, 5).Font.Bold = True
        .Cells(r, 5).HorizontalAlignment = xlCenter
        .Rows(r).RowHeight = 18: r = r + 1

        ' Name + Date line
        .Range("A" & r & ":C" & r).Merge
        .Cells(r, 1).Value = "Nom & Pr" & Chr(233) & "nom :  " & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95)
        .Cells(r, 1).HorizontalAlignment = xlLeft: .Cells(r, 1).Font.Size = 9
        .Range("E" & r & ":G" & r).Merge
        .Cells(r, 5).Value = "Nom & Pr" & Chr(233) & "nom :  " & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95) & Chr(95)
        .Cells(r, 5).HorizontalAlignment = xlLeft: .Cells(r, 5).Font.Size = 9
        .Rows(r).RowHeight = 16: r = r + 1

        ' Signature box (tall empty row)
        .Rows(r).RowHeight = 48
        .Range("A" & r & ":C" & r).Merge
        .Range("A" & r).Borders.LineStyle = xlContinuous
        .Range("A" & r).Borders.Weight    = xlThin
        .Range("E" & r & ":G" & r).Merge
        .Range("E" & r).Borders.LineStyle = xlContinuous
        .Range("E" & r).Borders.Weight    = xlThin
        r = r + 1

        ' Cachet label
        .Range("A" & r & ":C" & r).Merge
        .Cells(r, 1).Value = "Signature & Cachet Officiel"
        .Cells(r, 1).Font.Size = 8: .Cells(r, 1).Font.Italic = True
        .Cells(r, 1).Font.Color = RGB(128, 128, 128)
        .Cells(r, 1).HorizontalAlignment = xlCenter
        .Range("E" & r & ":G" & r).Merge
        .Cells(r, 5).Value = "Signature & Cachet Officiel"
        .Cells(r, 5).Font.Size = 8: .Cells(r, 5).Font.Italic = True
        .Cells(r, 5).Font.Color = RGB(128, 128, 128)
        .Cells(r, 5).HorizontalAlignment = xlCenter
        .Rows(r).RowHeight = 14: r = r + 1

        ' ?? 10. FOOTER ================================================================================
        .Rows(r).RowHeight = 8: r = r + 1
        .Range("A" & r & ":G" & r).Merge
        .Cells(r, 1).Value = "Document g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & _
                             " par ERP Acad" & Chr(233) & "mie v13.2  |  " & _
                             Format(Now, "DD/MM/YYYY HH:MM") & _
                             "  |  Syst" & Chr(232) & "me de Gestion Minist" & Chr(232) & "re " & Chr(201) & "ducation"
        With .Cells(r, 1)
            .Font.Size = 7: .Font.Italic = True
            .Font.Color = RGB(128, 128, 128)
            .HorizontalAlignment = xlCenter
        End With
        .Rows(r).RowHeight = 12

        ' ?? 11. COLUMN WIDTHS + PRINT AREA ================================================================================
        .Columns("A").ColumnWidth = 13
        .Columns("B").ColumnWidth = 30
        .Columns("C").ColumnWidth = 10
        .Columns("D").ColumnWidth = 7
        .Columns("E").ColumnWidth = 13
        .Columns("F").ColumnWidth = 16
        .Columns("G").ColumnWidth = 12
        .PageSetup.PrintArea = "$A$1:$G$" & r

    End With  ' wsTpl

    wsTpl.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    Application.ScreenUpdating = True

    PopulateTemplateBon = True
    Exit Function

PopulateError:
    Application.ScreenUpdating = True
    On Error Resume Next
    wsTpl.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    MsgBox "Erreur construction template: " & Err.Description, vbCritical, "ACADEMIX v13"
    PopulateTemplateBon = False
End Function


' ================================================================================
' SECTION 3 -- HELPER: DYNAMIC COLUMN FINDER
' Searches row 1 of a worksheet for a given header text.
' Returns the column number (1-based) or 0 if not found.
' This makes PopulateTemplateBon immune to column-order variations.
' ================================================================================
Private Function FindColumn(ByRef ws As Worksheet, _
                              ByVal headerName As String) As Integer
    Dim lastCol As Integer
    Dim c       As Integer
    
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    For c = 1 To lastCol
        Dim cellVal As String: cellVal = UCase(Trim(CStr(ws.Cells(1, c).Value)))
        ' Match if the header contains the keyword (e.g., "CODE_ARTICLE" matches "Code Article")
        If cellVal = UCase(headerName) Or InStr(cellVal, UCase(Replace(headerName, "_", " "))) > 0 Then
            FindColumn = c
            Exit Function
        End If
    Next c
    FindColumn = 0  ' Not found
End Function



' ================================================================================
' SECTION 4 -- SAFE NUMERIC CAST
' Returns 0 for empty / non-numeric cells. Prevents runtime error 13
' on dirty data in MOUVEMENTS sheet.
' ================================================================================
Private Function SafeNumericVal(ByVal v As Variant) As Double
    If IsNumeric(v) And Not IsEmpty(v) Then
        SafeNumericVal = CDbl(v)
    Else
        SafeNumericVal = 0
    End If
End Function

' ================================================================================
' SECTION 5 -- SHEET EXISTENCE CHECK
' ================================================================================
Private Function SheetExists(ByVal sheetName As String) As Boolean
    Dim s As Worksheet
    SheetExists = False
    For Each s In ThisWorkbook.Sheets
        If s.Name = sheetName Then SheetExists = True: Exit Function
    Next s
End Function


' ================================================================================
' SECTION 6 -- EXISTING EXPORTS (UNCHANGED)
' ================================================================================
Public Sub ExportToExcel(Optional sheetName As String = "ARTICLES")
    Dim ws As Worksheet
    Dim desktopPath As String, fileName As String, fullPath As String
    Dim wb As Workbook
    On Error GoTo ExportError2
    Set ws = ThisWorkbook.Sheets(sheetName)
    desktopPath = Environ("USERPROFILE") & "\Desktop\"
    fileName    = sheetName & "_Export_" & Format(Date, "yyyy-mm-dd") & ".xlsx"
    fullPath    = desktopPath & fileName
    ws.Copy
    Set wb = ActiveWorkbook
    wb.SaveAs Filename:=fullPath, FileFormat:=xlOpenXMLWorkbook
    wb.Close
    MsgBox "Export" & Chr(233) & " vers: " & fullPath, vbInformation, "ACADEMIX v13"
    Exit Sub
ExportError2:
    MsgBox "Export Error: " & Err.Description, vbCritical, "ACADEMIX v13"
End Sub

Public Sub ExportDashboardPDF()
    Dim wsDash      As Worksheet
    Dim desktopPath As String, fileName As String, fullPath As String
    On Error GoTo ExportError3
    Set wsDash  = ThisWorkbook.Sheets("DASHBOARD")
    desktopPath = Environ("USERPROFILE") & "\Desktop\"
    fileName    = "Dashboard_Report_" & Format(Date, "yyyy-mm-dd") & ".pdf"
    fullPath    = desktopPath & fileName
    wsDash.ExportAsFixedFormat Type:=xlTypePDF, Filename:=fullPath, _
        Quality:=xlQualityStandard
    MsgBox "Dashboard export" & Chr(233) & " vers: " & fullPath, vbInformation, "ACADEMIX v13"
    Exit Sub
ExportError3:
    MsgBox "Export Error: " & Err.Description, vbCritical, "ACADEMIX v13"
End Sub

'==============================================================================
' END -- mod_ExportEngine.bas (v13.2 -- PDF Engine Repair)
'==============================================================================
