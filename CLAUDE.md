# Academix v13.4 — Project Context for Claude Desktop

## Project Overview
- **System**: VBA/Excel DSS for inventory management
- **Organization**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Ground Truth**: D=789, Q*=37, ROP=206, SS=200, LT=2 days, S=801.45 DZD, PU=4500 DZD, I=20%
- **Master Password**: erp_secure_pwd_2026

## Current Status (Session 45 — 2026-06-14)
- **ERP Workbook**: ERP_v13.4.xlsm (718.2 KB, 114/114 PASS) ✅
- **Thesis DOCX**: Memoire_DSS_Logistique_ElBayadh.docx (143.3 KB, 32/32 PASS) ✅
- **Thesis PDF**: Memoire_DSS_Logistique_ElBayadh.pdf (1,380 KB) ✅
- **English Paper**: English_Research_Paper_IEEE.pdf (69 KB, 9 pages) ✅
- **Manual Verification**: 99% complete — user verified and fixed in Word ✅
- **Git**: Synced with remote (fd9c342) ✅

## Thesis File Paths
- **Source Markdown**: `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md`
- **Output DOCX**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx`
- **Output PDF**: `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.pdf`
- **Build Script**: `Thesis_Surgical_Edit/build-thesis.ps1`
- **Verification**: `Thesis_Surgical_Edit/style/verify_docx_checks.py`

## Key Scripts
- **Pipeline**: `Thesis_Surgical_Edit/run-thesis-pipeline.ps1` (orchestrates build → fixes → verification)
- **Section Fix**: `Thesis_Surgical_Edit/style/fix_docx_sections.py` (single-section layout)
- **Comprehensive Fix**: `Thesis_Surgical_Edit/style/fix_thesis_all.py` (tables, RTL, footers, etc.)

## Page Numbering Configuration
- **Single section** with `titlePg` (different first page enabled)
- **Cover page**: No page number displayed (uses blank footer1.xml)
- **Page numbering**: Continuous decimal from cover (page 1 hidden, TOC=page 2, body continues)
- **Footer**: `footer2.xml` contains PAGE field (no cached value)

## What Was Accomplished (Session 40)
1. Fixed "page1" bug: root cause was multi-section layout with each section restarting at page 1
2. Implemented single-section layout with continuous numbering
3. Fixed footer1.xml (blank for cover) and footer2.xml (clean PAGE field)
4. All 32/32 verification checks pass
5. Tables match v7c backup styles
6. Full RTL: Traditional Arabic 14pt, 1.5 spacing
7. Content preserved: 709 paragraphs, 26 tables, 46 footnotes

## Next Steps
1. Open DOCX in Word
2. Press Ctrl+A then F9 to update all fields
3. Verify manually:
   - Cover: No page number
   - TOC: Page 2
   - Body: Starts at page 3
4. Check RTL alignment, table layout, footnote formatting
5. Final review and submission

## Deep Verification Session (Claude Desktop GUI)
1. Launch Claude Desktop GUI (desktop application, not CLI)
2. Read `ClaudeDesktop_DEEP_VERIFICATION.md` for full strategy
3. Follow the 7-step verification process
4. Provide final assessment and sign-off

## Claude Desktop MCP Access
The filesystem MCP server provides access to:
- Project root: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
- Google Drive: `C:\Users\Administrator\My Drive`

## How to Help
- Review thesis content for accuracy
- Check formatting and structure
- Verify academic standards
- Assist with final polish before submission

## Additional Context Files
- **THESIS_CONTEXT.md**: Detailed thesis information and verification results
- **CrossFlow HANDOFF.md**: Current project status and handoff information
- **MASTER_BOOTSTRAP.xml**: Complete system context and configuration