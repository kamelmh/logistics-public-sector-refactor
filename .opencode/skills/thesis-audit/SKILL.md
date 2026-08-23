---
name: thesis-audit
description: Audit thesis content — ground truth, formatting, academic standards
level: 2
---

# Thesis Audit Skill

Use this skill when auditing the thesis for accuracy, formatting, and academic standards.

## Ground Truth (LOCKED — Never Modify)
- D = 33 units/yr (Annual demand)
- Q* = 15 units (Wilson EOQ)
- ROP = 201 units (Reorder Point)
- SS = 200 units (Safety Stock)
- LT = 7 days (Lead Time, avg 5-10 days per annex)
- S = 801.45 DZD (Order Cost)
- PU = 1,200 DZD (Unit Price)
- I = 20% (Holding Rate)
- Master Password: erp_secure_pwd_2026

## Audit Commands

```powershell
# Full audit (comprehensive)
python Thesis_Surgical_Edit\style\audit_thesis_comprehensive.py Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx

# Verify checks (36 checks)
python Thesis_Surgical_Edit\style\verify_docx_checks.py Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx

# Inspect metrics
python Thesis_Surgical_Edit\style\inspect_docx_metrics.py Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh.docx
```

## Checklist
1. Ground truth accuracy — all constants match locked values
2. Arabic MSA — correct grammar, no dialect
3. RTL formatting — proper right-to-left alignment
4. Footnotes — CNEPD format (Author, Title, Publisher, Year, Page)
5. Tables — alignment, captions, numbering
6. Page numbers — continuous decimal from cover
7. References — all cited works in bibliography
