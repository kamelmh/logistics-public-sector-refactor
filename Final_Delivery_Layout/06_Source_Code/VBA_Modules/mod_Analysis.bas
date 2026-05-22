Attribute VB_Name = "mod_Analysis"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================
'
' ANALYSIS UI HUB — Consolidated entry point for all analytical operations.
' Delegates computation to engine modules (mod_StockEngine, mod_Forecasting,
' mod_StockOutPredictor) and provides user-friendly UI feedback.
'
' Pattern: UI Layer (mod_Analysis) → Engine Layer (mod_StockEngine, etc.)
'
' ============================================================================

Option Explicit

' ---------------------------------------------------------------------------
' ABC-XYZ Classification
' ---------------------------------------------------------------------------
Public Sub UpdateABC_Classification()
    On Error GoTo ErrorHandler
    
    MsgBox "Lancement du recalcul des classifications ABC-XYZ via le moteur VBA...", vbInformation, "Analyse en cours"
    
    ' Delegate to engine: recalculates CMUP and ABC from MOUVEMENTS ledger
    Call mod_SyncBridge.SyncMetricsFromLedger
    
    MsgBox "La classification ABC-XYZ a été mise a jour avec succes a partir des donnees de consommation.", vbInformation, "Analyse Complete"
    Exit Sub

ErrorHandler:
    MsgBox "Une erreur s'est produite durant l'analyse: " & Err.Description, vbCritical, "ERP Académie v13"
    Debug.Print "[Analysis] Error " & Err.Number & " in UpdateABC_Classification: " & Err.Description
End Sub

' ---------------------------------------------------------------------------
' Stock-Out Prediction
' ---------------------------------------------------------------------------
Public Sub RunStockOutAnalysis()
    On Error GoTo ErrorHandler
    
    MsgBox "Lancement de l'analyse de rupture de stock...", vbInformation, "Analyse en cours"
    
    ' Delegate to prediction engine
    Call mod_StockOutPredictor.RunStockOutPrediction
    
    Exit Sub

ErrorHandler:
    MsgBox "Une erreur s'est produite durant l'analyse de rupture: " & Err.Description, vbCritical, "ERP Académie v13"
    Debug.Print "[Analysis] Error " & Err.Number & " in RunStockOutAnalysis: " & Err.Description
End Sub

' ---------------------------------------------------------------------------
' Forecasting Refresh
' ---------------------------------------------------------------------------
Public Sub RefreshForecastAnalysis()
    On Error GoTo ErrorHandler
    
    ' Delegate to forecasting engine
    Call mod_Forecasting.RefreshForecastSheet
    
    Exit Sub

ErrorHandler:
    MsgBox "Une erreur s'est produite durant le recalcul des prévisions: " & Err.Description, vbCritical, "ERP Académie v13"
    Debug.Print "[Analysis] Error " & Err.Number & " in RefreshForecastAnalysis: " & Err.Description
End Sub

' ---------------------------------------------------------------------------
' Stock Aging Report
' ---------------------------------------------------------------------------
Public Sub RunStockAgingAnalysis()
    On Error GoTo ErrorHandler
    
    ' Delegate to aging engine
    Call mod_StockAging.RunStockAgingReport
    
    Exit Sub

ErrorHandler:
    MsgBox "Une erreur s'est produite durant l'analyse de vieillissement: " & Err.Description, vbCritical, "ERP Académie v13"
    Debug.Print "[Analysis] Error " & Err.Number & " in RunStockAgingAnalysis: " & Err.Description
End Sub
Public Sub RunFullAnalysis()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    ' Step 1: Recalculate CMUP from ledger
    Call mod_StockEngine.RefreshAllCMUP
    
    ' Step 2: Update ABC classifications
    Call mod_StockEngine.UpdateAllABCClassifications(silent:=True)
    
    ' Step 3: Refresh forecasts
    Call mod_Forecasting.RefreshForecastSheet
    
    ' Step 4: Run stock-out prediction
    Call mod_StockOutPredictor.RunStockOutPrediction
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    
    MsgBox "Analyse complete: CMUP, ABC-XYZ, prévisions et rupture de stock mis a jour.", vbInformation, "ERP Académie v13"
    Exit Sub

ErrorHandler:
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    MsgBox "Une erreur s'est produite durant l'analyse complete: " & Err.Description, vbCritical, "ERP Académie v13"
    Debug.Print "[Analysis] Error " & Err.Number & " in RunFullAnalysis: " & Err.Description
End Sub
