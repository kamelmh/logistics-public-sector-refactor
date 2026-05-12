Attribute VB_Name = "mod_Analysis"
' ============================================================================
' Academix v13.2 - DSS Logistique El Bayadh
' Copyright (c) 2025-2026 Mahi Kamel Abdelghani
' Direction de l'Éducation - Wilaya d'El Bayadh
' Protected under Algerian Copyright Law (Ordinance 03-05, July 19, 2003)
' All rights reserved. Unauthorized reproduction or distribution prohibited.
' ============================================================================

Option Explicit

Public Sub UpdateABC_Classification()
'------------------------------------------------------------------------------
' UPDATED v13.2: Logic consolidated into Local VBA Processing Units
' This macro triggers the local sync to recalculate CMUP and ABC-XYZ metrics
' and syncs the results back to the ARTICLES sheet.
'------------------------------------------------------------------------------
    On Error GoTo ABC_Error
    
    MsgBox "Lancement du recalcul des classifications ABC-XYZ via le moteur VBA...", vbInformation, "Analyse en cours"
    
    ' 1. Trigger local compute pass
    Call mod_SyncBridge.SyncMetricsFromLedger
    
    MsgBox "La classification ABC-XYZ a été mise a jour avec succes a partir des donnees de consommation.", vbInformation, "Analyse Complete"
    Exit Sub

ABC_Error:
    MsgBox "Une erreur s'est produite durant l'analyse: " & Err.Description, vbCritical
End Sub

