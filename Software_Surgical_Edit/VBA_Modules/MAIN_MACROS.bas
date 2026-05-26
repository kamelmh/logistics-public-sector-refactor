Attribute VB_Name = "MAIN_MACROS"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Public Sub AjouterMouvement()
    On Error GoTo ErrorHandler
    Dim frmName As String
    frmName = "frmStockEntry"

    If MainMacrosFormExists(frmName) Then
        VBA.UserForms.Add(frmName).Show
    Else
        MsgBox "Erreur: Le formulaire '" & frmName & "' n'existe pas." & vbCrLf & _
               "Veuillez vérifier que le fichier n'est pas corrompu.", _
               vbCritical, "ERP Académie v13.2"
    End If
    Exit Sub

ErrorHandler:
    MsgBox "Erreur lors de l'ouverture du formulaire: " & Err.Description, _
           vbCritical, "ERP Académie v13.2"
End Sub

Public Sub RunGenerateDemoData()
    On Error Resume Next
    Call mod_DemoData.GenerateDemoData
    If Err.Number <> 0 Then
        MsgBox "Erreur: " & Err.Description, vbCritical, "ACADEMIX v13.2"
    End If
    On Error GoTo 0
End Sub

Public Sub ShowMainMenu()
    On Error GoTo ErrorHandler
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_ACCUEIL)
    If Not ws Is Nothing Then
        ws.Activate
    Else
        MsgBox "Erreur: Feuille d'accueil introuvable.", vbCritical, "ERP Académie v13.2"
    End If
    Exit Sub

ErrorHandler:
    MsgBox "Erreur: " & Err.Description, vbCritical, "ERP Académie v13.2"
End Sub

Private Function MainMacrosFormExists(ByVal formName As String) As Boolean
    Dim vbComp As Object
    On Error Resume Next
    Set vbComp = ThisWorkbook.VBProject.VBComponents(formName)
    MainMacrosFormExists = Not (vbComp Is Nothing)
    On Error GoTo 0
End Function

' ============================================================================
' NEW: BARCODE SIMULATION ENHANCED ENTRY POINTS
' ============================================================================

Public Sub GenerateBarcodeInteractive()
    Call mod_BarcodeSim.GenerateBarcodeFromInput
End Sub

Public Sub PrintBarcodeLabels()
    Call mod_BarcodeSim.PrintBarcodeLabels
End Sub

Public Sub SimulateBarcodeScanner()
    Call mod_BarcodeSim.SimulateBarcodeScan
End Sub

Public Sub GenerateBarcodesForAllArticles()
    Dim wsArt As Worksheet
    Dim lastRow As Long
    
    On Error Resume Next
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    If wsArt Is Nothing Then Exit Sub
    lastRow = wsArt.Cells(wsArt.Rows.Count, 1).End(xlUp).Row
    
    If lastRow < 3 Then
        MsgBox "Aucun article trouv" & Chr(233) & ".", vbExclamation
        Exit Sub
    End If
    
    Call mod_BarcodeSim.GenerateBarcodeRange("BARCODE_LABELS", "A3", _
        wsArt.Range("A3:A" & lastRow), bcCode128, 30)
    MsgBox "Codes-barres g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & "s pour tous les articles!", _
           vbInformation, "Academix v13.2"
End Sub

Public Sub RegisterBarcodeSymbology()
    Call mod_BarcodeSim.RegisterBarcodeWithSymbology
End Sub

' ============================================================================
' NEW: TASK ORCHESTRATION ENTRY POINTS
' ============================================================================

Public Sub RunTaskSync()
    Call mod_TaskOrchestrator.QuickRunSync
End Sub

Public Sub RunTaskBackup()
    Call mod_TaskOrchestrator.QuickRunBackup
End Sub

Public Sub RunTaskAll()
    Call mod_TaskOrchestrator.QuickRunAll
End Sub

Public Sub ShowTaskDashboard()
    Call mod_TaskOrchestrator.ShowTaskDashboard
End Sub

Public Sub StartTaskScheduler()
    Call mod_TaskOrchestrator.StartScheduler(60)
    MsgBox "Planificateur de t" & Chr(226) & "ches d" & Chr(233) & "marr" & Chr(233) & " (intervalle: 60s).", _
           vbInformation, "Ordonnanceur"
End Sub

Public Sub StopTaskScheduler()
    Call mod_TaskOrchestrator.StopScheduler
    MsgBox "Planificateur arr" & Chr(234) & "t" & Chr(233) & ".", vbInformation, "Ordonnanceur"
End Sub

Public Sub CreateCustomTaskChain()
    ' Creates a user-defined task chain
    Dim t1 As String, t2 As String, t3 As String, t4 As String, t5 As String
    
    t1 = mod_TaskOrchestrator.DefineTask("RUN-VALIDATE", "Validation des donn" & Chr(233) & "es", _
        "mod_DataValidator.ValidateAll", priority:=tpHigh, retryCount:=2)
    t2 = mod_TaskOrchestrator.DefineTask("RUN-SYNC", "Sync des stocks", _
        "mod_SyncBridge.SyncMetricsFromLedger", priority:=tpHigh)
    t3 = mod_TaskOrchestrator.DefineTask("RUN-FORECAST", "Pr" & Chr(233) & "visions", _
        "mod_Forecasting.RunForecast", priority:=tpNormal)
    t4 = mod_TaskOrchestrator.DefineTask("RUN-REPORT", "Rapport PDF", _
        "mod_Reports.GenerateDashboardReport", priority:=tpLow)
    t5 = mod_TaskOrchestrator.DefineTask("RUN-BACKUP", "Sauvegarde", _
        "mod_ExportEngine.ExportAll", priority:=tpLow)
    
    mod_TaskOrchestrator.SetDependencies t2, t1
    mod_TaskOrchestrator.SetDependencies t3, t2
    mod_TaskOrchestrator.SetDependencies t4, t3
    mod_TaskOrchestrator.SetDependencies t5, t4
    
    mod_TaskOrchestrator.EnqueueMultiple t1, t2, t3, t4, t5
    mod_TaskOrchestrator.RunQueue True
    
    MsgBox "Cha" & Chr(238) & "ne de t" & Chr(226) & "ches termin" & Chr(233) & "e.", vbInformation, "Ordonnanceur"
