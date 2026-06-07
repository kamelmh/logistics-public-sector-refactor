Attribute VB_Name = "mod_Localization"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Education - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

' ================================================================================
' API DECLARATIONS (for Unicode/Arabic support)
' ================================================================================
#If VBA7 Then
    Private Declare PtrSafe Function MessageBoxW Lib "user32" ( _
        ByVal hwnd As LongPtr, _
        ByVal lpText As LongPtr, _
        ByVal lpCaption As LongPtr, _
        ByVal uType As Long) As Long
#Else
    Private Declare Function MessageBoxW Lib "user32" ( _
        ByVal hwnd As Long, _
        ByVal lpText As Long, _
        ByVal lpCaption As Long, _
        ByVal uType As Long) As Long
#End If

' ================================================================================
' FUNCTION: GetLocalizedString
' Returns Arabic text from SYS_STRINGS sheet by STRING_ID
' ================================================================================
Public Function GetLocalizedString(ByVal stringID As String) As String
    On Error Resume Next
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_SYS_STRINGS)
    
    If ws Is Nothing Then
        GetLocalizedString = stringID
        Exit Function
    End If
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.count, COL_SYS_ID).End(xlUp).Row
    
    Dim i As Long
    For i = 2 To lastRow
        If Trim(ws.Cells(i, COL_SYS_ID).Value) = stringID Then
            GetLocalizedString = Trim(ws.Cells(i, COL_SYS_VALUE).Value)
            Exit Function
        End If
    Next i
    
    GetLocalizedString = stringID
    On Error GoTo 0
End Function

' Compatibility wrapper for SafeGetTxt used in forms
Public Function SafeGetTxt(ByVal strID As String) As String
    SafeGetTxt = GetLocalizedString(strID)
End Function

' ================================================================================
' SUB: ShowLocalizedMessage
' Shows a localized message box in Arabic (Unicode supported)
' ================================================================================
Public Sub ShowLocalizedMessage(ByVal stringID As String, _
                         Optional ByVal msgType As VbMsgBoxStyle = vbInformation, _
                         Optional ByVal title As String = "")
    Dim msg As String
    msg = GetLocalizedString(stringID)
    
    If title = "" Then
        title = GetLocalizedString("SYS_TITLE")
        If title = "SYS_TITLE" Then title = mod_Config.SYS_TITLE
    End If
    
    ' Use Unicode MessageBox to prevent Arabic garbling
    UnicodeMsgBox msg, msgType, title
End Sub

' ================================================================================
' SUB: UnicodeMsgBox
' Wrapper for Windows API MessageBoxW to support Unicode/Arabic
' ================================================================================
Public Sub UnicodeMsgBox(ByVal msg As String, _
                         Optional ByVal msgType As VbMsgBoxStyle = vbInformation, _
                         Optional ByVal title As String = "")
    ' We use StrPtr to pass the pointer to the Unicode string (BSTR)
    MessageBoxW 0, StrPtr(msg), StrPtr(title), CLng(msgType)
End Sub

' ================================================================================
' FUNCTION: GetBilingualLabel
' Returns "French / Arabic" by looking up Arabic from SYS_STRINGS
' Falls back to French only if key not found
' ================================================================================
Public Function GetBilingualLabel(ByVal frenchText As String, ByVal stringKey As String) As String
    Dim arabicText As String
    arabicText = GetLocalizedString(stringKey)
    If arabicText = stringKey Or arabicText = "" Then
        GetBilingualLabel = frenchText
    Else
        GetBilingualLabel = frenchText & " / " & arabicText
    End If
End Function

' ================================================================================
' FUNCTION: Ar
' Converts hex codepoint string to Arabic Unicode text
' Example: Ar("633 62C 644") returns ChrW(0x633) & ChrW(0x62C) & ChrW(0x644) = "???"
' This avoids .bas file encoding issues with Arabic characters
' ================================================================================
Private Function Ar(ByVal hexCodes As String) As String
    Dim codes() As String
    codes = Split(hexCodes)
    Dim result As String
    result = ""
    Dim i As Long
    For i = 0 To UBound(codes)
        Dim trimmed As String
        trimmed = Trim(codes(i))
        If Len(trimmed) > 0 Then
            result = result & ChrW(CLng("&H" & trimmed))
        End If
    Next i
    Ar = result
End Function

