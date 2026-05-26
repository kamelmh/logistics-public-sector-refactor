Attribute VB_Name = "mod_TaskOrchestrator"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Task Orchestration Engine — advanced macro coordination with queue,
' priorities, dependencies, progress tracking, error retry, and scheduler.
' ============================================================================

Option Explicit

' ============================================================================
' ENUMS AND TYPES
' ============================================================================

Public Enum TaskPriority
    tpCritical = 0   ' Must run immediately
    tpHigh = 1       ' High importance
    tpNormal = 2     ' Default
    tpLow = 3        ' Background, runs when system idle
End Enum

Public Enum TaskStatus
    tsPending = 0
    tsQueued = 1
    tsRunning = 2
    tsCompleted = 3
    tsFailed = 4
    tsRetrying = 5
    tsSkipped = 6
    tsCancelled = 7
End Enum

Public Enum TaskScheduleType
    stOnce = 0          ' Run once
    stDaily = 1         ' Run daily at specified time
    stWeekly = 2        ' Run weekly on specified day
    stMonthly = 3       ' Run monthly on specified date
    stOnIdle = 4        ' Run when system is idle
    stOnOpen = 5        ' Run on workbook open
    stOnChange = 6      ' Run when specific data changes
End Enum

' Task structure
Public Type TaskDefinition
    TaskID As String                ' Unique identifier
    Name As String                  ' Human-readable name
    Description As String           ' Longer description
    MacroName As String             ' VBA macro to execute: "Module.Sub"
    Priority As TaskPriority
    Status As TaskStatus
    Dependencies() As String        ' TaskIDs that must complete first
    RetryCount As Long              ' Max retries on failure
    RetryDelay As Long              ' Seconds between retries
    Timeout As Long                 ' Max execution time in seconds (0=no limit)
    ScheduleType As TaskScheduleType
    ScheduleValue As String         ' Time/day spec
    CreatedAt As Date
    StartedAt As Date
    CompletedAt As Date
    LastError As String
    Result As String
    Tag As String                   ' Custom metadata
End Type

' Scheduler entry
Public Type ScheduleEntry
    TaskID As String
    IsActive As Boolean
    LastRun As Date
    NextRun As Date
    RunCount As Long
End Type

' ============================================================================
' MODULE-LEVEL STATE
' ============================================================================

Private m_TaskList() As TaskDefinition
Private m_TaskCount As Long
Private m_ScheduleList() As ScheduleEntry
Private m_ScheduleCount As Long
Private m_Queue() As String              ' Ordered TaskID queue
Private m_QueueCount As Long
Private m_IsRunning As Boolean
Private m_CurrentTaskID As String
Private m_ProgressValue As Double        ' 0.0 to 100.0
Private m_ProgressMessage As String
Private m_SchedulerTimer As Double
Private m_InitDone As Boolean

' Sheet for persistent task log
Private Const TASK_LOG_SHEET As String = "TASK_LOG"
Private Const TASK_LOG_HEADER() As Variant = Array("TASK_ID", "NAME", "STATUS", "STARTED", _
                                                   "COMPLETED", "DURATION_S", "ERROR", "RESULT")

' ============================================================================
' INITIALIZATION
' ============================================================================

Private Sub ClassInit()
    If m_InitDone Then Exit Sub
    m_TaskCount = 0
    ReDim m_TaskList(0 To 99)
    m_ScheduleCount = 0
    ReDim m_ScheduleList(0 To 19)
    m_QueueCount = 0
    ReDim m_Queue(0 To 99)
    m_IsRunning = False
    m_InitDone = True
End Sub

Public Sub Initialize()
    ClassInit
    Debug.Print "[TASK] Orchestrator initialized"
End Sub

' ============================================================================
' PUBLIC API — Task Definition & Registration
' ============================================================================

