import sys
from docx import Document

def search_in_docx(path, search_text):
    try:
        doc = Document(path)
        found = False
        for p in doc.paragraphs:
            if search_text in p.text:
                print(f"Found '{search_text}' in paragraph: {p.text[:50]}...")
                found = True
        if not found:
            print(f"'{search_text}' NOT found in DOCX.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python search_docx.py <path> [search_text]")
    else:
        path = sys.argv[1]
        text = sys.argv[2] if len(sys.argv) > 2 else ""
        search_in_docx(path, text)
