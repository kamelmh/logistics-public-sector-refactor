"""Enhancement 1: OCR for Screenshots - Extract text from all screenshots."""
import os
import sys
import json
import pytesseract
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))

LW_ROOT = r"C:\Users\Admin\My Drive\LifeWorkspace"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")
os.environ["TESSDATA_PREFIX"] = r"C:\Users\Admin\scoop\apps\tesseract\current\tessdata"


def ocr_image(path):
    """Extract text from an image using Tesseract."""
    try:
        img = Image.open(path)
        text = pytesseract.image_to_string(img)
        return {"success": True, "text": text.strip(), "chars": len(text.strip())}
    except Exception as e:
        return {"success": False, "error": str(e)}


def find_screenshots():
    """Find all screenshots in LifeWorkspace."""
    screenshots = []
    for root, _, files in os.walk(LW_ROOT):
        for f in files:
            if f.lower().startswith("screenshot") and f.lower().endswith((".png", ".jpg", ".jpeg")):
                screenshots.append(os.path.join(root, f))
    return screenshots


def run_ocr():
    """OCR all screenshots and save results."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    screenshots = find_screenshots()
    print(f"Found {len(screenshots)} screenshots")

    results = {}
    for i, path in enumerate(screenshots):
        rel = path.replace(LW_ROOT + "\\", "")
        print(f"  [{i+1}/{len(screenshots)}] {rel[:60]}")
        result = ocr_image(path)
        results[rel] = {
            "text": result.get("text", ""),
            "chars": result.get("chars", 0),
            "success": result.get("success", False),
        }

    # Save results
    out_path = os.path.join(OUTPUT_DIR, "ocr_results.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    # Generate MD
    md_path = os.path.join(OUTPUT_DIR, "screenshots_ocr.md")
    lines = ["# Screenshots OCR Results\n"]
    lines.append(f"Total: {len(screenshots)} screenshots\n\n")

    for path, data in results.items():
        if data["success"] and data["chars"] > 10:
            lines.append(f"## {os.path.basename(path)}\n")
            lines.append(f"**File:** `{path}`\n")
            lines.append(f"**Text extracted:** {data['chars']} characters\n")
            lines.append(f"```\n{data['text'][:500]}\n```\n")

    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"\nResults saved to: {out_path}")
    print(f"MD saved to: {md_path}")
    return results


if __name__ == "__main__":
    run_ocr()
