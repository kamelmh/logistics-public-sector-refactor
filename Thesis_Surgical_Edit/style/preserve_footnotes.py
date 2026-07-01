"""
preserve_footnotes.py — Save and restore footnotes around Word COM operations.

Word COM strips empty footnotes and may corrupt footnote XML on save. This script:
  1. Saves footnotes.xml from the DOCX
  2. After Word COM, restores it

IMPORTANT: We do NOT preserve document.xml — that would overwrite Word COM's
TOC/TOF field insertions and field updates.

Usage:
  python preserve_footnotes.py save <docx_path>    # Save footnotes.xml to temp
  python preserve_footnotes.py restore <docx_path>  # Restore footnotes.xml from temp
"""
import sys
import os
import shutil
import zipfile
import tempfile


def save_parts(docx_path):
    """Save footnotes.xml from DOCX to temp file."""
    temp_dir = tempfile.gettempdir()
    saved = 0
    
    parts = ['word/footnotes.xml']
    
    with zipfile.ZipFile(docx_path, 'r') as z:
        for part in parts:
            if part in z.namelist():
                temp_fn = os.path.join(temp_dir, "preserved_%s" % part.replace('/', '_'))
                raw = z.read(part)
                with open(temp_fn, 'wb') as f:
                    f.write(raw)
                print("[PRESERVE] Saved %s (%d bytes)" % (part, len(raw)))
                saved += 1
            else:
                print("[PRESERVE] No %s in %s" % (part, docx_path))
    
    return saved > 0


def restore_parts(docx_path):
    """Restore footnotes.xml into DOCX from temp file."""
    temp_dir = tempfile.gettempdir()
    
    parts = ['word/footnotes.xml']
    
    temp_docx = docx_path + ".tmp"
    with zipfile.ZipFile(docx_path, 'r') as zin:
        with zipfile.ZipFile(temp_docx, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                if item.filename in parts:
                    temp_fn = os.path.join(temp_dir, "preserved_%s" % item.filename.replace('/', '_'))
                    if os.path.exists(temp_fn):
                        with open(temp_fn, 'rb') as f:
                            raw = f.read()
                        zout.writestr(item, raw)
                        print("[PRESERVE] Restored %s (%d bytes)" % (item.filename, len(raw)))
                        os.remove(temp_fn)
                    else:
                        zout.writestr(item, zin.read(item.filename))
                else:
                    zout.writestr(item, zin.read(item.filename))
    
    shutil.move(temp_docx, docx_path)
    print("[PRESERVE] DOCX updated: %s" % docx_path)
    return True


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python preserve_footnotes.py <save|restore> <docx_path>")
        sys.exit(1)
    
    action = sys.argv[1]
    docx_path = sys.argv[2]
    
    if action == "save":
        sys.exit(0 if save_parts(docx_path) else 1)
    elif action == "restore":
        sys.exit(0 if restore_parts(docx_path) else 1)
    else:
        print("Unknown action: %s" % action)
        sys.exit(1)
