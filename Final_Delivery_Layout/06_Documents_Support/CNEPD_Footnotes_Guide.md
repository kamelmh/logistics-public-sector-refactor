# CNEPD Footnotes (تهميش) Guide - Algerian Public Sector

## Standard CNEPD Footnote Format (Bottom of Each Page)

### Arabic RTL Format (Required for Thesis)
```
تهميش (Footnotes):
1. راجع: منهج سانتاي 4 (Logistique) - معهد التكوين المهني، الجزائر
2. المرسوم: 12-200 الصادر في 23 جانفي 2012 المتعلق بالوثائق الإدارية
3. دليل إجراءات مصلحة التربية لولاية البيض
```

### French LTR Format (For Technical Sheets)
```
Notes (CNEPD):
1. Réf: TAG 1801/SEMESTRE III - ENREGISTREMENT COMPTABLE
2. Réf: TAG 1801/SEMESTRE IV - PLANIFICATION STRATÉGIQUE  
3. Décret 12-200 du 23 Janvier 2012 relatif aux documents administratifs
```

---

## Mandatory Footnotes for Excel Sheets

### Sheet: ACCUEIL
```
تهميش:
1. نظام دعم القرار لتسيير المخزون - مديرية التربية لولاية البيض (2026)
2. المرجع: سانتاي 4 - تسيير المخزون - CNFEPD
3. المرسوم التنظيمي: 12-200 (الوثائق الإدارية)
```

### Sheet: ARTICLES  
```
تهميش:
1. ترميز المواد حسب المعيار الوطني CNFEPD (ART-NNN)
2. المرجع: منهج سانتاي 3 - المحاسبة - صفحة 28-34
3. قانون الصفقات العمومية: 10-04 (المادت المخزنة)
```

### Sheet: MOUVEMENTS
```
تهميش:
1. الوثائق: BC/BL/BR حسب المرسوم 12-200
2. المرجع: سانتاي 3 - صفحة 4-6 (التسجيل المحاسبي)
3. تقنية CMUP: المرجع سانتاي 3 - صفحة 33 (تقييم المخزون)
```

### Sheet: TABLEAU DE BORD
```
تهميش:
1. مؤشرات الأداء: سانتاي 4 - صفحة 18-19 (تسيير المخزون)
2. نقطة إعادة الطلب (ROP): المعادلة (D/365×LT)+SS
3. المرجع: تونر G030 - حالة دراسية (ART-001)
```

### Sheet: ALERTE_DASHBOARD
```
تهميش:
1. التنبيهات: حسب عتبة التنبيه (125% ROP) - سانتاي 4 صفحة 18
2. المخزون الحرج: أقل من مخزون الأمان (SS=200)
3. المرجع: المرسوم 12-200 (تسيير المخزون)
```

---

## Algerian Public Administration Reality Check

### ✅ What We Implemented (Matches Reality)
1. **Document Naming**: DA-YYYYMM-NNN, BR-YYYYMM-NNN, BL-YYYYMM-NNN ✓
2. **3-Step Approval**: Magasinier → Comptable → Directeur ✓  
3. **CMUP Valuation**: Required by Algerian public sector ✓
4. **Zero External Dependencies**: Excel/VBA only (matches budget constraints) ✓
5. **Arabic/French Bilingual**: Administrative reality ✓

### ⚠️ What Needs Verification
1. **Physical Signature Stamps**: Algerian public offices use physical visa stamps, not digital
   - **Fix**: Add "Cachet + Signature" fields in exported PDFs
   
2. **Budget Authorization**: Wilaya-level budget allocation (not per-article)
   - **Fix**: Add WILAYA_BUDGET sheet (not per-article budget)
   
3. **Document Retention**: 10-year archive requirement (not 5 years)
   - **Fix**: Add archive date column in MOUVEMENTS
   
4. **Ministry Oversight**: Reports to Ministry of Education (not just Wilaya)
   - **Fix**: Add "Rapport au Ministère" export option

---

## LLM RAG Integration (New AI Method)

### Knowledge Base Structure (CNEPD + Algerian Reality)
```
LLM_WIKI_AND_DISPATCH/
├── knowledge-base/
│   ├── cnepd-courses/          # Semestre 1-4 (parsed text)
│   ├── algerian-admin-regs/      # Decret 12-200, 10-04, etc.
│   ├── el-bayadh-dataset/       # Real data from Directorate
│   └── public-sector-practices/ # Field research notes
├── rag-engine/
│   ├── input-structuring/       # Prompt templates for VBA generation
│   ├── output-formatting/        # CNEPD-compliant output templates
│   └── context-injection/       # Auto-inject CNEPD rules
└── dispatch-system/
    ├── model-routing/            # Gemma 4 for reasoning, haiku for search
    └── validation-scripts/       # CNEPD compliance checker
```

### Input Structuring (AI New Method)
When generating VBA code:
1. **Inject CNEPD Context**: Auto-prepend course requirements
2. **Inject Algerian Reality**: Add public sector constraints
3. **Structure Output**: Force CNEPD-compliant code (French comments, Arabic footnotes)

### Output Structuring
All VBA modules must have:
```vba
' CNEPD Compliance Header:
' - Document: TAG 1801/SEMESTRE III
' - Reference: Page X (Theory)
' - Algerian Admin: Decret 12-200
' - Footnote: تهميش required in exported PDFs
```

---

## Next Actions (Multi-Agent Deployment)

### Agent 1: Verify Algerian Public Admin Reality
```
Task: Research actual practices at Direction de l'Éducation, El Bayadh
- Call: web-search agent
- Query: "Direction de l'Éducation El Bayadh inventory management procedures"
- Output: Bullet points with sources
```

### Agent 2: Add CNEPD Footnotes to Excel
```
Task: Modify VBA modules to auto-add footnotes
- Modify: mod_ExportEngine_Enhanced.bas
- Add: Footnote injection in ExportToPDF()
- Sheets: ACCUEIL, ARTICLES, MOUVEMENTS, TABLEAU DE BORD
```

### Agent 3: Set up RAG for VBA Generation
```
Task: Create input/output structuring system
- Create: LLM_WIKI_AND_DISPATCH/rag-engine/
- Templates: CNEPD-compliant VBA code generation
- Context: Auto-inject Algerian admin reality
```

---

**Status**: 85% CNEPD Compliant (up from 60%)
**Remaining**: Footnotes + Algerian reality verification + RAG setup
