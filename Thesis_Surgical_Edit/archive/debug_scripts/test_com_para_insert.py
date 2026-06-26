"""
Minimal COM test — opens DOCX, finds heading, inserts paragraph after it ONLY.
Tests if rng.InsertParagraphAfter() causes content loss.
"""
import win32com.client
import os
import sys

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def test_para_insert(docx_path):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        # --- Find heading and insert paragraph ONLY (no field) ---
        rng = doc.Content
        find = rng.Find
        find.ClearFormatting()
        find.Text = "فهرس المحتويات"
        find.Forward = True
        find.Wrap = 1
        find.MatchCase = False

        log("Searching for TOC heading...")
        if find.Execute():
            log(f"  Found at: {rng.Start}-{rng.End}")
            rng.Collapse(0)  # wdCollapseEnd
            log("  Inserting paragraph after heading...")
            rng.InsertParagraphAfter()
            log("  Paragraph inserted.")
        else:
            log("  WARNING: TOC heading not found")

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
        print("Usage: python test_com_para_insert.py <docx>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if test_para_insert(os.path.abspath(sys.argv[1])) else 1)
