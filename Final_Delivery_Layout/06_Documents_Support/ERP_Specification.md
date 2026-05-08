# ERP Specification v13.2 - Decision Support System

## System Overview
- **Name**: نظام الإلكتروني المتكامل للتسيير التمويني (Integrated Electronic System)
- **Institution**: Directorate of Education, El Bayadh (مديرية التربية — ولاية البيض)
- **Version**: v13.2 (NOT v9, NOT Academix)
- **Model**: google/gemma-4-31b-it

## Critical Constants (Ground Truth)
- Annual Demand (D): 1,546 units
- Reorder Point (ROP): 205.6 units
- Safety Stock (SS): 200 units
- Economic Order Quantity (Q*): 176 units
- Lead Time (LT): 2 days
- **Case Study Article**: Toner G030 (ART-001) — NOT Rame papier A4

## Excel Workbook Structure

### 1. ACCUEIL (Dashboard)
**Sheet Name**: `ACCUEIL`
**Title**: نظام ERP مديرية التربية — ولاية البيض
**Version**: v13.2

**KPIs**:
- Total Stock Value (DA)
- RUPTURE count (!! RUPTURE)
- ALERTE count (~ ALERTE)
- COMMANDER count (> COMMANDER)

**Workflow Shortcuts**:
- AjouterMouvement (①)
- VerifierAlertes (②)
- RafraichirTableauBord (③)
- GenererBonReception (④)
- GenererBonSortie (⑤)
- GenererDA (⑥)
- GenererBC (⑦)

**NO "Academix" or "ERP_Academie" text allowed**

---

### 2. ARTICLES (Catalogue)
**Sheet Name**: `ARTICLES`

**Columns**:
| Col | Header (FR) | Header (AR) | Notes |
|-----|--------------|--------------|-------|
| A | Code Article | رمز المادة | ART-NNN format |
| B | Désignation (FR) | التسمية | Official name |
| C | التسمية (AR) | الاسم العربي | Arabic name |
| D | Unité | الوحدة | Rame/Unité/Boîte |
| E | Cl. ABC | الفئة | A/B/C |
| F | Stock Min | الحد الأدنى | Safety threshold |
| G | Stock Max | الحد الأقصى | Max capacity |
| H | Prix Unit. (DA) | السعر | Unit price |
| I | Fournisseur | المورد | Supplier |
| J | Emplacement | الموقع | Rayon X-EY |
| K | Catégorie principale | الفئة الرئيسية | RTL Arabic |
| L | Sous-catégorie | الفئة الفرعية | RTL Arabic |
| M | Alias / Noms alternatifs | الأسماء البديلة | For reference only |

**12 Articles** (ART-001 to ART-012):
1. ART-001: Toner imprimante G030 (noir) — **Primary case study**
2. ART-002: Rame papier A4 80g/m²
3. ART-003: Rame papier A3 80g/m²
4. ART-004: Boîte archives carton
5. ART-005: Agrafeuse de bureau
6. ART-006: Stylos bille boîte/50
7. ART-007: Registre grand format 5m
8. ART-008: Encre tampon
9. ART-009: Sous-chemise carton
10. ART-010: Chemise cartonnée
11. ART-011: Rouleau papier fax
12. ART-012: Marqueur permanent noir

**RTL/LTR Rules**:
- Arabic columns: `dir="rtl"`, text-align:right
- French columns: NO `dir="rtl"`, text-align:left

---

### 3. FOURNISSEURS
**Sheet Name**: `FOURNISSEURS`

**Columns**: Code, Nom abrégé, Raison sociale, Wilaya, Téléphone, Classe, Délai (j), Note/100, Spécialité

**3 Suppliers**:
1. F-001: ENAP Alger (Classe A, Délai 8j, Note 95)
2. F-002: Bureautique Oran (Classe A, Délai 5j, Note 90)
3. F-003: Bureau Plus (Classe B, Délai 7j, Note 80)

---

### 4. CONVENTIONS
**Sheet Name**: `CONVENTIONS`

**Document Naming** (RTL Arabic):
- DA (طلب الاحتياج): DA-SSSS-NNN
- BC (أمر الشراء): BC-SSSS-NNN
- BR (وصل الاستلام): BR-SSSS-NNN
- BS (وصل الخروج): BS-SSSS-NNN
- BC_Comp (تكميلي): BC-SSSS-NNN-C

**Article Naming**: ART-NNN (never reuse deleted codes)

**Category Hierarchy** (NO "فرع"):
1. لوازم مكتبية (Fournitures Bureau)
2. مستهلكات إعلام آلي (Consommables IT)
3. أرشيف وتخزين (Archivage)
4. أدوات مكتبية (Matériel Bureau)
5. أدوات الكتابة (Écriture)
6. سجلات إدارية (Registres)

---

### 5. MOUVEMENTS (Stock Ledger)
**Sheet Name**: `MOUVEMENTS`

