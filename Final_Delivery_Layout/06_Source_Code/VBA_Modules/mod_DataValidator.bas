Attribute VB_Name = "mod_DataValidator"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Private Const SHEET_VALIDATION As String = "VALIDATION_INTEGRITE"

Public Sub RunDataValidation()
    Dim wsOut As Worksheet
    Dim issues As Collection
    Dim issueCount As Long

    On Error GoTo ErrorHandler
    Application.ScreenUpdating = False

    Set issues = New Collection

    Call ValidateMouvements(issues)
    Call ValidateArticles(issues)
    Call ValidateSuppliers(issues)

    Set wsOut = GetOrCreateSheet(SHEET_VALIDATION)
    wsOut.Unprotect Password:=mod_Config.MASTER_PWD
    wsOut.Cells.Clear

    With wsOut
        .Range("A1:E1").Merge
        .Cells(1, 1).Value = "RAPPORT DE VALIDATION D'INTEGRITE DES DONNEES"
        .Cells(1, 1).Font.Bold = True
        .Cells(1, 1).Font.Size = 14
        .Cells(2, 1).Value = "Date: " & Format(Now, "DD/MM/YYYY HH:MM")
        .Cells(2, 1).Font.Italic = True

        .Cells(4, 1).Value = "SOURCE"
        .Cells(4, 2).Value = "TYPE"
        .Cells(4, 3).Value = "DESCRIPTION"
        .Cells(4, 4).Value = "VALEUR"
        .Cells(4, 5).Value = "GRAVITE"
        .Range("A4:E4").Font.Bold = True
        .Range("A4:E4").Interior.Color = RGB(0, 70, 127)
        .Range("A4:E4").Font.Color = RGB(255, 255, 255)
    End With

    issueCount = issues.Count
    Dim rowNum As Long
    rowNum = 5

    If issueCount = 0 Then
        wsOut.Cells(rowNum, 1).Value = "AUCUN PROBLEME DETECTE"
        wsOut.Range("A" & rowNum & ":E" & rowNum).Merge
        wsOut.Cells(rowNum, 1).Font.Color = RGB(0, 128, 0)
        wsOut.Cells(rowNum, 1).Font.Bold = True
    Else
        Dim idx As Long
        For idx = 1 To issueCount
            Dim item
            item = issues.Item(idx)
            With wsOut
                .Cells(rowNum, 1).Value = item(0)
                .Cells(rowNum, 2).Value = item(1)
                .Cells(rowNum, 3).Value = item(2)
                .Cells(rowNum, 4).Value = item(3)
                .Cells(rowNum, 5).Value = item(4)

                If item(4) = "CRITIQUE" Then
                    .Range(.Cells(rowNum, 1), .Cells(rowNum, 5)).Interior.Color = RGB(255, 200, 200)
                ElseIf item(4) = "AVERTISSEMENT" Then
                    .Range(.Cells(rowNum, 1), .Cells(rowNum, 5)).Interior.Color = RGB(255, 243, 224)
                End If
            End With
            rowNum = rowNum + 1
        Next idx
    End If

    Dim sRow As Long
    sRow = rowNum + 1
    With wsOut
        .Cells(sRow, 1).Value = "RESUME"
        .Cells(sRow, 1).Font.Bold = True
        .Cells(sRow + 1, 1).Value = "Total problemes:"
        .Cells(sRow + 1, 2).Value = issueCount
        .Columns("A:E").AutoFit
    End With

    wsOut.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True

    Application.ScreenUpdating = True
    If issueCount > 0 Then
        MsgBox "Validation terminee. " & issueCount & " probleme(s) detecte(s). Consultez l'onglet " & SHEET_VALIDATION & ".", _
               vbExclamation, "ACADEMIX v13.2"
    Else
        MsgBox "Validation terminee. Aucun probleme detecte.", vbInformation, "ACADEMIX v13.2"
    End If
    Exit Sub

ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur validation: " & Err.Description, vbCritical
End Sub

