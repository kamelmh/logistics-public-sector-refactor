# Support

## Getting Help

### Documentation
Start here:
- `README.md` — Project overview
- `Thesis_Surgical_Edit/submission/SUBMISSION_GUIDE.md` — Thesis guide
- `vbe-auto/pipeline-full.ps1` — Full pipeline reference
- `tools/gh-models.ps1 env` — GitHub Models status

### Issues
Open a GitHub issue using the templates:
- **Bug report**: For problems with the ERP, thesis, or tooling
- **Feature request**: For suggestions and improvements

### Local Testing
```powershell
# Run pre-build validation (no Excel needed)
python vbe-auto/vba-check.py

# Full pipeline (requires Excel)
& "vbe-auto\pipeline-full.ps1" -ContinueOnError

# Quick health check
python vbe-auto/vba-check.py && & "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"
```

### Author
**Mahi Kamel Abdelghani**  
Direction de l'Education, Wilaya de El Bayadh, Algeria
