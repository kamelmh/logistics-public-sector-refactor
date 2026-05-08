---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Segoe UI', 'Arial', sans-serif;
    font-size: 22px;
    direction: rtl;
    text-align: right;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    color: #e8e8e8;
    padding: 40px 50px;
  }
  h1 {
    font-size: 36px;
    color: #4ecca3;
    border-bottom: 3px solid #4ecca3;
    padding-bottom: 10px;
    margin-bottom: 20px;
  }
  h2 {
    font-size: 30px;
    color: #4ecca3;
    margin-bottom: 15px;
  }
  ul {
    font-size: 20px;
    line-height: 1.8;
  }
  li {
    margin-bottom: 8px;
  }
  table {
    font-size: 18px;
    border-collapse: collapse;
    width: 100%;
  }
  th, td {
    padding: 10px 15px;
    border: 1px solid #333;
    text-align: right;
  }
  th {
    background: #4ecca3;
    color: #1a1a2e;
    font-weight: bold;
  }
  .highlight {
    color: #4ecca3;
    font-weight: bold;
  }
  .metric {
    font-size: 48px;
    color: #4ecca3;
    text-align: center;
    font-weight: bold;
    margin: 10px 0;
  }
  .subtitle {
    font-size: 18px;
    color: #aaa;
  }
  .two-col {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
  }
---

# بناء نظام دعم قرار لتسيير المخزون
## Decision Support System for Inventory Management

<div class="subtitle">
ماحي كمال عبد الغني | إشراف: دهيني ميمونة<br>
BTS تسيير المخزونات واللوجستيك — CNEPD TAG1801<br>
معهد INMF بن سعيدي عبد العاطي — البيض | دورة أكتوبر 2025
</div>

---

# إشكالية البحث

### تسيير مخزون مديرية التربية لولاية البيض

- ❌ نفاد متكرر للأصناف الأساسية (Toner G030 وصل لـ **وحدة واحدة**)
- ❌ لا تتبع آني — الجرد اليدوي يستغرق **أسابيع**
- ❌ أرصدة وهمية — **42%** من الأصناف دون مستوى ROP
- ❌ تكلفة الحلول التجارية: **~8.5 مليون دج/سنة**

> كيف نرقمن تسيير المخزون **بتكلفة صفرية** ودون اتصال بالإنترنت؟

---

# التشخيص الميداني — 38 يوم عمل

| المؤشر | القيمة |
|--------|--------|
| مدة الملاحظة | 38 يوم عمل |
| عدد الأصناف المُدارة | 12 صنف |
| الأصناف الحرجة (< ROP) | 5 من 12 (42%) |
| الطلب السنوي (D) | 1,546 وحدة |
| نقطة إعادة الطلب (ROP) | 205.6 وحدة |

<div class="metric">ART-005: 1 وحدة فقط</div>
<p class="subtitle" style="text-align: center;">Toner G030 — نفاد كلي في ديسمبر 2025</p>

---

# لماذا نظام دعم قرار (DSS)؟

### Excel/VBA — الحل الواقعي للقطاع العمومي

<div class="two-col">
<div>

**✅ المزايا:**
- تكلفة **صفرية** — Office متوفر مسبقًا
- عمل **دون إنترنت** — مناسب للولايات النائية
- واجهة **مألوفة** — لا يحتاج تكوين تقني
- مرونة كاملة — تكييف مع الإجراءات المحلية

</div>
<div>

**❌ بدائل غير مناسبة:**
- SAP: ~5 مليون دج/سنة
- Oracle: ~3.5 مليون دج/سنة
- يحتاج خادم + إنترنت + مبرمج

</div>
</div>

---

# بنية النظام

### نظام دعم القرار لتسيير المخزون v13.2

```
واجهة المستخدم (UserForms)
         ↓
محرك المعالجة VBA (28 وحدة)
         ↓
السجل الرقمي (25 ورقة Excel محمية)
         ↓
التقارير PDF (DA / BC / BR / BS)
```

- **25 ورقة عمل** (ACCUEIL, ARTICLES, MOUVEMENTS...)
- **28 وحدة VBA** (mod_StockEngine, mod_Analysis, mod_AuditTrail...)
- **حماية بكلمة مرور** على جميع الأوراق
- **سجل مراجعة** غير قابل للتعديل (Append-Only)

---

# الابتكار 1: نظام الحراسة المزدوجة

### Dual-Guard System — منع الأرصدة الوهمية

| الحراسة | الوظيفة |
|---------|---------|
| **الأولى** | التحقق من صلاحية الإدخال قبل الكتابة (UserForm validation) |
| **الثانية** | منع الرصيد السالب آنيًا (StockEngine.CheckNegative) |

### النتيجة:
- ❌ **قبل:** رصيد سالب في السجلات — بضاعة غير موجودة
- ✅ **بعد:** كل حركة تتحقق من الرصيد المتاح **قبل** التأكيد

<div class="metric">0 أرصدة وهمية</div>
<p class="subtitle" style="text-align: center;">مقارنة بـ 42% من الأصناف الحرجة سابقًا</p>

---

# الابتكار 2: الحسابات الآنية

### EOQ + CMUP + ROP — كلها تعمل آنياً

| النموذج | المعادلة | القيمة |
|---------|----------|--------|
| **EOQ (Wilson)** | Q* = √(2DC₀/CI) | **176 وحدة** |
| **ROP** | SS + (D/250) × LT | **205.6 وحدة** |
| **CMUP** | (S₁×Q₁ + S₂×Q₂) / (Q₁+Q₂) | آني مع كل حركة |
| **ABC-XYZ** | تصنيف 12 صنف | A: 84% من القيمة |

