"""
Minimal COM test — opens DOCX, inserts TOC field at END of document.
Tests if field insertion at end causes content loss.
"""
import win32com.client
import os
import sys

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def test_field_at_end(docx_path):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        # --- Insert field at END of document (no Find, no paragraph insert) ---
        sel = word.Selection
        sel.WholeStory()
        sel.Collapse(0)  # wdCollapseEnd

        log("Adding TOC field at end of document...")
        sel.Fields.Add(sel.Range, -1, r'TOC \o "1-3" \h \z \u', True)
        log("  Field added.")

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
    if len(sys.argv) < 2:
        print("Usage: python test_com_field_end.py <docx>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if test_field_at_end(os.path.abspath(sys.argv[1])) else 1)
