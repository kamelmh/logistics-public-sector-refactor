# Project: Academix v13.2 (Public Sector Refactor)

## 🎯 Goal
Refactor the thesis and software from a hybrid Python/VBA system to a **pure VBA-only Decision Support System (DSS)** compliant with CNEPD BTS standards for the public sector. The project must demonstrate the professional progression from manual stock management science to digital optimization (The "Ladder Logic").

## 🛠 Technical Stack
- **Core:** Microsoft Excel / VBA (Pure)
- **Architecture:** Offline-First, Local Processing Units.
- **Data Store:** Digital Ledger (السجل الرقمي) - internal structured sheets.
- **Dependencies:** Zero external dependencies (No Python, No Flask, No SQL).

## 🏛 Thesis Structural Constraints
- **Hierarchy:** `فصل` (Chapter) $\rightarrow$ `مبحث` (Section) $\rightarrow$ `مطلب` (Requirement) $\rightarrow$ `أولاً، ثانياً...` (First, Second...).
- **Forbidden Terms:** Strictly **NO `فرع` (Branch)** in the structural hierarchy.
- **Terminology Mapping:**
    - ❌ Database $\rightarrow$ ✅ السجل الرقمي (Digital Ledger)
    - ❌ Python/Backend $\rightarrow$ ✅ وحدات المعالجة VBA (VBA Processing Units)
    - ❌ Hybrid System $\rightarrow$ ✅ نظام إلكتروني متكامل (Integrated Electronic System)

## 📈 Critical Constants (Ground Truth)
- **Annual Demand (D):** 1,546 units
- **Reorder Point (ROP):** 205.6 units
- **Safety Stock (SS):** 200 units
- **Economic Order Quantity (Q*):** 176 units
- **Lead Time (LT):** 2 days
- **Case Study Article:** Toner G030 (ART-001)
- **Institution:** Directorate of Education, El Bayadh.

## 📝 Documentation Guidelines
- **Citations:** Use strict CNEPD footnotes (تهميش) at the bottom of each page.
- **Language:** Formal Academic Arabic (RTL).
- **Logic:** Emphasize "Zero Cost", "Standard Tools", and "Accountability".

## 🚀 Current Status
- Thesis structural realignment: ✅ Complete.
- Python dependency removal from VBA: ✅ Complete.
- Terminology cleanup: ✅ Complete.
- Constants synchronization: ✅ Complete.
- DSS narrative pivot: ✅ Complete.
- Chapter alignment (6 → 4): ✅ Complete.
- CNEPD footnotes added: ✅ Complete.
- References cleaned (Python/Flask/JSON → VBA): ✅ Complete.
- TOC & Table/Figure list built: ✅ Complete.
- Defense documents sanitized: ✅ Complete.
- Appendix JSON → VBA ledger: ✅ Complete.
- **OMC Orchestration & Skills**: ✅ Integrated (60+ skills active).
- **VBA Code Review**: ✅ Passed (Modules located in `Software_Surgical_Edit\VBA_Modules`).
- **Default Model**: ✅ Gemma 4 (31B) via OpenCode Cloud.
- VBA Modules Professional Audit: ✅ Complete (Surgically Verified)
