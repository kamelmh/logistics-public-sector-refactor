"""
Minimal COM test — opens DOCX, adds TOC field via Selection, saves, closes.
Uses Selection.Fields.Add instead of Range.Fields.Add.
"""
import win32com.client
import os
import sys

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def test_field_insertion(docx_path):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras, {doc.TablesOfContents.Count} TOCs")

        # --- Approach: Use Selection instead of Range ---
        sel = word.Selection
        sel.WholeStory()  # Select all
        sel.Collapse(0)   # wdCollapseEnd

        # Insert TOC at the END of the document (instead of finding heading)
        # This avoids any RTL/find interaction issues
        sel.TypeParagraph()
        log("Inserted paragraph at end")

        # Now select that last paragraph
        sel.WholeStory()
        sel.Collapse(0)  # wdCollapseEnd
        sel.MoveUp(5, 1)  # wdParagraph=5, move up by 1

        log("Adding TOC field via Selection...")
        field = sel.Fields.Add(sel.Range, -1, r'TOC \o "1-3" \h \z \u', False)
        log(f"  Field added: {field.Code.Text[:50]}")

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
        print("Usage: python test_com_field_only.py <docx>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if test_field_insertion(os.path.abspath(sys.argv[1])) else 1)
