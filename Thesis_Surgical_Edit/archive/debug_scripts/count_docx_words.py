import sys
from docx import Document

def count_words_in_docx(path):
    try:
        doc = Document(path)
        words = 0
        for para in doc.paragraphs:
            words += len(para.text.split())
        print(f"Words in DOCX: {words}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python count_docx_words.py <path>")
    else:
        count_words_in_docx(sys.argv[1])
