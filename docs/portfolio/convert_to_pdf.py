import subprocess
import os

# Convert Word to PDF using LibreOffice (if available)
def convert_to_pdf(docx_path):
    try:
        # Try using LibreOffice
        subprocess.run([
            'soffice',
            '--headless',
            '--convert-to', 'pdf',
            docx_path
        ], check=True, capture_output=True)
        print(f"Converted: {docx_path}")
        return True
    except:
        print(f"Could not convert: {docx_path}")
        return False

# List of documents to convert
documents = [
    r"C:\Users\Admin\Projects\active\portfolio\editing_sample.docx",
    r"C:\Users\Admin\Projects\active\portfolio\formatting_sample.docx",
    r"C:\Users\Admin\Projects\active\portfolio\apa_paper_sample.docx"
]

print("Converting documents to PDF...")
for doc in documents:
    convert_to_pdf(doc)

print("\nDone! Check folder for PDF files.")
