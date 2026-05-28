Attribute VB_Name = "mod_PCControl"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' PC Control Toolset - Shell execution, WMI queries, Registry access,
' FileSystem operations, Windows API, network tools, process management.
' Style: MCP (Model Context Protocol) - tool-oriented, composable.
' ============================================================================

Option Explicit

' ============================================================================
' WINDOWS API DECLARATIONS
' ============================================================================

#If VBA7 Then
    Private Declare PtrSafe Function FindWindow Lib "user32" Alias "FindWindowA" _
        (ByVal lpClassName As String, ByVal lpWindowName As String) As LongPtr
    Private Declare PtrSafe Function SendMessage Lib "user32" Alias "SendMessageA" _
        (ByVal hWnd As LongPtr, ByVal Msg As Long, ByVal wParam As LongPtr, ByVal lParam As LongPtr) As LongPtr
    Private Declare PtrSafe Function ShowWindow Lib "user32" _
        (ByVal hWnd As LongPtr, ByVal nCmdShow As Long) As Boolean
    Private Declare PtrSafe Function SetForegroundWindow Lib "user32" _
        (ByVal hWnd As LongPtr) As Boolean
    Private Declare PtrSafe Function GetForegroundWindow Lib "user32" () As LongPtr
    Private Declare PtrSafe Function GetWindowText Lib "user32" Alias "GetWindowTextA" _
        (ByVal hWnd As LongPtr, ByVal lpString As String, ByVal nMaxCount As Long) As Long
    Private Declare PtrSafe Function IsWindowVisible Lib "user32" _
        (ByVal hWnd As LongPtr) As Boolean
    Private Declare PtrSafe Function GetDesktopWindow Lib "user32" () As LongPtr
    Private Declare PtrSafe Function GetWindow Lib "user32" _
        (ByVal hWnd As LongPtr, ByVal wCmd As Long) As LongPtr
    Private Declare PtrSafe Function keybd_event Lib "user32" _
        (ByVal bVk As Byte, ByVal bScan As Byte, ByVal dwFlags As Long, ByVal dwExtraInfo As LongPtr) As Long
    Private Declare PtrSafe Function GetKeyboardState Lib "user32" _
        (pbKeyState As Byte) As Long
    Private Declare PtrSafe Function SetKeyboardState Lib "user32" _
        (lppbKeyState As Byte) As Long
