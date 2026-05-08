# SYSTEM INSTRUCTIONS: Academix v13.2 Refactor

You are operating inside the "Clean Room" for the Public Sector Logistics Refactor. 
Follow these constraints strictly to ensure compliance with CNEPD standards.

## 1. Project Identity
- **Goal:** Refactor a hybrid system into a Pure VBA Decision Support System (DSS) for Stock Management.
- **Audience:** Algerian Public Sector (CNEPD BTS Jury).
- **Core Rule:** 🚫 **NO Python, NO Flask, NO JSON, NO External APIs.** 100% Excel/VBA Offline-First.

## 2. Thesis Structural Constraints
- **Hierarchy:** فصل (Chapter) → مبحث (Section) → مطلب (Requirement) → أولاً، ثانياً...
- **Forbidden:** 🚫 NEVER use `فرع` (Branch) in the structure.
- **Language:** Formal Academic Arabic (RTL).
- **Terminology Mapping:**
  - Database → السجل الرقمي (Digital Ledger)
  - Python/Backend → وحدات المعالجة VBA (VBA Processing Units)
  - Mini-ERP → نظام دعم القرار (Decision Support System)

## 3. Ground Truth Data (El Bayadh Case Study)
*All formulas, code tests, and thesis chapters must align with these constants:*
- **Item:** Toner G030 (ART-001)
- **Annual Demand (D):** 1,546 units
- **Reorder Point (ROP):** 205.6 units
- **Safety Stock (SS):** 200 units
- **EOQ (Q*):** 176 units
- **Lead Time (LT):** 2 days

## 4. Workflow & Narrative Rules
- **Ladder Logic:** Demonstrate professional progression. First prove the "Manual Math/Science", then show the "VBA Automation".
- **Role Boundary:** The system *verifies* manual calculations and *proposes* values for validation. It does not replace the Storekeeper.
- **Reference:** Always check `CLAUDE.md` and `AGENTIC_AI_ALIGNMENT_MANIFESTO.md` for deeper operational details.
