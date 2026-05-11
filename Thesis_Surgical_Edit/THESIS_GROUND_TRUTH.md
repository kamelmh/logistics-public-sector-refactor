# Academix v13.2 — Thesis Ground Truth (LOCKED — DO NOT MODIFY)
# Reference for all chapter edits. Every article code, constant, and measure must match this table.

## 12 Articles (Source: instructions.md + VBA modules)
| Code | French Designation | Arabic Name | Class | Annual Demand D |
|------|-------------------|-------------|-------|-----------------|
| ART-001 | Toner imprimante G030 (noir) | حبر الطابعة Toner G030 | A | 1,546 |
| ART-002 | Rame papier A4 80g/m² | رزم الورق A4 | A | 1,200 |
| ART-003 | Rame papier A3 80g/m² | رزم الورق A3 | B | 800 |
| ART-004 | Boîte archives carton | صندوق أرشيف كرتوني | B | 400 |
| ART-005 | Agrafeuse de bureau | أغرف الأغراض (دباسة) | C | 300 |
| ART-006 | Stylos bille boîte/50 | أقلام حبر (علبة/50) | C | 450 |
| ART-007 | Registre grand format 5m | سجل كبير 5م | C | 350 |
| ART-008 | Encre tampon | حبر أختام | C | 200 |
| ART-009 | Sous-chemise carton | مغلف كرتوني | C | 250 |
| ART-010 | Chemise cartonnée | مجلد كرتوني | C | - |
| ART-011 | Rouleau papier fax | لفافة ورق فاكس | C | - |
| ART-012 | Marqueur permanent noir | قلم دائم أسود | C | - |

## Case Study Constants (Source: instructions.md)
| Constant | Value | Unit | Meaning |
|----------|-------|------|---------|
| D (ART-001) | 1,546 | unit/year | Annual demand |
| Q* (EOQ) | 176 | units | √(2×1546×500 / 0.20×PU) |
| ROP | 205.6 | units | (1546/250)×2 + 200 |
| SS | 200 | units | (MaxDaily − AvgDaily)×2 |
| LT | 2 | days | Default delivery lead time |
| S | 500 | DZD | Fixed order cost |
| I | 20% | - | Annual holding rate |
| PU (ART-001) | 400 | DZD/unit | Unit price |
| Observation Period | 38 | days | MOUVEMENTS data collection |
| Working Days | 250 | days/year | Standard |

## Chapter-by-Chapter ART Assignments
| Chapter | ART-001 is | ART-005 is | Notes |
|---------|-----------|-----------|-------|
| Ch1 (Theory) | Toner G030 | Agrafeuse | Fix: currently says "رزم الورق A4" |
| Ch2 (Diagnosis) | Toner G030 | Agrafeuse | Fix: currently says "رزم الورق A4" |
| Ch3 (Design) | Toner G030 | Agrafeuse | Verify: no swap known |
| Ch4 (Results) | Toner G030 ✅ | Agrafeuse ✅ | Already correct |

## Footnotes Template (CNEPD Standard)
### First citation (Arabic book):
```
[^n]: اسم المؤلف الكامل، عنوان الكتاب (بخط غليظ)، دار النشر، مكان النشر، سنة النشر، الجزء (إن وجد)، الطبعة، ص. رقم.
```
### First citation (French book):
```
[^n]: Prénom Nom, Titre de l'ouvrage (en italique), Éditeur, Lieu, Année, p. XX.
```
### Immediate repeat (same page):
```
[^n]: المرجع نفسه، ص.XX.  (or Ibid., p.XX)
```
### Later repeat:
```
[^n]: اسم المؤلف، المرجع السابق، ص.XX.  (or Nom, Op.cit., p.XX)
```
### Journal article:
```
[^n]: اسم المؤلف، "عنوان المقال"، اسم المجلة، العدد، المجلد، سنة النشر، ص.XX.
```
### Online source:
```
[^n]: اسم المؤلف، عنوان الصفحة، اسم الموقع، تاريخ الاطلاع: DD/MM/YYYY, URL.
```

## Time Measurement (Ch4 Results)
| Measure | Before (Manual) | After (DSS) | Reduction |
|---------|----------------|-------------|-----------|
| Processing time per transaction | 20-30 minutes | < 5 seconds | **99.7%** |
| Abstract must say: **99.7%** (NOT 97%) |
