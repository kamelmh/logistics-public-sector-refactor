"""
Minimal COM test — opens DOCX, finds heading via Selection.Find,
moves to end of heading, inserts field via Selection.Fields.Add.
NO rng.InsertParagraphAfter() used.
"""
import win32com.client
import os
import sys

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def test_sel_navigate(docx_path):
    word = None
    doc = None
    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        # --- Find via Selection.Find (not Content.Find) ---
        sel = word.Selection
        sel.WholeStory()
        sel.Collapse(1)  # wdCollapseStart

        log("Searching for TOC heading via Selection.Find...")
        found = sel.Find.Execute(FindText="فهرس المحتويات",
                                 Forward=True,
                                 Wrap=0,  # wdFindStop
                                 MatchCase=False)
        if not found:
            log("  Trying wdFindContinue...")
            sel.WholeStory()
            sel.Collapse(1)
            found = sel.Find.Execute(FindText="فهرس المحتويات",
                                     Forward=True,
                                     Wrap=1,
                                     MatchCase=False)

        if found:
            log("  Found! Moving to end of paragraph...")
            sel.EndOf(5, 0)  # wdParagraph=0, wdMove=0
            sel.Move(5, 1)   # Move to next paragraph start
            log(f"  Selection at: {sel.Range.Start}-{sel.Range.End}")

            log("  Inserting TOC field via Selection.Fields.Add...")
            sel.Fields.Add(sel.Range, -1, r'TOC \o "1-3" \h \z \u', True)
            log("  Field added.")
        else:
            log("  WARNING: TOC heading not found")

        # --- TOF ---
        log("Searching for TOF heading via Selection.Find...")
        sel.WholeStory()
        sel.Collapse(1)
        found = sel.Find.Execute(FindText="قائمة الجداول",
                                 Forward=True,
                                 Wrap=1,
                                 MatchCase=False)
        if found:
            log("  Found! Moving to end of paragraph...")
            sel.EndOf(5, 0)
            sel.Move(5, 1)
            log(f"  Selection at: {sel.Range.Start}-{sel.Range.End}")

            log("  Inserting TOF field via Selection.Fields.Add...")
            sel.Fields.Add(sel.Range, -1, r'TOC \h \z \c "جدول"', True)
            log("  Field added.")
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
        print("Usage: python test_com_sel_navigate.py <docx> <logo1> <logo2>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if test_sel_navigate(os.path.abspath(sys.argv[1])) else 1)
