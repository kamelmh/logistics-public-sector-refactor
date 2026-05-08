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
| `04_Systeme_Academix_v13_2/` | Fichier Excel fonctionnel — الملف التنفيذي |
| `05_Sources_VBA/` | Code source VBA (28 modules) — الكود المصدري |
| `06_Documents_Support/` | Documents de référence — وثائق الدعم |

## 01_Memoire_Final/
| Fichier | Description |
|---------|-------------|
| `Memoire_Academix_v13_2_Final.pdf` | **Version finale** — Thèse complète (799 KB) |
| `Memoire_Academix_v13_2_Final.docx` | Version DOCX modifiable |
| `Memoire_Academix_v13_1_*.pdf` | Versions précédentes (archive) |

## 04_Systeme_Academix_v13_2/
| Fichier | Description |
|---------|-------------|
| `ERP_v13.2.xlsm` | **Fichier principal** — 25 feuilles, 28 modules VBA, protégé |
| Mot de passe | `erp_secure_pwd_2026` |

## 05_Sources_VBA/
| Module | Fonction |
|--------|----------|
| `mod_Config.bas` | Configuration et constantes |
| `mod_StockEngine.bas` | Moteur de calcul des stocks |
| `mod_StockEntry_Logic.bas` | Logique de saisie des mouvements |
| `mod_Dashboard.bas` | Tableau de bord et KPIs |
| `mod_Analysis.bas` | Analyses EOQ, ABC-XYZ |
| `mod_Procurement.bas` | Génération des documents DA/BC |
| `mod_ReceiptTag.bas` | Tags de réception avec code de vérification |
| `mod_AuditTrail.bas` | Journal d'audit (append-only) |
| ... + 19 autres modules | Voir `VBA_DESIGN_SPEC.md` |

## Caractéristiques Techniques / المواصفات التقنية

- **Architecture:** Pure VBA / Excel — zéro dépendance externe
- **Fonctionnement:** 100% hors ligne (Offline-First)
- **Coût:** Zéro (utilise Office existant)
- **Feuilles:** 25 (ACCUEIL, ARTICLES, MOUVEMENTS, etc.)
- **Modules VBA:** 28 (importés, 0 erreur de compilation)
- **Protection:** Mots de passe sur toutes les feuilles
- **Conformité:** CNEPD TAG1801, Décret 20-270, SCO

## Constantes Validées / الثوابت المعتمدة

| Constante | Valeur |
|-----------|--------|
| Demande Annuelle (D) | 1,546 unités |
| Point de Réapprovisionnement (ROP) | 205.6 unités |
| Stock de Sécurité (SS) | 200 unités |
| Quantité Économique (Q*) | 176 unités |
| Délai de Livraison (LT) | 2 jours |
| Taux de Possession (I) | 20% (CNEPD) |