Private Sub ValidateMouvements(ByRef issues As Collection)
    Dim ws As Worksheet
    Dim lastRow As Long, i As Long
    Dim artCode As String, mvtType As String, refDoc As String
    Dim qty As Double, mvtDate As Variant
    Dim wsArt As Worksheet, found As Variant

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_MOUVEMENTS)
    Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If ws Is Nothing Then
        issues.Add Array("MOUVEMENTS", "ABSENT", "Feuille MOUVEMENTS introuvable", "", "CRITIQUE")
        Exit Sub
    End If

    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row

    For i = 2 To lastRow
        artCode = Trim(ws.Cells(i, 2).Value)
        mvtType = Trim(ws.Cells(i, 4).Value)
        refDoc = Trim(ws.Cells(i, 7).Value)
        qty = mod_Utilities.SafeVal(ws.Cells(i, 5).Value)
        mvtDate = ws.Cells(i, 1).Value

        If artCode = "" Then
            issues.Add Array("MOUVEMENTS", "CODE_VIDE", "Ligne " & i & " - Code article manquant", "", "CRITIQUE")
            GoTo NextMvt
        End If

        If Len(artCode) < 5 Then
            issues.Add Array("MOUVEMENTS", "CODE_COURT", "Ligne " & i & " - Code suspect: " & artCode, artCode, "AVERTISSEMENT")
        End If

        If mvtType <> "IN" And mvtType <> "OUT" Then
            issues.Add Array("MOUVEMENTS", "TYPE_INVALIDE", "Ligne " & i & " - Type mouvement invalide: " & mvtType, mvtType, "CRITIQUE")
        End If

        If qty <= 0 Then
            issues.Add Array("MOUVEMENTS", "QUANTITE_INVALIDE", "Ligne " & i & " - Quantite <= 0", qty, "AVERTISSEMENT")
        End If

        If IsEmpty(mvtDate) Then
            issues.Add Array("MOUVEMENTS", "DATE_VIDE", "Ligne " & i & " - Date manquante", "", "CRITIQUE")
        ElseIf Not IsDate(mvtDate) Then
            issues.Add Array("MOUVEMENTS", "DATE_INVALIDE", "Ligne " & i & " - Date invalide: " & CStr(mvtDate), CStr(mvtDate), "CRITIQUE")
        End If

        If Not wsArt Is Nothing Then
            found = Application.Match(artCode, wsArt.Range("A:A"), 0)
                If IsError(found) Then
                    issues.Add Array("MOUVEMENTS", "ARTICLE_ORPHELIN", "Ligne " & i & " - " & artCode & " n'existe pas dans ARTICLES" & SuggestSimilarArticles(artCode), artCode, "CRITIQUE")
                End If
        End If
NextMvt:
    Next i

    ' Check duplicate ref
    Dim refs As Object
    Set refs = CreateObject("Scripting.Dictionary")
    For i = 2 To lastRow
        refDoc = Trim(ws.Cells(i, 7).Value)
        If refDoc <> "" Then
            If refs.Exists(refDoc) Then
                issues.Add Array("MOUVEMENTS", "REF_DUPLICATE", "Reference dupliquee: " & refDoc, refDoc, "AVERTISSEMENT")
            Else
                refs.Add refDoc, True
            End If
        End If
    Next i
End Sub

Private Sub ValidateArticles(ByRef issues As Collection)
    Dim ws As Worksheet
    Dim lastRow As Long, i As Long
    Dim artCode As String, stock As Double, pu As Double
    Dim codes As Object

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    On Error GoTo 0

    If ws Is Nothing Then
        issues.Add Array("ARTICLES", "ABSENT", "Feuille ARTICLES introuvable", "", "CRITIQUE")
        Exit Sub
    End If

    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    Set codes = CreateObject("Scripting.Dictionary")

    For i = 2 To lastRow
        artCode = Trim(ws.Cells(i, 1).Value)

        If artCode = "" Then
            issues.Add Array("ARTICLES", "CODE_VIDE", "Ligne " & i & " - Code article manquant", "", "CRITIQUE")
            GoTo NextArt
        End If

        If codes.Exists(artCode) Then
            issues.Add Array("ARTICLES", "DUPLICATE", "Code article duplique: " & artCode, artCode, "CRITIQUE")
        Else
            codes.Add artCode, True
        End If

        stock = mod_Utilities.SafeVal(ws.Cells(i, 3).Value)
        If stock < 0 Then
            issues.Add Array("ARTICLES", "STOCK_NEGATIF", artCode & " - Stock negatif: " & stock, stock, "CRITIQUE")
        End If

        pu = mod_Utilities.SafeVal(ws.Cells(i, 8).Value)
        If pu <= 0 Then
            issues.Add Array("ARTICLES", "PRIX_INVALIDE", artCode & " - Prix unitaire <= 0", pu, "AVERTISSEMENT")
        End If

        Dim designation As String
        designation = Trim(ws.Cells(i, 2).Value)
        If designation = "" Then
            issues.Add Array("ARTICLES", "DESIGNATION_VIDE", artCode & " - Designation manquante", artCode, "AVERTISSEMENT")
        End If
