#!/usr/bin/env python3
"""
Convert color PDF to grayscale PDF using pdf2image + PIL.
Rasterizes at high DPI (300) for print-quality grayscale output.
"""
import sys
from pathlib import Path

try:
    from pdf2image import convert_from_path
    from PIL import Image
except ImportError:
    print("Installing required packages...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pdf2image", "pillow", "--quiet"])
    from pdf2image import convert_from_path
    from PIL import Image

def pdf_to_grayscale_pdf(input_path, output_path, dpi=300):
    """Convert PDF to grayscale PDF by rasterizing each page."""
    print(f"Converting {input_path} to grayscale at {dpi} DPI...")
    
    # Convert PDF pages to images
    pages = convert_from_path(input_path, dpi=dpi)
    print(f"  Converted {len(pages)} pages to images")
    
    # Convert each page to grayscale
    grayscale_pages = []
    for i, page in enumerate(pages):
        print(f"  Processing page {i+1}/{len(pages)}...")
        # Convert to grayscale (mode 'L')
        gray_page = page.convert('L')
        # Convert back to RGB for PDF saving (PIL requires RGB/RGBA for PDF)
        gray_page = gray_page.convert('RGB')
        grayscale_pages.append(gray_page)
    
    # Save as PDF
    print(f"  Saving grayscale PDF to {output_path}...")
    grayscale_pages[0].save(
        output_path,
        "PDF",
        resolution=dpi,
        save_all=True,
        append_images=grayscale_pages[1:]
    )
    print(f"  Done! Output: {output_path}")

if __name__ == "__main__":
    input_pdf = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh_COLOR.pdf"
    output_pdf = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit\output\Memoire_DSS_Logistique_ElBayadh_GRAYSCALE.pdf"
    
    if not Path(input_pdf).exists():
        print(f"Error: Input PDF not found: {input_pdf}")
        sys.exit(1)
    
    pdf_to_grayscale_pdf(input_pdf, output_pdf, dpi=300)