"""Re-run OCR on screenshots with better settings."""
import os
import sys
import json
import pytesseract
from PIL import Image, ImageFilter, ImageEnhance

os.environ["TESSDATA_PREFIX"] = r"C:\Users\Admin\scoop\apps\tesseract\current\tessdata"

LW_ROOT = r"C:\Users\Admin\My Drive\LifeWorkspace"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")

# Load existing results
existing_path = os.path.join(OUTPUT_DIR, "ocr_results.json")
with open(existing_path, encoding="utf-8") as f:
    results = json.load(f)

# Find screenshots with minimal text
needs_retry = []
for path, data in results.items():
    if data.get("chars", 0) < 50:
        needs_retry.append(path)

print(f"Screenshots needing retry: {len(needs_retry)}")


def enhanced_ocr(path):
    """Try multiple OCR approaches."""
    try:
        img = Image.open(path)

        # Approach 1: Original with PSM 6 (uniform block)
        text1 = pytesseract.image_to_string(img, config="--psm 6")

        # Approach 2: Grayscale + threshold
        gray = img.convert("L")
        enhancer = ImageEnhance.Contrast(gray)
        gray = enhancer.enhance(2.0)
        text2 = pytesseract.image_to_string(gray, config="--psm 6")

        # Approach 3: Upscaled
        big = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
        text3 = pytesseract.image_to_string(big, config="--psm 6")

        # Approach 4: Different PSM modes
        text4 = pytesseract.image_to_string(img, config="--psm 3")
        text5 = pytesseract.image_to_string(img, config="--psm 11")

        # Pick best result
        texts = [text1, text2, text3, text4, text5]
        best = max(texts, key=len)

        return {
            "success": True,
            "text": best.strip(),
            "chars": len(best.strip()),
            "attempts": len(texts),
            "best_approach": texts.index(best) + 1,
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


# Re-run OCR
updated = 0
for path in needs_retry:
    full_path = os.path.join(LW_ROOT, path)
    if not os.path.exists(full_path):
        continue

    print(f"  Retrying: {path[:60]}")
    result = enhanced_ocr(full_path)
    old_chars = results[path].get("chars", 0)
    new_chars = result.get("chars", 0)

    if new_chars > old_chars:
        results[path] = result
        updated += 1
        print(f"    Improved: {old_chars} -> {new_chars} chars")

# Save updated results
with open(existing_path, "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2, ensure_ascii=False)

# Regenerate MD
md_path = os.path.join(OUTPUT_DIR, "screenshots_ocr.md")
lines = ["# Screenshots OCR Results\n"]
lines.append(f"Total: {len(results)} screenshots\n")
lines.append(f"With extractable text: {sum(1 for d in results.values() if d.get('chars', 0) > 50)}\n\n")

for path, data in sorted(results.items()):
    if data.get("success") and data.get("chars", 0) > 10:
        lines.append(f"## {os.path.basename(path)}\n")
        lines.append(f"**File:** `{path}`\n")
        lines.append(f"**Text extracted:** {data.get('chars', 0)} characters\n")
        lines.append(f"```\n{data.get('text', '')[:500]}\n```\n")

with open(md_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"\nUpdated: {updated} screenshots")
print(f"Total with text: {sum(1 for d in results.values() if d.get('chars', 0) > 50)}")
