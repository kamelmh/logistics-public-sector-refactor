# 🌉 Global Bridge Manifest
> **Purpose:** Mapping the Global `.claude\skills` library to Academix v13.2 specific needs.
> **Protocol:** When a high-level generic skill is needed, resolve via the Global Path.

## 🎯 High-Priority Global Mappings

| Global Skill | Project Use Case | Priority |
| :--- | :--- | :--- |
| `security-audit` | Final DSS Security Verification | CRITICAL |
| `sql-query-generation` | Ledger $\rightarrow$ SQL translation for reporting | HIGH |
| `refactoring` | Optimizing `mod_StockEngine` logic | HIGH |
| `technical-writing` | Polishing the User Guide | MEDIUM |
| `proofreading` | Final Thesis Arabic/French check | MEDIUM |
| `testing` | Unit test generation for new VBA functions | MEDIUM |
| `data-analysis` | Validating 38-day observation history | MEDIUM |

## 🚀 Access Protocol
To use a global skill:
1. Resolve path via `erp-admin-paths.xml` $\rightarrow$ `global-skills`.
2. Load the `SKILL.md` from the corresponding global folder.
3. Merge with local `L1 Drivers` for project-specific context.

---
*Bridged by Jem | System Intelligence Layer*