> الحسابات اليدوية كانت تستغرق 15-20 دقيقة ← الآن **30 ثانية**

---

# واجهة النظام — سكرين شوت

### UserForm إدخال الحركات المخزنية

<div style="text-align: center; color: #888; font-size: 18px; margin-top: 40px;">
<strong>[أدخل هنا لقطة شاشة من frmStockEntry.frm]</strong><br><br>
UserForm يحتوي على:<br>
• قائمة الأصناف (12 صنف من ARTICLES)<br>
• نوع الحركة (دخول / خروج)<br>
• الكمية + التاريخ + المرجع<br>
• زر "تسجيل" → تسجيل آني + PDF
</div>

---

# النتائج — قبل وبعد

<div class="two-col">
<div>

**قبل (النظام اليدوي):**
- ❌ جرد يدوي: **أسابيع**
- ❌ حسابات يدوية: **15-20 دقيقة/حركة**
- ❌ 42% أصناف حرجة
- ❌ لا تنبيهات
- ❌ أرصدة وهمية

</div>
<div>

**بعد (نظام دعم القرار):**
- ✅ جرد آني: **لحظة واحدة**
- ✅ تسجيل آلي: **30 ثانية/حركة**
- ✅ تنبيهات ROP تلقائية
- ✅ حراسة مزدوجة ← 0 أخطاء
- ✅ سجل مراجعة غير قابل للتعديل

</div>
</div>

<div class="metric">97% تخفيض الزمن</div>
<p class="subtitle" style="text-align: center;">100% تطابق الرصيد المحاسبي والفيزيائي</p>

---

# المؤشرات الرئيسية — ملخص الأرقام

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-top: 30px;">

<div style="text-align: center;">
<div class="metric">1,546</div>
<p>وحدة/سنة (D)</p>
</div>

<div style="text-align: center;">
<div class="metric">176</div>
<p>وحدة (Q*)</p>
</div>

<div style="text-align: center;">
<div class="metric">97%</div>
<p>تخفيض الزمن</p>
</div>

</div>

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-top: 20px;">

<div style="text-align: center;">
<div class="metric">0 دج</div>
<p>التكلفة</p>
</div>

<div style="text-align: center;">
<div class="metric">38</div>
<p>يوم ملاحظة</p>
</div>

<div style="text-align: center;">
<div class="metric">58</div>
<p>ولاية قابلة للنشر</p>
</div>

</div>

---

# الانسجام مع CNEPD TAG1801

### كل سداس من المنهاج مُطبَّق في وحدة VBA

| السداسي | المحور | التطبيق في DSS |
|---------|--------|----------------|
| 1 | دراسات الأسعار | حساب التكاليف + مقارنة الموردين |
| 2 | إجراءات الشراء | DA → BC → BR → BS آليًا |
| 3 | النماذج الرياضية | EOQ + ROP + ABC-XYZ |
| 4 | الجرد الدائم | تحديث آني + Audit Trail |

<div class="metric">92.9%</div>
<p class="subtitle" style="text-align: center;">درجة التوافق مع معايير تقييم CNEPD (79/85)</p>

---

# إمكانية التعميم على 58 ولاية

### نموذج النشر — 3 أسابيع، 0 دج

| المرحلة | الإجراء | المدة |
|---------|---------|------|
| 1 | نسخ ملف Excel | يوم واحد |
| 2 | تعديل البيانات المرجعية | أسبوع |
| 3 | تدريب المسير | 3 أيام |
| 4 | تشغيل تجريبي + ضبط المعاملات | أسبوعان |

### العائق الوحيد:
بيانات ميدانية محلية (الطلب السنوي، الموردون، أجل التسليم) — **متوفرة** في سجلات كل مديرية

---

# خارطة طريق التكامل مع SIGLE

### SIGLE = منظومة المحاسبة العمومية الجزائرية

```
DSS (المخزون)  ──→  CSV  ──→  SIGLE (المحاسبة)
     ↑                                    │
     ←──── تحديث الأرصدة ←──── تقارير مالية
```

- **SIGLE**: يغطي الجانب المالي (ميزانية، محاسبة)
- **DSS**: يغطي جانب المخزون (لا يغطيه SIGLE)
- **الربط**: تصدير CSV شهري → استيراد في SIGLE
- **الملحق 6**: خارطة طريق تفصيلية

---

# الخاتمة والتوصيات

### النتائج

نظام دعم القرار لتسيير المخزون **يُثبت** أن الرقمنة ممكنة **بتكلفة صفرية** حتى في أصعب الظروف:
- ✅ تخفيض 97% في زمن المعالجة
- ✅ 0 أرصدة وهمية بعد نظام الحراسة المزدوجة
- ✅ 100% تطابق محاسبي-فيزيائي
- ✅ قابل للتعميم على 58 ولاية

### التوصيات

1. 🔄 نشر النظام في مديريات التربية الأخرى
2. 🔗 التكامل مع SIGLE للمحاسبة العمومية
3. 📱 تطوير نسخة ويب (مرحلة لاحقة عند توفر الإنترنت)

---

# شكرًا

### أسئلة اللجنة

<div class="subtitle" style="text-align: center; margin-top: 30px;">
ماحي كمال عبد الغني<br>
إشراف: دهيني ميمونة<br>
معهد INMF بن سعيدي عبد العاطي — البيض<br><br>
<strong>نظام دعم القرار لتسيير المخزون v13.2</strong><br>
<em>"الرقمنة ممكنة بموارد محدودة"</em>
</div>