Public Function DefineTask(ByVal taskID As String, _
                           ByVal name As String, _
                           ByVal macroName As String, _
                           Optional ByVal description As String = "", _
                           Optional ByVal priority As TaskPriority = tpNormal, _
                           Optional ByVal retryCount As Long = 0, _
                           Optional ByVal retryDelay As Long = 5, _
                           Optional ByVal timeout As Long = 0, _
                           Optional ByVal tag As String = "") As String
    ' Register a new task definition. Returns TaskID.
    
    ClassInit
    
    ' Validate
    If Len(Trim(taskID)) = 0 Then
        taskID = "TASK-" & Format(Now, "YYMMDD-HHMMSS") & "-" & CStr(m_TaskCount + 1)
    End If
    If Len(Trim(macroName)) = 0 Then
        DefineTask = ""
        Exit Function
    End If
    
    ' Ensure array capacity
    If m_TaskCount >= UBound(m_TaskList) Then
        ReDim Preserve m_TaskList(0 To m_TaskCount + 50)
    End If
    
    ' Create task
    With m_TaskList(m_TaskCount)
        .TaskID = taskID
        .Name = name
        .Description = description
        .MacroName = macroName
        .Priority = priority
        .Status = tsPending
        ReDim .Dependencies(0 To 0)
        .RetryCount = retryCount
        .RetryDelay = retryDelay
        .Timeout = timeout
        .ScheduleType = stOnce
        .ScheduleValue = ""
        .CreatedAt = Now
        .LastError = ""
        .Result = ""
        .Tag = tag
    End With
    
    m_TaskCount = m_TaskCount + 1
    DefineTask = taskID
    Debug.Print "[TASK] Defined: " & name & " (" & taskID & ")"
End Function

Public Sub SetDependencies(ByVal taskID As String, ParamArray depIDs() As Variant)
    Dim i As Integer
    Dim idx As Long
    
    idx = FindTaskIndex(taskID)
    If idx < 0 Then Exit Sub
    
    If UBound(depIDs) >= 0 Then
        ReDim m_TaskList(idx).Dependencies(0 To UBound(depIDs))
        For i = LBound(depIDs) To UBound(depIDs)
            m_TaskList(idx).Dependencies(i) = CStr(depIDs(i))
        Next i
    End If
End Sub

Public Sub SetSchedule(ByVal taskID As String, _
                       ByVal scheduleType As TaskScheduleType, _
                       ByVal scheduleValue As String)
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then Exit Sub
    
    m_TaskList(idx).ScheduleType = scheduleType
    m_TaskList(idx).ScheduleValue = scheduleValue
    
    ' Register in scheduler
    RegisterSchedule taskID, scheduleType, scheduleValue
End Sub

' ============================================================================
' PUBLIC API — Queue Management
' ============================================================================

Public Sub EnqueueTask(ByVal taskID As String)
    ' Add a task to the execution queue
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then Exit Sub
    
    ' Don't re-queue completed/cancelled tasks
    If m_TaskList(idx).Status = tsCompleted Or _
       m_TaskList(idx).Status = tsCancelled Then Exit Sub
    
    ' Check if already queued
    Dim i As Long
    For i = 0 To m_QueueCount - 1
        If m_Queue(i) = taskID Then Exit Sub
    Next i
    
    ' Ensure capacity
    If m_QueueCount >= UBound(m_Queue) Then
        ReDim Preserve m_Queue(0 To m_QueueCount + 50)
    End If
    
    ' Insert in priority order
    Dim insertPos As Long
    insertPos = m_QueueCount
    
    For i = m_QueueCount - 1 To 0 Step -1
        Dim existingIdx As Long
        existingIdx = FindTaskIndex(m_Queue(i))
        Dim newIdx As Long
        newIdx = FindTaskIndex(taskID)
        
        If existingIdx >= 0 And newIdx >= 0 Then
            If m_TaskList(newIdx).Priority < m_TaskList(existingIdx).Priority Then
                ' New task has higher priority (lower number)
                m_Queue(i + 1) = m_Queue(i)
                insertPos = i
            End If
        End If
    Next i
    
    m_Queue(insertPos) = taskID
    m_QueueCount = m_QueueCount + 1
    m_TaskList(idx).Status = tsQueued
    
    Debug.Print "[TASK] Enqueued: " & m_TaskList(idx).Name & " (priority " & m_TaskList(idx).Priority & ")"
