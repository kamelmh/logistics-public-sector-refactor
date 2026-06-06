# Academix v13.4+ Roadmap

## Completed in v13.4 (Session 20, 2026-06-06)
- ✅ Version bump v13.3 → v13.4
- ✅ Golden master replaced with clean build (699.8 KB, lean VBA)
- ✅ Build: COMPILE OK | Verify: **113/113 PASS**
- ✅ 4 critical VBA defects fixed in mod_StockEntry_Logic (missing End Sub/Function + duplicate)
- ✅ Defense materials updated: 4 files, all metrics corrected
- ✅ D=789 methodology documentation verified in thesis
- ✅ Telegram bot command handler: `/status`, `/build`, `/verify`, `/help`
- ✅ QuantMind environment verified
- ✅ Ollama qwen3:1.7b downloaded (3 models total)
- ✅ Module refactoring analysis complete (4 modules)

---

## Phase 1 — Refactoring (Module Splitting)

### Priority: mod_ExportEngine PopulateTemplateBon split
- **File**: `mod_ExportEngine.bas` (964 lines)
- **Target**: 675-line `PopulateTemplateBon` → 8 sub-functions in `mod_TemplateBuilder.bas`
- **Risk**: HIGH — called from frmStockEntry + 3 modules
- **Benefit**: Maintainable PDF generation with A4/Compact/Silent modes as clean sub-functions
- **Timing**: Before defense if time permits, or post-defense

### Phase 0 (Done): mod_StockEntry_Logic defects
- Fixed 4 missing End Sub/End Function
- Removed 1 duplicate procedure
- Next: Split into 6 sub-modules (Init, DocType, ArticleLogic, GridOps, Transaction)

### Future candidates:
- mod_TaskOrchestrator (41 procs, MEDIUM risk) → 8 sub-modules
- mod_LibreBridge (LOW risk) → 7 sub-modules

---

## Phase 2 — Feature Development

### Short-term (Post-Defense)
| Feature | Effort | Impact | Notes |
|---------|--------|--------|-------|
| Real barcode scanning (USB scanner) | 3-4 days | HIGH | Trigger stock entry from scanner input |
| ARIMA-based demand forecasting | 5-7 days | HIGH | Replace simple moving average in mod_Forecasting |
| PDF report with charts | 2-3 days | MEDIUM | Export dashboard KPIs as PDF summary |
| Multi-year data archive | 1-2 days | MEDIUM | Year-end rollover for MOUVEMENTS |

### Medium-term
| Feature | Effort | Impact | Notes |
|---------|--------|--------|-------|
| Mobile-responsive ACCUEIL (HTML export) | 5-7 days | HIGH | Access via intranet browser |
| Supplier auto-sourcing | 3-4 days | MEDIUM | Auto-create order from ROP alerts |
| Telegram alerts (stockout/ROP) | 2 days | MEDIUM | Push notifications via existing bot |
| Budget vs Actual dashboard | 3-4 days | MEDIUM | Track spend vs annual budget |

### Long-term (v14+)
- Web-based dashboard (Flask + VBA backend)
- Multi-directorate deployment (template per wilaya)
- ML-driven consumption prediction
- OCR integration for paper Bons

---

## Phase 3 — Defense & Thesis

- [x] Defense materials updated to v13.4
- [x] D=789 methodology documented
- [ ] Defense rehearsal (user)
- [ ] Final thesis PDF build
- [ ] Submission package ready
- [ ] Backup: USB stick with all deliverables

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| v13.2 | 2026-05-31 | 4 DSS pillars (Print, UX, Projection, Fuzzy Search) |
| v13.3 | 2026-06-02 | 15 articles, barcode, bilingual UI, print, stockout |
| v13.3.1 | 2026-06-03 | VBA state.prefix cleanup, Hermes fallback chain |
| **v13.4** | **2026-06-06** | **VBA defects fixed, defense prep, Telegram bot, lean build** |
