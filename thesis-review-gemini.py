#!/usr/bin/env python3
"""
Thesis Review Tool using Gemini 2.5 Flash (FREE)
Reviews thesis content, formatting, and academic standards
"""

import os
import sys
from pathlib import Path

# Set API key
os.environ["GEMINI_API_KEY"] = "AQ.Ab8RN6Kh8O7XS3UVe-Df-9NFyU3GywgBXPG7kXIVegYae4M2sw"

def review_thesis():
    """Review thesis using Gemini 2.5 Flash"""
    
    print("=" * 60)
    print("  Thesis Review Tool - Gemini 2.5 Flash (FREE)")
    print("=" * 60)
    print()
    
    # Read context files
    project_root = Path(r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor")
    
    context_files = [
        "CLAUDE.md",
        "THESIS_CONTEXT.md", 
        "Thesis_Surgical_Edit/SESSION_HANDOFF.md",
        "CROSSFLOW_CLAUDE_DESKTOP.md"
    ]
    
    context = ""
    for file in context_files:
        file_path = project_root / file
        if file_path.exists():
            print(f"✅ Reading: {file}")
            with open(file_path, 'r', encoding='utf-8') as f:
                context += f"\n\n=== {file} ===\n"
                context += f.read()
        else:
            print(f"⚠️  Not found: {file}")
    
    print()
    print("📊 Context loaded. Starting review...")
    print()
    
    # Create review prompt
    prompt = f"""
You are an expert thesis reviewer for a BTS CNEPD (Technicien Supérieur en Comptabilité et Gestion des Entreprises Publiques et Décentralisées) program in Algeria.

Based on the following context, provide a comprehensive review of the thesis:

{context}

Please review:

1. **Content Completeness**: Are all required sections present?
   - Cover page
   - Dedication (إهداء)
   - Acknowledgments (شكر وتقدير)
   - Table of Contents
   - Abstract (Arabic + French)
   - 4 Chapters with proper structure
   - Bibliography
   - Annexes
   - Glossary
   - Abbreviations

2. **Academic Standards**: Does it meet CNEPD BTS requirements?
   - Proper citation format
   - Academic writing style
   - Research methodology
   - Analysis and discussion

3. **Formatting Compliance**: Is the formatting correct?
   - A4 page size (21.0×29.7 cm)
   - Margins: 2.5cm all sides
   - Font: Traditional Arabic 14pt
   - Line spacing: 1.5
   - RTL alignment for Arabic text
   - Proper table formatting
   - Correct page numbering

4. **Ground Truth Verification**: Are the parameters correct?
   - D = 789 (Annual Demand)
   - Q* = 37 (EOQ)
   - ROP = 206 (Reorder Point)
   - SS = 200 (Safety Stock)
   - LT = 2 days (Lead Time)
   - S = 801.45 DZD (Order Cost)
   - PU = 4500 DZD (Unit Price)
   - I = 20% (Holding Rate)

5. **Language Quality**: 
   - Arabic content grammar and style
   - French content grammar and style
   - Technical terminology consistency

6. **Submission Readiness**: 
   - Is it ready for final submission?
   - What improvements are needed?

Provide a detailed assessment with specific recommendations.
"""
    
    print("=" * 60)
    print("  REVIEW PROMPT GENERATED")
    print("=" * 60)
    print()
    print("To review your thesis, you can:")
    print()
    print("Option 1: Use OpenCode with Gemini (Recommended)")
    print("  1. Open terminal in project root")
    print("  2. Run: OpenCode gemini")
    print("  3. Paste the review prompt above")
    print()
    print("Option 2: Use the prompt manually")
    print("  1. Copy the prompt from this script")
    print("  2. Paste it into any AI tool (Gemini, ChatGPT, etc.)")
    print("  3. Get your thesis reviewed")
    print()
    print("Option 3: Use Claude Desktop (requires billing)")
    print("  1. Set up billing at https://console.anthropic.com")
    print("  2. Use Claude Desktop with the context files")
    print()
    
    # Save prompt to file
    prompt_file = project_root / "thesis-review-prompt.txt"
    with open(prompt_file, 'w', encoding='utf-8') as f:
        f.write(prompt)
    
    print(f"✅ Review prompt saved to: {prompt_file}")
    print()
    print("=" * 60)
    print("  READY FOR THESIS REVIEW!")
    print("=" * 60)

if __name__ == "__main__":
    review_thesis()