Attribute VB_Name = "mod_ExportEngine"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

'   - Engagement / Liquidation / Code Budgtaire lines
'   - QR code (generated BEFORE PDF export - embedded in document)
'   - Verification code (deterministic hash)
'   - NIF / NIS / RC / Article tax identifiers
'   - DGI-standard document numbering (BS-YYYY-NNNN)
'   - A4 portrait, proper margins, print area
'
' MOUVEMENTS COLUMN CONTRACT:
'   Col A: DATE | Col B: CODE_ARTICLE | Col C: DESIGNATION
'   Col D: TYPE_MVT | Col E: QTE | Col F: LINE_VALUE
'   Col G: REF_DOCUMENT | Col H: PRIX_UNITAIRE | Col I: THIRD_PARTY
'   Col L: NOTES
'==============================================================================

Option Explicit

'================================================================================
' SECTION 1 - PRIMARY EXPORT ENTRY POINT
'================================================================================

Public Sub ExportTransactionToPDF(ByVal docRef As String)
    Call ExportTransactionToPDF_Internal(docRef, False, "")
End Sub

' Silent export for batch operations - no dialog, no MsgBox, saves to specified path
Public Function ExportTransactionToPDF_Silent(ByVal docRef As String, Optional ByVal outputPath As String) As Boolean
    ExportTransactionToPDF_Silent = ExportTransactionToPDF_Internal(docRef, True, outputPath)
End Function

' Compact export - half-A5 size, ORIGINAL/COPIE markers, 2-per-page layout
Public Sub ExportTransactionToPDF_Compact(ByVal docRef As String)
    Call ExportTransactionToPDF_Internal(docRef, False, "", True)
End Sub

Private Function ExportTransactionToPDF_Internal(ByVal docRef As String, ByVal silent As Boolean, Optional ByVal outputPath As String, Optional ByVal compact As Boolean = False) As Boolean
    Dim wsTemplate  As Worksheet
    Dim wsMouv      As Worksheet
    Dim savePath    As String
    Dim fileName    As String
    Dim fullPath    As String
    
    If Not silent Then Debug.Print "--- PDF EXPORT START: " & docRef & " ---"
    On Error GoTo ExportError
    
    ' 1. Pre-flight: validate required sheets
    If Not sheetExists("TEMPLATE_BON") Then
        If Not silent Then Debug.Print "[Export] FAIL: TEMPLATE_BON sheet missing"
        GoTo ExportError
    End If
    If Not sheetExists(mod_Config.SHEET_MOUVEMENTS) Then
        If Not silent Then Debug.Print "[Export] FAIL: MOUVEMENTS sheet missing"
        GoTo ExportError
    End If
    
    ' Self-healing: ensure MOUVEMENTS headers exist
    Call mod_Utilities.RestoreMouvementsHeaders(silent:=True)
    
    Set wsTemplate = ThisWorkbook.Sheets("TEMPLATE_BON")
    Set wsMouv = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    
    ' 2. Populate template from transaction data
    If Not silent Then Debug.Print "[Export] Populating template for Ref: " & docRef
    If Not PopulateTemplateBon(docRef, wsMouv, wsTemplate, compact) Then
        If Not silent Then Debug.Print "[Export] FAIL: No lines found for " & docRef
        GoTo ExportError
    End If
    
    ' 3. Generate QR code BEFORE PDF export
    On Error Resume Next
    Dim qrRow As Long
    qrRow = GetQRRow(wsTemplate)
    Call mod_QRCode.GenerateQRCodeForForm(docRef, "TEMPLATE_BON", "F" & qrRow)
    On Error GoTo ExportError
    
    ' 4. Determine save path
    If silent Then
        fullPath = IIf(Len(outputPath) > 0, outputPath, mod_Utilities.GetSharedExportPath() & docRef & "_" & Format(Date, "yyyy-mm-dd") & ".pdf")
    Else
        savePath = SelectPDFSavePath(docRef)
        If savePath = "" Then
            Debug.Print "[Export] User cancelled save dialog"
            ExportTransactionToPDF_Internal = False
            Exit Function
        End If
        fullPath = savePath
    End If
    
    ' 5. Export to PDF (QR code now embedded in template)
    wsTemplate.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        fileName:=fullPath, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, _
        IgnorePrintAreas:=False, _
        OpenAfterPublish:=Not silent
    
    If Not silent Then
        Debug.Print "[Export] SUCCESS: PDF generated with QR code."
        MsgBox "Document export" & Chr(233) & " vers :" & vbCrLf & fullPath, _
               vbInformation, "ACADEMIX v13.2"
    End If
    
    ExportTransactionToPDF_Internal = True
    Exit Function
    
