Attribute VB_Name = "mod_Profiler"
'=====================================================================
' mod_Profiler.bas
' Simple performance logger for VBA procedures.
' Writes a CSV file (PerformanceLog.csv) in the workbook's directory.
' Each line: Timestamp, ProcedureName, ElapsedMs
'=====================================================================
Option Explicit

' ------------------------------------------------------------------
' Declarations (MUST be before any Sub/Function/Property)
' ------------------------------------------------------------------
Private Const LOG_FILE_NAME As String = "PerformanceLog.csv"

' High-resolution timer API
#If VBA7 Then
    Private Declare PtrSafe Function QueryPerformanceFrequency Lib "kernel32" (ByRef Frequency As LongLong) As LongLong
    Private Declare PtrSafe Function QueryPerformanceCounter Lib "kernel32" (ByRef Counter As LongLong) As LongLong
#Else
    Private Declare Function QueryPerformanceFrequency Lib "kernel32" (ByRef Frequency As Currency) As Long
    Private Declare Function QueryPerformanceCounter Lib "kernel32" (ByRef Counter As Currency) As Long
#End If

' Module-level timer state
Private m_FreqInitialized As Boolean
Private m_Frequency As Double

' ------------------------------------------------------------------
' Helper: ensure frequency is initialized once
' ------------------------------------------------------------------
Private Sub InitFrequency()
    If Not m_FreqInitialized Then
        #If VBA7 Then
            Dim freq As LongLong
            QueryPerformanceFrequency freq
            m_Frequency = CDbl(freq)
        #Else
            ' Currency is a 64-bit type scaled by 10000; QPC raw value
            ' is divided by 10000 when read, so counter/freq cancels it
            Dim freq As Currency
            QueryPerformanceFrequency freq
            m_Frequency = CDbl(freq)
        #End If
        m_FreqInitialized = True
    End If
End Sub

' Returns the full path to the log file (same folder as the workbook)
Private Function GetLogPath() As String
    GetLogPath = ThisWorkbook.Path & Application.PathSeparator & LOG_FILE_NAME
End Function

' Initializes the log file with a header if it doesn't exist
Public Sub EnsureLogHeader()
    Dim fso As Object, ts As Object
    Dim logPath As String
    logPath = GetLogPath()
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(logPath) Then
        Set ts = fso.CreateTextFile(logPath, True, True) ' overwrite, Unicode
        ts.WriteLine "Timestamp,ProcedureName,ElapsedMs"
        ts.Close
    End If
    Set fso = Nothing
    Set ts = Nothing
End Sub

' Logs a single measurement
Public Sub LogPerf(ByVal procName As String, ByVal elapsedMs As Double)
    Dim fso As Object, ts As Object
    Dim logPath As String
    logPath = GetLogPath()
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set ts = fso.OpenTextFile(logPath, 8, True, -1) ' 8 = ForAppending, -1 = Unicode
    ts.WriteLine Format(Now, "yyyy-mm-dd hh:nn:ss") & "," & procName & "," & Format(elapsedMs, "0.000")
    ts.Close
    Set fso = Nothing
    Set ts = Nothing
End Sub

' Start timer - returns seconds as Double
Public Function TimerStart() As Double
    InitFrequency
    #If VBA7 Then
        Dim counter As LongLong
    #Else
        Dim counter As Currency
    #End If
    QueryPerformanceCounter counter
    TimerStart = CDbl(counter) / m_Frequency
End Function

' Stop timer and return elapsed seconds
Public Function TimerStop(ByVal startTime As Double) As Double
    InitFrequency
    #If VBA7 Then
        Dim counter As LongLong
    #Else
        Dim counter As Currency
    #End If
    QueryPerformanceCounter counter
    TimerStop = (CDbl(counter) / m_Frequency) - startTime
End Function

' Convenience: elapsed milliseconds
Public Function TimerStopMs(ByVal startTime As Double) As Double
    TimerStopMs = TimerStop(startTime) * 1000#
End Function