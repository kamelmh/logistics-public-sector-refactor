# Academix v13.2 — ERP Académie

**نظام إلكتروني متكامل للتسيير التمويني** — Integrated Electronic Inventory Management System

Direction de l'Éducation, Wilaya de El Bayadh, Algeria

[![GitHub](https://img.shields.io/badge/GitHub-kamelmh-blue)](https://github.com/kamelmh/logistics-public-sector-refactor)
[![Version](https://img.shields.io/badge/Version-v13.2-green)](VERSION)
[![License](https://img.shields.io/badge/License-CNEPD%20BTS-orange)](LICENSE)

---

## Overview

Academix v13.2 is a **pure VBA Excel Decision Support System (DSS)** for public sector inventory management. Built for the Algerian Ministry of Education, it implements Wilson EOQ, CMUP, ABC classification, and two-tier approval workflows — all offline, zero external dependencies.

| Metric | Value |
|--------|-------|
| **Architecture** | Offline-First, Pure VBA, Zero External Dependencies |
| **Sheets** | 25 |
| **Modules** | 27 (clean) |
| **Articles** | 12 (ART-001 → ART-012) |
| **Suppliers** | 3 (F-001: ENAP Alger, F-002: Bureautique Oran, F-003: Bureau Plus) |
| **Compliance** | CNEPD BTS Public Sector Standards |
| **Locale** | fr-FR (UI) / ar-DZ (thesis) |

## Ground Truth Parameters

These values are **locked** — derived from 38-day observation history and used throughout the thesis:

| Parameter | Value | Description |
|-----------|-------|-------------|
| **D** (Annual Demand) | 1,546 units | Derived from MOUVEMENTS history |
| **Q*** (EOQ) | 176 units | Wilson formula: √(2DS/Ih) |
| **ROP** (Reorder Point) | 212.4 units | (D/250) × LT + SS |
| **SS** (Safety Stock) | 200 units | (MaxDaily - AvgDaily) × LT |
| **LT** (Lead Time) | 2 days | Default delivery time |
| **S** (Order Cost) | 500 DZD | Fixed cost per order |
| **I** (Holding Rate) | 20% | Annual holding cost rate |

## Quick Start

### Launch (Recommended)
Double-click `Academix_v13.2_Launch.bat` on Desktop — it verifies your setup and launches OpenCode with Groq.

### Manual Launch
```powershell
cd C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor
opencode
```

### AI Context Activation
Type this at session start:
```
ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE
```
This triggers instant project awareness: all paths, all modules, all ground truth, all skills loaded.

## Architecture

### Workbook Structure (25 Sheets)
| Sheet | Purpose |
|-------|---------|
| `ACCUEIL` | Dashboard / Home — KPIs, workflow shortcuts |
| `ARTICLES` | Master catalog (12 articles) |
| `FOURNISSEURS` | Supplier catalog (3 suppliers) |
| `MOUVEMENTS` | Core transaction ledger — all stock IN/OUT |
| `TABLEAU_DE_BORD` | Performance dashboard — calculated KPIs |
| `CALCULS_EOQ` | Wilson EOQ calculations |
| `AUDIT_LOG` | Audit trail — append-only |

### VBA Modules (37 — All Clean)
| Tier | Modules |
|------|---------|
| **Critical** | `mod_Config`, `mod_StockEngine`, `mod_StockEntry_Logic`, `mod_TransactionSafety` |
| **High** | `mod_SyncBridge`, `mod_Dashboard`, `mod_ExportEngine`, `mod_Utilities`, `mod_Reports`, `mod_Database`, `mod_AuditTrail`, `mod_ReceiptTag`, `mod_QRCode`, `mod_SharedEnvironment`, `mod_InventoryReconciliation`, `mod_SupplierScorecard`, `mod_SupplierRegistry`, `mod_StockAging`, `mod_StockOutPredictor`, `mod_Forecasting`, `mod_DataValidator`, `mod_DemoData`, `mod_Barcode`, `mod_CSVImportExport`, `mod_EntryPoints`, `mod_ThemingEngine` |
| **Medium** | `mod_SheetSetup`, `mod_Procurement`, `mod_Analysis`, `mod_Localization`, `mod_ApprovalWorkflow`, `mod_Navigation`, `mod_Budget`, `mod_BudgetSetup`, `mod_UIEnhancements` |
| **Low** | `mod_UI_Setup` |

### Transaction Data Flow
```
frmStockEntry → mod_StockEntry_Logic.btnEnregistrer_Click
  → mod_Database.SecureWriteTransaction → MOUVEMENTS
  → mod_SyncBridge.SyncTransactionInternal → mod_StockEngine → ARTICLES
  → mod_AuditTrail.LogTransaction → AUDIT_LOG
  → mod_ExportEngine.ExportTransactionToPDF → TEMPLATE_BON → PDF
```

## AI Integration & OS Spectrum

The project is powered by a **Layered AI Operating System (AI OS Spectrum)**, moving from foundational logic to task-specific execution.

| Layer | Name | Purpose | Location |
| :--- | :--- | :--- | :--- |
| **L0** | `Core/` | **Kernel** (Identities, Cognitive Frameworks) | `.opencode\skills_spectrum\Core\` |
| **L1** | `Drivers/` | **Skills** (Domain-specific functional modules) | `.opencode\skills_spectrum\Drivers\` |
| **L2** | `Shell/` | **Interaction** (Templates, Toolkits) | `.opencode\skills_spectrum\Shell\` |
| **L3** | `Apps/` | **Personas** (Composite roles for specific goals) | `.opencode\skills_spectrum\Apps\` |
| **L4** | `Registry/` | **BIOS/Docs** (System documentation & inventory) | `.opencode\skills_spectrum\Registry\` |

### Stable Model Stack
| Role | Model | Backend | Context |
| :--- | :--- | :--- | :--- |
| **Primary** | Gemma 4 31B | Google AI Studio | 32K |
| **Reasoning** | Llama 3.3 70B | Groq | 32K |
| **Large Context**| Gemini 2.5 Flash | Google | 1M |
| **Agentic** | Ring 2.6 1T | OpenRouter | 262K |

### 🛡️ Certification Matrix
The system is verified via a **Certification Matrix** that mathematically links every Thesis claim to a VBA implementation and a specific `verify.ps1` test case.
- **Location**: `Software_Surgical_Edit\CERTIFICATION_MATRIX.md`
- **Status**: 174/174 PASS (Golden State)

## Project Structure

```
Dropbox/Logistics.Public.Sector.Refactor/
├── .opencode/
│   ├── bootstrap/                ← Master system context & boot protocol
│   ├── skills_spectrum/          ← AI OS Spectrum (L0-L4 Intelligence Layer)
│   └── erp-context-compact.md    ← Token-optimized snapshot
├── Software_Surgical_Edit/
│   ├── erp-project-context.xml   ← Module intelligence map
│   ├── erp-admin-paths.xml       ← All file paths
│   ├── CERTIFICATION_MATRIX.md   ← Thesis-to-Code proof matrix
│   ├── VBA_Modules/              ← 37 .bas source files
│   └── build.ps1                 ← Workbook build script
├── Thesis_Surgical_Edit/         ← Thesis chapters (Arabic)
├── vbe-auto/                      ← Verification & Build toolkit
├── docs/                         ← Requirements & User guides
├── CLAUDE.md                     ← Source of truth for Claude
└── README.md                     ← This file
```
Dropbox/Logistics.Public.Sector.Refactor/
├── .opencode/
│   └── context.md                    ← Master context injection file
├── AI_Workspace/
│   ├── Context_Injections/           ← Context injection files
│   ├── Skills_Config/                ← Skills configuration
│   ├── Agentic_Protocols/            ← Cross-AI collaboration rules
│   └── Academix_v13.2_Launch.bat     ← Launch script
├── Software_Surgical_Edit/
│   ├── erp-project-context.xml       ← Module intelligence map
│   ├── erp-admin-paths.xml           ← All file paths
│   ├── erp-agent-handoff.xml         ← Session state & routing
│   ├── VBA_Modules/                  ← 27 .bas source files
│   └── Build_Excel_DSS.ps1           ← Workbook build script
├── Thesis_Surgical_Edit/             ← Thesis chapters (Arabic)
├── CLAUDE.md                         ← Source of truth for Claude
└── README.md                         ← This file
```

## Development

### Coding Conventions
- VBA modules: PascalCase, comments in French
- Excel tab names: French or bilingual
- Column headers: French — do not translate
- Special chars: `Chr(233)` for é, `Chr(201)` for É
- **No XLOOKUP** — must work in Excel 2010 / Windows 7
- Sheet protection password: `erp_secure_pwd_2026`

### Cross-Agent Protocol
1. Read `erp-project-context.xml` FIRST on session start
2. Check dependencies in call graph before code changes
3. Update `erp-project-context.xml` after code changes
4. Always work on copy in `$env:TEMP`, then deploy to Dropbox
5. Never modify `mod_Config` constants or `CANON_*` values
6. Never remove sheet protection without re-protecting
7. Never commit changes without explicit user approval

### Warnings Status
| ID | Status | Description |
|----|--------|-------------|
| W001 | ✅ Resolved | Module1 deleted |
| W002 | ✅ Resolved | Module2 deleted |
| W003 | ✅ Resolved | MASTER_PWD unified |
| W004 | ✅ Resolved | Budget guard added |
| W005 | ✅ Resolved | StockLedger redirected |
| W006 | ✅ Resolved | Public keywords (modNavigation) |
| W007 | ✅ Resolved | Public keywords (mod_ReceiptTag) |
| W008 | ✅ Resolved | Public keywords (mod_Utilities) |
| W009 | ✅ Resolved | SyncBridge stubs implemented |
| W010 | ✅ Resolved | ThisWorkbook.cls fixed |

## Performance Baseline

Benchmark results from `.\scripts\benchmark.ps1` (3 iterations, 2026-05-18):

| Operation | Avg | Min | Max |
|-----------|-----|-----|-----|
| VBA module scan | 99ms | 74ms | 129ms |
| Script syntax parse | 282ms | 221ms | 385ms |
| Git status | 809ms | 754ms | 868ms |
| Git log (100 commits) | 286ms | 245ms | 361ms |
| Full file enumeration | 15,843ms | 13,202ms | 20,362ms |
| XML context parse | 124ms | 63ms | 223ms |
| Symlink resolution (75 links) | 319ms | 280ms | 349ms |

Run benchmarks: `.\scripts\benchmark.ps1`

## Additional Documentation
- `AGENTS.md` — Agent configuration, model routing, session recovery
- `CLAUDE.md` — Project identity, ground truth, thesis constraints, AI backends
- `CNEPD_REQUIREMENTS.md` — CNEPD BTS compliance, privacy, case study details
- `USER_GUIDE.md` — End-user instructions for the ERP workbook
- The `.opencode/bootstrap/` directory contains the master system context

## Thesis Progress

| Chapter | Status |
|---------|--------|
| Ch1 — Theoretical framework | ✅ DONE |
| Ch2 — Institution presentation | ✅ DONE (raw Arabic draft) |
| Ch3 — Field diagnosis + ABC/Wilson/CMUP | ✅ DONE (raw Arabic draft) |
| Ch4 — Mini ERP solution + results | ⏳ PENDING |
| Front matter | ✅ DONE (intro, abstract AR+FR, glossary, dedication) |

**Supervisor:** دهيني ميمونة (مصلحة الميزانيات والاقتصاد)

## License

CNEPD BTS Public Sector Standards — Algerian Ministry of Education

