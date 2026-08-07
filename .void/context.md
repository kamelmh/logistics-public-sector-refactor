# Academix DSS VBA Project Context

## Project Overview
- **Name:** Academix DSS v14.0
- **Type:** Excel VBA Decision Support System
- **Purpose:** Inventory management for Algerian public sector
- **Language:** VBA (Visual Basic for Applications)
- **Platform:** Microsoft Excel

## Coding Standards

### Language
- All user-facing messages MUST be in French
- Code comments in English
- Variable names in English

### Error Handling Pattern
```vba
Sub ProcedureName()
    On Error GoTo ErrorHandler
    ' Main code
    Exit Sub
ErrorHandler:
    MsgBox "Erreur: " & Err.Description, vbCritical, "Academix DSS"
End Sub
```

### Naming Conventions
- Modules: `mod_Name.bas`
- Forms: `frmName.frm`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

## Key Files

### Core Modules
| Module | Purpose |
|--------|---------|
| `mod_Database.bas` | Data operations |
| `mod_StockEngine.bas` | Stock calculations (CMUP, EOQ, ROP) |
| `mod_Invoice.bas` | Invoice generation |
| `mod_AuditTrail.bas` | Audit logging |
| `mod_ApprovalWorkflow.bas` | Approval workflow |
| `mod_ExportEngine.bas` | PDF/Excel export |
| `mod_StockEntry_Logic.bas` | Stock entry logic |

## Known Issues

### English Error Messages (Fix These)
| File | Line | English | French Fix |
|------|------|---------|------------|
| `mod_AuditTrail.bas` | 51 | "Audit Logging Failed" | "Échec de l'enregistrement de l'audit" |
| `mod_AuditTrail.bas` | 57 | "WARNING: This will permanently delete..." | "ATTENTION: Ceci supprimera définitivement..." |
| `mod_ApprovalWorkflow.bas` | 41 | "Transaction ID not found" | "ID transaction introuvable" |
| `mod_ApprovalWorkflow.bas` | 60 | "Transaction must be validated..." | "La transaction doit être validée..." |
| `mod_ApprovalWorkflow.bas` | 73 | "Transaction ID not found" | "ID transaction introuvable" |
| `mod_ApprovalWorkflow.bas` | 112 | "MOUVEMENTS sheet not found" | "Feuille MOUVEMENTS introuvable" |
| `mod_ExportEngine.bas` | 387 | "Export Error" | "Erreur d'export" |
| `mod_ExportEngine.bas` | 422 | "Export Error" | "Erreur d'export" |
| `mod_ObsidianExporter.bas` | 97 | "Obsidian export completed" | "Export Obsidian terminé" |
| `mod_ObsidianExporter.bas` | 107 | "Worksheet not found" | "Feuille introuvable" |
| `mod_Utilities.bas` | 233 | "Failed to setup dropdown" | "Échec de la configuration de la liste déroulante" |
| `mod_Utilities.bas` | 279 | "Formatting Error" | "Erreur de formatage" |
| `mod_Utilities.bas` | 348 | "Failed to generate PDF" | "Échec de la génération du PDF" |

## When Working on This Project

1. **Always use French** for user-facing messages
2. **Always add error handlers** to new functions
3. **Always log to audit trail** for important operations
4. **Always close connections** in error handlers
5. **Always validate inputs** before processing

## Testing

When making changes:
1. Check for English error messages
2. Check for missing error handlers
3. Check for audit trail logging
4. Check for connection cleanup
5. Check for input validation