End Sub

Public Sub ExportTaskLog()
    Call mod_TaskOrchestrator.ExportTaskLogToSheet
    MsgBox "Journal export" & Chr(233) & " vers la feuille TASK_LOG.", vbInformation
End Sub

' ============================================================================
' NEW: PC CONTROL ENTRY POINTS
' ============================================================================

Public Sub PcShowSystemInfo()
    Call mod_PCControl.WMI_ShowSystemInfo
End Sub

Public Sub PcShowDiagnostics()
    Call mod_PCControl.PC_ShowDiagnostics
End Sub

Public Sub PcShowNetwork()
    Call mod_PCControl.Net_ShowIPConfig
End Sub

Public Sub PcShowWindows()
    Call mod_PCControl.Window_ShowList
End Sub

Public Sub PcRunCommand()
    Dim cmd As String
    cmd = InputBox("Commande 'a ex" & Chr(233) & "cuter:", "Ex" & Chr(233) & "cution commande", "systeminfo | findstr /i ""OS""")
    If Len(Trim(cmd)) = 0 Then Exit Sub
    Call mod_PCControl.PC_RunAndWait(cmd)
End Sub

Public Sub PcListProcesses()
    Dim result As String
    result = mod_PCControl.Process_List
    MsgBox result, vbInformation, "Processus en cours"
End Sub

Public Sub PcKillProcess()
    Dim procName As String
    procName = InputBox("Nom du processus 'a tuer (sans .exe):", "Arr" & Chr(234) & "ter processus", "")
    If Len(Trim(procName)) = 0 Then Exit Sub
    If mod_PCControl.Process_Kill(procName) Then
        MsgBox "Processus '" & procName & "' arr" & Chr(234) & "t" & Chr(233) & ".", vbInformation
    Else
        MsgBox "Processus '" & procName & "' non trouv" & Chr(233) & ".", vbExclamation
    End If
End Sub

Public Sub PcShowEnv()
    Call mod_PCControl.Env_Show
End Sub

Public Sub PcCheckExcelVersion()
    Dim result As String
    result = mod_PCControl.Registry_GetExcelVersion
    MsgBox "Version Excel install" & Chr(233) & "e:" & vbCrLf & result, vbInformation
End Sub

' ============================================================================
' NEW: LIBREOFFICE BRIDGE ENTRY POINTS
' ============================================================================

Public Sub LibeExportToPDF()
    Call mod_LibreBridge.ExportCurrentSheetToPDF
End Sub

Public Sub LibeExportAllToPDF()
    Call mod_LibreBridge.ExportAllToPDF
End Sub

Public Sub LibeConvertBatch()
    Dim folderPath As String
    folderPath = InputBox("Dossier contenant les fichiers 'a convertir:", "Conversion batch PDF", _
                          ThisWorkbook.Path)
    If Len(Trim(folderPath)) = 0 Then Exit Sub
    Dim count As Long
    Application.StatusBar = "Conversion en cours..."
    count = mod_LibreBridge.ConvertBatchToPDF(folderPath, "*.docx")
    Application.StatusBar = False
    MsgBox count & " fichiers convertis en PDF.", vbInformation, "Conversion batch"
End Sub

Public Sub LibeShowBridgeInfo()
    Dim info As String
    info = mod_LibreBridge.Bridge_Description
    MsgBox info, vbInformation, "Ponts d'Int" & Chr(233) & "gration"
End Sub

' ============================================================================
' NEW: RUN ALL MACROS ENTRY POINTS
' ============================================================================

Public Sub RunAllBarcodeGeneration()
    ' One-click: generate barcodes for all articles + print labels
    Call GenerateBarcodesForAllArticles
    Call PrintBarcodeLabels
    MsgBox "Codes-barres g" & Chr(233) & "n" & Chr(233) & "r" & Chr(233) & "s et " & Chr(233) & "tiquettes cr" & Chr(233) & "" & Chr(233) & "es!", _
           vbInformation, "G" & Chr(233) & "n" & Chr(233) & "ration compl" & Chr(232) & "te"
End Sub

Public Sub RunFullPipeline()
    ' One-click: full pipeline — validate, sync, forecast, export, backup
    Application.StatusBar = "[PIPELINE] Lancement de la cha" & Chr(238) & "ne compl" & Chr(232) & "te..."
    
    Call mod_TaskOrchestrator.CreateDataSyncTasks
    Call mod_TaskOrchestrator.CreateBackupTasks
    Call mod_TaskOrchestrator.CreateInventoryTasks
    Call mod_TaskOrchestrator.EnqueueAll
    Call mod_TaskOrchestrator.RunQueue(True)
    
    Application.StatusBar = "[PIPELINE] Termin" & Chr(233)
    MsgBox "Pipeline complet ex" & Chr(233) & "cut" & Chr(233) & " avec succ" & Chr(232) & "s!", _
           vbInformation, "Academix v13.2 Pipeline"
End Sub
