"""
Minimal COM test — opens DOCX, inserts ONLY the TOC field, saves, closes.
Tests if TOC insertion alone causes content loss.
"""
import win32com.client
import os
import sys

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def test_toc_insertion(docx_path):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        # --- TOC field insertion only ---
        rng = doc.Content
        find = rng.Find
        find.ClearFormatting()
        find.Text = "فهرس المحتويات"
        find.Forward = True
        find.Wrap = 1  # wdFindContinue
        find.MatchCase = False

        log("Searching for TOC heading...")
        if find.Execute():
            log("  Found. Inserting paragraph after heading...")
            rng.Collapse(0)  # wdCollapseEnd
            rng.InsertParagraphAfter()
            rng.MoveEnd(15, 1)  # wdParagraph=15, move end by 1
            rng.Fields.Add(rng, -1, r'TOC \o "1-3" \h \z \u', True)
            log("  TOC field inserted.")
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
        print("Usage: python test_com_toc_only.py <docx>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if test_toc_insertion(os.path.abspath(sys.argv[1])) else 1)
