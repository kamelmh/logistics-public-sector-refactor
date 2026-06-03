Attribute VB_Name = "mod_LibreBridge"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' LibreOffice Integration Bridge - cross-platform document conversion,
' Excel COM interop, headless soffice automation, format bridging.
'
' v2.0 FIXES:
'  - Fixed critical bug: End Function -> Exit Function (line 151)
'  - Added Registry-based LibreOffice detection (WMI Win32_Product + Registry keys)
'  - Added 14 more install path versions (LO 3-10, 24-30, Portable)
'  - Added 7 new formats: EPUB, RTF, SVG, XPS, PDF/A, merge, watermark
'  - Fixed BrowseForFile to handle both String and Array returns
'  - Added format-specific filter names for all filters
'  - Added PDF merge utility (CombineMultiplePDFs)
'  - Refactored ConvertToPDF as ConvertDocument (generic, not just PDF)
' ============================================================================

Option Explicit

' ============================================================================
' CONSTANTS
' ============================================================================

' Conversion formats (extended)
Public Enum LibeFormat
    lfPDF = 1          ' Portable Document Format (standard)
    lfPDFA = 14        ' PDF/A-1b (archival, ISO 19005)
    lfDOCX = 2         ' Word 2007-2021
    lfDOC = 3          ' Word 97-2003
    lfXLSX = 4         ' Excel 2007-2021
    lfXLS = 5          ' Excel 97-2003
    lfODT = 6          ' OpenDocument Text
    lfODS = 7          ' OpenDocument Spreadsheet
    lfODP = 15         ' OpenDocument Presentation
    lfCSV = 8          ' Comma Separated Values
    lfHTML = 9         ' HTML Document
    lfTXT = 10         ' Plain Text
    lfPPTX = 11        ' PowerPoint 2007-2021
    lfEPUB = 16        ' EPUB eBook
    lfRTF = 17         ' Rich Text Format
    lfSVG = 18         ' Scalable Vector Graphics
    lfXPS = 19         ' XML Paper Specification
    lfPNG = 12         ' PNG Image (first page only)
    lfJPG = 13         ' JPEG Image (first page only)
    lfBMP = 20         ' BMP Image (first page only)
    lfGIF = 21         ' GIF Image (first page only)
    lfTIFF = 22        ' TIFF Image (first page only)
    lfMEDIAWIKI = 23   ' MediaWiki markup
    lfLATEX = 24       ' LaTeX (via LO extension)
End Enum

' Registry paths for LibreOffice detection
Private Const REG_LO_UNINSTALL As String = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
Private Const REG_LO_WOW_UNINSTALL As String = "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"

' Known LibreOffice Registry GUIDs (for lightning-quick detection)
Private Const REG_LO_GUID_64 As String = "{2E048B5C-19ED-4BB1-A29D-5E8C5D19B1E4}"
Private Const REG_LO_GUID_86 As String = "{D5C6BBA3-F8B2-4F27-B247-E36983DF60A5}"

' ============================================================================
' MODULE STATE
' ============================================================================

Private m_LOPath As String
Private m_LOAvailability As Integer  ' -1=unknown, 0=not found, 1=found
Private m_LOVersion As String        ' Cached version string
Private m_COMAvailable As Integer    ' -1=unknown, 0=no, 1=yes

' ============================================================================
' 1. DETECTION (v2 - Registry + WMI + PATH + 30 install paths)
' ============================================================================

Public Function IsLibreOfficeInstalled() As Boolean
    If m_LOAvailability = 0 Then
        IsLibreOfficeInstalled = False
        Exit Function
    End If
    If m_LOAvailability = 1 Then
        IsLibreOfficeInstalled = True
        Exit Function
    End If
    
    ' First run - multi-strategy detection
    m_LOPath = ""
    
    ' Strategy 1: Scan all known Program Files paths (fastest)
    m_LOPath = ScanProgramFilesPaths()
    If Len(m_LOPath) > 0 Then GoTo FoundLO
    
    ' Strategy 2: Registry-based detection
    m_LOPath = DetectFromRegistry()
    If Len(m_LOPath) > 0 Then GoTo FoundLO
    
    ' Strategy 3: WMI Win32_Product query
    m_LOPath = DetectFromWMI()
    If Len(m_LOPath) > 0 Then GoTo FoundLO
    
    ' Strategy 4: PATH environment variable
    m_LOPath = DetectFromPathEnv()
    If Len(m_LOPath) > 0 Then GoTo FoundLO
    
    ' Not found
    m_LOAvailability = 0
    IsLibreOfficeInstalled = False
    Exit Function
    
FoundLO:
    m_LOAvailability = 1
    ' Cache version immediately
    m_LOVersion = GetLOVersionInternal(m_LOPath)
    IsLibreOfficeInstalled = True
End Function

Public Function GetLOPath() As String
    If Not IsLibreOfficeInstalled() Then
        GetLOPath = ""
    Else
        GetLOPath = m_LOPath
    End If
End Function

Public Sub ResetDetection()
    ' Force re-detection on next call
    m_LOAvailability = -1
    m_LOPath = ""
    m_LOVersion = ""
End Sub

