"""
Pipeline v12 (Final): Fresh pandoc build + fix scripts + Word COM.

ROOT CAUSE FINDINGS:
1. Golden source text replacement destroys TOC/PAGEREF fields via para.text
2. python-docx save() is actually SAFE - preserves fields
3. Paragraph alignment in golden source is fragile due to spacer paragraphs

SOLUTION: Build fresh from pandoc with --toc, apply fixes, run Word COM.
"""
import subprocess
import shutil
from pathlib import Path
import os

PROJECT = Path(r"C:\Users\Admin\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit")
MD_FILE = PROJECT / "Memoire_DSS_Logistique_ElBayadh.md"
OUTPUT_DIR = PROJECT / "output"
STYLE_DIR = PROJECT / "style"
OUTPUT = OUTPUT_DIR / "Memoire_DSS_Logistique_ElBayadh.docx"
VENV_PYTHON = r"C:\Users\Admin\AppData\Local\Temp\thesis-venv\Scripts\python.exe"


def run_python(script_path: str, args: str = "") -> tuple[int, str]:
    """Run a Python script with the venv interpreter."""
    cmd = f'"{VENV_PYTHON}" "{script_path}" {args}'
    result = subprocess.run(cmd, capture_output=True, text=True, shell=True, timeout=120)
    return result.returncode, (result.stdout + result.stderr)


def test_word_com(docx_path: str) -> bool:
    """Test if Word COM can open the document."""
    ps = (
        '$w = New-Object -ComObject Word.Application; $w.Visible = $false; '
        f'try {{ $d = $w.Documents.Open("{docx_path}", $false); $d.Close(0); '
        'Write-Host OK } catch { Write-Host FAIL } finally { $w.Quit() }'
    )
    r = subprocess.run(['powershell', '-Command', ps], capture_output=True, text=True, timeout=30)
    return 'OK' in r.stdout


def run_pipeline():
    print("=" * 65)
    print("  ACADEMIX v13.4 - Pipeline v12 (Fresh Pandoc + Fixes + COM)")
    print("=" * 65)

    # Step 1: Fresh pandoc build
    print("\n== Step 1: Pandoc Build (with --toc) ==")
    pandoc_tmp = OUTPUT_DIR / "_pandoc_tmp.docx"
    cmd = [
        'pandoc', str(MD_FILE), '-o', str(pandoc_tmp),
        '--from', 'markdown+smart',
        '--to', 'docx',
        '--toc'
    ]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        print(f"  PANDOC FAILED: {r.stderr[:200]}")
        return False
    size_kb = pandoc_tmp.stat().st_size / 1024
    print(f"  {size_kb:.0f} KB - OK")

    # Step 2: fix_docx_sections.py
    print("\n== Step 2: fix_docx_sections.py ==")
    code, out = run_python(str(STYLE_DIR / "fix_docx_sections.py"), f'"{pandoc_tmp}" --save')
    for line in out.split('\n'):
        line = line.strip()
        if line and ('section' in line.lower() or 'pgNum' in line or 'A4' in line or 'Saved' in line or 'margin' in line):
            print(f"  {line}")

    # Step 3: fix_thesis_all.py
    print("\n== Step 3: fix_thesis_all.py ==")
    code, out = run_python(str(STYLE_DIR / "fix_thesis_all.py"), f'"{pandoc_tmp}" --save')
    for line in out.split('\n'):
        line = line.strip()
        if any(k in line for k in ['para_rtl', 'fn_rtl', 'run_rtl', 'styles_updated',
                                     'footer_injected', 'File size', 'compat_fixes']):
            print(f"  {line}")

    # Step 4: Copy to output
    print("\n== Step 4: Copy to Output ==")
    shutil.copy2(pandoc_tmp, OUTPUT)
    pandoc_tmp.unlink(missing_ok=True)
    print(f"  {OUTPUT.name}: {OUTPUT.stat().st_size / 1024:.1f} KB")

    # Step 5: Word COM field update
    print("\n== Step 5: Word COM Field Update ==")
    code, out = run_python(str(STYLE_DIR / "update_fields.py"), f'"{OUTPUT}" --save-only')
    for line in out.split('\n'):
        line = line.strip()
        if line and ('FIELDS' in line or 'SAVED' in line or 'TOC' in line or 'body fields' in line.lower()):
            print(f"  {line}")

    # Step 6: Word COM automation (logos, TOC refresh)
    print("\n== Step 6: Word COM Automation (logos/TOC) ==")
    logo1 = str(STYLE_DIR / "logo1.png")
    logo2 = str(STYLE_DIR / "logo2.png")
    if not os.path.exists(logo1): logo1 = ""
    if not os.path.exists(logo2): logo2 = ""
    code, out = run_python(str(STYLE_DIR / "word_automation.py"), f'"{OUTPUT}" "{logo1}" "{logo2}"')
    for line in out.split('\n'):
        line = line.strip()
        if line and ('WORD-AUTO' in line or 'TOC' in line or 'Logo' in line or 'done' in line.lower()):
            print(f"  {line}")

    # Step 7: Post-COM polish
    print("\n== Step 7: Post-COM Polish ==")
    code, out = run_python(str(STYLE_DIR / "surgical_polish.py"), f'"{OUTPUT}" --save')
    code, out = run_python(str(STYLE_DIR / "fix_thesis_all.py"), f'"{OUTPUT}" --save')
    print(f"  fix_thesis_all post-COM: exit={code}")
    code, out = run_python(str(STYLE_DIR / "fix_docx_sections.py"), f'"{OUTPUT}" --save')
    print(f"  fix_docx_sections post-COM: exit={code}")

    # Step 8: Verification
    print("\n== Step 8: Verification ==")
    code, out = run_python(str(STYLE_DIR / "verify_docx_checks.py"),
                           f'"{OUTPUT}" --size-threshold 50000')
    for line in out.split('\n'):
        if line.strip() and ('PASS' in line or 'FAIL' in line or 'Summary' in line):
            print(f"  {line.strip()}")

    # Step 9: Word COM open test
    print("\n== Step 9: Word COM Test ==")
    com_ok = test_word_com(str(OUTPUT))
    print(f"  {'OK - Word COM opens' if com_ok else 'FAIL - Word COM cannot open'}")

    print("\n" + "=" * 65)
    print(f"  FINAL: {OUTPUT.stat().st_size / 1024:.1f} KB | Word COM: {com_ok}")
    print("=" * 65)
    return True


if __name__ == "__main__":
    success = run_pipeline()
    exit(0 if success else 1)
