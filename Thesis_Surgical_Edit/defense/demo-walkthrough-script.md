# Academix v13.2 — Demo Walkthrough Script
## Soutenance / Defense — Direction de l'Éducation d'El Bayadh
**Auteur :** Mahi Kamel Abdelghani | **Durée :** 9 min | **Workbook :** `ERP_v13.2.xlsm`

---

## STEP 1 / 8 — Accueil & Vue d'Ensemble | الواجهة الرئيسية ونظرة عامة
**⏱ 1:00** (0:00 → 1:00)

### Action
1. Double-clic sur `ERP_v13.2.xlsm` — Activer les macros si demandé (Oui)
2. La feuille **Accueil** s'affiche automatiquement (macro `ShowMainMenu` dans `MAIN_MACROS.bas:40`)
3. Pointer la barre de titre : *"ERP Académie v13.2 — Direction de l'Éducation — El Bayadh"*
4. Parcourir les 5 sections de boutons : **SAISIE**, **TABLEAU DE BORD**, **ANALYSE**, **RAPPORTS**, **UTILITAIRES**

### Discours (Arabe)
> بسم الله الرحمن الرحيم. هذه هي الواجهة الرئيسية للنظام — "ERP Académie v13.2". صممت الواجهة بخمسة أقسام وظيفية تغطي دورة التخزين بكاملها: الإدخال، لوحة القيادة، التحليل، التقارير، والأدوات المساعدة. كل وظيفة متاحة بنقرة واحدة — لا حاجة إلى أوامر أو أكواد. النظام مبني بالكامل على Excel/VBA بتكلفة صفرية، ولا يتطلب أي برامج إضافية أو اتصال بالإنترنت.

### Métriques clés
- 25 feuilles de calcul interconnectées
- 38 modules VBA
- 0 DZD de coût de licence

### Transition
> ننتقل الآن إلى جرد المخزون لمعاينة الأصناف المسجلة.

---

## STEP 2 / 8 — Catalogue Articles / Stock | جدول المخزون والأصناف
**⏱ 1:15** (1:00 → 2:15)

### Action
1. Cliquer sur l'onglet **ARTICLES** (ou bouton de navigation)
2. Montrer la liste des 12 articles (ART-001 à ART-012)
3. Pointer les colonnes : Code, Désignation, Stock Actuel, Seuil Min, Classe ABC, PU, Fournisseur
4. Cliquer sur **ART-001 — Toner G030** (ligne 2)
5. Montrer : Stock Actuel, Stock de Sécurité (200), Classe A

### Discours (Arabe)
> صفحة المخزون تضم 12 صنفاً مسجلاً، كل صنف له رمز فريد (ART-001 إلى ART-012). الصنف المرجعي ART-001 هو حبر الطابعة Toner G030 — وهو صنف استراتيجي من الفئة A حسب تصنيف ABC. نلاحظ هنا أن المخزون الحالي مسجل، مع حد أدنى ومخزون أمان محددين. هذه البيانات هي الأساس الذي تبني عليه خوارزميات النظام حساباتها.

### Métriques clés
- 12 articles (ART-001 → ART-012)
- ART-001 : Toner G030 — Classe A
- SS = 200 unités

### Transition
> لنقم الآن بتسجيل حركة مخزنية جديدة لنرى كيفية عمل النظام آلياً.

---

## STEP 3 / 8 — Saisie d'un Mouvement | تسجيل حركة مخزنية
**⏱ 1:30** (2:15 → 3:45)

### Action
1. Revenir à **Accueil** (onglet ou bouton)
2. Cliquer sur `[ENTRY] Formulaire de Saisie` (appelle `OpenStockForm`)
3. Le formulaire `frmStockEntry` s'ouvre
4. Remplir :
   - Code Article : ART-001 (ou le sélectionner dans la liste déroulante)
   - Type : **Sortie** (Bon de Sortie)
   - Quantité : 50
   - Réf. Document : BS-2026-001
5. Cliquer **Valider**
6. Un message de confirmation apparaît : *"Mouvement enregistré avec succès"*
7. Pointer que la cellule du stock s'est mise à jour instantanément

