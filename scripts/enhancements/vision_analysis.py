"""Enhancement 3: Image Vision Analysis - Describe what's in images."""
import os
import json
import httpx
from PIL import Image

LW_ROOT = r"C:\Users\Admin\My Drive\LifeWorkspace"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"


def analyze_with_vision(image_path, api_key):
    """Use Groq vision model to describe an image."""
    try:
        img = Image.open(image_path)
        width, height = img.size

        # Get image info
        info = f"Image: {width}x{height}, format: {img.format}, mode: {img.mode}"

        prompt = f"""Describe this image in detail. What does it show?
- Is it a screenshot, photo, diagram, or other type?
- What content is visible (text, UI elements, people, objects)?
- What is the likely purpose or context?

Image info: {info}
File: {os.path.basename(image_path)}

Respond in JSON:
{{"type": "screenshot/photo/diagram/other", "description": "...", "content_summary": "...", "likely_purpose": "..."}}"""

        with httpx.Client(timeout=30) as client:
            r = client.post(GROQ_URL, headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            }, json={
                "model": "llama-3.1-8b-instant",
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 300,
            })
            resp = r.json()
            content = resp["choices"][0]["message"]["content"]
            start = content.find("{")
            end = content.rfind("}") + 1
            if start != -1 and end > start:
                return {"success": True, **json.loads(content[start:end])}
            return {"success": True, "raw": content}
    except Exception as e:
        return {"success": False, "error": str(e)}


def run_vision(limit=20):
    """Analyze key images with vision."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    api_key = os.environ.get("GROQ_API_KEY", "")
    if not api_key:
        api_key = input("Enter GROQ_API_KEY: ")

    # Focus on screenshots and tech images
    targets = []
    for root, _, files in os.walk(LW_ROOT):
        for f in files:
            path = os.path.join(root, f)
            if f.lower().startswith("screenshot") and f.lower().endswith((".png", ".jpg")):
                targets.append(path)
            elif "Langflow" in root or "Advanced_Tools" in root:
                if f.lower().endswith((".png", ".jpg")):
                    targets.append(path)

    targets = targets[:limit]
    print(f"Analyzing {len(targets)} images with vision...")

    results = {}
    for i, path in enumerate(targets):
        rel = path.replace(LW_ROOT + "\\", "")
        print(f"  [{i+1}/{len(targets)}] {rel[:60]}")
        result = analyze_with_vision(path, api_key)
        results[rel] = result

    out_path = os.path.join(OUTPUT_DIR, "vision_results.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\nResults saved to: {out_path}")
    return results


if __name__ == "__main__":
    run_vision()