End Sub

Public Sub EnqueueMultiple(ParamArray taskIDs() As Variant)
    Dim i As Integer
    For i = LBound(taskIDs) To UBound(taskIDs)
        EnqueueTask CStr(taskIDs(i))
    Next i
End Sub

Public Sub EnqueueAll(Optional ByVal includeSchedule As Boolean = False)
    ' Queue all pending tasks
    Dim i As Long
    For i = 0 To m_TaskCount - 1
        If m_TaskList(i).Status = tsPending Then
            If includeSchedule Or m_TaskList(i).ScheduleType = stOnce Then
                EnqueueTask m_TaskList(i).TaskID
            End If
        End If
    Next i
End Sub

Public Sub ClearQueue()
    m_QueueCount = 0
    ReDim m_Queue(0 To 99)
    Debug.Print "[TASK] Queue cleared"
End Sub

' ============================================================================
' PUBLIC API — Execution Engine
' ============================================================================

Public Sub RunQueue(Optional ByVal concurrent As Boolean = False)
    ' Execute all tasks in the queue sequentially
    ' concurrent=True: still sequential in VBA (single-threaded),
    ' but uses DoEvents between tasks for responsiveness
    
    If m_IsRunning Then
        MsgBox "Le planificateur est d" & Chr(233) & "j" & Chr(224) & " en cours d'ex" & Chr(233) & "cution.", _
               vbInformation, "Orchestrateur"
        Exit Sub
    End If
    
    ClassInit
    m_IsRunning = True
    
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.EnableEvents = False
    
    On Error GoTo RunError
    
    Dim i As Long
    For i = 0 To m_QueueCount - 1
        If m_Queue(i) <> "" Then
            m_CurrentTaskID = m_Queue(i)
            Call ExecuteTask(m_CurrentTaskID)
            
            If concurrent Then
                DoEvents
                ' Check if user pressed Cancel
                If m_IsRunning = False Then Exit For
            End If
        End If
    Next i
    
    ' Report summary
    Dim completed As Long, failed As Long, skipped As Long
    For i = 0 To m_TaskCount - 1
        Select Case m_TaskList(i).Status
            Case tsCompleted: completed = completed + 1
            Case tsFailed: failed = failed + 1
            Case tsSkipped, tsCancelled: skipped = skipped + 1
        End Select
    Next i
    
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.EnableEvents = True
    
    m_IsRunning = False
    m_CurrentTaskID = ""
    
    Debug.Print "[TASK] Queue complete: " & completed & " OK, " & failed & " failed, " & skipped & " skipped"
    MsgBox "Ordonnancement termin" & Chr(233) & ":" & vbCrLf & _
           "  R" & Chr(233) & "ussites: " & completed & vbCrLf & _
           "  Echecs: " & failed & vbCrLf & _
           "  Ignor" & Chr(233) & "s: " & skipped, _
           vbInformation, "Rapport T" & Chr(226) & "ches"
    Exit Sub
    
RunError:
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.EnableEvents = True
    m_IsRunning = False
    MsgBox "Erreur d'ex" & Chr(233) & "cution: " & Err.Description, vbCritical, "Orchestrateur"
End Sub

Public Sub CancelRun()
    m_IsRunning = False
    Dim idx As Long
    idx = FindTaskIndex(m_CurrentTaskID)
    If idx >= 0 Then
        m_TaskList(idx).Status = tsCancelled
        m_TaskList(idx).LastError = "Cancelled by user"
    End If
    Debug.Print "[TASK] Execution cancelled by user"
End Sub