### Discours (Arabe)
> نقوم الآن بتسجيل خروج 50 وحدة من حبر ART-001. النموذج يتحقق من صحة البيانات قبل الحفظ — يمنع إدخال قيم سالبة أو أكواد غير موجودة. بمجرد الضغط على "موافق"، يقوم محرك VBA بتحديث رصيد المخزون آنياً، وتسجيل الحركة في سجل المعاملات الرقمي، وتدوينها في سجل المراجعة. هذا هو جوهر الجرد الدائم المحوسب — كل حركة تنعكس فوراً على جميع المؤشرات.

### Métriques clés
- Temps de traitement : < 5 secondes (vs 20-30 min en mode manuel)
- Mise à jour instantanée du stock
- Enregistrement dans AUDIT_LOG

### Backup plan
> إذا لم يفتح النموذج: استخدم `Alt+F8` → `AjouterMouvement` → تشغيل

### Transition
> بعد تسجيل الحركات، يقوم النظام تلقائياً بإعادة تصنيف الأصناف حسب تحليل ABC-XYZ. دعونا نرى ذلك.

---

## STEP 4 / 8 — Classification ABC-XYZ | تصنيف ABC-XYZ
**⏱ 1:15** (3:45 → 5:00)

### Action
1. Depuis **Accueil**, cliquer sur `[ABC] Classement ABC` sous la section **ANALYSE**
2. Attendre le message *"Classification ABC-XYZ mise à jour"*
3. Aller à l'onglet **ARTICLES** — pointer la colonne **Classe ABC** (colonne F)
4. Montrer : ART-001 = **A**, certains en B, d'autres en C
5. Optionnel : Lancer `[FULL] Analyse Complète` pour montrer les analyses groupées
6. Pointer la feuille **FORECAST** (créée dynamiquement)

### Discours (Arabe)
> تصنيف ABC يوزع الأصناف حسب مبدأ باريتو: الفئة A تمثل 20% من الأصناف لكنها تستحوذ على 80% من القيمة المخزنية. هنا، حبر ART-001 من الفئة A — أي صنف استراتيجي يجب مراقبته يومياً. أما الفئة B فتراقب أسبوعياً، والفئة C شهرياً. هذا التصنيف يتغير ديناميكياً مع كل حركة، وهو ما يعجز عنه النظام اليدوي بالكامل.

### Métriques clés
- A : 20% des articles ≈ 80% de la valeur
- Classification dynamique (recalculée à chaque mouvement)
- 12 articles classés ABC-XYZ

### Backup plan
> إذا لم يعمل زر ABC: افتح `Alt+F8` → `mod_SyncBridge.SyncMetricsFromLedger`

### Transition
> الآن ننتقل إلى أهم مؤشرين كميين: كمية الطلب الاقتصادي ونقطة إعادة الطلب.

---

## STEP 5 / 8 — EOQ, ROP & SS | المؤشرات الكمية: ويلسون ونقطة إعادة الطلب
**⏱ 1:30** (5:00 → 6:30)

