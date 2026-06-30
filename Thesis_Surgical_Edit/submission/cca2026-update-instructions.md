# CCA'2026 — Update Submission to v13.4 (Step by Step)

## Before you start
Files ready at: `Thesis_Surgical_Edit/output/`
- `English_Research_Paper_CCA2026.pdf` (158 KB, blind, IEEE double-column)
- `English_Research_Paper_CCA2026.docx` (21 KB, blind, backup)

## Step 1: Login
Go to https://cmt3.research.microsoft.com/CCA2026/
Click "Author Console" (top right, logged in as Kamel Abdelghani)

## Step 2: Find your submission
Look for the paper with v13.2 title. Click "Edit Submission"

## Step 3: Update Title
Old: ...Academix v13.2 Framework
New: An Offline-First Decision Support System for Inventory Optimization in Public Sector Logistics: The Academix v13.4 Framework

## Step 4: Update Abstract (paste this exactly)
Public sector logistics in developing regions often rely on manual inventory methods prone to overstocking and stockouts, yet commercial Enterprise Resource Planning (ERP) systems are prohibitively expensive and depend on reliable connectivity. This paper presents Academix v13.4, an offline-first Decision Support System (DSS) implemented entirely in Pure VBA (Visual Basic for Applications) that requires zero external dependencies. The framework integrates ABC classification with the Wilson Economic Order Quantity (EOQ) model to automate reorder decisions, augmented by four DSS intelligence pillars: print engineering, UX optimization, stockout projection, and fuzzy search. Empirical validation using 38 days of field data from the Education Directorate of El Bayadh, Algeria, demonstrates a 99.7% operational performance rate, with 112/112 verification checks passed and zero critical audit failures. For the benchmark article ART-002 (Toner G030), the system computed an Economic Order Quantity of 37 units and a Reorder Point of 206 units, effectively eliminating stockout risk. The results establish that mathematically rigorous, low-tech architectures can deliver sustainable digitalization for resource-constrained public administrations.

## Step 5: Update Files
- Remove: English_Research_Paper_Blind.docx
- Remove: English_Research_Paper_Blind.pdf
- Upload: English_Research_Paper_CCA2026.pdf (158 KB)
- Optionally upload: English_Research_Paper_CCA2026.docx as supplementary

## Step 6: Subject Areas
Keep as-is: Primary = Optimization, Secondary = Operational Research

## Step 7: Submit
Click "Submit" button

## What changed (v13.2 → v13.4)
- Title: v13.2 → v13.4
- Architecture: 35 → 42 modules, 8100 → 17700 lines
- Verification: 141 → 144 checks (112+16+16)
- New: 4 DSS intelligence pillars (Section IV.E)
- New: IEEE double-column PDF format
- Fixed: 8 KB truncated PDF → proper 158 KB PDF
