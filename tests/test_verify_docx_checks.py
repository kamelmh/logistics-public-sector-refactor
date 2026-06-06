import subprocess
import sys
import os

def test_verify_docx_checks():
    # Run the verification script on the main thesis DOCX.
    # The script exits with code 0 when all checks pass.
    result = subprocess.run([
        sys.executable,                     # Use the current Python interpreter
        'Thesis_Surgical_Edit/style/verify_docx_checks.py',
        'Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx'
    ], cwd=os.path.abspath('.'), capture_output=True, text=True)

    # If the script fails, capture_output will contain the error details.
    assert result.returncode == 0, f'Verification script failed:\\n{result.stderr}'