Public Function RunSingleTask(ByVal taskID As String) As Boolean
    ' Execute a single task directly (bypass queue)
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then
        RunSingleTask = False
        Exit Function
    End If
    
    ' Check dependencies
    If Not CheckDependencies(taskID) Then
        RunSingleTask = False
        Exit Function
    End If
    
    m_CurrentTaskID = taskID
    m_IsRunning = True
    Call ExecuteTask(taskID)
    m_IsRunning = False
    m_CurrentTaskID = ""
    
    RunSingleTask = (m_TaskList(idx).Status = tsCompleted)
End Function

' ============================================================================
' PUBLIC API — Progress Tracking
' ============================================================================

Public Sub UpdateProgress(ByVal pct As Double, Optional ByVal message As String = "")
    m_ProgressValue = pct
    m_ProgressMessage = message
    
    ' Update status bar
    If Len(message) > 0 Then
        Application.StatusBar = "[" & CStr(Int(pct)) & "%] " & message
    End If
    
    DoEvents
End Sub

Public Function GetProgress() As Double
    GetProgress = m_ProgressValue
End Function

Public Function GetProgressMessage() As String
    GetProgressMessage = m_ProgressMessage
End Function

Public Sub ShowProgressDialog()
    ' Show a simple progress form (Excel 2010 compatible)
    Dim progressForm As Object
    Dim frmName As String
    frmName = "frmTaskProgress"
    
    On Error Resume Next
    Set progressForm = ThisWorkbook.VBProject.VBComponents(frmName)
    If progressForm Is Nothing Then
        ' No form available, use status bar only
        Application.StatusBar = "Ordonnancement en cours..."
    Else
        VBA.UserForms.Add(frmName).Show vbModeless
    End If
    On Error GoTo 0
End Sub

' ============================================================================
' PUBLIC API — Task Status & Reporting
' ============================================================================

Public Function GetTaskStatus(ByVal taskID As String) As TaskStatus
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx >= 0 Then
        GetTaskStatus = m_TaskList(idx).Status
    Else
        GetTaskStatus = tsCancelled
    End If
End Function

Public Function GetTaskError(ByVal taskID As String) As String
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx >= 0 Then
        GetTaskError = m_TaskList(idx).LastError
    Else
        GetTaskError = "T" & Chr(226) & "che inconnue"
    End If
End Function

Public Function TaskCount() As Long
    TaskCount = m_TaskCount
End Function

Public Function QueueCount() As Long
    QueueCount = m_QueueCount
End Function

Public Function IsRunning() As Boolean
    IsRunning = m_IsRunning
End Function

Public Function GetAllTasksSummary() As String
    Dim result As String
    Dim i As Long
    
    result = "=== RAPPORT DES TACHES ===" & vbCrLf
    result = result & "Total: " & m_TaskCount & " | En file: " & m_QueueCount & _
             " | En cours: " & m_IsRunning & vbCrLf & vbCrLf
    
    For i = 0 To m_TaskCount - 1
        With m_TaskList(i)
            result = result & .TaskID & " [" & StatusLabel(.Status) & "] " & .Name
            If Len(.LastError) > 0 Then
                result = result & " -> " & .LastError
            End If
            result = result & vbCrLf
        End With
    Next i
    
    GetAllTasksSummary = result
End Function

