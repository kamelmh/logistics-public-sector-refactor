# Contributing to Academix v13.2

Thank you for contributing to this project. This is a VBA/Excel Decision Support System for logistics inventory management in the Algerian public education sector.

## Ground Rules

1. **Pure VBA only** — No Python, no Flask, no databases, no XLOOKUP (Excel 2010 compatibility)
2. **Fix `.bas` sources, not `.xlsm`** — The workbook is rebuilt from source files; editing `.xlsm` directly creates stale p-code cache
3. **French headers stay in French** — Column headers and tab names must remain in French
4. **No XLOOKUP** — Use INDEX/MATCH for Excel 2010 compatibility
5. **UTF-8 em dashes → hyphens** — Em dashes (—) cause VBA syntax errors

## Development Workflow

### 1. Clone & Setup
```powershell
git clone https://github.com/kamelmh/logistics-public-sector-refactor.git
cd logistics-public-sector-refactor
```

### 2. Make Changes
Edit `.bas` files in `Software_Surgical_Edit/VBA_Modules/`

### 3. Build
```powershell
.\vbe-auto\build.ps1 -ConfigPath vbe-auto\config.json
```

### 4. Verify (137 checks)
```powershell
.\vbe-auto\verify.ps1 -ConfigPath vbe-auto\config.json
```

### 5. Test Macros
```powershell
.\Software_Surgical_Edit\test-macros.ps1
```

### 6. Audit (5-phase DSS)
```powershell
.\milestone_13_2\tests\dss-audit.ps1
```

## Git Workflow

### Branch Naming
- `feat/description` — New features
- `fix/description` — Bug fixes
- `docs/description` — Documentation
- `refactor/description` — Code improvements

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
type: description

feat: add stock reorder point calculation
fix: resolve UTF-8 em dash syntax error
docs: update build instructions
```

### Pull Requests
- Reference related issues
- Include build/verify output
- Describe testing performed

## Code Style

### VBA Conventions
- `mod_` prefix for modules
- `frm_` prefix for forms
- `cls_` prefix for classes
- `Public Const` before procedures
- `Property Get` for cross-module constants

### Naming
Follow A/HC/LC pattern: `{prefix}{action}{context}`
- `CalculateStockLevel` (action + context)
- `IsValidArticleCode` (question prefix + context)
- `GetReorderPoint` (get prefix + context)

## Testing

### Before Submitting
- [ ] Build passes: `build.ps1` (174/174)
- [ ] Verify passes: `verify.ps1` (137/137)
- [ ] Tests pass: `test-macros.ps1` (20/20)
- [ ] Audit passes: `dss-audit.ps1` (16/16)

### Performance Baseline
Run benchmarks to detect regressions:
```powershell
.\scripts\benchmark.ps1
```

## Security

- Never commit API keys or passwords
- Use environment variables for secrets
- Run `.\scripts\lock-api-keys.ps1` before committing
- Review `.gitignore` coverage

## Contact

For questions, open an issue or reach out to the project maintainer.
