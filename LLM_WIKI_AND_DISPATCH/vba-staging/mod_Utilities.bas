'-------------------------------------------------
' Module: mod_Utilities.bas
' Arabic: وظائف مساعدة (Helper Functions)
' PURPOSE: General utility functions for VBA DSS
' Clean Room: Pure VBA only (NO external dependencies)
'-------------------------------------------------

Option Explicit

'-------------------------------------------------
' Function: IsNumericValue
' Arabic: التحقق مما إذا كان رقمياً
' Purpose: Validate numeric input (avoid internal errors)
'-------------------------------------------------
Public Function IsNumericValue(Value As Variant) As Boolean
    On Error Resume Next
    Dim test As Double
    test = CDbl(Value)
    IsNumericValue = (Err.Number = 0)
    On Error GoTo 0
End Function

'-------------------------------------------------
' Function: FormatArabicNumber
' Arabic: تنسيق الرقم بالعربية
' Purpose: Format numbers for Arabic RTL display
'-------------------------------------------------
Public Function FormatArabicNumber(Value As Double, Optional DecimalPlaces As Integer = 2) As String
    On Error GoTo ErrorHandler
    FormatArabicNumber = Format(Value, "0." & String(DecimalPlaces, "0"))
    Exit Function
ErrorHandler:
    FormatArabicNumber = "0"
End Function

'-------------------------------------------------
' Sub: ClearSheetData
' Arabic: مسح بيانات الورقة (بدون حذف الورقة)
' Purpose: Clear data while preserving structure
'-------------------------------------------------
Public Sub ClearSheetData(SheetName As String, Optional StartRow As Long = 2)
    On Error GoTo ErrorHandler
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(SheetName)
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If lastRow >= StartRow Then
        ws.Rows(StartRow & ":" & lastRow).Delete
    End If
    Exit Sub
ErrorHandler:
    MsgBox "Error clearing sheet data: " & Err.Description, vbCritical
End Sub

'-------------------------------------------------
' Function: GetNextID
' Arabic: الحصول على الرقم التالي (Auto-increment)
' Purpose: Generate next ID for Digital Ledger entries
'-------------------------------------------------
Public Function GetNextID(SheetName As String, IDColumn As Long) As String
    On Error GoTo ErrorHandler
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(SheetName)
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, IDColumn).End(xlUp).Row
    If lastRow < 2 Then
        GetNextID = "1"
    Else
        GetNextID = CStr(ws.Cells(lastRow, IDColumn).Value + 1)
    End If
    Exit Function
ErrorHandler:
    GetNextID = "1"
End Function

'-------------------------------------------------
' Sub: ExportToTextFile
' Arabic: تصدير إلى ملف نصي
' Purpose: Simple text export (NO JSON, NO APIs)
'-------------------------------------------------
Public Sub ExportToTextFile(TextData As String, FilePath As String)
    On Error GoTo ErrorHandler
    Dim fnum As Integer
    fnum = FreeFile
    Open FilePath For Output As #fnum
    Print #fnum, TextData
    Close #fnum
    Exit Sub
ErrorHandler:
    MsgBox "Error exporting to text file: " & Err.Description, vbCritical
End Sub

' End of mod_Utilities.bas