ExportError:
    If Not silent Then
        Debug.Print "[Export] CRASH: " & Err.Description & " (Error #" & Err.Number & ")"
        MsgBox "Erreur PDF Export : " & Err.Description, vbCritical, "ACADEMIX v13.2"
    End If
    ExportTransactionToPDF_Internal = False
End Function

'================================================================================
' SECTION 2 - TEMPLATE POPULATION ENGINE
'================================================================================

Private Function PopulateTemplateBon(ByVal docRef As String, _
                                      ByRef wsMouv As Worksheet, _
                                      ByRef wsTpl As Worksheet, _
                                      Optional ByVal compact As Boolean = False) As Boolean
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
    
    ' Column discovery (robust against column-order variations)
    Dim colDate    As Integer: colDate = FindColumn(wsMouv, "DATE")
    Dim colCode    As Integer: colCode = FindColumn(wsMouv, "CODE_ARTICLE")
    Dim colDesig   As Integer: colDesig = FindColumn(wsMouv, "DESIGNATION")
    Dim colType    As Integer: colType = FindColumn(wsMouv, "TYPE_MVT")
    Dim colQte     As Integer: colQte = FindColumn(wsMouv, "QTE")
    Dim colRef     As Integer: colRef = FindColumn(wsMouv, "REF_DOCUMENT")
    Dim colPU      As Integer: colPU = FindColumn(wsMouv, "PRIX_UNITAIRE")
    Dim colThird   As Integer: colThird = FindColumn(wsMouv, "THIRD_PARTY")
    Dim colNotes   As Integer: colNotes = FindColumn(wsMouv, "NOTES")
    
    ' Critical check
    If colDate = 0 Or colCode = 0 Or colRef = 0 Then
        MsgBox "ERREUR: Colonnes obligatoires introuvables dans MOUVEMENTS." & vbCrLf & _
               "V" & Chr(233) & "rifiez les ent" & Chr(234) & "tes (DATE, CODE_ARTICLE, REF_DOCUMENT).", _
               vbCritical, "Export Error"
        PopulateTemplateBon = False
        Exit Function
    End If
    
    ' Fallback to hardcoded positions
    If colDesig = 0 Then colDesig = mod_Config.COL_MOUV_DESIGNATION
    If colType = 0 Then colType = mod_Config.COL_MOUV_TYPE
    If colQte = 0 Then colQte = mod_Config.COL_MOUV_QTE
    If colPU = 0 Then colPU = mod_Config.COL_MOUV_PU
    If colThird = 0 Then colThird = mod_Config.COL_MOUV_THIRD_PARTY
    If colNotes = 0 Then colNotes = mod_Config.COL_MOUV_NOTES
    
    On Error GoTo PopulateError
    
    ' Step 1: Initialize template (page setup, clear, unprotect)
    r = mod_TemplateBuilder.InitializeTemplate(wsTpl, compact)
    
    ' Scan MOUVEMENTS for matching rows
    lastRow = wsMouv.Cells(wsMouv.Rows.Count, 1).End(xlUp).Row
    lineCount = 0
    docDate = Format(Date, "DD/MM/YYYY")
    mvtSign = "OUT"
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
                mvtSign = UCase(Trim(CStr(wsMouv.Cells(j, colType).Value)))
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
    
    ' Step 2: Header
    r = mod_TemplateBuilder.PopulateHeader(wsTpl, r, docRef, docDate, docType, _
                                           mvtSign, thirdParty, compact)
    
    ' Step 3: Column headers
    r = mod_TemplateBuilder.PopulateColumnHeaders(wsTpl, r, compact)
    
    ' Step 4: Data rows
    totalVal = 0
    r = mod_TemplateBuilder.PopulateDataRows(wsTpl, wsMouv, wsArt, r, docRef, _
                                              colCode, colDesig, colQte, colPU, colRef, _
                                              compact, totalVal)
    
    ' Step 5: Totals and footer
    r = mod_TemplateBuilder.PopulateTotalsAndFooter(wsTpl, r, totalVal, compact, _
                                                    thirdParty, docRef, docType, docDate)
    
    ' Step 6: Signatures and verify
    r = mod_TemplateBuilder.PopulateSignaturesAndVerify(wsTpl, r, thirdParty, compact, _
                                                        docRef, docType, docDate, totalVal)
    
    ' Step 7: Column widths + print area
    If compact Then
        wsTpl.Columns("A").ColumnWidth = 11
        wsTpl.Columns("B").ColumnWidth = 22
        wsTpl.Columns("C").ColumnWidth = 8
        wsTpl.Columns("D").ColumnWidth = 6
        wsTpl.Columns("E").ColumnWidth = 10
        wsTpl.Columns("F").ColumnWidth = 12
        wsTpl.Columns("G").ColumnWidth = 10
    Else
        wsTpl.Columns("A").ColumnWidth = 13
        wsTpl.Columns("B").ColumnWidth = 30
        wsTpl.Columns("C").ColumnWidth = 10
        wsTpl.Columns("D").ColumnWidth = 7
        wsTpl.Columns("E").ColumnWidth = 13
        wsTpl.Columns("F").ColumnWidth = 16
        wsTpl.Columns("G").ColumnWidth = 12
    End If
    wsTpl.PageSetup.PrintArea = "$A$1:$G$" & r
    
    wsTpl.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    Application.ScreenUpdating = True
    
    PopulateTemplateBon = True
    Exit Function