**Columns**:
| Col | Header | Formula/Lookup |
|-----|--------|-----------------|
| A | Date | Manual entry |
| B | Code Article | Manual entry |
| C | Désignation (auto) | VLOOKUP from ARTICLES |
| D | Type IN/OUT | Manual: IN or OUT |
| E | Quantité | Manual entry |
| F | Prix Unit. (DA) | Auto: VLOOKUP col I |
| G | Valeur (DA) | =E*F |
| H | Réf. Doc | BS-SSSS-NNN or BR-SSSS-NNN |
| I | Prix Cat. (VLOOKUP col I) | From ARTICLES |
| J | Stock Net (IN-OUT col J) | Cumulative |
| K | Valeur IN Cumulée (K) | Sum of INs |
| L | CMUP Exact (L=K/MAX(1,ΣIN)) | [OPT-02] |
| M | Notes | Manual |

**Observation Period**: 38 days (01/02/2026 — 09/03/2026)

**ROP Formula**: `= (ΣOuts/38j) × 2j + Stock_Min`

---

### 6. TABLEAU DE BORD
**Sheet Name**: `TABLEAU DE BORD`

**Columns**: Code, Désignation, ABC, Total IN, Total OUT, Stock Actuel, Stock Min, CMUP, Valeur Stock, ROP, Statut

**Status Logic**:
- `✔ NORMAUX`: Stock > ROP
- `~ ALERTE`: Stock < 125% of ROP
- `> COMMANDER`: Stock ≤ ROP
- `!! RUPTURE`: Stock = 0

**Parameters** (Right side):
- Jours observation (fixe): 38
- Période réf. (jours ouvrés): 38
- Délai livraison LT (jours): 2

---

### 7. ALERTE_DASHBOARD
**Sheet Name**: `ALERTE_DASHBOARD`

**Counters**:
- !! RUPTURES: Red zone (stock = 0)
- > COMMANDER: Yellow zone (stock ≤ ROP)
- ~ ALERTE: Orange zone (stock < 125% ROP)
- ✔ NORMAUX: Green zone

**Detailed Table**: Code, Désignation, ABC, Stock Actuel, Stock Min, ROP, Statut, CMUP, Valeur, Priorité, Action recommandée

---

### 8. INVENTAIRE
**Sheet Name**: `INVENTAIRE`

**Columns**: Code, Désignation, Stock Comptable, Stock Physique, Écart, % Écart, Statut

---

## VBA Modules

### mod_StockCalculations.bas
- `CalculateROP(AnnualDemand, LeadTimeDays, SafetyStock)`: Returns 205.6 for D=1546, LT=2, SS=200
- `CalculateEOQ(AnnualDemand, OrderCost, HoldingCostPerUnit)`: Returns 176
- `UpdateStockLedger()`: Verifies ROP = 205.6

### mod_ExportEngine_Enhanced.bas
- `ExportToPDF(sheetName, fileName)`: Desktop export with timestamp
- `GenerateBonReception(articleName, quantity, supplier)`: BDR-YYYYMM-NNN format
- `GenerateStockDashboard()`: Auto-update alerts

### mod_StockEntry_Logic_Enhanced.bas
- `ValidateStockEntry(articleCode, quantity, transactionType)`: Checks safety stock, ROP alerts
- `ProcessTransaction()`: Updates ledgers, logs to MOUVEMENTS
- Helper functions: `ArticleExists`, `GetCurrentStock`, `GetROPValue`, `GetSafetyStock`

---

## CNEPD Compliance Checklist

- ✅ No "فرع" (branch) in hierarchy
- ✅ No "Python", "Flask", "JSON", "Database" terms
- ✅ Use "السجل الرقمي" (Digital Ledger) not "Database"
- ✅ Use "وحدات المعالجة VBA" not "Backend"
- ✅ Use "نظام إلكتروني متكامل" not "Hybrid System"
- ✅ Formal Arabic (RTL) for administrative docs
- ✅ CNEPD footnotes (تهميش) at page bottom
- ✅ Hierarchy: فصل → مبحث → مطلب → أولاً، ثانياً
- ✅ ART-001 = Toner G030 (primary case study)
- ✅ Version = v13.2 (NOT v9)
- ✅ No "Academix" or "ERP_Academie" references

---

## RTL/LTR Rules

| Content | Direction | Text Align |
|---------|-----------|-------------|
| Arabic (العربية) | `dir="rtl"` | `text-align:right` |
| French (Français) | NO `dir="rtl"` | `text-align:left` |
| Numbers/Dates | LTR | `text-align:right` |

**Fix from HTML**: Remove `dir="rtl"` from French-only cells (e.g., "RUPTURE", "WORKFLOW" labels)

---

## Verification Steps

1. Open `Decision_Support_System.xlsm`
2. Run `UpdateStockLedger` → Verify ROP = 205.6
3. Check ART-001 = "Toner imprimante G030 (noir)"
4. Verify version displayed = "v13.2"
5. Check NO "Academix" text in any sheet
6. Test `ValidateStockEntry` for Toner G030
7. Export PDF → Check file naming convention