#Else
    Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" _
        (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
    Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" _
        (ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    Private Declare Function ShowWindow Lib "user32" _
        (ByVal hWnd As Long, ByVal nCmdShow As Long) As Long
    Private Declare Function SetForegroundWindow Lib "user32" _
        (ByVal hWnd As Long) As Long
    Private Declare Function GetForegroundWindow Lib "user32" () As Long
    Private Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" _
        (ByVal hWnd As Long, ByVal lpString As String, ByVal nMaxCount As Long) As Long
    Private Declare Function IsWindowVisible Lib "user32" _
        (ByVal hWnd As Long) As Boolean
    Private Declare Function GetDesktopWindow Lib "user32" () As Long
    Private Declare Function GetWindow Lib "user32" _
        (ByVal hWnd As Long, ByVal wCmd As Long) As Long
    Private Declare Sub keybd_event Lib "user32" _
        (ByVal bVk As Byte, ByVal bScan As Byte, ByVal dwFlags As Long, ByVal dwExtraInfo As Long)
#End If

' Windows Constants
Private Const SW_HIDE As Long = 0
Private Const SW_SHOW As Long = 5
Private Const SW_MINIMIZE As Long = 6
Private Const SW_RESTORE As Long = 9
Private Const WM_CLOSE As Long = &H10
Private Const WM_SETTEXT As Long = &HC
Private Const WM_KEYDOWN As Long = &H100
Private Const VK_RETURN As Long = &HD
Private Const VK_ESCAPE As Long = &H1B
Private Const KEYEVENTF_KEYUP As Long = &H2
Private Const GW_HWNDNEXT As Long = 2
Private Const MAX_PATH As Long = 260

' ============================================================================
' 1. SHELL EXECUTION ENGINE
' ============================================================================

Public Function Shell_RunCommand(ByVal command As String, _
                                 Optional ByVal showWindow As Boolean = False, _
                                 Optional ByVal waitForCompletion As Boolean = False) As Long
    ' Execute any shell command via WScript.Shell
    ' Returns exit code (0 = success)
    ' If waitForCompletion=True, blocks until command finishes
    
    Dim wsh As Object
    Dim exec As Object
    Dim exitCode As Long
    
    On Error GoTo ShellError
    
    Set wsh = CreateObject("WScript.Shell")
    
    If waitForCompletion Then
        ' Run and wait for completion
        Set exec = wsh.Exec("%COMSPEC% /C " & command)
        Do While exec.Status = 0
            DoEvents
        Loop
        exitCode = exec.ExitCode
    Else
        ' Fire and forget
        exitCode = wsh.Run(command, IIf(showWindow, 1, 0), False)
    End If
    
    Shell_RunCommand = exitCode
    Debug.Print "[PCCTL] Shell: " & Left(command, 100) & " => exit " & exitCode
    Exit Function
    
ShellError:
    Debug.Print "[PCCTL] Shell error: " & Err.Description
    Shell_RunCommand = -1
End Function

Public Function Shell_CaptureOutput(ByVal command As String) As String
    ' Run command and capture stdout
    ' Returns output as string
    
    Dim wsh As Object
    Dim exec As Object
    Dim output As String
    
    On Error GoTo CaptureError
    
    Set wsh = CreateObject("WScript.Shell")
    Set exec = wsh.Exec("%COMSPEC% /C " & command)
    
    Do While exec.Status = 0
        DoEvents
    Loop
    
    output = exec.StdOut.ReadAll()
    If Len(output) = 0 Then
        output = exec.StdErr.ReadAll()
    End If
    
    Shell_CaptureOutput = output
    Exit Function
    
CaptureError:
    Shell_CaptureOutput = "[ERROR] " & Err.Description
End Function

Public Sub Shell_StartProcess(ByVal executable As String, _
                              Optional ByVal args As String = "", _
                              Optional ByVal workingDir As String = "")
    ' Start a process asynchronously (fire and forget)
    
    Dim wsh As Object
    Dim cmdLine As String
    
    On Error Resume Next
    
    cmdLine = executable
    If Len(args) > 0 Then cmdLine = cmdLine & " " & args
    
    Set wsh = CreateObject("WScript.Shell")
    
    If Len(workingDir) > 0 Then
        wsh.CurrentDirectory = workingDir
    End If
    
    wsh.Run cmdLine, 1, False
    Debug.Print "[PCCTL] Started: " & executable
End Sub

' ============================================================================
' 2. PROCESS MANAGEMENT
' ============================================================================

Public Function Process_List() As String
    ' Returns list of running processes (Name, PID, Memory)
    Dim wmi As Object
    Dim processes As Object
    Dim proc As Object
    Dim result As String
    
    On Error GoTo ProcListError
    
    result = "NOM_PROCESSUS|PID|MEMOIRE_KB" & vbCrLf
    result = result & String(50, "-") & vbCrLf
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set processes = wmi.ExecQuery("SELECT Name, ProcessId, WorkingSetSize FROM Win32_Process")
    
    For Each proc In processes
        result = result & proc.Name & "|" & proc.ProcessId & "|" & _
                 Round(proc.WorkingSetSize / 1024, 0) & vbCrLf
    Next proc
    
    If Len(result) > 1000 Then
        result = Left(result, 1000) & vbCrLf & "... [truncated]"
    End If
    
    Process_List = result
    Exit Function
    
ProcListError:
    Process_List = "[ERROR] " & Err.Description
End Function

Public Function Process_Kill(ByVal processName As String) As Boolean
    ' Kill a process by name (without .exe)
    Dim wmi As Object
    Dim processes As Object
    Dim proc As Object
    Dim killed As Boolean
    
    On Error GoTo KillError
    
    If Right(processName, 4) <> ".exe" Then
        processName = processName & ".exe"
    End If
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set processes = wmi.ExecQuery("SELECT Name, ProcessId FROM Win32_Process WHERE Name='" & processName & "'")
    
    killed = False
    For Each proc In processes
        proc.Terminate
        killed = True
        Debug.Print "[PCCTL] Killed: " & proc.Name & " (PID " & proc.ProcessId & ")"
    Next proc
    
    Process_Kill = killed
    Exit Function
    
KillError:
    Process_Kill = False
End Function

Public Function Process_GetInfo(ByVal processName As String) As String
    ' Get detailed info about a process
    Dim wmi As Object
    Dim processes As Object
    Dim proc As Object
    Dim result As String
    
    On Error GoTo ProcInfoError
    
    If Right(processName, 4) <> ".exe" Then
        processName = processName & ".exe"
    End If
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set processes = wmi.ExecQuery("SELECT * FROM Win32_Process WHERE Name='" & processName & "'")
    
    result = ""
    For Each proc In processes
        result = result & "Nom: " & proc.Name & vbCrLf
        result = result & "PID: " & proc.ProcessId & vbCrLf
        result = result & "Executable: " & proc.ExecutablePath & vbCrLf
        result = result & "M" & Chr(233) & "moire: " & Round(proc.WorkingSetSize / 1024 / 1024, 2) & " MB" & vbCrLf
        result = result & "Threads: " & proc.ThreadCount & vbCrLf
        result = result & "CPU: " & proc.KernelModeTime & vbCrLf
        result = result & "Date cr" & Chr(233) & "ation: " & proc.CreationDate & vbCrLf
        Exit For
    Next proc
    
    If Len(result) = 0 Then
        result = "Processus non trouv" & Chr(233) & ": " & processName
    End If
    
    Process_GetInfo = result
    Exit Function
    
ProcInfoError:
    Process_GetInfo = "[ERROR] " & Err.Description
End Function

' ============================================================================
' 3. WMI SYSTEM QUERIES
' ============================================================================

Public Function WMI_GetSystemInfo() As String
    ' Get comprehensive system information
    Dim wmi As Object
    Dim items As Object
    Dim item As Object
    Dim result As String
    
    On Error GoTo WMIError
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    result = "=== INFORMATIONS SYSTEME ===" & vbCrLf
    
    ' OS Info
    Set items = wmi.ExecQuery("SELECT Caption, Version, OSArchitecture, TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem")
    For Each item In items
        result = result & "OS: " & item.Caption & vbCrLf
        result = result & "Version: " & item.Version & vbCrLf
        result = result & "Architecture: " & item.OSArchitecture & vbCrLf
        result = result & "RAM Totale: " & Round(item.TotalVisibleMemorySize / 1024 / 1024, 2) & " GB" & vbCrLf
        result = result & "RAM Libre: " & Round(item.FreePhysicalMemory / 1024 / 1024, 2) & " GB" & vbCrLf
    Next item
    
    ' CPU Info
    result = result & vbCrLf & "=== PROCESSEUR ===" & vbCrLf
    Set items = wmi.ExecQuery("SELECT Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed FROM Win32_Processor")
    For Each item In items
        result = result & "CPU: " & item.Name & vbCrLf
        result = result & "C" & Chr(338) & "urs: " & item.NumberOfCores & " (logiques: " & item.NumberOfLogicalProcessors & ")" & vbCrLf
        result = result & "Freq: " & item.MaxClockSpeed & " MHz" & vbCrLf
    Next item
    
    ' Disk Info
    result = result & vbCrLf & "=== DISQUES ===" & vbCrLf
    Set items = wmi.ExecQuery("SELECT DeviceID, Size, FreeSpace, FileSystem FROM Win32_LogicalDisk WHERE DriveType=3")
    For Each item In items
        result = result & item.DeviceID & " " & Round(item.Size / 1024 / 1024 / 1024, 1) & " GB (libre: " & _
                 Round(item.FreeSpace / 1024 / 1024 / 1024, 1) & " GB) [" & item.FileSystem & "]" & vbCrLf
    Next item
    
    WMI_GetSystemInfo = result
    Exit Function
    
WMIError:
    WMI_GetSystemInfo = "[ERROR] " & Err.Description
End Function

Public Sub WMI_ShowSystemInfo()
    ' Display system info in a message box
    MsgBox WMI_GetSystemInfo(), vbInformation, "Systeme - Academix v13.2"
End Sub

Public Function WMI_GetNetworkInfo() As String
    ' Get network adapter configuration
    Dim wmi As Object
    Dim items As Object
    Dim item As Object
    Dim result As String
    
    On Error GoTo NetError
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    result = "=== CONFIGURATION RESEAU ===" & vbCrLf
    
    Set items = wmi.ExecQuery("SELECT Description, MACAddress, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")
    
    For Each item In items
        result = result & "Carte: " & item.Description & vbCrLf
        result = result & "MAC: " & item.MACAddress & vbCrLf
        
        If Not IsNull(item.IPAddress) Then
            Dim ip As Variant
            For Each ip In item.IPAddress
                result = result & "IP: " & ip & vbCrLf
            Next ip
        End If
        
        If Not IsNull(item.DefaultIPGateway) Then
            Dim gw As Variant
            For Each gw In item.DefaultIPGateway
                result = result & "Passerelle: " & gw & vbCrLf
            Next gw
        End If
        
        result = result & vbCrLf
    Next item
    
    WMI_GetNetworkInfo = result
    Exit Function
    
NetError:
    WMI_GetNetworkInfo = "[ERROR] " & Err.Description
End Function

Public Function WMI_GetBatteryInfo() As String
    ' Get battery status (laptops)
    Dim wmi As Object
    Dim items As Object
    Dim item As Object
    Dim result As String
    
    On Error Resume Next
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set items = wmi.ExecQuery("SELECT EstimatedChargeRemaining, BatteryStatus, EstimatedRunTime FROM Win32_Battery")
    
    result = "=== BATTERIE ===" & vbCrLf
    For Each item In items
        result = result & "Charge: " & item.EstimatedChargeRemaining & "%" & vbCrLf
        result = result & "Statut: " & item.BatteryStatus & vbCrLf
        result = result & "Autonomie: " & item.EstimatedRunTime & " min" & vbCrLf
    Next item
    
    If InStr(result, "BATTERIE") = Len(result) - 14 Then
        result = "Pas d'information batterie disponible"
    End If
    
    WMI_GetBatteryInfo = result
End Function

Public Function WMI_GetServices() As String
    ' Get list of Windows services
    Dim wmi As Object
    Dim items As Object
    Dim item As Object
    Dim result As String
    
    On Error GoTo SrvError
    
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    result = "SERVICE|ETAT|DEMARRAGE" & vbCrLf
    result = result & String(50, "-") & vbCrLf
    
    Set items = wmi.ExecQuery("SELECT Name, DisplayName, State, StartMode FROM Win32_Service WHERE State='Running'", , 48)
    
    For Each item In items
        result = result & item.Name & "|" & item.State & "|" & item.StartMode & vbCrLf
    Next item
    
    If Len(result) > 2000 Then
        result = Left(result, 2000) & vbCrLf & "... [truncated]"
    End If
    
    WMI_GetServices = result
    Exit Function
    
SrvError:
    WMI_GetServices = "[ERROR] " & Err.Description
End Function

' ============================================================================
' 4. WINDOW MANAGEMENT
' ============================================================================

Public Function Window_Find(ByVal windowTitle As String) As LongPtr
    ' Find a window by title, return handle
    Window_Find = FindWindow(vbNullString, windowTitle)
End Function

Public Function Window_FindByClass(ByVal className As String, _
                                   Optional ByVal windowTitle As String = "") As LongPtr
    ' Find a window by class name
    Window_FindByClass = FindWindow(className, windowTitle)
End Function

Public Sub Window_BringToFront(ByVal hWnd As LongPtr)
    ' Bring window to foreground
    If hWnd <> 0 Then
        SetForegroundWindow hWnd
        ShowWindow hWnd, SW_RESTORE
    End If
End Sub

Public Sub Window_Hide(ByVal hWnd As LongPtr)
    If hWnd <> 0 Then ShowWindow hWnd, SW_HIDE
End Sub

Public Sub Window_Show(ByVal hWnd As LongPtr)
    If hWnd <> 0 Then ShowWindow hWnd, SW_SHOW
End Sub

Public Sub Window_Close(ByVal hWnd As LongPtr)
    If hWnd <> 0 Then SendMessage hWnd, WM_CLOSE, 0, 0
End Sub

Public Function Window_GetTitle(ByVal hWnd As LongPtr) As String
    Dim buffer As String
    buffer = String$(MAX_PATH, Chr$(0))
    GetWindowText hWnd, buffer, MAX_PATH
    Window_GetTitle = Left(buffer, InStr(buffer, Chr$(0)) - 1)
End Function

Public Function Window_EnumerateAll() As String
    ' Enumerate all visible top-level windows
    Dim hWnd As LongPtr
    Dim result As String
    
    result = "HANDLE|TITRE" & vbCrLf
    result = result & String(50, "-") & vbCrLf
    
    hWnd = GetDesktopWindow()
    hWnd = GetWindow(hWnd, GW_HWNDNEXT)
    
    Do While hWnd <> 0
        If IsWindowVisible(hWnd) Then
            Dim title As String
            title = Window_GetTitle(hWnd)
            If Len(title) > 0 Then
                result = result & hWnd & "|" & title & vbCrLf
            End If
        End If
        hWnd = GetWindow(hWnd, GW_HWNDNEXT)
    Loop
    
    If Len(result) > 2000 Then
        result = Left(result, 2000) & vbCrLf & "... [truncated]"
    End If
    
    Window_EnumerateAll = result
End Function

Public Sub Window_ShowList()
    ' Display window list in message box
    MsgBox Window_EnumerateAll(), vbInformation, "Fen" & Chr(234) & "tres ouvertes"
End Sub

' ============================================================================
' 5. REGISTRY ACCESS
' ============================================================================

Public Function Registry_Read(ByVal keyPath As String, _
                              ByVal valueName As String) As String
    ' Read a registry value
    ' keyPath: "HKLM\Software\Microsoft\Windows\CurrentVersion\..."
    Dim wsh As Object
    
    On Error GoTo RegReadError
    Set wsh = CreateObject("WScript.Shell")
    Registry_Read = wsh.RegRead(keyPath & "\" & valueName)
    Exit Function
    
RegReadError:
    Registry_Read = "[ERROR] " & Err.Description
End Function

Public Function Registry_Write(ByVal keyPath As String, _
                               ByVal valueName As String, _
                               ByVal value As String, _
                               Optional ByVal valueType As String = "REG_SZ") As Boolean
    ' Write a registry value
    Dim wsh As Object
    
    On Error GoTo RegWriteError
    Set wsh = CreateObject("WScript.Shell")
    wsh.RegWrite keyPath & "\" & valueName, value, valueType
    Registry_Write = True
    Exit Function
    
RegWriteError:
    Registry_Write = False
End Function

Public Function Registry_Delete(ByVal keyPath As String, _
                                ByVal valueName As String) As Boolean
    ' Delete a registry value
    Dim wsh As Object
    
    On Error GoTo RegDelError
    Set wsh = CreateObject("WScript.Shell")
    wsh.RegDelete keyPath & "\" & valueName
    Registry_Delete = True
    Exit Function
    
RegDelError:
    Registry_Delete = False
End Function

Public Function Registry_GetExcelVersion() As String
    ' Get installed Excel version from registry
    Dim versions As Variant
    Dim i As Integer
    Dim result As String
    
    versions = Array("15.0", "14.0", "12.0", "11.0", "10.0")
    
    For i = LBound(versions) To UBound(versions)
        result = Registry_Read("HKLM\Software\Microsoft\Office\" & versions(i) & _
                              "\Excel\InstallRoot", "Path")
        If Left(result, 1) <> "[" Then
            Registry_GetExcelVersion = "Excel " & versions(i) & " : " & result
            Exit Function
        End If
    Next i
    
    Registry_GetExcelVersion = "Excel non trouv" & Chr(233)
End Function

' ============================================================================
' 6. FILESYSTEM OPERATIONS
' ============================================================================

Public Function FS_FileExists(ByVal filePath As String) As Boolean
    On Error Resume Next
    FS_FileExists = (Len(Dir(filePath)) > 0)
End Function

Public Function FS_FolderExists(ByVal folderPath As String) As Boolean
    On Error Resume Next
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    FS_FolderExists = fso.FolderExists(folderPath)
End Function

Public Sub FS_CreateFolder(ByVal folderPath As String)
    On Error Resume Next
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder folderPath
        Debug.Print "[PCCTL] Created folder: " & folderPath
    End If
End Sub

Public Function FS_CopyFile(ByVal source As String, ByVal destination As String, _
                           Optional ByVal overwrite As Boolean = True) As Boolean
    On Error GoTo CopyError
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.CopyFile source, destination, overwrite
    FS_CopyFile = True
    Exit Function
CopyError:
    FS_CopyFile = False
End Function

Public Function FS_MoveFile(ByVal source As String, ByVal destination As String) As Boolean
    On Error GoTo MoveError
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.MoveFile source, destination
    FS_MoveFile = True
    Exit Function
MoveError:
    FS_MoveFile = False
End Function

Public Function FS_DeleteFile(ByVal filePath As String) As Boolean
    On Error GoTo DelError
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.DeleteFile filePath, True
    FS_DeleteFile = True
    Exit Function
DelError:
    FS_DeleteFile = False
End Function

Public Function FS_GetFileSize(ByVal filePath As String) As Double
    ' Returns file size in bytes
    On Error Resume Next
    Dim fso As Object
    Dim f As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(filePath) Then
        Set f = fso.GetFile(filePath)
        FS_GetFileSize = f.Size
    Else
        FS_GetFileSize = -1
    End If
End Function

Public Function FS_FindFiles(ByVal folderPath As String, _
                             ByVal pattern As String, _
                             Optional ByVal recursive As Boolean = True) As String
    ' Find files matching pattern in folder
    On Error GoTo FindError
    
    Dim fso As Object
    Dim folder As Object
    Dim file As Object
    Dim subFolder As Object
    Dim result As String
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(folderPath) Then
        FS_FindFiles = "[ERROR] Folder not found"
        Exit Function
    End If
    
    Set folder = fso.GetFolder(folderPath)
    result = ""
    
    For Each file In folder.Files
        If LCase(file.Name) Like LCase(pattern) Then
            result = result & file.Path & " (" & Round(file.Size / 1024, 1) & " KB)" & vbCrLf
        End If
    Next file
    
    If recursive Then
        For Each subFolder In folder.SubFolders
            result = result & FS_FindFiles(subFolder.Path, pattern, True)
        Next subFolder
    End If
    
    If Len(result) = 0 Then
        result = "Aucun fichier trouv" & Chr(233)
    End If
    
    FS_FindFiles = result
    Exit Function
    
FindError:
    FS_FindFiles = "[ERROR] " & Err.Description
End Function

Public Sub FS_ListFolder(ByVal folderPath As String)
    ' Display folder contents in a message box
    Dim result As String
    result = FS_FindFiles(folderPath, "*.*", True)
    MsgBox "Contenu de " & folderPath & ":" & vbCrLf & vbCrLf & result, _
           vbInformation, "Explorateur Fichiers"
End Sub

' ============================================================================
' 7. ENVIRONMENT VARIABLES
' ============================================================================

Public Function Env_Get(ByVal varName As String) As String
    Env_Get = Environ(varName)
End Function

Public Function Env_GetAll() As String
    Dim i As Integer
    Dim result As String
    Dim envStr As String
    
    result = "VARIABLE|VALEUR" & vbCrLf
    result = result & String(50, "-") & vbCrLf
    
    For i = 1 To 100
        envStr = Environ(i)
        If InStr(envStr, "=") > 0 Then
            result = result & Left(envStr, InStr(envStr, "=") - 1) & "|" & _
                     Mid(envStr, InStr(envStr, "=") + 1) & vbCrLf
        ElseIf Len(envStr) = 0 Then
            Exit For
        End If
    Next i
    
    Env_GetAll = result
End Function

Public Sub Env_Show()
    MsgBox Env_GetAll(), vbInformation, "Variables d'environnement"
End Sub

' ============================================================================
' 8. CLIPBOARD OPERATIONS
' ============================================================================

Public Sub Clipboard_SetText(ByVal text As String)
    ' Set clipboard text
    Dim obj As Object
    On Error Resume Next
    Set obj = CreateObject("htmlfile")
    Set obj.parentWindow.clipboardData.GetData("text") = ""  ' Clear
    obj.parentWindow.clipboardData.SetData "text", text
End Sub

Public Function Clipboard_GetText() As String
    ' Get clipboard text
    Dim obj As Object
    On Error Resume Next
    Set obj = CreateObject("htmlfile")
    Clipboard_GetText = obj.parentWindow.clipboardData.GetData("text")
End Function

' ============================================================================
' 9. KEYBOARD SIMULATION
' ============================================================================

Public Sub Keyboard_SendKeys(ByVal keys As String)
    ' Simulate keyboard input
    
    On Error Resume Next
    SendKeys keys, True
End Sub

Public Sub Keyboard_TypeText(ByVal text As String)
    ' Type text with realistic timing
    
    Dim i As Integer
    For i = 1 To Len(text)
        SendKeys Mid(text, i, 1), True
        ' Small delay between keystrokes
        Application.Wait Now + TimeValue("00:00:01")
    Next i
End Sub

' ============================================================================
' 10. NETWORK TOOLS
' ============================================================================

Public Function Net_Ping(ByVal host As String) As String
    ' Ping a host and return result
    Dim output As String
    output = Shell_CaptureOutput("ping -n 1 -w 2000 " & host)
    
    If InStr(output, "TTL=") > 0 Or InStr(output, "Reply from") > 0 Then
        Net_Ping = "OK: " & host & " r" & Chr(233) & "pond"
    ElseIf InStr(output, "Destination net unreachable") > 0 Then
        Net_Ping = "INACCESSIBLE: " & host
    ElseIf InStr(output, "Request timed out") > 0 Then
        Net_Ping = "TIMEOUT: " & host
    Else
        Net_Ping = "INCONNU: " & host & " " & Left(output, 100)
    End If
End Function

Public Function Net_GetIPConfig() As String
    Net_GetIPConfig = Shell_CaptureOutput("ipconfig")
End Function

Public Function Net_GetDNS() As String
    Net_GetDNS = Shell_CaptureOutput("nslookup localhost 2>nul | findstr /i ""Default Server""")
End Function

Public Sub Net_ShowIPConfig()
    MsgBox Net_GetIPConfig(), vbInformation, "Configuration IP"
End Sub

' ============================================================================
' 11. HIGH-LEVEL COMPOSITE TOOLS
' ============================================================================

Public Sub PC_ShowDiagnostics()
    ' Show comprehensive system diagnostic
    Dim result As String
    
    result = WMI_GetSystemInfo()
    result = result & vbCrLf & WMI_GetNetworkInfo()
    result = result & vbCrLf & WMI_GetBatteryInfo()
    
    MsgBox result, vbInformation, "Diagnostic Syst" & Chr(232) & "me - Academix v13.2"
End Sub

Public Sub PC_TakeControl(ByVal appTitle As String)
    ' Bring an application window to foreground and activate it
    Dim hWnd As LongPtr
    hWnd = Window_Find(appTitle)
    
    If hWnd <> 0 Then
        Window_BringToFront hWnd
        Debug.Print "[PCCTL] Activated window: " & appTitle
    Else
        MsgBox "Fen" & Chr(234) & "tre non trouv" & Chr(233) & ": " & appTitle, vbExclamation
    End If
End Sub

Public Sub PC_RunAndWait(ByVal command As String)
    ' Run command, show output in message box if non-empty
    Dim output As String
    Dim exitCode As Long
    
    exitCode = Shell_RunCommand(command, False, True)
    output = Shell_CaptureOutput(command)
    
    If Len(output) > 0 Then
        MsgBox "Commande: " & command & vbCrLf & _
               "Code sortie: " & exitCode & vbCrLf & vbCrLf & _
               "Sortie:" & vbCrLf & output, _
               vbInformation, "R" & Chr(233) & "sultat Commande"
    End If
End Sub

' ============================================================================
' END - mod_PCControl.bas
' ============================================================================