PopulateError:
    Application.ScreenUpdating = True
    On Error Resume Next
    wsTpl.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    MsgBox "Erreur construction template: " & Err.Description, vbCritical, "ACADEMIX v13.2"
    PopulateTemplateBon = False
End Function

'================================================================================
' SECTION 2B - VERIFICATION CODE GENERATOR
'================================================================================

'================================================================================
' SECTION 3 - DYNAMIC COLUMN FINDER
'================================================================================

Private Function FindColumn(ByRef ws As Worksheet, _
                              ByVal headerName As String) As Integer
    Dim lastCol As Integer
    Dim c       As Integer
    
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    For c = 1 To lastCol
        Dim cellVal As String
        cellVal = UCase(Trim(CStr(ws.Cells(1, c).Value)))
        If cellVal = UCase(headerName) Or _
           InStr(cellVal, UCase(Replace(headerName, "_", " "))) > 0 Then
            FindColumn = c
            Exit Function
        End If
    Next c
    FindColumn = 0
End Function

'================================================================================
' SECTION 4 - SHEET EXISTENCE CHECK
'================================================================================

Private Function sheetExists(ByVal sheetName As String) As Boolean
    Dim s As Worksheet
    sheetExists = False
    For Each s In ThisWorkbook.Sheets
        If s.Name = sheetName Then
            sheetExists = True
            Exit Function
        End If
    Next s
End Function

'================================================================================
' SECTION 5B - PDF SAVE PATH SELECTOR
'================================================================================

