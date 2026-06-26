"""
Word COM Automation v11 — Production-ready.

ROOT CAUSE FIX (v10→v11):
  v9 used Range.Fields.Add() which corrupts the document XML
  (causes content loss: abstract, paragraphs). 
  v11 uses Selection.Find + Selection.Fields.Add which is SAFE.

  Also fixes: Content.Find couldn't find Arabic text "قائمة الجداول".
  Selection.Find CAN find it.
"""
import win32com.client
import os
import sys


def log(msg):
    print(f"[WORD-AUTO] {msg}", flush=True)


def find_and_insert_field_via_selection(word_app, heading_text, field_code):
    """Use Selection.Find to locate heading, then Selection.Fields.Add.
    
    This approach is proven safe — no XML corruption, no content loss.
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
    
    # Move selection to end of the found paragraph, then to next para
    sel.EndOf(5, 0)  # wdParagraph=0, wdMove=0
    sel.Move(5, 1)   # Move down 1 paragraph
    
    # Add the field via Selection.Fields.Add (safe — no XML corruption)
    sel.Fields.Add(sel.Range, -1, field_code, True)
    return True


def automate_word_tasks(docx_path, logo1_path, logo2_path):
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
        log("Inserting TOC field via Selection.Find + Selection.Fields.Add...")
        if find_and_insert_field_via_selection(
            word, "فهرس المحتويات", r'TOC \o "1-3" \h \z \u'
        ):
            log("  TOC field inserted")
        else:
            log("  WARNING: TOC heading not found")

        # --- TOF ---
        log("Inserting TOF field via Selection.Find + Selection.Fields.Add...")
        if find_and_insert_field_via_selection(
            word, "قائمة الجداول", r'TOC \h \z \c "جدول"'
        ):
            log("  TOF field inserted")
        else:
            log("  WARNING: TOF heading not found")

        # --- Logos ---
        log("Placing logos...")
        for label, path, left in [("Logo1", logo1_path, 36), ("Logo2", logo2_path, 432)]:
            if os.path.exists(path):
                try:
                    shape = doc.Shapes.AddPicture(
                        FileName=os.path.abspath(path),
                        LinkToFile=False, SaveWithDocument=True,
                        Left=left, Top=36, Width=108, Height=108
                    )
                    shape.WrapFormat.Type = 3  # wdWrapBehind
                    log(f"  {label} placed")
                except Exception as e:
                    log(f"  {label} FAILED: {e}")
            else:
                log(f"  SKIP: {label}")

        # --- Save (no field update — user does Ctrl+A F9) ---
        log("Saving...")
        doc.Save()
        log("SAVED")
        return True

    except Exception as e:
        log(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        try:
            if doc: doc.Close(SaveChanges=False)
        except: pass
        try:
            if word: word.Quit()
        except: pass


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python word_automation.py <docx> <logo1> <logo2>",
              file=sys.stderr)
        sys.exit(1)

    docx_path = os.path.abspath(sys.argv[1])
    logo1_path = os.path.abspath(sys.argv[2])
    logo2_path = os.path.abspath(sys.argv[3])

    log(f"DOCX:  {docx_path}")
    log(f"Logo1: {logo1_path}")
    log(f"Logo2: {logo2_path}")

    sys.exit(0 if automate_word_tasks(docx_path, logo1_path, logo2_path) else 1)