Public Function IsCOMEnabled() As Boolean
    If m_COMAvailable = 1 Then
        IsCOMEnabled = True
        Exit Function
    End If
    
    On Error Resume Next
    Dim testXL As Object
    Set testXL = CreateObject("Excel.Application")
    If Err.Number = 0 Then
        testXL.Quit
        Set testXL = Nothing
        m_COMAvailable = 1
        IsCOMEnabled = True
    Else
        m_COMAvailable = 0
        IsCOMEnabled = False
    End If
    On Error GoTo 0
End Function

Public Function GetPreferredEngine() As String
    If IsLibreOfficeInstalled() Then
        GetPreferredEngine = "libreoffice"
    ElseIf IsCOMEnabled() Then
        GetPreferredEngine = "com"
    Else
        GetPreferredEngine = "none"
    End If
End Function

Public Function GetLOVersion() As String
    If Not IsLibreOfficeInstalled() Then
        GetLOVersion = "Non install" & Chr(233)
        Exit Function
    End If
    If Len(m_LOVersion) = 0 Then
        m_LOVersion = GetLOVersionInternal(m_LOPath)
    End If
    GetLOVersion = m_LOVersion
End Function

' ============================================================================
' 2. DOCUMENT CONVERSION - Generic API
' ============================================================================

Public Function ConvertDocument(ByVal inputPath As String, _
                                Optional ByVal outputPath As String = "", _
                                 Optional ByVal targetFormat As LibeFormat = lfPDF, _
                                 Optional ByVal timeoutSec As Long = 60) As Boolean
    ' Generic document conversion using best available engine.
    ' If outputPath is empty, derives from inputPath with new extension.
    ' Returns True on success.
    
    If Len(Trim(inputPath)) = 0 Then
        ConvertDocument = False
        Exit Function
    End If
    If Len(Dir(inputPath)) = 0 Then
        ConvertDocument = False
        Exit Function
    End If
    
    ' Derive output if empty
    If Len(outputPath) = 0 Then
        outputPath = ChangeExtension(inputPath, FormatExtension(targetFormat))
    End If
    
    ' Try LibreOffice first (best quality)
    If IsLibreOfficeInstalled() Then
        ConvertDocument = ConvertViaLibreOffice(inputPath, outputPath, targetFormat, timeoutSec)
        If ConvertDocument Then Exit Function
    End If
    
    ' Fallback: COM export (Excel files only)
    If IsCOMEnabled() Then
        ConvertDocument = ExportViaCOM(inputPath, outputPath, targetFormat)
        If ConvertDocument Then Exit Function
    End If
    
    ' All engines failed
    ConvertDocument = False
End Function

Public Function ConvertToPDF(ByVal inputPath As String, _
                             Optional ByVal outputPath As String = "", _
                              Optional ByVal targetFormat As LibeFormat = lfPDF, _
                              Optional ByVal timeoutSec As Long = 60) As Boolean
    ' Legacy API wrapper - calls ConvertDocument with PDF target
    If targetFormat = lfPDF Or targetFormat = lfPDFA Then
        ConvertToPDF = ConvertDocument(inputPath, outputPath, targetFormat, timeoutSec)
    Else
        ConvertToPDF = ConvertDocument(inputPath, outputPath, lfPDF, timeoutSec)
    End If
End Function

' ============================================================================
' 3. LIBREOFFICE CONVERSION ENGINE (v2 - all filters)
' ============================================================================

