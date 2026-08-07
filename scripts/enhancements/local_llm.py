"""Enhancement 2: Local LLM for offline summarization using Ollama."""
import os
import json
import httpx

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.1:8b"


def check_ollama():
    """Check if Ollama is running."""
    try:
        with httpx.Client(timeout=5) as client:
            r = client.get("http://localhost:11434/api/tags")
            return r.status_code == 200
    except Exception:
        return False


def summarize_local(text, context="document"):
    """Summarize using local Ollama."""
    if not check_ollama():
        return {"success": False, "error": "Ollama not running"}

    prompt = f"""Analyze this document and provide:
1. TITLE: A descriptive title
2. CATEGORY: One of [academic, spiritual, teaching, logistics, business, personal, technical, other]
3. SUMMARY: 2-3 sentence summary
4. KEY_TOPICS: List of 3-5 key topics
5. ACTIONABLE_INFO: Any useful information, URLs, setups, configurations

Context: {context}

Document (first 2000 chars):
{text[:2000]}

Respond in JSON:
{{"title": "...", "category": "...", "summary": "...", "key_topics": ["..."], "actionable_info": ["..."]}}"""

    try:
        with httpx.Client(timeout=60) as client:
            r = client.post(OLLAMA_URL, json={
                "model": MODEL,
                "prompt": prompt,
                "stream": False,
            })
            response = r.json().get("response", "")
            start = response.find("{")
            end = response.rfind("}") + 1
            if start != -1 and end > start:
                return {"success": True, **json.loads(response[start:end])}
            return {"success": True, "raw": response}
    except Exception as e:
        return {"success": False, "error": str(e)}


if __name__ == "__main__":
    print("Checking Ollama...")
    if check_ollama():
        print("Ollama: Running")
        result = summarize_local("This is a test document about Python programming.", "test")
        print(f"Test result: {result}")
    else:
        print("Ollama: Not running. Start with: ollama serve")
