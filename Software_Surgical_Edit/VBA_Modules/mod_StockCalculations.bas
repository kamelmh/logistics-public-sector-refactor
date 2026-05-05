Attribute VB_Name = "mod_StockCalculations"
' VBA Module: mod_StockCalculations.bas
' Purpose: Calculer le Point de Recommandation (ROP) pour la gestion de stock
' Institution: Direction de l'Éducation, El Bayadh
' Cas d'étude: Toner G030 (ART-001)

Option Explicit

' Constantes VBA
Private Const xlUp As Long = -4162

' =============================================
' Function: CalculateROP
' Purpose: Calculer le Point de Commande (ROP)
' Formule: ROP = (DemandeAnnuelle / 365 * Delai) + StockSecurite
' =============================================
Public Function CalculateROP(AnnualDemand As Double, LeadTimeDays As Double, SafetyStock As Double) As Double
    On Error GoTo ErrorHandler
    
    Dim DailyDemand As Double
    Dim LeadTimeDemand As Double
    
    ' Valider les entrées
    If AnnualDemand < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    If LeadTimeDays < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    If SafetyStock < 0 Then
        CalculateROP = 0
        Exit Function
    End If
    
    ' Calculer la demande journalière
    DailyDemand = AnnualDemand / 365
    
    ' Calculer la demande pendant le délai
    LeadTimeDemand = DailyDemand * LeadTimeDays
    
    ' Ajouter le stock de sécurité
    CalculateROP = LeadTimeDemand + SafetyStock
    
    Exit Function
    
ErrorHandler:
    ' Journaliser l'erreur et retourner 0
    Debug.Print "Erreur dans CalculateROP: " & Err.Description
    CalculateROP = 0
End Function

' =============================================
' Function: CalculateEOQ
' Purpose: Calculer la Quantité Économique de Commande (Formule Wilson)
' Formule: EOQ = Racine((2 * DemandeAnnuelle * CoutCommande) / CoutStockageUnitaire)
' =============================================
Public Function CalculateEOQ(AnnualDemand As Double, OrderCost As Double, HoldingCostPerUnit As Double) As Double
    On Error GoTo ErrorHandler
    
    If AnnualDemand <= 0 Or OrderCost <= 0 Or HoldingCostPerUnit <= 0 Then
        CalculateEOQ = 0
        Exit Function
    End If
    
    CalculateEOQ = Sqr((2 * AnnualDemand * OrderCost) / HoldingCostPerUnit)
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateEOQ: " & Err.Description
    CalculateEOQ = 0
End Function

' =============================================
' Function: CalculateCMUP
' Purpose: Calculer le Cût Moyen Unitaire Pondéré (Weighted Average Unit Cost)
' Formule: CMUP = Valeur Cumulée IN ÷ MAX(1, Σ Quantités IN)
' Reference: OPT-02 (Optimisation comptable)
' =============================================
Public Function CalculateCMUP(TotalINValue As Double, TotalINQuantity As Double) As Double
    On Error GoTo ErrorHandler
    
    ' Éviter la division par zéro
    If TotalINQuantity <= 0 Then
        CalculateCMUP = 0
        Exit Function
    End If
    
    ' CMUP = Valeur totale des entrées ÷ Quantité totale des entrées
    CalculateCMUP = TotalINValue / TotalINQuantity
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateCMUP: " & Err.Description
    CalculateCMUP = 0
End Function

' =============================================
' Function: CalculateStockDuration
' Purpose: Calculer la Durée de Stock (Stock Duration in days)
' Formule: Durée = Stock Actuel / Consommation Journalière
' CNEPD: Indicateur de performance recommandé
' =============================================
Public Function CalculateStockDuration(CurrentStock As Double, DailyConsumption As Double) As Double
    On Error GoTo ErrorHandler
    
    If DailyConsumption <= 0 Then
        CalculateStockDuration = 0
        Exit Function
    End If
    
    CalculateStockDuration = CurrentStock / DailyConsumption
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateStockDuration: " & Err.Description
    CalculateStockDuration = 0
