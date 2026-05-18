# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| v13.2   | ✅ Yes    |
| < 13.2  | ❌ No     |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please:

1. **Do NOT** open a public issue
2. Contact the maintainer directly
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices

### Workbook Protection
- All 26 sheets are password-protected
- VBA project is locked with a master password
- Transaction safety macros prevent data corruption

### API Key Management
- API keys are stored in environment variables, not in code
- Run `.\scripts\lock-api-keys.ps1` to secure keys before committing
- `.gitignore` excludes `.env` files and key-containing directories

### Data Integrity
- Rebuild workbook from `.bas` sources (never edit `.xlsm` directly)
- Automated backups with versioned snapshots (`.\scripts\backup-workbook.ps1`)
- 137-point verification ensures workbook integrity after every build

### Access Control
- Workbook protection prevents unauthorized formula changes
- Sheet-level permissions restrict editing to authorized ranges
- VBA project locking prevents code inspection/modification

## Known Security Considerations

| Area | Status | Notes |
|------|--------|-------|
| VBA Project Password | ✅ Protected | Master password required |
| Sheet Protection | ✅ Protected | All 26 sheets locked |
| API Keys | ✅ Secured | Environment variables only |
| Git Secrets | ✅ Clean | No secrets in git history |
| Backup Integrity | ✅ Verified | Hash-checked backups |

## Automated Security

- **CI/CD Pipeline**: GitHub Actions validates critical files and script syntax
- **Daily Health Check**: Scheduled task runs system verification at 09:00
- **Backup Schedule**: Daily workbook backup with version retention

## Audit Trail

All changes are tracked via git. Use `git log` to review modification history:
```powershell
git log --oneline --since="2026-01-01"
```
