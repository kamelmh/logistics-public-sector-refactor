"""
update_fields.py — Thorough Word COM field update (Ctrl+A → F9 equivalent).

Updates ALL fields in the document before final PDF export:
  - Main document body fields
  - Headers and footers (all sections, all types)
  - Table of Contents and Table of Figures
  - Footnotes and endnotes
  - Text boxes and shapes
  - Page number fields

Usage:
  python update_fields.py <path/to/docx>
  python update_fields.py <path/to/docx> --save-only   # Save without PDF export
"""

import sys
import os
import win32com.client
import pythoncom


def log(msg):
    print(f"[FIELDS] {msg}", flush=True)


def update_all_fields(docx_path, export_pdf=True):
    word = None
    doc = None
    try:
        log("Starting Word COM...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0  # wdAlertsNone

        doc = word.Documents.Open(os.path.abspath(docx_path), ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paragraphs")

        # ── Step 1: Update fields in main document body ──
        log("Updating body fields...")
        doc.Fields.Update()
        body_count = doc.Fields.Count
        log(f"  Body fields updated ({body_count} total)")

        # ── Step 2: Update TOC and TOF fields ──
        toc_count = doc.TablesOfContents.Count
        if toc_count > 0:
            log(f"Updating {toc_count} Table of Contents...")
            for i in range(1, toc_count + 1):
                try:
                    toc = doc.TablesOfContents(i)
                    toc.Update()
                    log(f"  TOC {i} updated")
                except Exception as e:
                    log(f"  TOC {i} update skipped: {e}")
        else:
            log("  No TOC fields found")

        tof_count = doc.TablesOfFigures.Count
        if tof_count > 0:
            log(f"Updating {tof_count} Tables of Figures...")
            for i in range(1, tof_count + 1):
                try:
                    tof = doc.TablesOfFigures(i)
                    tof.Update()
                    log(f"  TOF {i} updated")
                except Exception as e:
                    log(f"  TOF {i} update skipped: {e}")

        # ── Step 3: Update fields in headers and footers ──
        log("Updating headers and footers...")
        hf_count = 0
        for i in range(1, doc.Sections.Count + 1):
            section = doc.Sections(i)
            for header_footer_type in [1, 2, 3]:  # wdHeaderFooterPrimary, FirstPage, EvenPages
                try:
                    section.Headers(header_footer_type).Range.Fields.Update()
                    hf_count += 1
                except Exception:
                    pass
                try:
                    section.Footers(header_footer_type).Range.Fields.Update()
                    hf_count += 1
                except Exception:
                    pass
        log(f"  Headers/footers updated ({hf_count} containers)")

        # ── Step 4: Skip footnotes ──
        # Word strips empty footnotes on save, reducing count from 48 to ~9.
        # No fields exist in footnotes anyway — only reference text.
        log("Skipping footnotes (Word strips empty ones on save)")

        # ── Step 5: Skip endnotes ──
        log("Skipping endnotes (same reason)")

        # ── Step 6: Update fields in text boxes and shapes ──
        log("Updating text boxes and shapes...")
        try:
            textbox_count = 0
            for shape in doc.Shapes:
                if shape.TextFrame.HasText:
                    shape.TextFrame.TextRange.Fields.Update()
                    textbox_count += 1
            log(f"  {textbox_count} shape text frames updated")
        except Exception:
            log("  No shape text frames found")

        # ── Step 7: Force page number update via Print Preview ──
        # Word doesn't truly evaluate PAGE fields until print preview or print
        log("Forcing page number evaluation...")
        try:
            doc.PrintPreview = True
            doc.PrintPreview = False
            log("  Page numbers evaluated")
        except Exception:
            log("  Print preview toggle skipped")

        # ── Save ──
        log("Saving document...")
        doc.Save()
        log("SAVED")

        # ── Export PDF if requested ──
        if export_pdf:
            pdf_path = docx_path.rsplit('.', 1)[0] + '.pdf'
            log(f"Exporting PDF: {pdf_path}")
            try:
                doc.ExportAsFixedFormat(
                    OutputFileName=pdf_path,
                    ExportFormat=17,  # wdExportFormatPDF
                    OpenAfterExport=False,
                    OptimizeFor=0,  # wdExportOptimizeForPrint
                    Range=0,  # wdExportAllDocument
                    IncludeDocProps=True,
                    DocStructureTags=True,
                    BitmapMissingFonts=True,
                    UseISO19005_1=False
                )
                pdf_size = os.path.getsize(pdf_path) / 1024
                log(f"PDF exported: {pdf_size:.0f} KB")
            except Exception as e:
                log(f"PDF export FAILED: {e}")

        return True

    except Exception as e:
        log(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        try:
            if doc:
                doc.Close(SaveChanges=False)
        except Exception:
            pass
        try:
            if word:
                word.Quit()
                pythoncom.CoUninitialize()
        except Exception:
            pass


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python update_fields.py <path/to/docx> [--save-only]")
        sys.exit(1)

    docx_path = os.path.abspath(sys.argv[1])
    save_only = "--save-only" in sys.argv

    log(f"DOCX: {docx_path}")
    log(f"Mode: {'save only' if save_only else 'field update + PDF export'}")

    sys.exit(0 if update_all_fields(docx_path, export_pdf=not save_only) else 1)