Public Sub ExportTaskLogToSheet()
    ' Write task execution log to TASK_LOG sheet
    Dim ws As Worksheet
    Dim i As Long
    Dim row As Long
    
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(TASK_LOG_SHEET)
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        ws.Name = TASK_LOG_SHEET
    End If
    On Error GoTo 0
    
    ws.Cells.Clear
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    
    ' Header
    ws.Cells(1, 1).Value = "TASK_ID"
    ws.Cells(1, 2).Value = "NAME"
    ws.Cells(1, 3).Value = "STATUS"
    ws.Cells(1, 4).Value = "STARTED"
    ws.Cells(1, 5).Value = "COMPLETED"
    ws.Cells(1, 6).Value = "DURATION_S"
    ws.Cells(1, 7).Value = "ERROR"
    ws.Cells(1, 8).Value = "RESULT"
    ws.Range("A1:H1").Font.Bold = True
    
    row = 2
    For i = 0 To m_TaskCount - 1
        With m_TaskList(i)
            ws.Cells(row, 1).Value = .TaskID
            ws.Cells(row, 2).Value = .Name
            ws.Cells(row, 3).Value = StatusLabel(.Status)
            ws.Cells(row, 4).Value = Format(.StartedAt, "dd/mm/yyyy HH:MM:SS")
            ws.Cells(row, 5).Value = Format(.CompletedAt, "dd/mm/yyyy HH:MM:SS")
            If .StartedAt > 0 And .CompletedAt > 0 Then
                ws.Cells(row, 6).Value = DateDiff("s", .StartedAt, .CompletedAt)
            End If
            ws.Cells(row, 7).Value = .LastError
            ws.Cells(row, 8).Value = Left(.Result, 255)
        End With
        row = row + 1
    Next i
    
    ws.Columns("A:H").AutoFit
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    Debug.Print "[TASK] Log exported to " & TASK_LOG_SHEET
End Sub

' ============================================================================
' PUBLIC API — Scheduler
' ============================================================================

Public Sub StartScheduler(Optional ByVal intervalSeconds As Long = 60)
    ' Start the scheduled task checker
    ' Uses Application.OnTime to periodically check for scheduled tasks
    
    m_SchedulerTimer = intervalSeconds
    Call ScheduleNextCheck
    Debug.Print "[TASK] Scheduler started (interval: " & intervalSeconds & "s)"
End Sub

Public Sub StopScheduler()
    On Error Resume Next
    Application.OnTime EarliestTime:=m_SchedulerTimer, Name:="SchedulerCheck", Schedule:=False
    On Error GoTo 0
    Debug.Print "[TASK] Scheduler stopped"
End Sub

Public Sub SchedulerCheck()
    ' Called by Application.OnTime — checks and runs scheduled tasks
    If m_IsRunning Then
        ' Re-schedule and return if orchestrator is busy
        Call ScheduleNextCheck
        Exit Sub
    End If
    
    Dim i As Long
    Dim nowTime As Date
    nowTime = Now
    
    For i = 0 To m_ScheduleCount - 1
        If m_ScheduleList(i).IsActive Then
            If nowTime >= m_ScheduleList(i).NextRun Then
                ' Time to run
                Dim taskIdx As Long
                taskIdx = FindTaskIndex(m_ScheduleList(i).TaskID)
                
                If taskIdx >= 0 And m_TaskList(taskIdx).Status <> tsRunning Then
                    Debug.Print "[TASK] Scheduler triggering: " & m_TaskList(taskIdx).Name
                    m_TaskList(taskIdx).Status = tsPending
                    EnqueueTask m_ScheduleList(i).TaskID
                    
                    ' Update next run
                    m_ScheduleList(i).LastRun = nowTime
                    m_ScheduleList(i).RunCount = m_ScheduleList(i).RunCount + 1
                    m_ScheduleList(i).NextRun = CalculateNextRun(m_TaskList(taskIdx).ScheduleType, _
                                                                 m_TaskList(taskIdx).ScheduleValue)
                End If
            End If
        End If
    Next i
    
    ' Re-schedule
    Call ScheduleNextCheck
End Sub

' ============================================================================
' PUBLIC API — Predefined Task Factories
' ============================================================================

