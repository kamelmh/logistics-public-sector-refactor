# Changelog

All notable changes to the ERP Académie v13.2 project.

## 2026-05-10

### Features
- Mass update launchers, profiles, and context files

## 2026-05-09

### Features
- System architecture: MASTER_BOOTSTRAP.xml, session persistence, multi-session
- Major cleanup: gitignore, XML compression, infrastructure tracking
- AI: switch to Groq Llama 3.3 70B free tier, drop paid Claude
- AI: add Anthropic Claude as primary provider, refactor build pipeline, clean milestone_13_2

### Documentation
- Add MASTER_BOOTSTRAP.xml reference to admin-paths config
- Consolidate master context for Llama 3.3 70B compatibility

## 2026-05-08

### Features
- Thesis: style pipeline, v13.1-matched formatting, USB deploy, sync tools
- Project: major cleanup, 16 new VBA modules, delivery layout, build pipeline

### Bug Fixes
- Thesis: CNEPD compliance audit — SIGLE→SIGB, add Law 23-12, FormState architecture, public sector compliance section

## 2026-05-06

### Features
- Thesis: expand Ch4 with full EOQ/ROP math, ABC classification for 12 articles, KPI tables, before/after comparison, approval workflow
- Thesis: expand Chapter4 with full EOQ/ROP calculations, ABC results, 27-module technical metrics, before/after comparison
- Launcher: add Qwen2.5-Coder 1.5B local bat file with Ollama service check
- Launcher: add Desktop bat file with Groq context injection, 3 backup copies
- AI workspace: add context injection system, trigger phrases, skills config, agentic protocols
- Regenerate XML context files for Groq backend (W001-W010 all resolved, 27 modules)
- Add remaining VBA modules, context files, and thesis docs

### Bug Fixes
- VBA: fix all audit findings — mod_Utilities concat line, mod_StockEngine dead code, ThisWorkbook Option Explicit, MAIN_MACROS/mod_Navigation form checks, UTF-8 BOM all 31 files, garbled comments fixed
- Build: fix worksheet creation COM error; successful 25 sheets + 28 modules, all compile
- Build: rewrite Build_Excel_DSS.ps1 — 25 sheets, 27 modules, v13.2 ground truth, approval columns
- W010: Remove Option Explicit from ThisWorkbook.cls to prevent compile errors
- W006-W008: Add missing Public keywords to mod_Navigation, mod_ReceiptTag, mod_Utilities
- Surgical edit: fix 7 bugs, add test harness, sync AGENTS.md

### Refactoring
- Thesis: realign Ch4 to original outline — 6→4 mabahith, move بيئة_التجريب to Ch3, move تصنيف_ABC to Ch1

### Documentation
- Defense: add DEFENSE_QA_GUIDE.md with 8 jury questions, fix 'Database' CNEPD violation, verify workbook, regenerate PDF
- Thesis: enhance DSS-Algerian references appendix with CNEPD jury rubric (92.9%), SIGLE roadmap
- Thesis: proofreading fixes — Arabic abstract, French résumé, English abstract, keywords, glossary, bibliography
- Thesis: fix table numbering order in Ch2, replace missing image, remove manual TOC
- Thesis: mass audit — add # headings, replace Arabic letters with numbers in chapters, fix annex numbering
- Thesis: deduplicate glossaries, add DSS-Algerian references appendix
- Thesis: add subtitle, append software_originality.md as annexes
- Rewrite CLAUDE.md — v13.2 ground truth, 27 modules, AI context trigger
- Add comprehensive README.md with project overview, ground truth, architecture

## 2026-05-02

### Features
- Add enhanced VBA Stock Entry Logic with validation and dashboard alerts
- Add enhanced VBA Export Engine with PDF generation and Stock Dashboard
- Add VBA Stock Calculations module and Enhanced Stock Entry Form for thesis

### Documentation
- Add CNEPD-compliant thesis defense summary
- Replace all technical terms in Review Report with CNEPD-compliant terminology
- Replace 'Academix' with CNEPD-compliant name 'نظام دعم القرار لتسيير المخزون'

### Bug Fixes
- Remove forbidden term 'فرع' (Branch) — replaced with 'تكميلية' per CNEPD requirements

### Initial Commit
- Logistics.Public.Sector.Refactor (current refactored version from Dropbox)
