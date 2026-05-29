# VBA Barcode Simulation Skill (v1.1)

## Overview
Generates and simulates barcodes in Excel using pure VBA (no external dependencies). Supports Code128, EAN-13, Code39, and Interleaved 2-of-5 symbologies with visual rendering in worksheet cells.

## Capabilities
- **Code128 Encoding** — Full charset (A/B/C subsets, checksum, start/stop patterns)
- **EAN-13 Encoding** — 13-digit standard, checksum calculation, parity table
- **Code39 Encoding** — Variable length, 43-character set, start/stop asterisks
- **Interleaved 2-of-5** — Numeric only, even digit pairs
- **QR Visual** — 9x9 deterministic pattern with finder corners (offline fallback)
- **Visual Rendering** — Binary pattern as Excel column fills (black/white)
- **Scanner Simulation** — Click a rendered barcode to "scan" it
- **Label Printing** — Generate barcode labels for all inventory articles
- **Batch Generation** — Generate from a range of cells in one call
- **Symbology Registry** — Register barcodes with type metadata

## Module
`mod_BarcodeSim.bas` in `Software_Surgical_Edit/VBA_Modules/`

## Entry Points (MAIN_MACROS.bas)
| Macro | Description |
|-------|-------------|
| `GenerateBarcodeInteractive` | Interactive barcode creation with type selection |
| `PrintBarcodeLabels` | Generate and print labels for all articles |
| `SimulateBarcodeScanner` | Click a barcode cell to decode |
| `GenerateBarcodesForAllArticles` | Batch generate for all ARTICLES sheet rows |
| `RegisterBarcodeSymbology` | Register barcode with symbology type |

## Key Functions

### Code128
```vb
mod_BarcodeSim.Code128_Encode("ART-001")           ' Returns binary pattern
mod_BarcodeSim.GenerateBarcode("STAGING_BUFFER", "A1", "ART-001", bcCode128, True, 50)
```

### EAN-13
```vb
mod_BarcodeSim.EAN13_Encode("123456789012")        ' Returns pattern|checksum
mod_BarcodeSim.GenerateBarcode("STAGING_BUFFER", "A1", "1234567890123", bcEAN13)
```

### Code39
```vb
mod_BarcodeSim.Code39_Encode("ACADEMIX")            ' Returns binary pattern
mod_BarcodeSim.GenerateBarcode("STAGING_BUFFER", "A1", "ACADEMIX", bcCode39)
```

### Batch Generation
```vb
mod_BarcodeSim.GenerateBarcodeRange("BARCODE_LABELS", "A3", range, bcCode128, 30)
```

## Symbology Constants
| Constant | Value | Symbology |
|----------|-------|-----------|
| `bcCode128` | 0 | Code128 (recommended) |
| `bcEAN13` | 1 | EAN-13 (retail) |
| `bcCode39` | 2 | Code39 (variable text) |
| `bcInterleaved2of5` | 3 | Interleaved 2 of 5 (numeric) |
| `bcQR_Visual` | 4 | QR Visual Pattern |

## Dependencies
- `mod_Config.bas` — Sheet names, passwords
- `mod_Barcode.bas` — Existing barcode lookup (extended)
- `STAGING_BUFFER` and `BARCODE_LABELS` sheets (auto-created)

## Pre-Build Validation
This module is checked by `vba-check.py` (v1.2) which catches:
- ❌ `Return` statement (VB.NET syntax — use `Function = value` instead)
- ❌ Parameter named `format` (conflicts with built-in `Format()`)
- ❌ `Name:=` in `Application.OnTime` (must be `Procedure:=`)
- ❌ `Const Array()` (runtime function in Const declaration)
- ❌ UTF-8 encoding issues, missing headers, broken continuations

Run `& "vbe-auto\vba-check.py"` before any build to catch issues.

## Verification
Run `build.ps1` then `verify.ps1` — new checks validate:
1. Barcode functions compile without errors
2. `LookupBarcode` fallback chain complete
3. All 5 symbology types encode without crashing

## History
| Version | Date | Changes |
|---------|------|---------|
| v1.1 | 2026-05-29 | Added pre-build validation section; documented fixes |
| v1.0 | 2026-02-24 | Initial release — all 5 symbologies + label printing |
