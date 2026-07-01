"""
Word COM Automation v12 — Production-ready.

ROOT CAUSE FIX (v11→v12):
  v11 inserted duplicate TOC/TOF fields when Golden Source already had them.
  v12 checks for existing field after heading and UPDATES it instead of inserting duplicate.
  Also ensures hyperlinks are properly generated via field update.
"""
import win32com.client
import os
import sys


def log(msg):
    print(f"[WORD-AUTO] {msg}", flush=True)


def find_and_update_field_via_selection(word_app, heading_text, field_code):
    """Use Selection.Find to locate heading, then update existing field or insert new one.
    
    This avoids duplicate TOC/TOF fields when Golden Source already has them.
    """
    sel = word_app.Selection
    
    # Find the heading via Selection.Find
    sel.WholeStory()
    sel.Collapse(1)  # wdCollapseStart
    
    found = sel.Find.Execute(FindText=heading_text,
                             Forward=True,
                             Wrap=1,  # wdFindContinue
                             MatchCase=False)
    if not found:
        return False
    
    # Get the heading paragraph
    heading_para = sel.Paragraphs(1)
    
    # Check the NEXT paragraph for existing TOC/TOF field
    # In Word COM, Next is a method
    next_para = heading_para.Next()
    if next_para:
        fields = next_para.Range.Fields
        if fields.Count > 0:
            # Update existing field
            field = fields(1)
            field.Code.Text = field_code
            log(f"  Updated existing field in next paragraph: {field_code[:40]}...")
            return True
    
    # No existing field - move to end of heading paragraph and insert new field
    sel.EndOf(5, 0)  # wdParagraph=0, wdMove=0
    sel.Move(5, 1)   # Move down 1 paragraph
    
    # Add the field via Selection.Fields.Add
    sel.Fields.Add(sel.Range, -1, field_code, True)
    log(f"  Inserted new field: {field_code[:40]}...")
    return True


def automate_word_tasks(docx_path, logo1_path, logo2_path, export_pdf=False):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        # --- TOC ---
        log("Updating/Inserting TOC field via Selection.Find...")
        if find_and_update_field_via_selection(
            word, "فهرس المحتويات", r'TOC \o "1-3" \h \z \u'
        ):
            log("  TOC field ready")
        else:
            log("  WARNING: TOC heading not found")

        # --- TOF ---
        log("Updating/Inserting TOF field via Selection.Find...")
        if find_and_update_field_via_selection(
            word, "قائمة الجداول", r'TOC \h \z \c "جدول"'
        ):
            log("  TOF field ready")
        else:
            log("  WARNING: TOF heading not found")

        # --- Update all fields (generates hyperlinks) ---
        log("Updating all fields (Ctrl+A F9 equivalent)...")
        doc.Fields.Update()
        log("  Fields updated")

        # --- Logos ---
        log("Placing logos...")
        for label, path, left in [("Logo1", logo1_path, 36), ("Logo2", logo2_path, 432)]:
            if not path or not os.path.exists(path):
                log(f"  SKIP: {label} — {'no path' if not path else 'file not found'}")
                continue
            # Validate: must be >100 bytes and start with PNG magic bytes
            fsize = os.path.getsize(path)
            with open(path, 'rb') as f:
                header = f.read(8)
            is_png = header[:4] == b'\x89PNG'
            is_jpeg = header[:2] == b'\xff\xd8'
            is_real = fsize > 100 and (is_png or is_jpeg)
            if not is_real:
                log(f"  SKIP: {label} — placeholder ({fsize} bytes, not a real image)")
                continue
            try:
                shape = doc.Shapes.AddPicture(
                    FileName=os.path.abspath(path),
                    LinkToFile=False, SaveWithDocument=True,
                    Left=left, Top=36, Width=108, Height=108
                )
                shape.WrapFormat.Type = 3  # wdWrapBehind
                log(f"  {label} placed ({fsize/1024:.1f} KB)")
            except Exception as e:
                log(f"  {label} FAILED: {e}")

        # --- Save ---
        log("Saving...")
        doc.Save()
        log("SAVED")

        # --- Export PDF (optional, off by default) ---
        if export_pdf:
            pdf_path = docx_path.rsplit('.', 1)[0] + '.pdf'
            try:
                log(f"Exporting PDF: {pdf_path}")
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
        else:
            log("PDF export skipped")

        return True

    except Exception as e:
        log(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        try:
            if doc: doc.Close(SaveChanges=True)
        except: pass
        try:
            if word: word.Quit()
        except: pass


if __name__ == "__main__":
    export_pdf = False
    args = [a for a in sys.argv[1:] if a.startswith('-')]
    pos_args = [a for a in sys.argv[1:] if not a.startswith('-')]

    for a in args:
        if a == '--export-pdf':
            export_pdf = True
        elif a in ('--skip-pdf', '--save-only'):
            export_pdf = False

    if len(pos_args) < 1:
        print("Usage: python word_automation.py <docx> [logo1] [logo2] [--export-pdf]",
              file=sys.stderr)
        sys.exit(1)

    docx_path = os.path.abspath(pos_args[0])
    logo1_path = os.path.abspath(pos_args[1]) if len(pos_args) > 1 and pos_args[1] else ""
    logo2_path = os.path.abspath(pos_args[2]) if len(pos_args) > 2 and pos_args[2] else ""

    log(f"DOCX:  {docx_path}")
    log(f"Logo1: {logo1_path or '(none)'}")
    log(f"Logo2: {logo2_path or '(none)'}")
    log(f"Export PDF: {export_pdf}")

    sys.exit(0 if automate_word_tasks(docx_path, logo1_path, logo2_path, export_pdf) else 1)
