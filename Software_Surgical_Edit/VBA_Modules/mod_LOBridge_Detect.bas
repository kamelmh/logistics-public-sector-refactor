Attribute VB_Name = "mod_LOBridge_Detect"
' ============================================================================
' Academix v13.3 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' LibreOffice Detection Module - extracted from mod_LibreBridge v2.0
'
' Extracted during v13.3 refactoring to reduce mod_LibreBridge from 1141
' to ~850 lines. All detection logic consolidated here: registry, WMI,
' PATH scanning, and 30 known Program Files install paths.
' ============================================================================

Option Explicit

' ============================================================================
' CONSTANTS
' ============================================================================

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
' END - mod_LOBridge_Detect.bas
' ============================================================================
