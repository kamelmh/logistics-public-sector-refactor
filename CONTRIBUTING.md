# Contributing to Academix DSS

Thank you for your interest in contributing to Academix DSS v13.4!

## Development Setup

### Prerequisites
- Windows with Excel 2010+ (for ERP builds)
- Python 3.x (for verification scripts)
- PowerShell (for build scripts)
- Git

### Getting Started
1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run verification: `& "vbe-auto\verify.ps1"`
6. Commit with conventional format: `feat:`, `fix:`, `docs:`
7. Push and create a Pull Request

## Code Standards

### VBA
- All edits in `.bas` source files â€” never edit `.xlsm` directly
- Follow existing naming conventions
- Add comments for complex logic
- Run `vbe-auto\verify.ps1` before committing

### Python
- Use `snake_case` for variables and functions
- Type hints for all functions
- Black formatter for formatting
- pytest for testing

### Git Commits
```
feat: add new feature
fix: fix a bug
docs: update documentation
refactor: refactor code
test: add tests
chore: maintenance tasks
```

## Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all verification checks pass
4. Request review from maintainer
5. Merge after approval

## Reporting Issues

- Use GitHub Issues for bug reports
- Include steps to reproduce
- Include expected vs actual behavior
- Add screenshots if applicable

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