Private Function SelectPDFSavePath(ByVal docRef As String) As String
    Dim dlg As Object
    Dim fileName As String
    Dim desktopPath As String
    
    On Error GoTo FallbackDesktop
    
    Set dlg = Application.FileDialog(2)
    If dlg Is Nothing Then GoTo FallbackDesktop
    
    fileName = docRef & "_" & Format(Date, "yyyy-mm-dd") & ".pdf"
    
    With dlg
        .Title = "Enregistrer le document PDF -- " & docRef
        .InitialFileName = mod_Utilities.GetSharedExportPath() & fileName
        .Filters.Clear
        .Filters.Add "PDF Files", "*.pdf"
        .FilterIndex = 1
        
        If .Show = -1 Then
            SelectPDFSavePath = .SelectedItems(1)
            If Right(SelectPDFSavePath, 4) <> ".pdf" Then
                SelectPDFSavePath = SelectPDFSavePath & ".pdf"
            End If
        Else
            SelectPDFSavePath = ""
        End If
    End With
    
    Set dlg = Nothing
    Exit Function

FallbackDesktop:
    desktopPath = mod_Utilities.GetSharedExportPath()
    SelectPDFSavePath = desktopPath & docRef & "_" & Format(Date, "yyyy-mm-dd") & ".pdf"
    Set dlg = Nothing
End Function

'================================================================================
' SECTION 5C - GET QR CODE ROW
'================================================================================

Private Function GetQRRow(ByRef ws As Worksheet) As Long
    Dim r As Long
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    For r = 1 To lastRow
        If ws.Range("F" & r).Value = "[QR]" Then
            GetQRRow = r
            Exit Function
        End If
    Next r
    
    GetQRRow = lastRow - 3
End Function

'================================================================================
' SECTION 6 - EXISTING EXPORTS
'================================================================================

Public Sub ExportToExcel(Optional sheetName As String = "ARTICLES")
    Dim ws As Worksheet
    Dim desktopPath As String, fileName As String, fullPath As String
    Dim wb As Workbook
    On Error GoTo ExportError2
    Set ws = ThisWorkbook.Sheets(sheetName)
    desktopPath = mod_Utilities.GetSharedExportPath()
    fileName = sheetName & "_Export_" & Format(Date, "yyyy-mm-dd") & ".xlsx"
    fullPath = desktopPath & fileName
    ws.Copy
    Set wb = ActiveWorkbook
    wb.SaveAs fileName:=fullPath, FileFormat:=xlOpenXMLWorkbook
    wb.Close
    MsgBox "Export" & Chr(233) & " vers: " & fullPath, vbInformation, "ACADEMIX v13.2"
    Exit Sub
ExportError2:
    MsgBox "Export Error: " & Err.Description, vbCritical, "ACADEMIX v13.2"
End Sub

Public Sub ExportDashboardPDF()
    Dim wsDash      As Worksheet
    Dim desktopPath As String, fileName As String, fullPath As String
    On Error GoTo ExportError3
    Set wsDash = ThisWorkbook.Sheets("DASHBOARD")
    desktopPath = mod_Utilities.GetSharedExportPath()
    fileName = "Dashboard_Report_" & Format(Date, "yyyy-mm-dd") & ".pdf"
    fullPath = desktopPath & fileName
    
    ' Proper page setup for dashboard export
    With wsDash.PageSetup
        .Orientation = xlPortrait
        .PaperSize = xlPaperA4
        .FitToPagesWide = 1
        .FitToPagesTall = 1
        .LeftMargin = Application.CentimetersToPoints(1.5)
        .RightMargin = Application.CentimetersToPoints(1.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1.5)
        .CenterHorizontally = True
    End With
    
    wsDash.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        fileName:=fullPath, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, _
        OpenAfterPublish:=True
    
    MsgBox "Dashboard export" & Chr(233) & " vers: " & fullPath, vbInformation, "ACADEMIX v13.2"
    Exit Sub
ExportError3:
    MsgBox "Export Error: " & Err.Description, vbCritical, "ACADEMIX v13.2"
End Sub

' ================================================================================
' TASK CALLBACK STUB - Added Session 22
' Referenced by MAIN_MACROS and mod_TaskOrchestrator ("RUN-BACKUP" / "BACKUP-DATA")
' as runtime Application.Run callback. Delegates to ExportDashboardPDF (closest
' "export everything" equivalent).
' ================================================================================
Public Sub ExportAll()
    Call ExportDashboardPDF
End Sub

'==============================================================================
' END -- mod_ExportEngine.bas
'==============================================================================
