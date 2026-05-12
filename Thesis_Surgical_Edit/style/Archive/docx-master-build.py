"""docx-master-build.py -- Academix v13.2
One-command orchestrator: MD → fully formatted DOCX.
Chains pandoc → style-fix → style-apply → format-tables → format-cover.
Usage:
  python docx-master-build.py --source <thesis.md> [--output <name>] [--no-pdf]
"""

import sys, os, subprocess, argparse, shutil, json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STYLE_DIR = ROOT / "style"
OUT_DIR = ROOT / "output"
SOURCE_DEFAULT = ROOT / "Memoire_DSS_Logistique_ElBayadh.md"
COVER_DOCX = ROOT / "cover-page.docx"

# Tool paths
PANDOC = shutil.which("pandoc")
PYTHON = sys.executable

TOOLS = {
    "style-fix": STYLE_DIR / "docx-style-fix.py",
    "style-apply": STYLE_DIR / "docx-style-apply.py",
    "format-tables": STYLE_DIR / "format-tables.py",
    "format-cover": STYLE_DIR / "format-cover.py",
    "analyze": STYLE_DIR / "docx-analyze.py",
    "customize-ref": STYLE_DIR / "customize-reference.py",
    "ref-docx": STYLE_DIR / "reference.docx",
    "ref-in": STYLE_DIR / "reference-in.docx",
    "meta": STYLE_DIR / "thesis-metadata.yaml",
}


def step(msg):
    print()
    print("=" * 60)
    print(f"  [{msg}]")
    print("=" * 60)


def run(cmd, desc):
    print(f"  Running: {desc}")
    print(f"  $ {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  [ERROR] {desc} failed:")
        print(result.stderr)
        sys.exit(1)
    for line in result.stdout.strip().split("\n"):
        if line.strip():
            print(f"  {line.strip()}")
    return result.stdout


def build_pipeline(source_md, output_name, skip_pdf=False):
    source_md = Path(source_md).resolve()
    output_name = output_name or source_md.stem.replace("Final_Thesis_", "Memoire_")

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    docx_path = OUT_DIR / f"{output_name}.docx"
    pdf_path = OUT_DIR / f"{output_name}.pdf"

    print()
    print("=" * 60)
    print("  ACADEMIX v13.2 — MASTER DOCX BUILDER")
    print("=" * 60)
    print(f"  Source:      {source_md.name}")
    print(f"  Output DOCX: {docx_path}")
    print(f"  Output PDF:  {pdf_path if not skip_pdf else '(skipped)'}")
    print()

    # Step 1: Build reference template
    if not TOOLS["ref-docx"].exists():
        step("1/7: Building reference template")
        run(f'"{PYTHON}" "{TOOLS["customize-ref"]}"', "customize-reference.py")

    # Step 2: Pandoc MD -> DOCX
    step("2/7: Pandoc MD → DOCX")
    pandoc_args = (
        f'"{PANDOC}" "{source_md}" '
        f'--from markdown+grid_tables-yaml_metadata_block '
        f'--to docx '
        f'--reference-doc "{TOOLS["ref-docx"]}" '
        f'--metadata-file "{TOOLS["meta"]}" '
        f'--output "{docx_path}" '
        f'--resource-path "{ROOT / "images"};{ROOT}" '
        f'--wrap preserve --eol lf'
    )
    run(pandoc_args, "pandoc")

    # Step 3: Style fix
    step("3/7: Fixing styles")
    run(f'"{PYTHON}" "{TOOLS["style-fix"]}" "{docx_path}"', "docx-style-fix.py")

    # Step 4: Apply heading styles
    step("4/7: Applying heading styles")
    run(f'"{PYTHON}" "{TOOLS["style-apply"]}" "{docx_path}"', "docx-style-apply.py")

    # Step 5: Format tables
    step("5/7: Formatting tables")
    run(f'"{PYTHON}" "{TOOLS["format-tables"]}" "{docx_path}"', "format-tables.py")

    # Step 6: Format cover
    step("6/7: Formatting cover")
    run(f'"{PYTHON}" "{TOOLS["format-cover"]}" "{docx_path}"', "format-cover.py")

    # Step 7: Optional PDF via Word COM
    if not skip_pdf:
        step("7/7: Generating PDF via Word")
        print("  Activating Word COM...")
        try:
            import win32com.client
            word = win32com.client.Dispatch("Word.Application")
            word.Visible = False
            word.DisplayAlerts = 0
            wdDoc = word.Documents.Open(str(docx_path))
            wdDoc.SaveAs2(str(pdf_path), 17)
            wdDoc.Close()
            word.Quit()
            pdf_size = os.path.getsize(pdf_path)
            print(f"  PDF: {pdf_size // 1024} KB")
        except Exception as e:
            print(f"  [WARN] PDF via Word failed: {e}")
            print(f"  Open {docx_path} in Word and save as PDF manually.")

    # Summary
    docx_size = os.path.getsize(docx_path)
    print()
    print("=" * 60)
    print("  BUILD COMPLETE")
    print("=" * 60)
    print(f"  DOCX: {docx_path} ({docx_size // 1024} KB)")
    if not skip_pdf and pdf_path.exists():
        print(f"  PDF:  {pdf_path} ({os.path.getsize(pdf_path) // 1024} KB)")

    # Validate
    step("Post-build analysis")
    run(f'"{PYTHON}" "{TOOLS["analyze"]}" "{docx_path}"', "docx-analyze.py")

    return docx_path


def main():
    parser = argparse.ArgumentParser(description="Academix v13.2 — Master DOCX Builder")
    parser.add_argument("--source", default=str(SOURCE_DEFAULT),
                        help="Source markdown file")
    parser.add_argument("--output", default=None,
                        help="Output name (without extension)")
    parser.add_argument("--no-pdf", action="store_true",
                        help="Skip PDF generation")
    parser.add_argument("--from-docx", default=None,
                        help="Skip MD → DOCX, work on existing DOCX instead")

    args = parser.parse_args()

    if not PANDOC:
        print("[ERROR] pandoc not found in PATH. Install pandoc first.")
        print("  https://pandoc.org/installing.html")
        sys.exit(1)

    if args.from_docx:
        # Work on existing DOCX (style-fix + style-apply only)
        docx_path = Path(args.from_docx).resolve()
        if not docx_path.exists():
            print(f"[ERROR] DOCX not found: {docx_path}")
            sys.exit(1)
        print(f"Working on existing DOCX: {docx_path}")
        step("1/3: Fixing styles")
        run(f'"{PYTHON}" "{TOOLS["style-fix"]}" "{docx_path}"', "docx-style-fix.py")
        step("2/3: Applying heading styles")
        run(f'"{PYTHON}" "{TOOLS["style-apply"]}" "{docx_path}"', "docx-style-apply.py")
        step("3/3: Analysis")
        run(f'"{PYTHON}" "{TOOLS["analyze"]}" "{docx_path}"', "docx-analyze.py")
    else:
        build_pipeline(args.source, args.output, args.no_pdf)


if __name__ == "__main__":
    main()
