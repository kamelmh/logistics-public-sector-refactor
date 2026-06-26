# OCR Demo Script
"""
OCR Demo Script
----------------
A minimal command‑line OCR utility.

Dependencies:
    - Python 3.7+
    - pytesseract (`pip install pytesseract`)
    - Pillow (`pip install pillow`)
    - Tesseract OCR engine installed and on PATH
      (https://github.com/tesseract-ocr/tesseract)

Usage:
    python ocr_demo.py <image_path>

Example:
    python ocr_demo.py sample.png
"""

import sys
from pathlib import Path

try:
    from PIL import Image
    import pytesseract
except ImportError as e:
    sys.exit(f"Missing dependency: {e}. Install with `pip install pillow pytesseract`.")

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"


def ocr_image(image_path: Path) -> str:
    """Run Tesseract OCR on the supplied image and return the extracted text."""
    try:
        img = Image.open(image_path)
    except Exception as exc:
        sys.exit(f"Unable to open image {image_path}: {exc}")

    text = pytesseract.image_to_string(img, lang="eng")
    return text.strip()


def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python ocr_demo.py <image_path>")

    img_path = Path(sys.argv[1])
    if not img_path.is_file():
        sys.exit(f"File not found: {img_path}")

    result = ocr_image(img_path)
    print("=== OCR Output ===")
    print(result or "[No text detected]")

if __name__ == "__main__":
    main()
