Attribute VB_Name = "mod_TestHarness"
'==============================================================================
' mod_TestHarness.bas — ERP Académie v13.2
' Unit & Integration Test Procedures
' Created: 2026-05-06 (Action #5: Test harness for mod_StockEngine)
'==============================================================================

Option Explicit

'--------------------------------------------------------------------------------------
' TEST RUNNER — Execute all tests and report results
'--------------------------------------------------------------------------------------
Public Sub RunAllTests()
    Dim totalPass As Long, totalFail As Long, totalSkip As Long
    Dim testResults As String
    
    testResults = "═══════════════════════════════════════════" & vbCrLf & _
                  "  ERP Académie v13.2 — Test Results" & vbCrLf & _
                  "═══════════════════════════════════════════" & vbCrLf & vbCrLf
    
    ' Phase 1: Unit Tests — mod_StockCalculations
    testResults = testResults & "--- Phase 1: Unit Tests (mod_StockCalculations) ---" & vbCrLf
    Call TestUnit(testResults, "CalculateROP(1546, 2, 200)", 205.6, _
        mod_StockCalculations.CalculateROP(1546, 2, 200), 0.01)
    Call TestUnit(testResults, "CalculateROP(0, 2, 200) — zero demand", 0, _
        mod_StockCalculations.CalculateROP(0, 2, 200), 0.01)
    Call TestUnit(testResults, "CalculateEOQ(1546, 500, 80) — Wilson H=80", 138.9, _
        mod_StockCalculations.CalculateEOQ(1546, 500, 80), 1)
    Call TestUnit(testResults, "CalculateEOQ(0, 500, 80) — zero demand", 0, _
        mod_StockCalculations.CalculateEOQ(0, 500, 80), 0.01)
    Call TestUnit(testResults, "CalculateCMUP(50000, 250)", 200, _
        mod_StockCalculations.CalculateCMUP(50000, 250), 0.01)
    Call TestUnit(testResults, "CalculateCMUP(50000, 0) — zero qty", 0, _
        mod_StockCalculations.CalculateCMUP(50000, 0), 0.01)
    Call TestUnit(testResults, "CalculateABCCategory(50) — Class A", "A", _
        mod_StockCalculations.CalculateABCCategory(50), 0)
    Call TestUnit(testResults, "CalculateABCCategory(90) — Class B", "B", _
        mod_StockCalculations.CalculateABCCategory(90), 0)
    Call TestUnit(testResults, "CalculateABCCategory(98) — Class C", "C", _
        mod_StockCalculations.CalculateABCCategory(98), 0)
    
    ' Phase 2: Unit Tests — mod_Utilities
    testResults = testResults & vbCrLf & "--- Phase 2: Unit Tests (mod_Utilities) ---" & vbCrLf
    Call TestUnit(testResults, "SafeVal("""") — empty string", 0, _
        mod_Utilities.SafeVal(""), 0.01)
    Call TestUnit(testResults, "SafeVal(""abc"") — text", 0, _
        mod_Utilities.SafeVal("abc"), 0.01)
    Call TestUnit(testResults, "SafeVal(""123.45"") — number", 123.45, _
        mod_Utilities.SafeVal("123.45"), 0.01)
    Call TestUnitBool(testResults, "IsValidDate(""2026-05-06"")", True, _
        mod_Utilities.IsValidDate("2026-05-06"))
    Call TestUnitBool(testResults, "IsValidDate(""invalid"")", False, _
        mod_Utilities.IsValidDate("invalid"))
    
    ' Phase 3: Integration Tests — mod_Config constants
    testResults = testResults & vbCrLf & "--- Phase 3: Config Constants (mod_Config) ---" & vbCrLf
    Call TestUnit(testResults, "DOC_TYPE_BS", "Bon de Sortie", _
        mod_Config.DOC_TYPE_BS, 0)
    Call TestUnit(testResults, "VERSION", "v13.2", _
        mod_Config.VERSION, 0)
    Call TestUnit(testResults, "MASTER_PWD", "erp_secure_pwd_2026", _
        mod_Config.MASTER_PWD, 0)
    Call TestUnit(testResults, "OBSERVATION_DAYS", 38, _
        mod_Config.OBSERVATION_DAYS, 0)
    
    ' Summary
    testResults = testResults & vbCrLf & "═══════════════════════════════════════════" & vbCrLf
    MsgBox testResults, vbInformation, "Test Results"
End Sub

'--------------------------------------------------------------------------------------
' TEST HELPERS
'--------------------------------------------------------------------------------------
Private Sub TestUnit(ByRef results As String, testName As String, expected As Variant, _
                     actual As Variant, tolerance As Double)
    Dim pass As Boolean
    
    If IsNumeric(expected) And IsNumeric(actual) Then
        pass = (Abs(CDbl(actual) - CDbl(expected)) <= tolerance)
    Else
        pass = (CStr(actual) = CStr(expected))
    End If
    
    If pass Then
        results = results & "  PASS: " & testName & vbCrLf
    Else
        results = results & "  FAIL: " & testName & " — expected: " & _
                  CStr(expected) & ", got: " & CStr(actual) & vbCrLf
    End If
End Sub

Private Sub TestUnitBool(ByRef results As String, testName As String, _
                         expected As Boolean, actual As Boolean)
    If expected = actual Then
        results = results & "  PASS: " & testName & vbCrLf
    Else
        results = results & "  FAIL: " & testName & " — expected: " & _
                  CStr(expected) & ", got: " & CStr(actual) & vbCrLf
    End If
End Sub

'--------------------------------------------------------------------------------------
' SMOKE TEST — Full workbook verification
'--------------------------------------------------------------------------------------
Public Sub SmokeTest()
    Dim issues As String
    issues = ""
    
    ' Check all critical sheets
    Dim criticalSheets As Variant
    criticalSheets = Array("ARTICLES", "MOUVEMENTS", "CALCULS_EOQ", "SYS_STRINGS", _
                           "AUDIT_LOG", "STAGING_BUFFER")
    
    Dim i As Long
    For i = 0 To UBound(criticalSheets)
        On Error Resume Next
        Dim ws As Worksheet
        Set ws = ThisWorkbook.Sheets(criticalSheets(i))
        On Error GoTo 0
        If ws Is Nothing Then
            issues = issues & "  MISSING: " & criticalSheets(i) & vbCrLf
        End If
    Next i
    
    ' Check mod_Config constants
    If mod_Config.VERSION <> "v13.2" Then
        issues = issues & "  WRONG VERSION: " & mod_Config.VERSION & vbCrLf
    End If
    
    ' Check ROP calculation
    Dim rop As Double
    rop = mod_StockCalculations.CalculateROP(1546, 2, 200)
    If Abs(rop - 205.6) > 0.1 Then
        issues = issues & "  ROP MISMATCH: " & rop & vbCrLf
    End If
    
    ' Check EOQ calculation
    Dim eoq As Double
    eoq = mod_StockCalculations.CalculateEOQ(1546, 500, 0.2 * 400)
    If eoq < 130 Or eoq > 150 Then
        issues = issues & "  EOQ OUT OF RANGE: " & eoq & vbCrLf
    End If
    
    ' Report
    If issues = "" Then
        MsgBox "SMOKE TEST: ALL PASS" & vbCrLf & _
               "  Sheets: OK" & vbCrLf & _
               "  Config: OK" & vbCrLf & _
               "  ROP=205.6: OK" & vbCrLf & _
               "  EOQ~139: OK", vbInformation, "Smoke Test"
    Else
        MsgBox "SMOKE TEST: FAILURES" & vbCrLf & vbCrLf & issues, vbCritical, "Smoke Test"
    End If
End Sub
