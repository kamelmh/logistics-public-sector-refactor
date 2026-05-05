Attribute VB_Name = "mod_Restore"
Option Explicit

Public Sub RestoreInventoryAdvanced()
    Dim wbBackup As Workbook
    Dim wsBackup As Worksheet
    Dim wsMaster As Worksheet
    Dim backupPath As String
    Dim lastRow As Long, i As Long
    Dim articleCode As Variant
    Dim matchIdx As Variant
    Dim startTime As Double
    Dim restoredCount As Long
    
    startTime = Timer
    Set wsMaster = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    
    backupPath = ThisWorkbook.Path & "\..\Z_ARCHIVE\01_ERP_Backups\ERP_Academie_v13_Backup_2026-04-19_16-06-24.xlsm"
    
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    wsMaster.Unprotect Password:=mod_Config.MASTER_PWD
    
    ' Add headers for new columns
    wsMaster.Range("G1").Value = "STOCK_MAX"
    wsMaster.Range("H1").Value = "EMPLACEMENT"
    wsMaster.Range("G1:H1").Font.Bold = True
    wsMaster.Range("G1:H1").Interior.Color = RGB(44, 62, 80)
    wsMaster.Range("G1:H1").Font.Color = RGB(255, 255, 255)
    
    Set wbBackup = Workbooks.Open(backupPath, ReadOnly:=True, UpdateLinks:=False)
    Set wsBackup = wbBackup.Sheets(mod_Config.SHEET_ARTICLES)
    
    Dim backupCodes As Range
    Set backupCodes = wsBackup.Range("A1:A" & wsBackup.Cells(wsBackup.Rows.Count, "A").End(xlUp).Row)
    
    lastRow = wsMaster.Cells(wsMaster.Rows.Count, "A").End(xlUp).Row
    
    If lastRow < 2 Then
        MsgBox "No data in master ARTICLES sheet", vbExclamation
        wbBackup.Close False
        Exit Sub
    End If
    
    restoredCount = 0
    
    For i = 3 To lastRow
        articleCode = wsMaster.Cells(i, 1).Value
        
        If articleCode <> "" Then
            matchIdx = Application.Match(articleCode, backupCodes, 0)
            
            If Not IsError(matchIdx) Then
                wsMaster.Cells(i, 2).Value = wsBackup.Cells(matchIdx, 3).Value   ' DESIGNATION_AR (Col C)
                wsMaster.Cells(i, 4).Value = wsBackup.Cells(matchIdx, 8).Value   ' PRIX_UNITAIRE (Col H)
                wsMaster.Cells(i, 5).Value = wsBackup.Cells(matchIdx, 11).Value  ' CATEGORIE (Col K)
                wsMaster.Cells(i, 6).Value = wsBackup.Cells(matchIdx, 6).Value   ' MIN_STOCK (Col F)
                wsMaster.Cells(i, 7).Value = wsBackup.Cells(matchIdx, 7).Value   ' STOCK_MAX (Col G)
                wsMaster.Cells(i, 8).Value = wsBackup.Cells(matchIdx, 10).Value  ' EMPLACEMENT (Col J)
                restoredCount = restoredCount + 1
            End If
        End If
    Next i
    
    wsMaster.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    wbBackup.Close SaveChanges:=False
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    
    MsgBox "Restored " & restoredCount & " articles in " & Round(Timer - startTime, 2) & " seconds!", vbInformation, "Restore Complete"
    Exit Sub
    
ErrorHandler:
    On Error Resume Next
    If Not wsMaster Is Nothing Then wsMaster.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    If Not wbBackup Is Nothing Then wbBackup.Close False
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    MsgBox "Error: " & Err.Description, vbCritical, "Restore Failed"
End Sub