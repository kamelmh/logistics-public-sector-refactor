Attribute VB_Name = "mod_Timer"
'=====================================================================
' mod_Timer.bas
' Simple high-resolution timer for profiling VBA code.
' Usage:
'   Dim t As Double
'   t = TimerStart
'   ' ... code to measure ...
'   Debug.Print "Elapsed: " & TimerStop(t) & " seconds"
'=====================================================================
Option Explicit

' API declarations for high-resolution timer (Windows)
#If VBA7 Then
    Private Declare PtrSafe Function QueryPerformanceFrequency Lib "kernel32" (ByRef Frequency As LongLong) As LongLong
    Private Declare PtrSafe Function QueryPerformanceCounter Lib "kernel32" (ByRef Counter As LongLong) As LongLong
#Else
    Private Declare Function QueryPerformanceFrequency Lib "kernel32" (ByRef Frequency As Currency) As Long
    Private Declare Function QueryPerformanceCounter Lib "kernel32" (ByRef Counter As Currency) As Long
#End If

Private FrequencyAsDouble As Double

' Initialize frequency once
Private Sub Class_Initialize()
    Dim freq As LongLong
    QueryPerformanceFrequency freq
    FrequencyAsDouble = CDbl(freq)
End Sub

' Start timer
Public Function TimerStart() As Double
    Dim counter As LongLong
    QueryPerformanceCounter counter
    TimerStart = CDbl(counter) / FrequencyAsDouble
End Function

' Stop timer and return elapsed seconds
Public Function TimerStop(ByVal startTime As Double) As Double
    Dim counter As LongLong
    QueryPerformanceCounter counter
    TimerStop = (CDbl(counter) / FrequencyAsDouble) - startTime
End Function

' Convenience: return elapsed milliseconds
Public Function TimerStopMs(ByVal startTime As Double) As Double
    TimerStopMs = TimerStop(startTime) * 1000#
End Function

' Example usage (can be removed):
' Sub TestTimer()
'     Dim start As Double
'     start = TimerStart
'     Dim i As Long
'     For i = 1 To 100000
'         Dim x As Double: x = Rnd * i
'     Next i
'     Debug.Print "Loop took: " & TimerStopMs(start) & " ms"
' End Sub