' ================================================================================
' SUB: PopulateAccueilSysStrings
' Adds ACCUEIL-specific bilingual keys to SYS_STRINGS (idempotent)
' Called from mod_UI_Setup.SetupAccueilSheet
' ================================================================================
Public Sub PopulateAccueilSysStrings()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(mod_Config.SHEET_SYS_STRINGS)
    On Error GoTo 0
    If ws Is Nothing Then Exit Sub

    ' Check if already populated
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, COL_SYS_ID).End(xlUp).Row
    Dim i As Long
    For i = 2 To lastRow
        If Trim(ws.Cells(i, COL_SYS_ID).Value) = "ACC_SEC_SAISIE" Then
            Exit Sub ' Already populated
        End If
    Next i

    On Error Resume Next
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    On Error GoTo 0

    Dim r As Long
    r = lastRow + 1

    ' --- Section headers (5) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_SEC_SAISIE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("633 62C 644 20 627 644 639 645 644 64A 627 62A") ' ??? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_SEC_TABLEAU_BORD"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 645 624 634 631 627 62A 20 648 627 644 62A 646 628 64A 647 627 62A") ' ???????? ??????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_SEC_ANALYSE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 62A 62D 644 64A 644 20 648 627 644 62D 633 627 628 627 62A") ' ??????? ?????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_SEC_RAPPORTS"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 639 62F 627 62F 20 627 644 648 62B 627 626 642") ' ????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_SEC_UTILITAIRES"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62F 648 627 62A 20 627 644 635 64A 627 646 629") ' ????? ???????
    r = r + 1

    ' --- Buttons SAISIE (5) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_SAISIE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62F 62E 627 644 20 627 644 642 64A 648 62F") ' ????? ??????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_BARCODE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("645 633 62D 20 627 644 621 635 646 627 641") ' ??? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_SCANIN"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62F 62E 627 644 20 628 627 644 631 645 632") ' ????? ??????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_SCANOUT"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62E 631 627 62C 20 628 627 644 631 645 632") ' ????? ??????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_CSV_IMPORT"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 633 62A 64A 631 627 62F 20 627 644 62D 631 643 627 62A") ' ??????? ???????
    r = r + 1

    ' --- Buttons TABLEAU DE BORD (3) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_DASHBOARD"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 62D 62F 64A 62B 20 627 644 645 624 634 631 627 62A") ' ????? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_HEATMAP"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 637 628 64A 642 20 627 644 62E 631 64A 637 629 20 627 644 62D 631 627 631 64A 629") ' ????? ??????? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_PDF_EXPORT"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 635 62F 64A 631 20 644 648 62D 629 20 627 644 642 64A 627 62F 629") ' ????? ???? ???????
    r = r + 1

    ' --- Buttons ANALYSE (7) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_ABC"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 635 646 64A 641 20 ABC") ' ????? ABC
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_CMUP"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 62D 62F 64A 62B 20 CMUP") ' ????? CMUP
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_FORECAST"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 62A 646 628 624 20 628 627 644 646 641 627 62F") ' ?????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_FULL_ANALYSIS"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 62D 644 64A 644 20 643 627 645 644") ' ????? ????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_AGING"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 642 627 62F 645 20 627 644 645 62E 632 648 646") ' ????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_RECONCILE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62C 631 62F 20 627 644 645 62E 632 648 646") ' ??? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_SCORECARD"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 642 64A 64A 645 20 627 644 645 648 631 62F 64A 646") ' ????? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_BUDGET"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 642 631 64A 631 20 627 644 645 64A 632 627 646 64A 629") ' ????? ?????????
    r = r + 1

    ' --- Buttons RAPPORTS (8) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_IMPORT_CSV"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 633 62A 64A 631 627 62F 20 CSV") ' ??????? CSV
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_REPORT"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 62A 642 631 64A 631 20 627 644 634 647 631 64A") ' ??????? ??????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_STOCK_CARD"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("628 637 627 642 629 20 627 644 645 62E 632 648 646") ' ????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_ORDER"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 645 631 20 627 644 62A 645 648 64A 646") ' ??? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_PRINT_CFG"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 639 62F 627 62F 20 627 644 637 628 627 639 629") ' ??????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_PREVIEW_RAPPORTS"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("645 639 627 64A 646 629 20 627 644 62A 642 627 631 64A 631") ' ?????? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_PREVIEW_INVENTAIRE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("645 639 627 64A 646 629 20 627 644 62C 631 62F") ' ?????? ?????
    r = r + 1

    ' --- Buttons UTILITAIRES (10) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_VALIDATE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 62A 62D 642 642 20 645 646 20 627 644 628 64A 627 646 627 62A") ' ?????? ?? ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_SYNC"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 645 632 627 645 646 629") ' ????????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_LOCATION"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 639 62F 627 62F 20 627 644 645 648 627 642 639") ' ??????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_EXPORT_CSV"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 635 62F 64A 631 20 CSV") ' ????? CSV
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_EXPORT_XLS"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("62A 635 62F 64A 631 20 Excel") ' ????? Excel
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_BTN_DEMO"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("628 64A 627 646 627 62A 20 62A 62C 631 64A 628 64A 629") ' ?????? ???????
    r = r + 1

    ' --- KPI labels (3) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_KPI_ARTICLES"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 644 621 635 646 627 641") ' ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_KPI_ALERTES"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 646 630 627 631 627 62A 20 627 644 645 62E 632 648 646") ' ??????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_KPI_MIS_A_JOUR"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62E 631 20 62A 62D 62F 64A 62B") ' ??? ?????
    r = r + 1

    ' --- Header (2) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_HDR_TITLE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("646 638 627 645 20 625 62F 627 631 629 20 627 644 645 62E 632 648 646") ' ???? ????? ???????
    r = r + 1

    ws.Cells(r, COL_SYS_ID).Value = "ACC_HDR_SUBTITLE"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("645 62F 64A 631 64A 629 20 627 644 62A 631 628 64A 629 20 2D 20 627 644 628 64A 636") ' ?????? ??????? - ?????
    r = r + 1

    ' --- Footer (1) ---
    ws.Cells(r, COL_SYS_ID).Value = "ACC_FOOTER_LAST_UPD"
    ws.Cells(r, COL_SYS_VALUE).Value = Ar("627 62E 631 20 62A 62D 62F 64A 62B") ' ??? ?????
    r = r + 1

    On Error Resume Next
    ws.Protect Password:=mod_Config.MASTER_PWD
    On Error GoTo 0
End Sub