Public Sub CreateDataSyncTasks()
    ' Create standard data synchronization task chain
    Dim t1 As String, t2 As String, t3 As String, t4 As String
    
    t1 = DefineTask("SYNC-VALIDATE", "Valider les donn" & Chr(233) & "es", _
                    "mod_DataValidator.ValidateAll", description:="Valide l'int" & Chr(233) & "grit" & Chr(233) & " des donn" & Chr(233) & "es", _
                    priority:=tpHigh, retryCount:=2)
    
    t2 = DefineTask("SYNC-METRICS", "Calculer les m" & Chr(233) & "triques", _
                    "mod_StockEngine.RefreshAllCMUP", description:="Recalcule les CMUP", _
                    priority:=tpHigh)
    
    t3 = DefineTask("SYNC-ABC", "Classifier ABC", _
                    "mod_StockEngine.UpdateAllABCClassifications", _
                    description:="Met 'a jour les classifications ABC", _
                    priority:=tpNormal)
    
    t4 = DefineTask("SYNC-REPORT", "G" & Chr(233) & "n" & Chr(233) & "rer le rapport", _
                    "mod_Reports.GenerateDashboardReport", _
                    description:="G" & Chr(233) & "n" & Chr(233) & "re le rapport de bord", _
                    priority:=tpLow)
    
    ' Set dependencies
    SetDependencies t2, t1
    SetDependencies t3, t2
    SetDependencies t4, t3
    
    Debug.Print "[TASK] Created sync chain: " & t1 & " -> " & t2 & " -> " & t3 & " -> " & t4
End Sub

Public Sub CreateBackupTasks()
    Dim t1 As String, t2 As String
    t1 = DefineTask("BACKUP-DATA", "Sauvegarde des donn" & Chr(233) & "es", _
                    "mod_ExportEngine.ExportAll", priority:=tpNormal, _
                    tag:="backup")
    t2 = DefineTask("BACKUP-CLEAN", "Nettoyage des logs", _
                    "mod_AuditTrail.CleanOldLogs", priority:=tpLow)
    SetDependencies t2, t1
    SetSchedule t1, stDaily, "22:00"
    SetSchedule t2, stDaily, "22:30"
End Sub

Public Sub CreateInventoryTasks()
    Dim t1 As String, t2 As String, t3 As String
    t1 = DefineTask("INV-SCAN", "Scan inventaire", _
                    "mod_BarcodeSim.GenerateBarcodeFromInput", priority:=tpHigh)
    t2 = DefineTask("INV-RECONCILE", "R" & Chr(233) & "conciliation", _
                    "mod_InventoryReconciliation.RunReconciliation", priority:=tpNormal)
    t3 = DefineTask("INV-REPORT", "Rapport inventaire", _
                    "mod_Reports.GenerateInventoryReport", priority:=tpNormal)
    SetDependencies t2, t1
    SetDependencies t3, t2
End Sub

' ============================================================================
' PUBLIC API — Quick Run (one-call orchestration)
' ============================================================================

Public Sub QuickRunBackup()
    ' One-click: backup all data
    Application.StatusBar = "[TASK] Sauvegarde en cours..."
    
    Call CreateBackupTasks
    Call EnqueueAll
    Call RunQueue
    
    Application.StatusBar = "Sauvegarde termin" & Chr(233) & "e."
End Sub

Public Sub QuickRunSync()
    ' One-click: full data sync
    Application.StatusBar = "[TASK] Synchronisation en cours..."
    
    Call CreateDataSyncTasks
    Call EnqueueAll
    Call RunQueue
    
    Application.StatusBar = "Synchronisation termin" & Chr(233) & "e."
End Sub

Public Sub QuickRunAll()
    ' One-click: run all pending tasks
    
    ' Create standard task chains
    Call CreateDataSyncTasks
    Call CreateBackupTasks
    
    ' Enqueue and run
    Call EnqueueAll
    Call RunQueue
End Sub

Public Sub ShowTaskDashboard()
    ' Display task summary in a message box
    Dim summary As String
    summary = GetAllTasksSummary
    MsgBox summary, vbInformation, "Tableau de bord T" & Chr(226) & "ches"
End Sub

' ============================================================================
' PRIVATE — Execution Internals
' ============================================================================

