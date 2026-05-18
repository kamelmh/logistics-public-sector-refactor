# CHANGELOG — Academix v13.2

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed
- Replaced hardcoded ERP path in `system-health-test.ps1` with relative path
- Added missing `.gitignore` patterns (`.env`, `*password*`, `*secret*`, `node_modules/`, `__pycache__/`, `.venv/`)
- Updated stale model references: DeepSeek V4 Flash → Gemini 2.5 Flash
- Deprecated free-claude-code proxy reference in MASTER_BOOTSTRAP.xml
- Removed 3 orphaned `.bak` files

### Added
- GitHub Actions CI/CD pipeline (`.github/workflows/ci.yml`)
- Automated workbook backup script (`scripts/backup-workbook.ps1`)
- Daily health check script (`scripts/daily-health-check.ps1`)
- Symlink hub with 75 links in `links/`
- 211 skills linked across 4 ecosystems

### Changed
- Untracked 7 large embedded repos from git (ruflo, MiniCPM-V, oracle-ai-developer-hub, opencode_updates, mempalace, Auto-claude-code-research-in-sleep, cocoindex_exploration)

---

## [v13.2-FINAL] — 2026-05-17

### Added
- Project AGENTS.md and instructions.md from global config
- Pipeline scripts restored and merged
- Research paper, executive summary, and academic sign-off
- WindsurfAPI modes and expanded fallback chains
- FreeLLM gateway with 4 provider keys activated
- Completions.me integration (26 models)
- Engineering harness infrastructure
- Portable launchers with `%~dp0` paths

### Fixed
- Thesis pipeline — Word COM leak fixed, Vollmann false positive resolved (34/34 → 36/36 PASS)
- Thesis footnote mandatory fixes — 8 CNEPD footnotes
- Working directory on launch, fixed paths, added opicker
- Protected all 26 sheets via VBA FinalizeBuildProtection macro
- VBA syntax errors and error handlers
- ACCUEIL sheet integration
- Moved `.ps1` scripts to `scripts/` directory
- Secured API keys

### Changed
- Replaced deprecated Llama 3.3 70B with Gemini 2.5 Flash
- Optimized model selection and enforced redirections
- Consolidated launchers and updated documentation
- Expanded AI model stack and harmonized ground truth
- Polished thesis Chapter 1
- Compressed mode dispatch into variable lists
- Added Gemma 4 e2b to launcher

### Removed
- Added WindsurfAPI/ to `.gitignore`
- Cleaned up loose test files and archives
- Removed stale thesis binaries

---

## [thesis/v2-clean] — 2026-05-16

### Fixed
- Thesis pipeline Word COM memory leak
- Vollmann false positive in verification

---

## [thesis/v1-golden] — 2026-05-15

### Added
- Thesis golden baseline established
- Pipeline fixes for build and verify

---

## [Initial] — 2026-05-14

### Added
- ERP v13.2 core system (37 .bas + 1 .frm modules)
- 25 Excel sheets with French headers
- Thesis: 4 chapters, 16 مباحث, 52 مطالب
- Ground truth parameters: D=1546, Q*=176, ROP=205.6, SS=200, LT=2 days, S=801.45 DZD, I=20%
- Build pipeline: build.ps1, verify.ps1, test-macros.ps1, dss-audit.ps1
- CrossFlow multi-window orchestration
- OpenCode portable launcher with 23 modes
