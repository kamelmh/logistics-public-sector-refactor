# /thesis — Run the Thesis Build Pipeline

Build, fix, verify, and report on the Arabic thesis DOCX via `run-thesis-pipeline.ps1`.

## Description
5-phase comprehensive orchestrator for the Academix thesis DOCX. Handles source prep → section fixes → comprehensive fix (9 steps) → verification (29 checks) → reporting.

Pipeline phases:
- **Phase 0**: Environment check (tools, golden source, scripts)
- **Phase 1**: Source prep (copy golden or build from MD via pandoc)
- **Phase 2**: Section fixes (`fix_docx_sections.py`)
- **Phase 3**: Comprehensive fixes (`fix_thesis_all.py` — 9 steps, namespace+PAGE last)
- **Phase 4**: Verification (audit + verify 29/29 + sync + measure)
- **Phase 5**: Report (JSON + TXT)

## Usage
```
/thesis                    # Full pipeline (all 5 phases)
/thesis verify             # Verify only (phase 4)
/thesis build              # Build + fix only (phases 0-3)
/thesis report             # Report only (phase 5)
```

## Exit codes
- 0: All phases passed
- 1: One or more phases failed

## Dependencies
- Python 3.x (fix_thesis_all.py, verify_docx_checks.py, etc.)
- pandoc (optional — for building from MD)
- PowerShell 7+

## Golden source
`Desktop\Memoire_DSS_Logistique_ElBayadh_v2.docx` — clean namespace reference.

## Ground truth (thesis values)
- D=789, Q*=37, ROP=206, SS=200, S=801.45, PU=4500, I=20%