### Action
1. Aller à la feuille **ARTICLES**
2. Pointer la ligne ART-001
3. Afficher les colonnes de calcul (ou cliquer sur `[SYNC] Synchronisation` pour rafraîchir)
4. Expliquer en pointant :
   - **D = 1546** (demande annuelle extraite des mouvements réels)
   - **S = 801.45 DZD** (coût d'une commande)
   - **t = 20%** (taux de possession)
   - **PU** (prix unitaire) — le montrer dans la cellule
5. Pointer la cellule de **Q\*** → **176**
6. Pointer **ROP** → **212.4** (formule : demande quotidienne × délai + SS)
7. Pointer **SS** → **200**
8. Optionnel : cliquer sur `[CMUP] Rafraichir CMUP` pour montrer le calcul du coût moyen pondéré

### Discours (Arabe)
> هنا نرى قلب النظام — النماذج الكمية مطبقة على بيانات حقيقية. الطلب السنوي D = 1546 حُسب تلقائياً من سجل الحركات. تكلفة الطلب S = 801.45 دينار جزائري، ومعدل الحيازة 20%. بتطبيق معادلة ويلسون: الجذر التربيعي لـ (2 × 1546 × 801.45) ÷ (السعر × 0.2) = كمية اقتصادية 176 وحدة. نقطة إعادة الطلب ROP = (1546 ÷ 250) × 2 + 200 = 212.4. هذا يعني: عندما يصل المخزون إلى 213 وحدة، يصدر النظام تنبيهاً آلياً.

### Métriques clés
- **D = 1 546** unités/an (demande annuelle ART-001)
- **Q\* = 176** unités (EOQ — Wilson)
- **ROP = 212.4** unités
- **SS = 200** unités
- **LT = 2** jours
- **S = 801.45** DZD
- **I = 20%**

### Backup plan
> إذا كانت القيم فارغة: استخدم `Alt+F8` → `mod_SyncBridge.SyncMetricsFromLedger` لحساب كل المؤشرات

### Transition
> دعونا ننتقل إلى لوحة القيادة لرؤية المؤشرات الكلية في لمحة واحدة.

---

## STEP 6 / 8 — Tableau de Bord / Dashboard | لوحة القيادة
**⏱ 1:15** (6:30 → 7:45)

### Action
1. Depuis **Accueil**, cliquer sur `[DASHBOARD] Actualiser les KPIs`
2. Le message *"Tableau de bord actualisé"* apparaît
3. Aller à la feuille **DASHBOARD** (ou **ACCUEIL** si les KPIs y sont intégrés)
4. Pointer :
   - Total SKUs
   - Nombre d'articles en alerte (stock < ROP)
   - Stock total valorisé (DZD)
   - Dernière actualisation (timestamp)
5. Pointer le tableau **Articles Critiques** (Critical Items Table)
6. Pointer le résumé **ABC-XYZ**

### Discours (Arabe)
> لوحة القيادة تقدم صورة كلية عن وضع المخزون في لحظة واحدة. هنا نرى العدد الإجمالي للأصناف، عدد الأصناف في حالة تنبيه، والقيمة الإجمالية للمخزون. الأصناف الحرجة — التي وصلت أو تجاوزت نقطة إعادة الطلب — تظهر في جدول خاص مع توصية بالكمية المطلوب طلبها. كما يعرض ملخص ABC-XYZ التوزيع الحالي. كل هذه المؤشرات تُحدث آلياً عند كل حركة أو عند الضغط على زر التحديث.

### Métriques clés
- Total SKUs = 12
- Alertes en temps réel (stock < ROP)
- Valeur totale du stock en DZD
- ABC-XYZ Summary
- Timestamp de dernière actualisation

### Backup plan
> إذا لم تظهر لوحة القيادة: استخدم `Alt+F8` → `mod_Dashboard.RefreshDashboard`

### Transition
> بناءً على هذه المؤشرات، يمكن للنظام توليد أمر تموين آلي. دعونا نشاهد ذلك.

---

## STEP 7 / 8 — Bordereau de Commande / Order Report | أمر التموين الآلي
**⏱ 0:45** (7:45 → 8:30)

### Action
1. Depuis **Accueil**, cliquer sur `[ORDER] Rapport Approvisionnement` sous **RAPPORTS**
2. La feuille **BORDEREAU_COMMANDE** s'affiche ou se crée
3. Pointer :
   - En-tête : SKU, Désignation, Stock Actuel, Seuil ROP, Suggestion (EOQ), PU, Total Estimé
   - Ligne ART-001 : Stock = X, ROP = 212.4, Suggestion = 176, Total = 176 × PU
4. Mentionner que ce bordereau peut être exporté en PDF ou Excel

### Discours (Arabe)
> بناءً على الوضع الحالي، يقترح النظام أمر تموين آلي. لكل صنف تجاوز نقطة إعادة الطلب، يقترح النظام كمية مساوية لكمية ويلسون الاقتصادية — 176 للصنف ART-001. هذا يلغي تماماً التخمين البشري والتقدير الذاتي. يمكن تصدير هذا الأمر مباشرة إلى PDF أو Excel لتقديمه إلى مصلحة المشتريات.

### Métriques clés
- Suggestion EOQ = 176 unités (ART-001)
- Bordereau formaté et prêt à l'emploi
- Exportable en PDF / Excel

### Backup plan
> إذا لم يتم إنشاء BORDEREAU_COMMANDE: استخدم `Alt+F8` → `mod_Procurement.GenerateOrderReport`

### Transition
> نختم بما حققه النظام من نتائج ملموسة مقارنة بالتسيير اليدوي.

---

## STEP 8 / 8 — Résultats Clés & Conclusion | النتائج والخاتمة
**⏱ 0:30** (8:30 → 9:00)

### Action
1. Rester sur le bordereau ou revenir à l'**Accueil**
2. Montrer la synthèse (à préparer dans une cellule ou un commentaire) :
   - Temps de traitement : 20-30 min → **< 5 secondes** (99.7%)
   - Élimination des ruptures de stock pour les articles A
   - Validation : **174/174 modules**, **105/105 checks**
3. Conclure

### Discours (Arabe)
> هذه هي النتائج التي تؤكد صحة الفرضيتين:
> أولاً: وقت معالجة الطلبية انخفض من 20-30 دقيقة إلى أقل من 5 ثوانٍ — أي تحسن بنسبة 99.7%.
> ثانياً: نظام التنبيه الآلي عند نقطة إعادة الطلب ألغى جميع حالات النفاد للمواد الاستراتيجية.
> تم التحقق من سلامة النظام عبر 174 وحدة برمجية و 105 اختبارات — جميعها ناجحة.
> 
> الحل جاهز للتطبيق الفوري في مديرية التربية لولاية البيض، ويمكن تعميمه على باقي المديريات بتكلفة صفرية.
> شكراً على حسن إصغائكم. أنا جاهز للأسئلة.

### Métriques clés
- 99.7% réduction temps de traitement (20-30 min → < 5 sec)
- 0 ruptures de stock pour articles stratégiques
- 174/174 modules VBA valides
- 105/105 checks passés
- Coût : 0 DZD

### Transition
> — Fin de la démonstration. Prêt pour les questions —

---

## Résumé des boutons et macros utilisés

| Étape | Bouton (Accueil) | Macro VBA | Feuille |
|-------|-------------------|-----------|---------|
| 1 | — (ouverture) | `MAIN_MACROS.ShowMainMenu` | Accueil |
| 2 | Onglet ARTICLES | — | ARTICLES |
| 3 | `[ENTRY] Formulaire de Saisie` | `AjouterMouvement` / `OpenStockForm` | frmStockEntry |
| 4 | `[ABC] Classement ABC` | `mod_Analysis.UpdateABC_Classification` | ARTICLES |
| 5 | `[SYNC] Synchronisation` | `mod_SyncBridge.SyncMetricsFromLedger` | ARTICLES |
| 6 | `[DASHBOARD] Actualiser les KPIs` | `mod_Dashboard.RefreshDashboard` | Accueil / DASHBOARD |
| 7 | `[ORDER] Rapport Approvisionnement` | `mod_Procurement.GenerateOrderReport` | BORDEREAU_COMMANDE |
| 8 | — (récapitulatif) | — | Accueil |

## Plan B Global (en cas de panne majeure)
1. **Redémarrer Excel** → Ouvrir le fichier → Activer les macros
2. Si les macros sont bloquées : `Fichier > Options > Centre de gestion de la confidentialité > Paramètres > Activer toutes les macros`
3. Si un bouton ne répond pas : `Alt+F8` → sélectionner la macro manuellement
4. Si les données sont corrompues : `Alt+F8` → `mod_DemoData.GenerateDemoData` pour regénérer les données de démonstration
5. **Dernier recours :** Ouvrir `GOLDEN_ERP_v13.2.xlsm` ou `ARCHIVE_LEGACY_Copy_of_ERP_v13.2.xlsm` (copies de sauvegarde)