End Function

' =============================================
' Function: CalculateTurnoverRate
' Purpose: Calculer le Taux de Rotation des Stocks
' Formule: Taux = Demande Annuelle / Stock Moyen
' CNEPD: KPI essentiel pour le secteur public
' =============================================
Public Function CalculateTurnoverRate(AnnualDemand As Double, AverageStock As Double) As Double
    On Error GoTo ErrorHandler
    
    If AverageStock <= 0 Then
        CalculateTurnoverRate = 0
        Exit Function
    End If
    
    CalculateTurnoverRate = AnnualDemand / AverageStock
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateTurnoverRate: " & Err.Description
    CalculateTurnoverRate = 0
End Function

' =============================================
' Function: CalculateABCCategory
' Purpose: Déterminer la catégorie ABC (Pareto 80-15-5)
' Reference: CNEPD BTS Standard
' =============================================
Public Function CalculateABCCategory(PercentageOfTotal As Double) As String
    On Error GoTo ErrorHandler
    
    If PercentageOfTotal <= 0 Or PercentageOfTotal > 100 Then
        CalculateABCCategory = "C"
        Exit Function
    End If
    
    ' Règle Pareto: A=80%, B=15%, C=5%
    If PercentageOfTotal <= 80 Then
        CalculateABCCategory = "A"
    ElseIf PercentageOfTotal <= 95 Then
        CalculateABCCategory = "B"
    Else
        CalculateABCCategory = "C"
    End If
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateABCCategory: " & Err.Description
    CalculateABCCategory = "C"
End Function

' =============================================
' Function: CalculateSafetyStock
' Purpose: Calculer le Stock de Sécurité (Méthode différence de demande)
' Formule: SS = (Dmax - Davg) × LeadTime
' CNEPD: Recommandé pour le secteur public
' =============================================
Public Function CalculateSafetyStock(MaxDailyDemand As Double, AvgDailyDemand As Double, LeadTime As Double) As Double
    On Error GoTo ErrorHandler
    
    If LeadTime < 0 Then
        CalculateSafetyStock = 0
        Exit Function
    End If
    
    CalculateSafetyStock = (MaxDailyDemand - AvgDailyDemand) * LeadTime
    
    Exit Function
    
ErrorHandler:
    Debug.Print "Erreur dans CalculateSafetyStock: " & Err.Description
    CalculateSafetyStock = 0
End Function

' =============================================
' Sub: UpdateStockLedger
' Purpose: Mettre à jour le CALCULS_EOQ sheet avec le nouveau calcul ROP
' W005 FIX: Redirected from "StockLedger" (non-existent) to "CALCULS_EOQ"
Public Sub UpdateStockLedger()
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Dim LastRow As Long
    Dim ROP As Double
    
    Set ws = ThisWorkbook.Sheets("CALCULS_EOQ")
    
    LastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    
    ROP = CalculateROP(1546, 2, 200)
    
    ws.Unprotect Password:=mod_Config.MASTER_PWD
    
    On Error Resume Next
    ws.Range("ROP_Value").Value = ROP
    If Err.Number <> 0 Then
        ws.Cells(LastRow + 1, 1).Value = "ROP"
        ws.Cells(LastRow + 1, 2).Value = ROP
    End If
    On Error GoTo ErrorHandler
    
    ws.Protect Password:=mod_Config.MASTER_PWD, UserInterfaceOnly:=True
    
    If Abs(ROP - 205.6) < 0.1 Then
        MsgBox "Calcul ROP vérifié: " & Format(ROP, "0.0"), vbInformation
    Else
        MsgBox "Écart de calcul ROP. Vérifier les entrées.", vbExclamation
    End If
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de la mise à jour: " & Err.Description, vbCritical
End Sub
