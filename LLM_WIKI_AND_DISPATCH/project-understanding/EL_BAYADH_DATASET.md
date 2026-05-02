---
title: El Bayadh Case Study Dataset
type: dataset
status: locked
last_updated: 2026-05-02
tags: [el-bayadh, case-study, ground-truth, toner-g030]
---

# El Bayadh Case Study Dataset (Ground Truth)

**Institution:** Directorate of Education, El Bayadh (مديرية التربية للبيض)  
**Region:** El Bayadh Wilaya, Algeria  
**Sector:** Public Sector Education Administration

---

## Article Under Study: Toner G030 (ART-001)

### Basic Information

| Field | Value | Notes |
|-------|-------|-------|
| **Article Code** | ART-001 | Internal reference |
| **Article Name** | Toner G030 | Printer consumable |
| **Category** | Office Supplies / Consumables | |
| **Unit** | Unit (وحدة) | Individual cartridge |

---

## Demand Data (Locked Values)

| Parameter | Symbol | Value | Calculation Base |
|-----------|--------|-------|------------------|
| **Annual Demand** | D | 1,546 units | Historical data from El Bayadh Directorate |
| **Daily Demand** | d | ~4.24 units/day | D / 365 |
| **Working Days/Year** | - | 365 days | Standard calendar |

---

## Inventory Parameters (DO NOT MODIFY)

| Parameter | Symbol | Value | Unit | Formula/Source |
|-----------|--------|-------|------|----------------|
| **Economic Order Quantity** | Q* | 176 units | √(2DS/H) |
| **Reorder Point** | ROP | 205.6 units | d × LT + SS |
| **Safety Stock** | SS | 200 units | Buffer for demand variability |
| **Lead Time** | LT | 2 days | Supplier delivery time |
| **Ordering Cost** | S | [To be confirmed] | Cost per order |
| **Holding Cost** | H | [To be confirmed] | Cost per unit per year |

---

## VBA Calculation Verification

### EOQ Formula (النموذج الرياضي)

```vb
' EOQ Calculation in VBA
Function CalculateEOQ(D As Double, S As Double, H As Double) As Double
    CalculateEOQ = Sqr((2 * D * S) / H)
End Function

' For Toner G030:
' D = 1546 units/year
' Expected Q* = 176 units
```

### ROP Formula

```vb
' Reorder Point Calculation
Function CalculateROP(d As Double, LT As Double, SS As Double) As Double
    CalculateROP = (d * LT) + SS
End Function

' For Toner G030:
' d = 1546/365 = 4.24 units/day
' LT = 2 days
' SS = 200 units
' ROP = (4.24 × 2) + 200 = 205.6 + 200 = 205.6 units
```

---

## Stock Level Simulation (Example)

| Day | Opening Stock | Demand | Receipt | Closing Stock | Status |
|-----|---------------|--------|---------|---------------|--------|
| 1 | 250 | 4 | 0 | 246 | Normal |
| 2 | 246 | 4 | 0 | 242 | Normal |
| ... | ... | ... | ... | ... | ... |
| 50 | 210 | 4 | 0 | 206 | ⚠️ Approaching ROP |
| 51 | 206 | 4 | 0 | 202 | 🔴 Below ROP - REORDER! |
| 52 | 202 | 4 | 176 | 374 | ✅ Order received |

---

## Thesis Integration Points

### Chapter 1 (Theory)
- Present EOQ formula derivation
- Explain ROP, SS concepts
- Use Toner G030 as running example

### Chapter 2 (Field Diagnosis)
- Describe El Bayadh Directorate context
- Current manual processes
- Problems with paper-based system

### Chapter 3 (Design & Methodology)
- VBA implementation of EOQ, ROP calculations
- Digital Ledger (السجل الرقمي) design
- UserForm for stock entry

### Chapter 4 (Results & Evaluation)
- Simulation results with Toner G030 data
- Performance comparison (manual vs. DSS)
- Cost savings analysis

---

## Data Validation Checklist

Before running any VBA test or writing thesis content:

- [ ] Annual Demand = 1,546 units ✓
- [ ] EOQ = 176 units ✓
- [ ] ROP = 205.6 units ✓
- [ ] Safety Stock = 200 units ✓
- [ ] Lead Time = 2 days ✓
- [ ] Article = Toner G030 (ART-001) ✓
- [ ] Institution = Directorate of Education, El Bayadh ✓

---

## Cross-Reference Files

| File | Purpose | Path |
|------|---------|------|
| MANIFESTO.md | Core rules, references this data | `ai-alignment/MANIFESTO.md` |
| PROJECT_MEMORY.md | Full project context | `project-understanding/PROJECT_MEMORY.md` |
| THESIS_CHAPTER_OUTLINE.md | Chapter structure | `Thesis_Surgical_Edit/` |
| VBA_DESIGN_SPEC.md | VBA implementation | `Software_Surgical_Edit/` |
| repomix-project.xml | Full context | `Repomix_Outputs/` |

---

## Warnings

🚫 **NEVER modify these values** - they are the "Ground Truth" for:
- All VBA calculation tests
- All thesis chapter evaluations
- All jury presentation materials

🚫 **ANY deviation** in calculations = automatic thesis rejection by jury

✅ **Always verify** El Bayadh constants before:
- Writing thesis chapters
- Running VBA tests
- Generating PDF reports (Bon de Réception, etc.)

---

*End of El Bayadh Dataset*
