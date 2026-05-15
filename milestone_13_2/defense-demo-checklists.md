# Defense Demo Checklists — Academix v13.2

## A: Pre-Defense System Prep (2 days before)

- [ ] Run `build` → COMPILE: OK
- [ ] Run `verify` → 174/174 PASS
- [ ] Run `test-macros.ps1` → 20/20 PASS
- [ ] Run `dss-audit.ps1` → 16 PASS, 0 CRITICAL
- [ ] Verify workbook opens on target machine (Excel 2010+)
- [ ] Disable AV/firewall that might block macros
- [ ] Set macro security: low/trusted location
- [ ] Check all 26 sheets present and named correctly
- [ ] Verify printer/scanner (for jury handouts if needed)
- [ ] Backup: `ERP_v13.2.xlsm` + project folder to USB

## B: Demo Flow (8-12 min)

### 1. ACCUEIL (Home) — 30s
- Open workbook, show multi-lingual dashboard
- Click navigation buttons

### 2. ARTICLES (Articles) — 1 min
- Show 12 articles with codes, designations, stock levels
- Point out ground truth: ART-001 (Toner), SS=200, Q*=176
- Show color-coded stock alerts (green/yellow/red)

### 3. Stock Entry (Saisie Stock) — 2 min
- Open stock entry form (`frmStockEntry`)
- Enter new movement: article, quantity, type (IN/OUT)
- Submit → show audit log entry created
- Show negative stock prevention alert

### 4. MOUVEMENTS (Movements) — 1 min
- Show movement history (62 transactions)
- Filter by article, date range
- Show CMUP calculation per movement

### 5. Leaderboard / Decision Support — 2 min
- Show **CALCULS_EOQ**: EOQ, ROP, safety stock per article
- Show **TABLEAU DE BORD**: KPIs, charts
- Show **ALERTE_DASHBOARD**: low-stock alerts
- Reference ground truth: ART-001 has Q*=176, ROP=212.4

### 6. RAPPORTS (Reports) — 1 min
- Generate PDF report (via `mod_ExportEngine`)
- Show formatted output with headers, logos

### 7. ARCHIVES / Backup — 30s
- Show automatic CSV backup on export
- Show transaction history integrity

## C: Demo Talking Points (8-12 min) — "Intelligence + Integrity"

| Segment | Time | Key Action | The "Hero" Message |
|---------|------|------------|-------------------|
| **1. ACCUEIL** | 30s | Open & Navigate | "This is Academix v13.2: A zero-cost, offline Mini ERP designed specifically for the constraints of the public sector." |
| **2. ARTICLES** | 1m | Show Color Alerts | "We maintain a single source of truth. Notice the color-coding: Green is safe, Yellow warns of ROP, and Red signals an immediate stockout risk." |
| **3. Stock Entry** | 2m | Record Movement | "Watch the 'Six-Guard' validation: The system prevents negative stock and immediately writes an immutable entry to our Digital Ledger." |
| **4. MOUVEMENTS** | 1m | Filter Movements | "Every transaction is timestamped. We don't just have data; we have a complete, searchable audit trail for every centime spent." |
| **5. Decision Support** | 2m | Show EOQ/ROP | "This is the brain. We don't just record history; we predict the future using EOQ to minimize costs and ROP to prevent stockouts." |
| **6. RAPPORTS** | 1m | Generate PDF | "With one click, the system converts raw data into professional, administrative-ready documents (DA/BC/BR/BS)." |
| **7. Backup** | 30s | Show Archive | "Data integrity is paramount. Every operation is backed by transaction safety (ACID) and automatic CSV archiving." |

## D: Key Metrics to Reference (Ground Truth)

| Metric | Value | Formula |
|--------|-------|---------|
| Annual Demand (D) | 1,546 units | Data from ARTICLES |
| EOQ (Q*) | 176 | SQRT(2DS/PI) |
| ROP | 212.4 | (D/250)*LT + SS |
| Safety Stock | 200 units | Demand variability |
| Service Level | 99.7% | Z=2.75 for SS/Demand |
| Order Cost (S) | 801.45 DZD | Fixed order cycle cost (field value) |
| Holding Rate (I) | 20% | Storage + obsolescence |
| Lead Time (LT) | 2 days | Delivery + processing |

## E: Q&A Prep — "Jury Killer Guide"

| Question | Answer | Strategy |
|----------|--------|---------|
| Why VBA/Excel instead of a modern web app or Python/SQL? | "For this specific environment, Excel is the most strategic choice. It requires zero infrastructure cost, works completely offline, is fully compatible with existing Excel 2010+ licenses, and offers the highest user adoption rate for administrative staff." | **Zero-cost + Offline + Adoption** |
| How can you claim this system is "ACID" or secure? | "We implemented transaction safety in mod_TransactionSafety. A movement is either fully committed (Balance + CMUP + Audit Log) or rolled back entirely if an error occurs. Sheet protection and a central MASTER_PWD ensure data integrity." | **Atomic writes + Rollback** |
| How is the CMUP actually calculated? | "It is a dynamic weighted average: (Previous Stock Value + New Inflow Value) / Total New Quantity. This ensures price fluctuations are smoothed out and the financial value remains accurate." | **Formula + Logic** |
| What if the user tries to cheat or delete a sheet? | "Core sheets are locked. The mod_SheetSetup module ensures structural integrity. Any unauthorized attempt to bypass the VBA engine produces inconsistent data that our Audit Trail immediately flags." | **Prevention + Detection** |
| How do you know the stock levels are actually accurate? | "The Inventory Reconciliation module compares the Digital Ledger against the Physical Count, generating a variance report to ensure the 'Digital Truth' matches the 'Physical Reality'." | **Verification process** |
| How is this truly "Decision Support" and not just a digital notebook? | "A notebook only tells you what happened. Our system tells you what to do. By applying EOQ (minimize costs) and ROP (prevent stockouts), we move the manager from a reactive state to a proactive, optimized state." | **Proactive vs Reactive** |
| Why not use Excel's built-in stock formulas? | "Excel has no transaction safety, no audit trail, no EOQ optimization. A single accidental cell edit corrupts the entire stock record with no way to trace it." | **Built-in limitations** |
| What about multi-user access? | "Current design is single-user. For multi-user deployment, the natural evolution is a database backend — which is explicitly listed as future work in the thesis roadmap (SIGLE integration, Annex 6)." | **Honest + Roadmap** |

## F: Backup Plan

| If... | Then... |
|-------|---------|
| Excel crashes | Reopen; transactions survive via audit log |
| Demo PC has old Excel | Copy `ERP_v13.2.xlsm` to USB; test on target PC ahead |
| Beamer/projector fails | Print key sheets (ACCUEIL, ARTICLES, CALCULS_EOQ) as handouts |
| Macro security blocks | Set trusted location: `C:\Users\...\Dropbox\...\` |
| Jury asks obscure question | Say "Let me show you in the system" → navigate to relevant sheet |
| Network down | All offline — no external dependencies |

