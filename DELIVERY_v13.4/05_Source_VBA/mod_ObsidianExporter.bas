Attribute VB_Name = "mod_ObsidianExporter"
'=====================================================================
' mod_ObsidianExporter.bas
' Exports selected worksheets to Markdown files in the folder defined by
' the environment variable OBSIDIAN_EXPORT_PATH (defaults to a local
' folder if not set). Each sheet is saved as <SheetName>.md.
'=====================================================================
Option Explicit

' Main entry point
Public Sub ExportAllToObsidian()
    Dim ws As Worksheet
    Dim exportPath As String
    Dim fso As Object
    Dim ts As Object
    Dim sheetName As String
    Dim lastRow As Long, lastCol As Long
    Dim r As Long, c As Long
    Dim cellValue As Variant
    Dim line As String
    
    ' Determine export folder
    exportPath = Environ("OBSIDIAN_EXPORT_PATH")
    If exportPath = "" Then
        exportPath = CurDir & "\ObsidianExport"
    End If
    
    ' Ensure folder exists
    If Dir(exportPath, vbDirectory) = "" Then
        MkDir exportPath
    End If
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Loop through worksheets you want to export
    For Each ws In ThisWorkbook.Worksheets
        ' Optional: filter sheets; here we export all except hidden or system sheets
        If ws.Visible = xlSheetVisible Then
            sheetName = ws.Name
            ' Sanitize filename (remove invalid chars)
            sheetName = Replace(sheetName, "\", "_")
            sheetName = Replace(sheetName, "/", "_")
            sheetName = Replace(sheetName, ":", "_")
            sheetName = Replace(sheetName, "*", "_")
            sheetName = Replace(sheetName, "?", "_")
            sheetName = Replace(sheetName, """", "_")
            sheetName = Replace(sheetName, "<", "_")
            sheetName = Replace(sheetName, ">", "_")
            sheetName = Replace(sheetName, "|", "_")
            
            Set ts = fso.CreateTextFile(exportPath & "\" & sheetName & ".md", True, True) ' True = overwrite, True = Unicode
            
            ' Write sheet name as heading
            ts.WriteLine "# " & sheetName
            ts.WriteLine ""
            
            ' Find used range
            With ws
                lastRow = .Cells.Find(What:="*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
                lastCol = .Cells.Find(What:="*", SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
                If lastRow < 1 Then lastRow = 1
                If lastCol < 1 Then lastCol = 1
            End With
            
            ' Write table header
            line = ""
            For c = 1 To lastCol
                line = line & "| " & Trim(ws.Cells(1, c).Value) & " "
            Next c
            If line <> "" Then
                ts.WriteLine line
                ' separator line
                line = ""
                For c = 1 To lastCol
                    line = line & "| --- "
                Next c
                ts.WriteLine line
            End If
            
            ' Write data rows
            For r = 2 To lastRow
                line = ""
                For c = 1 To lastCol
                    cellValue = ws.Cells(r, c).Value
                    If IsError(cellValue) Then cellValue = CVErr(xlErrNA)
                    line = line & "| " & IIf(IsError(cellValue), "ERROR", CStr(cellValue)) & " "
                Next c
                If line <> "" Then ts.WriteLine line
            Next r
            
            ts.WriteLine "" ' blank line between sheets
            ts.Close
        End If
    Next ws
    
    Set fso = Nothing
    MsgBox "Obsidian export completed to: " & exportPath, vbInformation, "Export Done"
End Sub

' Helper to export a single sheet (optional)
Public Sub ExportSheetToObsidian(ByVal wsName As String)
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(wsName)
    On Error GoTo 0
    If ws Is Nothing Then
        MsgBox "Worksheet '" & wsName & "' not found.", vbExclamation, "Export Error"
        Exit Sub
    End If
    ExportAllToObsidian ' could be optimized to export just this sheet, but reuse for simplicity
End Sub
