Attribute VB_Name = "mod_Backup"
Option Explicit

'=======================================================================================
' SUB: BackupProjectCode
' Automatically exports all Modules, UserForms, and Classes to the local folder.
' Handles folder creation and ensures clean naming conventions.
'=======================================================================================
Public Sub BackupProjectCode()
    Dim fso As Object
    Dim comp As Object
    Dim backupPath As String
    Dim exportFile As String
    Dim extension As String
    Dim count As Integer
    
    ' 1. Define the Backup Path (Relative to the Workbook)
    ' This matches your project structure: \backend\VBA_Modules\
    backupPath = ThisWorkbook.Path & "\backend\VBA_Modules\"
    
    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' 2. Ensure the directory exists (creates it if missing)
    If Not fso.FolderExists(backupPath) Then
        ' Create parent directory if needed
        Dim parentFolder As String
        parentFolder = ThisWorkbook.Path & "\backend\"
        If Not fso.FolderExists(parentFolder) Then fso.CreateFolder (parentFolder)
        fso.CreateFolder (backupPath)
    End If
    On Error GoTo ErrorHandler
    
    count = 0
    
    ' 3. Iterate through all VB components
    For Each comp In ThisWorkbook.VBProject.VBComponents
        ' Determine file extension based on component type
        ' Type 1 = Standard Module (.bas)
        ' Type 2 = Class Module (.cls)
        ' Type 3 = UserForm (.frm)
        Select Case comp.Type
            Case 1: extension = ".bas"
            Case 2: extension = ".cls"
            Case 3: extension = ".frm"
            Case Else: extension = ".txt"
        End Select
        
        exportFile = backupPath & comp.Name & extension
        
        ' Export the component
        comp.Export exportFile
        count = count + 1
    Next comp
    
    MsgBox "Backup Complete!" & vbCrLf & _
           "Total Components Exported: " & count & vbCrLf & _
           "Location: " & backupPath, vbInformation, "System Backup"
    Exit Sub

ErrorHandler:
    MsgBox "Backup Failed!" & vbCrLf & _
           "Error: " & Err.Description & vbCrLf & vbCrLf & _
           "Check if 'Trust access to the VBA project object model' is enabled in Trust Center.", _
           vbCritical, "Backup Error"
End Sub