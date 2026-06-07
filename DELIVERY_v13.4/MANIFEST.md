# Academix v13.4 — Delivery Package

Generated: 20260606_1918
Project: Offline-First DSS for Inventory Optimization in Public Sector Logistics
Author: Mahi Kamel Abdelghani | Direction de l'Education, El Bayadh

## Contents

### 01_Thesis/ — Arabic Thesis (Memoire de Fin d'Etudes)
| File | Size |
|------|------|
| Memoire_DSS_Logistique_ElBayadh.docx | 143 KB |
| Memoire_DSS_Logistique_ElBayadh.md | 157 KB |
| Memoire_DSS_Logistique_ElBayadh.pdf | 1509 KB |

### 02_English_Paper/ — English Research Paper (CCA'2026 + IEEE)
| File | Size |
|------|------|
| cover-letter.md | 2 KB |
| English_Research_Paper_CCA2026.docx | 21 KB |
| English_Research_Paper_CCA2026.pdf | 158 KB |
| English_Research_Paper_IEEE.docx | 33 KB |
| English_Research_Paper_IEEE.pdf | 69 KB |
| English_Research_Paper.md | 22 KB |
| SUBMISSION_GUIDE.md | 2 KB |

### 03_ERP_Workbook/ — ERP v13.4 (Excel Workbook)
| File | Size |
|------|------|
| ERP_v13.4.xlsm | 700 KB |
| GOLDEN_ERP_v13.4.xlsm | 700 KB |

### 04_Defense_Materials/ — Defense Docs & Roadmap
| File | Size |
|------|------|
| defense-checklist.md | 18 KB |
| defense-presentation-script.md | 30 KB |
| demo-walkthrough-script.md | 14 KB |
| jury-qa-guide.md | 21 KB |
| ROADMAP_v13.4+.md | 3 KB |

### 05_Source_VBA/ — VBA Source Code
| File | Size |
|------|------|
| frmStockEntry.frm | 35 KB |
| MAIN_MACROS.bas | 10 KB |
| mod_Analysis.bas | 5 KB |
| mod_ApprovalWorkflow.bas | 5 KB |
| mod_AuditTrail.bas | 4 KB |
| mod_Barcode.bas | 11 KB |
| mod_BarcodeEncoder.bas | 19 KB |
| mod_BarcodeSim.bas | 29 KB |
| mod_Budget.bas | 15 KB |
| mod_BudgetSetup.bas | 5 KB |
| mod_Config.bas | 4 KB |
| mod_CSVImportExport.bas | 17 KB |
| mod_Dashboard.bas | 14 KB |
| mod_Database.bas | 2 KB |
| mod_DataValidator.bas | 18 KB |
| mod_DemoData.bas | 27 KB |
| mod_ExportEngine.bas | 40 KB |
| mod_Forecasting.bas | 22 KB |
| mod_InventoryReconciliation.bas | 7 KB |
| mod_LibreBridge.bas | 30 KB |
| mod_LOBridge_Detect.bas | 11 KB |
| mod_Localization.bas | 14 KB |
| mod_Navigation.bas | 2 KB |
| mod_ObsidianExporter.bas | 4 KB |
| mod_PCControl.bas | 29 KB |
| mod_Procurement.bas | 6 KB |
| mod_Profiler.bas | 4 KB |
| mod_QRCode.bas | 15 KB |
| mod_ReceiptTag.bas | 11 KB |
| mod_Reports.bas | 20 KB |
| mod_SharedEnvironment.bas | 14 KB |
| mod_StockAging.bas | 7 KB |
| mod_StockEngine.bas | 13 KB |
| mod_StockEntry_Logic.bas | 39 KB |
| mod_StockOutPredictor.bas | 6 KB |
| mod_SupplierRegistry.bas | 14 KB |
| mod_SupplierScorecard.bas | 9 KB |
| mod_SyncBridge.bas | 7 KB |
| mod_TaskOrchestrator.bas | 32 KB |
| mod_ThemingEngine.bas | 22 KB |
| mod_Timer.bas | 2 KB |
| mod_TransactionSafety.bas | 21 KB |
| mod_UI_Setup.bas | 16 KB |
| mod_Utilities.bas | 17 KB |

### 06_Build_Tools/ — Build & Verification Scripts
| File | Size |
|------|------|
| vbe-auto | 0 KB |
| build-cca2026.ps1 | 6 KB |
| build-english-paper.ps1 | 2 KB |
| build-thesis.ps1 | 6 KB |
| prepare-submission.ps1 | 7 KB |

---
**Total Package Size: 4.17 MB**
**ERP Version: v13.4**
**Build Status: COMPILE OK | 113/113 PASS**
**Modules: 44 VBA (.bas+.frm)**
**Sheets: 26**
**Articles: 15**

## Build & Verify
```powershell
& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"
& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"
```

## Delivery Notes
- Thesis PDF built via LibreOffice headless from DOCX (Arabic RTL support)
- English paper built via pandoc + xelatex (IEEE format)
- CCA'2026 paper is double-blind (anonymous)
- ERP workbook is the compiled .xlsm (VBA source in 05_Source_VBA/)
- Golden master (GOLDEN_ERP_v13.4.xlsm) is the clean source build