NextArt:
    Next i
End Sub

Private Sub ValidateSuppliers(ByRef issues As Collection)
    Dim ws As Worksheet
    Dim lastRow As Long, i As Long
    Dim fouCode As String, nif As String, nis As String

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_FOURNISSEURS)
    On Error GoTo 0

    If ws Is Nothing Then
        issues.Add Array("FOURNISSEURS", "ABSENT", "Feuille FOURNISSEURS introuvable", "", "AVERTISSEMENT")
        Exit Sub
    End If

    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row

    For i = 3 To lastRow
        fouCode = Trim(ws.Cells(i, 1).Value)
        If fouCode = "" Then
            issues.Add Array("FOURNISSEURS", "CODE_VIDE", "Ligne " & i & " - Code fournisseur manquant", "", "AVERTISSEMENT")
            GoTo NextFou
        End If

        nif = Trim(ws.Cells(i, 5).Value)
        nis = Trim(ws.Cells(i, 6).Value)
        If Len(nif) < 10 Then
            issues.Add Array("FOURNISSEURS", "NIF_COURT", fouCode & " - NIF semble invalide: " & nif, nif, "AVERTISSEMENT")
        End If
        If Len(nis) < 10 Then
            issues.Add Array("FOURNISSEURS", "NIS_COURT", fouCode & " - NIS semble invalide: " & nis, nis, "AVERTISSEMENT")
        End If
NextFou:
    Next i
End Sub