Private Sub ExecuteTask(ByVal taskID As String)
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then Exit Sub
    
    With m_TaskList(idx)
        ' Check dependencies
        If Not CheckDependencies(taskID) Then
            .Status = tsSkipped
            .LastError = "D" & Chr(233) & "pendances non satisfaites"
            LogTaskToDebug taskID
            Exit Sub
        End If
        
        .Status = tsRunning
        .StartedAt = Now
        .LastError = ""
        
        ' Update status bar
        Application.StatusBar = "[TASK] " & .Name & "..."
        Debug.Print "[TASK] Running: " & .Name & " (" & taskID & ")"
        
        ' Parse macro name (Module.Method)
        Dim moduleName As String
        Dim methodName As String
        Dim dotPos As Integer
        
        dotPos = InStr(.MacroName, ".")
        If dotPos > 0 Then
            moduleName = Left(.MacroName, dotPos - 1)
            methodName = Mid(.MacroName, dotPos + 1)
        Else
            moduleName = ""
            methodName = .MacroName
        End If
        
        ' Execute with retry
        Dim attempt As Long
        Dim maxAttempts As Long
        maxAttempts = 1 + .RetryCount
        
        For attempt = 1 To maxAttempts
            On Error GoTo ExecError
            
            If attempt > 1 Then
                .Status = tsRetrying
                Debug.Print "[TASK] Retry " & attempt & "/" & maxAttempts & " for " & .Name
                Application.StatusBar = "[TASK] " & .Name & " (tentative " & attempt & "/" & maxAttempts & ")"
                Application.Wait Now + TimeValue("00:00:" & CStr(.RetryDelay))
            End If
            
            ' Execute the macro
            If Len(moduleName) > 0 Then
                ' Run by full name
                Application.Run .MacroName
            Else
                ' Run as sub
                Application.Run methodName
            End If
            
            ' Success
            .Status = tsCompleted
            .CompletedAt = Now
            .Result = "OK"
            Application.StatusBar = "[TASK] " & .Name & " - OK"
            Debug.Print "[TASK] Completed: " & .Name & " in " & _
                       DateDiff("s", .StartedAt, .CompletedAt) & "s"
            
            LogTaskToDebug taskID
            Exit Sub
            
ExecError:
            If attempt >= maxAttempts Then
                ' All retries exhausted
                .Status = tsFailed
                .CompletedAt = Now
                .LastError = "[" & attempt & "/" & maxAttempts & "] " & Err.Description
                .Result = "FAILED"
                Application.StatusBar = "[TASK] " & .Name & " - ECHEC"
                Debug.Print "[TASK] FAILED: " & .Name & " - " & .LastError
                LogTaskToDebug taskID
            Else
                .LastError = "Attempt " & attempt & ": " & Err.Description
            End If
            On Error GoTo 0
        Next attempt
    End With
End Sub

Private Function CheckDependencies(ByVal taskID As String) As Boolean
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then
        CheckDependencies = False
        Exit Function
    End If
    
    Dim deps() As String
    deps = m_TaskList(idx).Dependencies
    
    If UBound(deps) < 0 Or (UBound(deps) = 0 And Len(deps(0)) = 0) Then
        CheckDependencies = True
        Exit Function
    End If
    
    Dim i As Integer
    For i = LBound(deps) To UBound(deps)
        Dim depIdx As Long
        depIdx = FindTaskIndex(deps(i))
        
        If depIdx < 0 Then
            ' Dependency not found — skip
            CheckDependencies = False
            Exit Function
        End If
        
        If m_TaskList(depIdx).Status <> tsCompleted Then
            ' Dependency not yet complete
            CheckDependencies = False
            Exit Function
        End If
    Next i
    
    CheckDependencies = True
End Function

Private Function FindTaskIndex(ByVal taskID As String) As Long
    Dim i As Long
    For i = 0 To m_TaskCount - 1
        If m_TaskList(i).TaskID = taskID Then
            FindTaskIndex = i
            Exit Function
        End If
    Next i
    FindTaskIndex = -1
End Function

Private Sub LogTaskToDebug(ByVal taskID As String)
    Dim idx As Long
    idx = FindTaskIndex(taskID)
    If idx < 0 Then Exit Sub
    
    With m_TaskList(idx)
        Debug.Print "[TASK-LOG] " & .TaskID & "|" & .Name & "|" & _
                   StatusLabel(.Status) & "|" & _
                   Format(.StartedAt, "HH:MM:SS") & "|" & _
                   Format(.CompletedAt, "HH:MM:SS") & "|" & _
                   .LastError
    End With
