# VBA LibreOffice Bridge Skill

## Overview
Cross-platform document conversion bridge that detects and uses LibreOffice (headless) for DOCX/XLSX/ODT → PDF conversion, with Excel COM fallback. Enables PDF generation without requiring Microsoft Word or Excel.

## Module
`mod_LibreBridge.bas` in `Software_Surgical_Edit/VBA_Modules/`

## Capabilities
- **LibreOffice Detection** — Auto-detect soffice.exe in common install locations and PATH
- **Auto Fallback** — LibreOffice first, Excel COM second, graceful failure third
- **PDF Conversion** — Any supported format → PDF
- **Batch Conversion** — Convert all matching files in a folder
- **Format Support** — DOCX, XLSX, XLSM, ODT, ODS, PPTX → PDF (and other formats)
- **COM Interop** — Run macros across workbooks, export via Excel COM
- **Python Bridge** — Execute Python scripts from VBA

## Entry Points (MAIN_MACROS.bas)
| Macro | Description |
|-------|-------------|
| `LibeExportToPDF` | Export current sheet to PDF |
| `LibeExportAllToPDF` | Export thesis + ERP to PDF |
| `LibeConvertBatch` | Batch convert all DOCX in a folder |
| `LibeShowBridgeInfo` | Show available bridge engines |

## Detection Flow
```
IsLibreOfficeInstalled()? YES → Use soffice --headless --convert-to
                         NO  → IsCOMEnabled()? YES → ExportViaCOM()
                                               NO  → Return error
```

## Key Functions

### Convert Single File
```vb
Dim success As Boolean
success = mod_LibreBridge.ConvertToPDF("C:\path\to\file.docx")
' Output: C:\path\to\file.pdf
```

### Convert with Custom Format
```vb
success = mod_LibreBridge.ConvertToPDF("input.docx", "output.pdf", lfPDF, 120)
' Formats: lfPDF(1), lfDOCX(2), lfDOC(3), lfXLSX(4), lfXLS(5), lfODT(6), lfODS(7)
'          lfCSV(8), lfHTML(9), lfTXT(10), lfPPTX(11), lfPNG(12), lfJPG(13)
```

### Batch Conversion
```vb
Dim count As Long
count = mod_LibreBridge.ConvertBatchToPDF("C:\docs\", "*.docx", True)
' Returns number of successful conversions
```

### Run Macro in External Workbook
```vb
mod_LibreBridge.RunMacroInWorkbook("C:\OtherWorkbook.xlsm", "Module1.MyMacro")
```

### Engine Status
```vb
mod_LibreBridge.GetPreferredEngine()
' Returns "libreoffice", "com", or "none"
mod_LibreBridge.Bridge_Description()
' Full report on available bridges
```

## LibreOffice Install Paths Checked
```
C:\Program Files\LibreOffice\program\soffice.exe
C:\Program Files (x86)\LibreOffice\program\soffice.exe
C:\Program Files\LibreOffice 5-7\program\soffice.exe
C:\Program Files\LibreOffice 24-26\program\soffice.exe
PATH environment variable fallback
```

## Requirements
- **LibreOffice** (recommended): `choco install libreoffice`
- **Excel COM**: Only needed for fallback (no LibreOffice)
- **VBA Security**: Must allow COM object creation

## Verification
```vb
' Check bridge status
?mod_LibreBridge.Bridge_Description()

' Test conversion (creates PDF alongside source)
?mod_LibreBridge.ConvertToPDF(ThisWorkbook.FullName)
```
