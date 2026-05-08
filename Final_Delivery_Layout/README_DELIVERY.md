# Academix v13.2 — Package de Livraison Finale
# نظام دعم القرار لتسيير المخزون — حزمة التسليم النهائية

**Institution:** Direction de l'Éducation, El Bayadh (مديرية التربية — ولاية البيض)
**Auteur:** Mahi Kamel Abdelghani (ماحي كمال عبد الغني)
**Superviseur:** Dehini Maimouna (دهيني ميمونة)
**Version:** v13.2 | **Date:** 2026-05-06
**Certification:** BTS Gestion des Stocks et Logistique — CNEPD TAG1801

---

## Structure du Package / هيكل الحزمة

| Dossier | Contenu |
|---------|---------|
| `01_Memoire_Final/` | Thèse finale (PDF + DOCX) — Mémoire de fin d'études |
| `02_Systeme_Academix_v13_1/` | Version précédente (archive) |
| `03_Documents_Generes_Exemples/` | Exemples de documents générés |
| `04_Systeme_Academix_v13_2/` | Fichier Excel fonctionnel — الملف التنفيذي |
| `05_Sources_VBA/` | Code source VBA (32 modules) — الكود المصدري |
| `06_Documents_Support/` | Documents de référence — وثائق الدعم |
| `07_Presentation_Defense/` | Présentation PPTX + guide Q&A |
| `08_Support_Documents/` | Manuel utilisateur (Arabic) |

## 01_Memoire_Final/
| Fichier | Description |
|---------|-------------|
| `Memoire_Academix_v13_2_Final.pdf` | **Version finale** — Thèse complète (69 pages, 34 tableaux) |
| `Memoire_Academix_v13_2_Final.docx` | Version DOCX modifiable (TOC auto-généré) |

## 04_Systeme_Academix_v13_2/
| Fichier | Description |
|---------|-------------|
| `ERP_v13.2.xlsm` | **Fichier principal** — 26 feuilles, 32+ modules VBA |
| Mot de passe | `erp_secure_pwd_2026` |

## 05_Sources_VBA/
| Module | Fonction |
|--------|----------|
| `mod_Config.bas` | Configuration et constantes |
| `mod_StockEngine.bas` | Moteur de calcul des stocks |
| `mod_StockEntry_Logic.bas` | Logique de saisie (BS/BR/BC/DA) |
| `mod_ExportEngine.bas` | Export PDF avec TVA + 4 signatures + QR |
| `mod_QRCode.bas` | Génération QR code (API + fallback offline) |
| `mod_ReceiptTag.bas` | Tags de réception avec code de vérification |
| `mod_Budget.bas` | Gestion budgétaire (623xxx codes) |
| `mod_BudgetSetup.bas` | Initialisation feuille BUDGET |
| `mod_ApprovalWorkflow.bas` | Workflow 3 niveaux (Magasinier → Comptable → Directeur) |
| `mod_Dashboard.bas` | Tableau de bord et KPIs |
| `mod_Analysis.bas` | Analyses EOQ, ABC-XYZ |
| `mod_Procurement.bas` | Génération des documents DA/BC |
| `mod_AuditTrail.bas` | Journal d'audit (append-only) |
| ... + 20 autres modules | Voir liste complète dans le dossier |

## Nouveautés v13.2 (Depuis v13.1)

### Conformité Secteur Public Algérien
| Fonctionnalité | Statut |
|----------------|--------|
| TVA non applicable (Instruction 09-2018) | ✅ Implémenté |
| 4 blocs de signature (Fournisseur, Comptable, Responsable, Directeur) | ✅ Implémenté |
| Multi-copie (ORIGINAL / COPIE / ARCHIVE) | ✅ Implémenté |
| Ligne Engagement/Liquidation/Code Budgétaire | ✅ Implémenté |
| Code de vérification sur chaque document (V-XXXX-XXXX-XXXX) | ✅ Implémenté |
| QR code avec fallback offline | ✅ Implémenté |
| Feuille BUDGET avec 12 articles + codes 623xxx | ✅ Implémenté |
| Préfixe BC (Bon de Commande) dans GetDocPrefix() | ✅ Ajouté |
| Chemin de sauvegarde PDF via FileDialog | ✅ Implémenté |

## Caractéristiques Techniques / المواصفات التقنية

- **Architecture:** Pure VBA / Excel — zéro dépendance externe
- **Fonctionnement:** 100% hors ligne (Offline-First, QR fallback inclus)
- **Coût:** Zéro (utilise Office existant)
- **Feuilles:** 26 (ACCUEIL, ARTICLES, MOUVEMENTS, BUDGET, etc.)
- **Modules VBA:** 32+ (importés, 0 erreur de compilation)
- **Protection:** Mots de passe sur toutes les feuilles
- **Conformité:** CNEPD TAG1801, Décret 20-270, SCO, Instruction 09-2018

## Constantes Validées / الثوابت المعتمدة

| Constante | Valeur |
|-----------|--------|
| Demande Annuelle (D) | 1,546 unités |
| Point de Réapprovisionnement (ROP) | 205.6 unités |
| Stock de Sécurité (SS) | 200 unités |
| Quantité Économique (Q*) | 176 unités |
| Délai de Livraison (LT) | 2 jours |
| Taux de Possession (I) | 20% (CNEPD) |

## Documents de Support / وثائق الدعم

| Document | Description |
|----------|-------------|
| `DEFENSE_QA_GUIDE.md` | Guide Q&A pour la soutenance (8 questions) |
| `Defense_Slides_Marp.md` | Source Marp pour les diapositives |
| `Defense_Academix_v13_2.pptx` | Présentation de soutenance (16 diapositives) |
| `USER_MANUAL_AR.md` | Manuel utilisateur en arabe (magasinier) |