End Sub

Private Sub RegisterSchedule(ByVal taskID As String, _
                             ByVal scheduleType As TaskScheduleType, _
                             ByVal scheduleValue As String)
    ' Ensure capacity
    If m_ScheduleCount >= UBound(m_ScheduleList) Then
        ReDim Preserve m_ScheduleList(0 To m_ScheduleCount + 10)
    End If
    
    With m_ScheduleList(m_ScheduleCount)
        .TaskID = taskID
        .IsActive = True
        .LastRun = 0
        .NextRun = CalculateNextRun(scheduleType, scheduleValue)
        .RunCount = 0
    End With
    
    m_ScheduleCount = m_ScheduleCount + 1
End Sub

Private Function CalculateNextRun(ByVal scheduleType As TaskScheduleType, _
                                  ByVal scheduleValue As String) As Date
    Dim result As Date
    Dim nowTime As Date
    nowTime = Now
    
    Select Case scheduleType
        Case stOnce
            result = 0  ' No repeat
        Case stDaily
            ' scheduleValue = "HH:MM"
            result = DateValue(nowTime) + TimeValue(scheduleValue)
            If result <= nowTime Then
                result = result + 1  ' Tomorrow
            End If
        Case stWeekly
            ' scheduleValue = "DOW HH:MM" (e.g., "1 22:00" for Monday)
            Dim parts() As String
            parts = Split(scheduleValue, " ")
            If UBound(parts) >= 1 Then
                Dim targetDOW As Integer
                targetDOW = CInt(parts(0))
                result = DateValue(nowTime) + TimeValue(parts(1))
                ' Adjust to correct day of week (vbSunday=1, but we use 1=Monday)
                Do While Weekday(result, vbMonday) <> targetDOW
                    result = result + 1
                Loop
                If result <= nowTime Then
                    result = result + 7
                End If
            Else
                result = nowTime + 1
            End If
        Case stMonthly
            ' scheduleValue = "DD HH:MM"
            parts = Split(scheduleValue, " ")
            If UBound(parts) >= 1 Then
                Dim targetDay As Integer
                targetDay = CInt(parts(0))
                result = DateSerial(Year(nowTime), Month(nowTime), targetDay) + TimeValue(parts(1))
                If result <= nowTime Then
                    result = DateSerial(Year(nowTime), Month(nowTime) + 1, targetDay) + TimeValue(parts(1))
                End If
            Else
                result = nowTime + 1
            End If
        Case stOnIdle
            result = nowTime + TimeValue("00:05:00")  ' Check in 5 minutes
        Case stOnOpen, stOnChange
            result = nowTime
        Case Else
            result = nowTime + 1
    End Select
    
    CalculateNextRun = result
End Function

Private Sub ScheduleNextCheck()
    On Error Resume Next
    Application.OnTime Now + TimeValue("00:00:" & CStr(m_SchedulerTimer)), _
                       "'" & Application.ThisWorkbook.Name & "'!SchedulerCheck", _
                       Schedule:=True
    On Error GoTo 0
End Sub

Private Function StatusLabel(ByVal status As TaskStatus) As String
    Select Case status
        Case tsPending:     StatusLabel = "EN ATTENTE"
        Case tsQueued:      StatusLabel = "EN FILE"
        Case tsRunning:     StatusLabel = "EN COURS"
        Case tsCompleted:   StatusLabel = "TERMINE"
        Case tsFailed:      StatusLabel = "ECHEC"
        Case tsRetrying:    StatusLabel = "NOUV. TENTATIVE"
        Case tsSkipped:     StatusLabel = "IGNORE"
        Case tsCancelled:   StatusLabel = "ANNULE"
        Case Else:          StatusLabel = "INCONNU"
    End Select
End Function

' ============================================================================
' END — mod_TaskOrchestrator.bas
' ============================================================================
