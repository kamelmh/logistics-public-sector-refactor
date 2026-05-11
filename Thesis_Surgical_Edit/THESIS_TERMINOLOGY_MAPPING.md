# Terminology Mapping: Tech → Administrative (BTS CNEPD Compliant) — v13.2

## Purpose
Ensure all technical terms in the thesis use CNEPD-approved administrative Arabic terminology suitable for BTS jury evaluation. (Phase 4 completed — thesis is clean, this is the reference log.)

---

## Core Term Replacements (Applied in Phase 4)

### Architecture Terms
| Old (Technical) | New (CNEPD Administrative) | Status |
|----------------|---------------------------|--------|
| Offline-First | الاستقلالية عن شبكات الإنترنت | ✅ Replaced |
| Bento Grid | *(removed — not part of thesis scope)* | ✅ Removed |
| Cognitive Load Theory | نظرية الحمل المعرفي | ✅ Replaced |
| Python Backend | وحدات المعالجة VBA | ✅ Done Phase 1 |
| JSON Ledger | السجل الرقمي للمخزون | ✅ Done |
| API Bridge | الربط المحلي | ✅ Done |
| Automation Pipeline | سلسلة المسك المحاسبي | ✅ Done |
| Database | قواعد البيانات المحلية | ✅ Done |

### System-Specific Terms
| Old (Technical) | New (CNEPD Administrative) |
|----------------|---------------------------|
| VBA UserForms | نماذج إدخال البيانات / استمارات العمل |
| Macro-enabled Workbook | المصنف الإلكتروني للتسيير |
| Stock Ledger / Log | السجل الرقمي للمخزون |
| Reorder Point (ROP) | نقطة إعادة الطلب |
| Safety Stock (SS) | مخزون الأمان |
| EOQ | الكمية الاقتصادية المثلى للطلب |
| CMUP | التكلفة المتوسطة المرجحة |
| FIFO | أول دخول أول خروج |
| KPI | مؤشر الأداء الرئيسي |
| Alert / Trigger | تنبيه استباقي / إطلاق |
| Guard / Watchdog | الحراسة المزدوجة / سلسلة الحراسة السداسية |
| Dual Validation | بروتوكول الموافقة الثنائية |

### Chapter-Specific Terminology

#### الفصل الأول (الإطار النظري)
| Old | New |
|-----|-----|
| Stock Management Theory | الإطار النظري لتسيير المخزونات |
| Inventory Models | النماذج الرياضية لتسيير المخزون |
| Supply Chain Management | إدارة سلسلة التوريد |
| Public Sector Procurement | التموين العمومي |
| Warehouse Operations | الوظائف الرئيسية للمستودعات |

#### الفصل الثاني (التشخيص)
| Old | New |
|-----|-----|
| Field Diagnosis | التشخيص الميداني |
| Bottlenecks | الاختناقات / نقاط الضعف البنيوية |
| Stockouts | انقطاعات التموين |
| Phantom Stock / Ghost Inventory | ظاهرة المخزون الوهمي |
| ABC-XYZ Matrix | المصفوفة المشتركة ABC-XYZ |
| Four Simultaneous Conditions | الأربعة شروط المتزامنة |

#### الفصل الثالث (التصميم)
| Old | New |
|-----|-----|
| System Architecture | البنية المتكاملة للنظام |
| Excel + VBA Solution | الحل المبني على Excel/VBA |
| Guard Chain | سلسلة الحراسة السداسية |
| Digital Ledger | السجل الرقمي المحلي |
| VBA Engine | محرك الذكاء المحلي |
| Zinc & Emerald Theme | لوحة الألوان Zinc و Emerald |
| 12 Core Features | الميزات الوظيفية الأساسية |

#### الفصل الرابع (النتائج)
| Old | New |
|-----|-----|
| Implementation Results | نتائج التطبيق / التجريب |
| Key Performance Indicators (KPIs) | مؤشرات الأداء المعتمدة |
| Before / After Comparison | مقارنة قبل التطبيق / بعده |
| Validation | التحقق الكمي / الميداني |
| Recommendations | التوصيات والآفاق |

---

## Terms DELETED from Thesis (No longer present)
| Term | Reason |
|------|--------|
| Python, Flask, JSON, API | Pure VBA-only requirement |
| Bento Grid, Dashboard UI | Web concepts removed per directive |
| Machine Learning, AI | Not used in VBA DSS |
| Mini-ERP | Replaced with "نظام دعم القرار" |
| Database Server, Client-Server | Offline-first Excel only |
| XLOOKUP | Excel 2010 compatibility |
| Cloud, Sync, Real-time | Decoupled/non-web scope |

---

## Footnotes Terminology Templates (CNEPD Standard)
| Context | Template |
|---------|----------|
| Arabic book (first cite) | اسم المؤلف الكامل، **عنوان الكتاب**، دار النشر، مكان النشر، سنة النشر، الجزء، الطبعة، ص. رقم. |
| French book (first cite) | Prénom Nom, *Titre de l'ouvrage*, Éditeur, Lieu, Année, p. XX. |
| Immediate repeat | المرجع نفسه، ص.XX. (or Ibid., p.XX) |
| Later repeat | اسم المؤلف، المرجع السابق، ص.XX. (or Nom, Op.cit., p.XX) |

---

## Status
| Item | Status |
|------|--------|
| Phase 1: ART-001/005 label swap | ✅ Fixed (10 locations) |
| Phase 4: CNEPD terminology | ✅ Applied (Offline-First, Bento Grid, CLT) |
| Bento Grid removal | ✅ Complete (0 references remain) |
| Abstracts (99.7%) | ✅ Corrected (Arabic, English, French) |
| Footnotes format | ✅ Converted to Pandoc `[^n]` syntax |
| All redundant tech terms | ✅ Purged from thesis |

**آخر تحديث**: 2026-05-11
**الحالة**: مكتمل — جميع المصطلحات مطابقة لمعايير CNEPD