Private Function GetOrCreateSheet(ByVal sheetName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(sheetName)
    On Error GoTo 0
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        ws.Name = sheetName
    End If
    Set GetOrCreateSheet = ws
End Function

'===============================================================================
' FUZZY SEARCH ENGINE — Offline AI (Pillar 4)
' Levenshtein distance + French Soundex for duplicate article prevention
'===============================================================================

Public Function LevenshteinDistance(ByVal s1 As String, ByVal s2 As String) As Long
    Dim len1 As Long: len1 = Len(s1)
    Dim len2 As Long: len2 = Len(s2)
    If len1 = 0 Then LevenshteinDistance = len2: Exit Function
    If len2 = 0 Then LevenshteinDistance = len1: Exit Function
    
    Dim i As Long, j As Long
    Dim d() As Long
    ReDim d(0 To len1, 0 To len2)
    
    For i = 0 To len1: d(i, 0) = i: Next i
    For j = 0 To len2: d(0, j) = j: Next j
    
    For i = 1 To len1
        For j = 1 To len2
            Dim cost As Long
            If Mid(s1, i, 1) = Mid(s2, j, 1) Then cost = 0 Else cost = 1
            
            d(i, j) = WorksheetFunction.Min( _
                d(i - 1, j) + 1, _
                d(i, j - 1) + 1, _
                d(i - 1, j - 1) + cost)
        Next j
    Next i
    
    LevenshteinDistance = d(len1, len2)
End Function

Public Function SoundexFR(ByVal word As String) As String
    ' French Soundex — handles accents, silent letters, French phonemes
    Dim s As String: s = UCase(word)
    Dim i As Long
    Dim result As String
    
    ' Step 1: Strip all non-alpha characters
    Dim cleaned As String
    cleaned = ""
    For i = 1 To Len(s)
        Dim ch As String: ch = Mid(s, i, 1)
        If ch >= "A" And ch <= "Z" Then cleaned = cleaned & ch
    Next i
    If Len(cleaned) = 0 Then SoundexFR = "": Exit Function
    
    ' Step 2: Keep first letter
    result = Left(cleaned, 1)
    
    ' Step 3: Replace remaining letters with phonetic codes (French rules)
    Dim codes As String: codes = "0"  ' placeholder
    For i = 2 To Len(cleaned)
        ch = Mid(cleaned, i, 1)
        Dim code As String
        Select Case ch
            Case "A", "E", "I", "O", "U", "Y": code = "0"
            Case "B", "P": code = "1"
            Case "C", "K", "Q": code = "2"
            Case "D", "T": code = "3"
            Case "L": code = "4"
            Case "M", "N": code = "5"
            Case "R": code = "6"
            Case "F", "V": code = "7"
            Case "G", "J": code = "8"
            Case "S", "Z": code = "9"
            Case "H": code = ""  ' silent in French
            Case "X": code = "29"
            Case Else: code = ""
        End Select
        If code <> "" And code <> Right(codes, 1) Then codes = codes & code
    Next i
    
    ' Step 4: Strip vowels (code 0) and limit to 4 chars
    codes = Replace(codes, "0", "")
    SoundexFR = result & Left(codes & "000", 4)
End Function

Public Function FuzzySearchArticle(ByVal inputText As String, Optional ByVal threshold As Double = 0.7) As Variant
    ' Returns array of up to 3 suggestions: ({code, designation, score})
    Dim wsArt As Worksheet: Set wsArt = ThisWorkbook.Sheets(mod_Config.SHEET_ARTICLES)
    Dim lastRow As Long: lastRow = wsArt.Cells(wsArt.Rows.Count, COL_ART_CODE).End(xlUp).Row
    Dim i As Long
    
    ' Pre-compute Soundex of input
    Dim inputSoundex As String: inputSoundex = SoundexFR(inputText)
    
    ' Collect matches with scores
    Dim results(1 To 3, 1 To 3) As Variant
    Dim count As Long: count = 0
    Dim bestScore As Double
    Dim maxLen As Long
    
    For i = 2 To lastRow
        Dim artCode As String: artCode = Trim(wsArt.Cells(i, COL_ART_CODE).Value)
        Dim designation As String: designation = Trim(wsArt.Cells(i, COL_ART_DESIGNATION).Value)
        
        ' Soundex pre-filter — rapid phonetic gating
        Dim desigSoundex As String: desigSoundex = SoundexFR(designation)
        Dim soundexMatch As Boolean
        If Len(inputSoundex) >= 3 And Len(desigSoundex) >= 3 Then
            soundexMatch = (Left(inputSoundex, 3) = Left(desigSoundex, 3))
        Else
            soundexMatch = True
        End If
        
        If soundexMatch Then
            ' Levenshtein for precise ranking
            Dim dist As Long: dist = LevenshteinDistance(LCase(inputText), LCase(designation))
            maxLen = Len(inputText)
            If Len(designation) > maxLen Then maxLen = Len(designation)
            
            Dim score As Double
            If maxLen > 0 Then score = (maxLen - dist) / maxLen Else score = 0
            
            ' Track top 3
            If score >= threshold Then
                If count < 3 Then
                    count = count + 1
                    results(count, 1) = artCode
                    results(count, 2) = designation
                    results(count, 3) = score
                Else
                    ' Replace lowest scored if this is better
                    Dim minIdx As Long: minIdx = 1
                    Dim minScore As Double: minScore = results(1, 3)
                    Dim j As Long
                    For j = 2 To 3
                        If results(j, 3) < minScore Then
                            minScore = results(j, 3)
                            minIdx = j
                        End If
                    Next j
                    If score > minScore Then
                        results(minIdx, 1) = artCode
                        results(minIdx, 2) = designation
                        results(minIdx, 3) = score
                    End If
                End If
            End If
        End If
    Next i
    
    ' Return only what was found
    If count = 0 Then
        FuzzySearchArticle = Array()
    Else
        ReDim ret(1 To count, 1 To 3) As Variant
        For i = 1 To count
            ret(i, 1) = results(i, 1)
            ret(i, 2) = results(i, 2)
            ret(i, 3) = results(i, 3)
        Next i
        FuzzySearchArticle = ret
    End If
End Function

' Wrapper for orphan detection in validation: returns suggestion string
Public Function SuggestSimilarArticles(ByVal artCode As String) As String
    Dim suggestions As Variant
    suggestions = FuzzySearchArticle(artCode, 0.7)
    
    If UBound(suggestions) < 1 Then
        SuggestSimilarArticles = ""
        Exit Function
    End If
    
    Dim result As String
    Dim i As Long
    For i = 1 To UBound(suggestions, 1)
        If i > 3 Then Exit For
        If i > 1 Then result = result & "; "
        result = result & suggestions(i, 1) & " (" & suggestions(i, 2) & ":" & Format(suggestions(i, 3), "0%") & ")"
    Next i
    
    SuggestSimilarArticles = " SUGGESTIONS: " & result
End Function
