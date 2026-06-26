
"""
Minimal COM test — opens a DOCX, saves it, and closes it.
Used to isolate if simple open/save via COM causes content loss.
"""
import win32com.client
import os
import sys
import time

def log(msg):
    print(f"[COM-TEST] {msg}", flush=True)

def minimal_save_test(docx_path):
    word = None
    doc = None
    try:
        log(f"Starting Word for: {docx_path}")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        log(f"Opening document: {docx_path}")
        doc = word.Documents.Open(docx_path, ReadOnly=False)
        log(f"Opened: {doc.Paragraphs.Count} paras")

        log("Saving document...")
        doc.Save()
        log("Document SAVED.")
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
                log("Document closed.")
        except Exception as e:
            log(f"Error closing document: {e}")
        try:
            if word:
                word.Quit()
                log("Word quit.")
        except Exception as e:
            log(f"Error quitting Word: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_com_minimal_save.py <docx_path>", file=sys.stderr)
        sys.exit(1)

    docx_path = os.path.abspath(sys.argv[1])
    sys.exit(0 if minimal_save_test(docx_path) else 1)