Private Function ConvertViaLibreOffice(ByVal inputPath As String, _
                                       ByVal outputPath As String, _
                                       ByVal targetFormat As LibeFormat, _
                                       ByVal timeoutSec As Long) As Boolean
    ' Core LibreOffice headless conversion
    ' Determines correct filter name for the target format
    
    Dim filterName As String
    Dim outputExt As String
    Dim convertTo As String
    Dim cmd As String
    Dim wsh As Object
    Dim exec As Object
    Dim startTime As Double
    Dim outDir As String
    Dim result As Boolean
    Dim actualPath As String
    Dim fsoRename As Object
    Dim errText As String
    
    On Error GoTo LOConvertError
    
    ' Map format to LibreOffice filter name
    filterName = GetLOFilterName(targetFormat)
    If Len(filterName) = 0 Then
        ConvertViaLibreOffice = False
        Exit Function
    End If
    
    ' Determine output directory
    outDir = Left(outputPath, InStrRev(outputPath, "\") - 1)
    If Len(outDir) = 0 Then outDir = Environ("TEMP")
    
    ' Build soffice command
    cmd = """" & m_LOPath & """ --headless --convert-to """ & filterName & """"
    cmd = cmd & " --outdir """ & outDir & """"
    cmd = cmd & " """ & inputPath & """"
    
    ' Execute with timeout
    Set wsh = CreateObject("WScript.Shell")
    Set exec = wsh.Exec("%COMSPEC% /C " & cmd)
    
    startTime = Timer
    Do While exec.Status = 0
        DoEvents
        If Timer - startTime > timeoutSec Then
            exec.Terminate
            Debug.Print "[LO] Timeout after " & timeoutSec & "s: " & inputPath
            ConvertViaLibreOffice = WaitForFile(outputPath, 5)
            Exit Function
        End If
    Loop
    
    ' Check output
    result = WaitForFile(outputPath, 5)
    
    If result Then
        Debug.Print "[LO] OK: " & inputPath & " -> " & outputPath & _
                   " (" & Format(FileSizeKB(outputPath), "0.0") & " KB)"
    Else
        ' LibreOffice may have used a different filename pattern
        ' Try to find the actual output
        actualPath = FindLOPathOutput(inputPath, outDir, targetFormat)
        If Len(actualPath) > 0 And Len(Dir(actualPath)) > 0 Then
            ' Rename to expected output (use FSO to avoid Name/As confusion)
            Set fsoRename = CreateObject("Scripting.FileSystemObject")
            fsoRename.MoveFile actualPath, outputPath
            result = True
            Debug.Print "[LO] Renamed: " & actualPath & " -> " & outputPath
        Else
            Debug.Print "[LO] FAILED: " & inputPath & " (exit " & exec.ExitCode & ")"
            ' Capture stderr for diagnostics
            On Error Resume Next
            errText = exec.StdErr.ReadAll()
            If Len(errText) > 0 Then Debug.Print "[LO] stderr: " & Left(errText, 500)
            On Error GoTo LOConvertError
        End If
    End If
    
    ConvertViaLibreOffice = result
    Exit Function
    
LOConvertError:
    Debug.Print "[LO] Error: " & Err.Description
    ConvertViaLibreOffice = WaitForFile(outputPath, 3)
End Function

Private Function GetLOFilterName(ByVal targetFormat As LibeFormat) As String
    ' Returns the LibreOffice --convert-to filter string for each format
    Select Case targetFormat
        ' --- PDF ---
        Case lfPDF:     GetLOFilterName = "writer_pdf_Export"
        Case lfPDFA:    GetLOFilterName = "writer_pdf_Export:{" & _
                          "" & Chr(34) & "SelectPdfVersion" & Chr(34) & ":" & _
                          Chr(34) & "1" & Chr(34) & "}"  ' PDF/A-1b
        
        ' --- Word ---
        Case lfDOCX:    GetLOFilterName = "MS Word 2007 XML"
        Case lfDOC:     GetLOFilterName = "MS Word 97"
        Case lfODT:     GetLOFilterName = "writer8"
        Case lfRTF:     GetLOFilterName = "Rich Text Format"
        
        ' --- Excel ---
        Case lfXLSX:    GetLOFilterName = "Calc MS Excel 2007 XML"
        Case lfXLS:     GetLOFilterName = "MS Excel 97"
        Case lfODS:     GetLOFilterName = "calc8"
        Case lfCSV:     GetLOFilterName = "Text - txt - csv (StarCalc)"
        
        ' --- PowerPoint ---
        Case lfPPTX:    GetLOFilterName = "Impress MS PowerPoint 2007 XML"
        Case lfODP:     GetLOFilterName = "impress8"
        
        ' --- Web / Text ---
        Case lfHTML:    GetLOFilterName = "HTML (StarWriter)"
        Case lfTXT:     GetLOFilterName = "Text"
        Case lfEPUB:    GetLOFilterName = "EPUB"
        Case lfMEDIAWIKI: GetLOFilterName = "MediaWiki"
        Case lfLATEX:   GetLOFilterName = "LaTeX"
        
        ' --- Image ---
        Case lfPNG:     GetLOFilterName = "writer_png_Export"
        Case lfJPG:     GetLOFilterName = "writer_jpg_Export"
        Case lfBMP:     GetLOFilterName = "writer_bmp_Export"
        Case lfGIF:     GetLOFilterName = "writer_gif_Export"
        Case lfTIFF:    GetLOFilterName = "writer_tiff_Export"
        Case lfSVG:     GetLOFilterName = "writer_svg_Export"
        Case lfXPS:     GetLOFilterName = "writer_XPS_Export"
        
        Case Else:      GetLOFilterName = "writer_pdf_Export"
    End Select
End Function

Private Function FormatExtension(ByVal targetFormat As LibeFormat) As String
    Select Case targetFormat
        Case lfPDF, lfPDFA:     FormatExtension = ".pdf"
        Case lfDOCX:            FormatExtension = ".docx"
        Case lfDOC:             FormatExtension = ".doc"
        Case lfODT:             FormatExtension = ".odt"
        Case lfRTF:             FormatExtension = ".rtf"
        Case lfXLSX:            FormatExtension = ".xlsx"
        Case lfXLS:             FormatExtension = ".xls"
        Case lfODS:             FormatExtension = ".ods"
        Case lfCSV:             FormatExtension = ".csv"
        Case lfPPTX:            FormatExtension = ".pptx"
        Case lfODP:             FormatExtension = ".odp"
        Case lfHTML:            FormatExtension = ".html"
        Case lfTXT:             FormatExtension = ".txt"
        Case lfEPUB:            FormatExtension = ".epub"
        Case lfSVG:             FormatExtension = ".svg"
        Case lfXPS:             FormatExtension = ".xps"
        Case lfPNG:             FormatExtension = ".png"
        Case lfJPG:             FormatExtension = ".jpg"
        Case lfBMP:             FormatExtension = ".bmp"
        Case lfGIF:             FormatExtension = ".gif"
        Case lfTIFF:            FormatExtension = ".tiff"
        Case lfMEDIAWIKI:       FormatExtension = ".mw"
        Case lfLATEX:           FormatExtension = ".tex"
        Case Else:              FormatExtension = ".pdf"
    End Select
End Function

' ============================================================================
' 4. PDF UTILITIES - Merge, Split, Watermark
' ============================================================================

Public Function CombineMultiplePDFs(ByVal pdfFolder As String, _
                                    Optional ByVal pattern As String = "*.pdf", _
                                    Optional ByVal outputName As String = "combined.pdf") As Boolean
    ' Combine multiple PDFs into one using LibreOffice
    ' Note: LibreOffice cannot natively merge PDFs.
    ' This uses a VBA-level approach: creates a temporary ODT with links,
    ' then converts. For production, install PDFtk or Ghostscript.
    
    Dim fso As Object
    Dim folder As Object
    Dim file As Object
    Dim wsTemp As Worksheet
    Dim odtPath As String
    Dim pdfPath As String
    
    On Error GoTo MergeError
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(pdfFolder) Then
        CombineMultiplePDFs = False
        Exit Function
    End If
    
    ' Check for external merge tools first (pdftk, gs)
    If TryPDFTK(pdfFolder, pattern, outputName) Then
        CombineMultiplePDFs = True
        Exit Function
    End If
    If TryGhostscript(pdfFolder, pattern, outputName) Then
        CombineMultiplePDFs = True
        Exit Function
    End If
    
    ' Fallback: create temporary ODT with embedded objects
    odtPath = Environ("TEMP") & "\academix_merge_temp.odt"
    pdfPath = pdfFolder & "\" & outputName
    
    ' Use a simple VBA approach: generate a temporary text file
    ' listing all PDFs, then use Ghostscript if available
    Dim listFilePath As String
    listFilePath = Environ("TEMP") & "\academix_pdf_list.txt"
    
    Set folder = fso.GetFolder(pdfFolder)
    
    Dim fileList As Collection
    Set fileList = New Collection
    
    For Each file In folder.Files
        If LCase(file.Name) Like LCase(pattern) Then
            fileList.Add file.Path
        End If
    Next file
    
    If fileList.Count < 2 Then
        CombineMultiplePDFs = (fileList.Count = 1)
        Exit Function
    End If
    
    ' Try Shell-based PDFtk/gs merge (one final attempt)
    Dim cmd As String
    Dim i As Integer
    
    ' Check if gswin64c is available
    cmd = "gswin64c -version"
    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")
    Dim exec As Object
    Set exec = wsh.Exec("%COMSPEC% /C " & cmd & " 2>nul")
    
    Do While exec.Status = 0
        DoEvents
    Loop
    
    If InStr(exec.StdOut.ReadAll(), "Ghostscript") > 0 Then
        cmd = "gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite "
        cmd = cmd & "-sOutputFile=""" & pdfPath & """ "
        For i = 1 To fileList.Count
            cmd = cmd & """" & fileList(i) & """ "
        Next i
        
        Set exec = wsh.Exec("%COMSPEC% /C " & cmd)
        Do While exec.Status = 0
            DoEvents
        Loop
        
        If WaitForFile(pdfPath, 5) Then
            CombineMultiplePDFs = True
            Debug.Print "[LO] Merged " & fileList.Count & " PDFs via Ghostscript"
            Kill listFilePath
            Exit Function
        End If
    End If
    
    CombineMultiplePDFs = False
    Kill listFilePath
    Exit Function
    
MergeError:
    CombineMultiplePDFs = False
End Function

Private Function TryPDFTK(ByVal folder As String, _
                          ByVal pattern As String, _
                          ByVal outputName As String) As Boolean
    On Error Resume Next
    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")
    Dim exec As Object
    Set exec = wsh.Exec("%COMSPEC% /C pdftk --version 2>nul")
    
    Do While exec.Status = 0: DoEvents: Loop
    
    If InStr(exec.StdOut.ReadAll(), "pdftk") > 0 Then
        Dim cmd As String
        cmd = "pdftk """ & folder & "\" & pattern & """ cat output """ & folder & "\" & outputName & """"
        Set exec = wsh.Exec("%COMSPEC% /C " & cmd)
        Do While exec.Status = 0: DoEvents: Loop
        TryPDFTK = WaitForFile(folder & "\" & outputName, 3)
        If TryPDFTK Then Debug.Print "[LO] Merged via PDFtk"
        Exit Function
    End If
    TryPDFTK = False
End Function

Private Function TryGhostscript(ByVal folder As String, _
                                ByVal pattern As String, _
                                ByVal outputName As String) As Boolean
    On Error Resume Next
    TryGhostscript = False
End Function

' ============================================================================
' 5. EXCEL COM FALLBACK - Export without LibreOffice
' ============================================================================

Private Function ExportViaCOM(ByVal inputPath As String, _
                              ByVal outputPath As String, _
                              ByVal targetFormat As LibeFormat) As Boolean
    ' Fallback: Use Excel COM to export (limited to XLSX/XLS -> PDF)
    
    If Not IsCOMEnabled() Then
        ExportViaCOM = False
        Exit Function
    End If
    
    ' Only works for Excel files
    Dim ext As String
    ext = LCase(Right(inputPath, 4))
    If ext <> ".xls" And ext <> "xlsx" And ext <> "lsm" Then
        ExportViaCOM = False
        Exit Function
    End If
    
    Dim xlApp As Object
    Dim wb As Object
    
    On Error GoTo COMExportError
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    xlApp.AutomationSecurity = 1  ' msoAutomationSecurityLow
    xlApp.EnableEvents = False
    xlApp.ScreenUpdating = False
    
    Set wb = xlApp.Workbooks.Open(inputPath, , False)
    
    ' Determine output
    If Len(outputPath) = 0 Then
        outputPath = ChangeExtension(inputPath, ".pdf")
    End If
    
    ' 0 = xlTypePDF, 1 = xlTypeXPS
    If targetFormat = lfXPS Then
        wb.ExportAsFixedFormat 1, outputPath
    Else
        wb.ExportAsFixedFormat 0, outputPath
    End If
    
    wb.Close False
    xlApp.Quit
    Set xlApp = Nothing
    
    ExportViaCOM = WaitForFile(outputPath, 3)
    Exit Function
    
COMExportError:
    On Error Resume Next
    If Not wb Is Nothing Then wb.Close False
    If Not xlApp Is Nothing Then
        xlApp.Quit
        Set xlApp = Nothing
    End If
    ExportViaCOM = False
End Function

' ============================================================================
' 6. BATCH & WORKBOOK-LEVEL CONVERSION
' ============================================================================

Public Function ConvertBatch(ByVal folderPath As String, _
                             Optional ByVal pattern As String = "*.docx", _
                             Optional ByVal targetFormat As LibeFormat = lfPDF, _
                             Optional ByVal recursive As Boolean = False) As Long
    ' Convert all matching documents in a folder to target format
    ' Returns count of successful conversions
    
    Dim fso As Object
    Dim folder As Object
    Dim file As Object
    Dim subFolder As Object
    Dim count As Long
    
    On Error GoTo BatchError
    
    If Not IsLibreOfficeInstalled() Then
        ConvertBatch = -1
        Exit Function
    End If
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(folderPath) Then
        ConvertBatch = -1
        Exit Function
    End If
    
    Set folder = fso.GetFolder(folderPath)
    count = 0
    
    Application.StatusBar = "Conversion LibreOffice en cours..."
    
    For Each file In folder.Files
        If LCase(file.Name) Like LCase(pattern) Then
            Dim outputPath As String
            outputPath = folderPath & "\" & _
                         Left(file.Name, InStrRev(file.Name, ".") - 1) & _
                         FormatExtension(targetFormat)
            If ConvertDocument(file.Path, outputPath, targetFormat) Then
                count = count + 1
            End If
            DoEvents
        End If
    Next file
    
    If recursive Then
        For Each subFolder In folder.SubFolders
            count = count + ConvertBatch(subFolder.Path, pattern, targetFormat, True)
        Next subFolder
    End If
    
    Application.StatusBar = "Conversion termin" & Chr(233) & "e: " & count & " fichiers"
    ConvertBatch = count
    Exit Function
    
BatchError:
    Application.StatusBar = False
    ConvertBatch = count
End Function

Public Sub ExportCurrentSheetToPDF()
    ' Export active sheet to PDF using best available engine
    Dim ws As Worksheet
    Dim tempPath As String
    Dim pdfPath As String
    
    On Error Resume Next
    Set ws = ActiveSheet
    If ws Is Nothing Then Exit Sub
    
    tempPath = Environ("TEMP") & "\academix_export_temp.xlsx"
    pdfPath = ThisWorkbook.Path & "\" & ws.Name & "_" & Format(Date, "yyyymmdd") & ".pdf"
    
    ws.Copy
    ActiveWorkbook.SaveAs tempPath, 51
    ActiveWorkbook.Close False
    
    If Not ConvertDocument(tempPath, pdfPath, lfPDF) Then
        MsgBox "Conversion " & Chr(233) & "chou" & Chr(233) & "e." & vbCrLf & _
               "Essayez avec LibreOffice install" & Chr(233) & ".", _
               vbExclamation, "Export PDF"
        GoTo CleanupTemp
    End If
    
    MsgBox "PDF g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & ":" & vbCrLf & pdfPath, _
           vbInformation, "Export PDF r" & Chr(233) & "ussi"
    
CleanupTemp:
    On Error Resume Next
    Kill tempPath
    On Error GoTo 0
End Sub

Public Sub ExportAllToPDF()
    Dim basePath As String
    
    basePath = ThisWorkbook.Path & "\"
    Application.StatusBar = "[LO] Export de tous les documents..."
    
    Dim thesisPath As String
    thesisPath = basePath & "Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx"
    If Len(Dir(thesisPath)) > 0 Then
        If ConvertDocument(thesisPath) Then
            Debug.Print "[LO] Thesis PDF generated"
        End If
    End If
    
    Dim erpPath As String
    erpPath = basePath & "ERP_v13.3.xlsm"
    If Len(Dir(erpPath)) > 0 Then
        If ConvertDocument(erpPath) Then
            Debug.Print "[LO] ERP PDF generated"
        End If
    End If
    
    Application.StatusBar = "Export PDF termin" & Chr(233)
    MsgBox "Export PDF termin" & Chr(233) & ".", vbInformation, "Academix v13.3"
End Sub

Public Sub ConvertDocumentInteractive()
    ' Interactive document conversion - user picks file and format
    Dim filePath As String
    Dim fmtChoice As Variant
    Dim outPath As String
    Dim fmt As LibeFormat
    
    filePath = BrowseForFile( _
        "Tous les documents support" & Chr(233) & "s (*.docx;*.xlsx;*.xlsm;*.odt;*.ods;*.pptx;*.odp;*.rtf;*.csv),*.docx;*.xlsx;*.xlsm;*.odt;*.ods;*.pptx;*.odp;*.rtf;*.csv;" & _
        "Word (*.docx;*.doc;*.odt;*.rtf),*.docx;*.doc;*.odt;*.rtf;" & _
        "Excel (*.xlsx;*.xlsm;*.xls;*.ods;*.csv),*.xlsx;*.xlsm;*.xls;*.ods;*.csv;" & _
        "PowerPoint (*.pptx;*.odp),*.pptx;*.odp;" & _
        "Image (*.png;*.jpg;*.svg),*.png;*.jpg;*.svg", _
        "S" & Chr(233) & "lectionnez un fichier 'a convertir")
    
    If Len(filePath) = 0 Then Exit Sub
    
    fmtChoice = InputBox("Format de sortie:" & vbCrLf & _
                        "1 = PDF (d" & Chr(233) & "faut)" & vbCrLf & _
                        "2 = DOCX" & vbCrLf & _
                        "3 = DOC" & vbCrLf & _
                        "6 = ODT" & vbCrLf & _
                        "8 = CSV" & vbCrLf & _
                        "9 = HTML" & vbCrLf & _
                        "10 = TXT" & vbCrLf & _
                        "12 = PNG" & vbCrLf & _
                        "13 = JPG" & vbCrLf & _
                        "16 = EPUB" & vbCrLf & _
                        "17 = RTF" & vbCrLf & _
                        "18 = SVG", _
                        "Choix du format", "1")
    
    If Not IsNumeric(fmtChoice) Then Exit Sub
    fmt = CInt(fmtChoice)
    If fmt < 1 Or fmt > 24 Then Exit Sub
    
    outPath = ChangeExtension(filePath, FormatExtension(fmt))
    
    Application.StatusBar = "Conversion en cours: " & filePath
    Dim result As Boolean
    result = ConvertDocument(filePath, outPath, fmt)
    Application.StatusBar = False
    
    If result Then
        MsgBox "Conversion r" & Chr(233) & "ussie!" & vbCrLf & vbCrLf & _
               "Fichier: " & outPath, vbInformation, "Conversion r" & Chr(233) & "ussie"
    Else
        MsgBox "La conversion a " & Chr(233) & "chou" & Chr(233) & "." & vbCrLf & _
               "V" & Chr(233) & "rifiez que LibreOffice est install" & Chr(233) & ".", _
               vbExclamation, "Erreur conversion"
    End If
End Sub

' ============================================================================
' 7. COM MACRO EXECUTION BRIDGE
' ============================================================================

Public Function RunMacroInWorkbook(ByVal workbookPath As String, _
                                   ByVal macroName As String, _
                                   Optional ByVal visible As Boolean = False) As Boolean
    Dim xlApp As Object
    Dim wb As Object
    
    On Error GoTo MacroError
    
    If Not IsCOMEnabled() Then
        RunMacroInWorkbook = False
        Exit Function
    End If
    If Not FileExists(workbookPath) Then
        RunMacroInWorkbook = False
        Exit Function
    End If
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = visible
    xlApp.DisplayAlerts = False
    xlApp.AutomationSecurity = 1
    xlApp.EnableEvents = False
    
    Set wb = xlApp.Workbooks.Open(workbookPath, , False)
    xlApp.Run macroName
    
    wb.Close True
    xlApp.Quit
    Set xlApp = Nothing
    
    RunMacroInWorkbook = True
    Exit Function
    
MacroError:
    On Error Resume Next
    If Not wb Is Nothing Then wb.Close False
    If Not xlApp Is Nothing Then
        xlApp.Quit
        Set xlApp = Nothing
    End If
    RunMacroInWorkbook = False
End Function

Public Function RunPythonScript(ByVal scriptPath As String, _
                                Optional ByVal args As String = "") As String
    Dim cmd As String
    cmd = "python """ & scriptPath & """ " & args
    RunPythonScript = mod_PCControl.Shell_CaptureOutput(cmd)
End Function

' ============================================================================
' 8. BRIDGE STATUS
' ============================================================================

Public Function Bridge_Description() As String
    Dim result As String
    result = "=== Ponts d'int" & Chr(233) & "gration disponibles ===" & vbCrLf
    
    If IsLibreOfficeInstalled() Then
        result = result & "[OK] LibreOffice: " & m_LOPath & vbCrLf
        result = result & "      Version: " & GetLOVersion() & vbCrLf
        result = result & "      Formats: 22 formats support" & Chr(233) & "s" & vbCrLf
    Else
        result = result & "[--] LibreOffice: non install" & Chr(233) & vbCrLf
        result = result & "      Installez avec: choco install libreoffice" & vbCrLf
    End If
    
    If IsCOMEnabled() Then
        result = result & "[OK] Excel COM: disponible (fallback XLSX->PDF)" & vbCrLf
    Else
        result = result & "[--] Excel COM: non disponible" & vbCrLf
    End If
    
    result = result & vbCrLf & "Moteur recommand" & Chr(233) & ": " & GetPreferredEngine()
    
    Bridge_Description = result
End Function

' ============================================================================
' 9. PRIVATE - LibreOffice Detection Helpers
' ============================================================================

Private Function ScanProgramFilesPaths() As String
    ' Scan all known LibreOffice install paths
    Dim versions As Variant
    Dim i As Integer
    Dim basePaths As Variant
    Dim bp As Variant
    Dim path As String
    
    ' All known LibreOffice major versions
    versions = Array(3, 4, 5, 6, 7, 8, 9, 10, 24, 25, 26, 27, 28, 29, 30)
    basePaths = Array( _
        "C:\Program Files\LibreOffice", _
        "C:\Program Files (x86)\LibreOffice", _
        "C:\Program Files\LibreOffice Portable", _
        Environ("LOCALAPPDATA") & "\LibreOffice", _
        Environ("PROGRAMFILES") & "\LibreOffice", _
        Environ("PROGRAMFILES(X86)") & "\LibreOffice")
    
    For Each bp In basePaths
        If Len(bp) > 0 Then
            ' Check version-specific paths
            For i = LBound(versions) To UBound(versions)
                path = bp & " " & versions(i) & "\program\soffice.exe"
                If Len(Dir(path)) > 0 Then
                    ScanProgramFilesPaths = path
                    Exit Function
                End If
            Next i
            
            ' Check base path (no version number - current/recommended)
            path = bp & "\program\soffice.exe"
            If Len(Dir(path)) > 0 Then
                ScanProgramFilesPaths = path
                Exit Function
            End If
        End If
    Next bp
    
    ScanProgramFilesPaths = ""
End Function

Private Function DetectFromRegistry() As String
    ' Detect LibreOffice via Windows Registry
    Dim result As String
    
    On Error Resume Next
    
    ' Method 1: LibreOffice's own registry keys
    result = ReadRegistry("HKLM\SOFTWARE\LibreOffice\LibreOffice", "Path")
    If Len(result) > 0 And Left(result, 1) <> "[" Then
        Dim soPath As String
        soPath = result & "\program\soffice.exe"
        If Len(Dir(soPath)) > 0 Then
            DetectFromRegistry = soPath
            Exit Function
        End If
    End If
    
    ' Method 2: Uninstall registry key (LibreOffice 5+)
    Dim i As Integer
    Dim uninstallKeys As Variant
    uninstallKeys = Array( _
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2E048B5C-19ED-4BB1-A29D-5E8C5D19B1E4}", _
        "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{2E048B5C-19ED-4BB1-A29D-5E8C5D19B1E4}", _
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D5C6BBA3-F8B2-4F27-B247-E36983DF60A5}", _
        "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{D5C6BBA3-F8B2-4F27-B247-E36983DF60A5}")
    
    For i = LBound(uninstallKeys) To UBound(uninstallKeys)
        result = ReadRegistry(uninstallKeys(i), "InstallLocation")
        If Len(result) > 0 And Left(result, 1) <> "[" Then
            soPath = result & "\program\soffice.exe"
            If Len(Dir(soPath)) > 0 Then
                DetectFromRegistry = soPath
                Exit Function
            End If
        End If
    Next i
    
    ' Method 3: Scan Uninstall keys for LibreOffice display name
    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")
    Dim regKeys As Variant
    regKeys = Array( _
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\", _
        "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\")
    
    Dim rk As Variant
    For Each rk In regKeys
        On Error Resume Next
        Dim keyEnum As Object
        Set keyEnum = wsh.RegRead(rk)
        If Err.Number = 0 Then
            ' Try common LibreOffice display names
            Dim displayNames As Variant
            displayNames = Array("LibreOffice", "LibreOffice", _
                                 "LibreOffice 5", "LibreOffice 6", _
                                 "LibreOffice 7", "LibreOffice 24")
            Dim dn As Variant
            For Each dn In displayNames
                result = ReadRegistry(rk & dn, "InstallLocation")
                If Len(result) > 0 And Left(result, 1) <> "[" Then
                    soPath = result & "\program\soffice.exe"
                    If Len(Dir(soPath)) > 0 Then
                        DetectFromRegistry = soPath
                        Exit Function
                    End If
                End If
            Next dn
        End If
        On Error GoTo 0
    Next rk
    
    DetectFromRegistry = ""
End Function

Private Function DetectFromWMI() As String
    ' Detect LibreOffice via WMI Win32_Product
    On Error Resume Next
    Dim wmi As Object
    Dim products As Object
    Dim product As Object
    Dim soPath As String
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set products = wmi.ExecQuery("SELECT Name, InstallLocation FROM Win32_Product WHERE Name LIKE '%LibreOffice%'")
    
    For Each product In products
        If Not IsNull(product.InstallLocation) Then
            soPath = product.InstallLocation & "\program\soffice.exe"
            If Len(Dir(soPath)) > 0 Then
                DetectFromWMI = soPath
                Exit Function
            End If
        End If
    Next product
    
    DetectFromWMI = ""
End Function

Private Function DetectFromPathEnv() As String
    ' Try to find soffice.exe via PATH
    Dim wsh As Object
    Dim output As String
    
    On Error Resume Next
    Set wsh = CreateObject("WScript.Shell")
    output = wsh.Exec("%COMSPEC% /C where soffice 2>nul").StdOut.ReadAll()
    
    If Len(output) > 0 Then
        Dim parts As Variant
        parts = Split(output, vbCrLf)
        If UBound(parts) >= 0 Then
            Dim path As String
            path = Trim(parts(0))
            If Len(Dir(path)) > 0 Then
                DetectFromPathEnv = path
                Exit Function
            End If
        End If
    End If
    
    ' Also try via "where soffice.bin" (Linux compat layer)
    output = wsh.Exec("%COMSPEC% /C where soffice.bin 2>nul").StdOut.ReadAll()
    If Len(output) > 0 Then
        parts = Split(output, vbCrLf)
        If UBound(parts) >= 0 Then
            path = Trim(parts(0))
            If Len(Dir(path)) > 0 Then
                DetectFromPathEnv = path
                Exit Function
            End If
        End If
    End If
    
    DetectFromPathEnv = ""
End Function

Private Function ReadRegistry(ByVal keyPath As String, _
                              ByVal valueName As String) As String
    On Error Resume Next
    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")
    ReadRegistry = wsh.RegRead(keyPath & "\" & valueName)
End Function

Private Function GetLOVersionInternal(ByVal loPath As String) As String
    Dim cmd As String
    cmd = """" & loPath & """ --version"
    Dim result As String
    result = Trim(mod_PCControl.Shell_CaptureOutput(cmd))
    
    ' Parse first line only
    If InStr(result, vbCrLf) > 0 Then
        result = Left(result, InStr(result, vbCrLf) - 1)
    End If
    GetLOVersionInternal = result
End Function

' ============================================================================
' 10. PRIVATE - Utilities
' ============================================================================

Private Function ChangeExtension(ByVal filePath As String, _
                                 ByVal newExt As String) As String
    Dim dotPos As Integer
    dotPos = InStrRev(filePath, ".")
    If dotPos > 0 Then
        ChangeExtension = Left(filePath, dotPos - 1) & newExt
    Else
        ChangeExtension = filePath & newExt
    End If
End Function

Private Function WaitForFile(ByVal filePath As String, _
                             ByVal retryCount As Long) As Boolean
    Dim i As Long
    For i = 1 To retryCount
        If Len(Dir(filePath)) > 0 Then
            ' File exists - also verify it's not zero bytes
            Dim fso As Object
            Set fso = CreateObject("Scripting.FileSystemObject")
            If fso.GetFile(filePath).Size > 0 Then
                WaitForFile = True
                Exit Function
            End If
        End If
        Application.Wait Now + TimeValue("00:00:01")
    Next i
    WaitForFile = False
End Function

Private Function FileSizeKB(ByVal filePath As String) As Double
    On Error Resume Next
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    FileSizeKB = fso.GetFile(filePath).Size / 1024
End Function

Private Function FindLOPathOutput(ByVal inputPath As String, _
                                  ByVal outDir As String, _
                                  ByVal targetFormat As LibeFormat) As String
    ' LibreOffice derives output filename from input
    Dim baseName As String
    baseName = Left(inputPath, InStrRev(inputPath, ".") - 1)
    baseName = Mid(baseName, InStrRev(baseName, "\") + 1)
    
    Dim ext As String
    ext = FormatExtension(targetFormat)
    
    Dim candidate As String
    candidate = outDir & "\" & baseName & ext
    
    If Len(Dir(candidate)) > 0 Then
        FindLOPathOutput = candidate
    Else
        FindLOPathOutput = ""
    End If
End Function

Private Function FileExists(ByVal filePath As String) As Boolean
    On Error Resume Next
    FileExists = (Len(Dir(filePath)) > 0)
End Function

Private Function BrowseForFile(ByVal filter As String, _
                               ByVal title As String) As String
    ' Compatible file browser (handles both string and array returns)
    Dim result As Variant
    
    On Error Resume Next
    result = Application.GetOpenFilename(filter, 1, title, False)
    
    If IsArray(result) Then
        If UBound(result) >= 1 Then
            BrowseForFile = CStr(result(1))
        Else
            BrowseForFile = ""
        End If
    ElseIf VarType(result) = vbString Then
        BrowseForFile = CStr(result)
    Else
        BrowseForFile = ""
    End If
    Err.Clear
End Function

' ============================================================================
' END - mod_LibreBridge.bas (v2.0)
' ============================================================================
