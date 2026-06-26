import win32com.client
import os
import sys

def test_open(docx_path):
    word = None
    doc = None
    try:
        print(f"DEBUG: Attempting to open {docx_path}")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = True
        print("DEBUG: Word application started.")
        
        doc = word.Documents.Open(docx_path)
        print("DEBUG: Document opened successfully.")
        
        print(f"DEBUG: Document name: {doc.Name}")
        print(f"DEBUG: Paragraph count: {doc.Paragraphs.Count}")
        
        doc.Close()
        print("DEBUG: Document closed.")
    except Exception as e:
        print(f"DEBUG: Error occurred: {e}")
    finally:
        if word:
            word.Quit()
            print("DEBUG: Word application quit.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_open.py <docx_path>")
        sys.exit(1)
    
    test_open(sys.argv[1])
