"""
preserve_footnotes.py — Save and restore footnotes.xml around Word COM operations.

Word COM strips empty footnotes on save. This script:
  1. Saves the footnotes.xml from the golden source
  2. After Word COM, restores it

Usage:
  python preserve_footnotes.py save <docx_path>    # Save footnotes to temp
  python preserve_footnotes.py restore <docx_path>  # Restore footnotes from temp
"""
import sys
import os
import shutil
import zipfile
import tempfile


def save_footnotes(docx_path):
    """Save footnotes.xml from DOCX to temp file."""
    temp_dir = tempfile.gettempdir()
    temp_fn = os.path.join(temp_dir, "preserved_footnotes.xml")
    
    with zipfile.ZipFile(docx_path, 'r') as z:
        if 'word/footnotes.xml' in z.namelist():
            raw = z.read('word/footnotes.xml')
            with open(temp_fn, 'wb') as f:
                f.write(raw)
            print("[PRESERVE] Saved footnotes.xml (%d bytes) to %s" % (len(raw), temp_fn))
            return True
        else:
            print("[PRESERVE] No footnotes.xml found in %s" % docx_path)
            return False


def restore_footnotes(docx_path):
    """Restore footnotes.xml into DOCX from temp file."""
    temp_dir = tempfile.gettempdir()
    temp_fn = os.path.join(temp_dir, "preserved_footnotes.xml")
    
    if not os.path.exists(temp_fn):
        print("[PRESERVE] No saved footnotes.xml at %s" % temp_fn)
        return False
    
    with open(temp_fn, 'rb') as f:
        fn_raw = f.read()
    
    # Replace footnotes.xml in the DOCX
    temp_docx = docx_path + ".tmp"
    with zipfile.ZipFile(docx_path, 'r') as zin:
        with zipfile.ZipFile(temp_docx, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                if item.filename == 'word/footnotes.xml':
                    zout.writestr(item, fn_raw)
                    print("[PRESERVE] Restored footnotes.xml (%d bytes)" % len(fn_raw))
                else:
                    zout.writestr(item, zin.read(item.filename))
    
    shutil.move(temp_docx, docx_path)
    print("[PRESERVE] DOCX updated: %s" % docx_path)
    
    # Clean up temp
    os.remove(temp_fn)
    return True


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python preserve_footnotes.py <save|restore> <docx_path>")
        sys.exit(1)
    
    action = sys.argv[1]
    docx_path = sys.argv[2]
    
    if action == "save":
        sys.exit(0 if save_footnotes(docx_path) else 1)
    elif action == "restore":
        sys.exit(0 if restore_footnotes(docx_path) else 1)
    else:
        print("Unknown action: %s" % action)
        sys.exit(1)
