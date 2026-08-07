from PIL import Image, ImageDraw, ImageFont
import os

# Create a new image
width, height = 1000, 1400
img = Image.new('RGB', (width, height), color='white')
draw = ImageDraw.Draw(img)

# Try to use a font
try:
    title_font = ImageFont.truetype("arial.ttf", 32)
    header_font = ImageFont.truetype("arial.ttf", 24)
    body_font = ImageFont.truetype("arial.ttf", 18)
    small_font = ImageFont.truetype("arial.ttf", 14)
except:
    title_font = ImageFont.load_default()
    header_font = ImageFont.load_default()
    body_font = ImageFont.load_default()
    small_font = ImageFont.load_default()

# Draw header background
draw.rectangle([0, 0, width, 120], fill='#1a73e8')

# Draw title
draw.text((width//2, 30), "Academic Editing Sample", fill='white', font=title_font, anchor='mt')
draw.text((width//2, 70), "Research Paper: AI in Education", fill='white', font=body_font, anchor='mt')
draw.text((width//2, 100), "APA 7th Edition | 1,500 Words | 48 Changes", fill='white', font=small_font, anchor='mt')

# Draw section title
y = 150
draw.text((50, y), "Before and After Comparison", fill='#1a73e8', font=header_font)
draw.line([50, y+30, width-50, y+30], fill='#1a73e8', width=2)

# Before/After boxes
y = 200
# Before box
draw.rectangle([50, y, 480, y+180], fill='#fff3f3', outline='#e53935', width=2)
draw.text((60, y+10), "ORIGINAL", fill='#e53935', font=small_font)
draw.text((60, y+35), '"The impact of artificial intelligence', fill='#333', font=small_font)
draw.text((60, y+55), 'on education has been significant in', fill='#333', font=small_font)
draw.text((60, y+75), 'recent years. Many researchers have', fill='#333', font=small_font)
draw.text((60, y+95), 'studied this topic and found that AI', fill='#333', font=small_font)
draw.text((60, y+115), 'can help students learn better."', fill='#333', font=small_font)

# After box
draw.rectangle([520, y, 950, y+180], fill='#f1f8e9', outline='#43a047', width=2)
draw.text((530, y+10), "EDITED", fill='#43a047', font=small_font)
draw.text((530, y+35), '"Artificial intelligence (AI) has', fill='#333', font=small_font)
draw.text((530, y+55), 'fundamentally transformed educational', fill='#333', font=small_font)
draw.text((530, y+75), 'practices in recent decades, prompting', fill='#333', font=small_font)
draw.text((530, y+95), 'extensive scholarly investigation into', fill='#333', font=small_font)
draw.text((530, y+115), 'its pedagogical implications."', fill='#333', font=small_font)

# Second comparison
y = 420
draw.rectangle([50, y, 480, y+140], fill='#fff3f3', outline='#e53935', width=2)
draw.text((60, y+10), "ORIGINAL", fill='#e53935', font=small_font)
draw.text((60, y+35), '"We looked at 50 studies about AI', fill='#333', font=small_font)
draw.text((60, y+55), 'in education. We searched Google', fill='#333', font=small_font)
draw.text((60, y+75), 'Scholar and other databases."', fill='#333', font=small_font)

draw.rectangle([520, y, 950, y+140], fill='#f1f8e9', outline='#43a047', width=2)
draw.text((530, y+10), "EDITED", fill='#43a047', font=small_font)
draw.text((530, y+35), '"This systematic review analyzed 50', fill='#333', font=small_font)
draw.text((530, y+55), 'peer-reviewed studies on AI applications', fill='#333', font=small_font)
draw.text((530, y+75), 'in education."', fill='#333', font=small_font)

# Stats section
y = 620
draw.text((50, y), "Editing Statistics", fill='#1a73e8', font=header_font)
draw.line([50, y+30, width-50, y+30], fill='#1a73e8', width=2)

# Stats boxes
y = 680
stats = [("48", "Total Changes"), ("12", "Clarity Fixes"), ("18", "Academic Tone"), ("6", "Citations")]
for i, (num, label) in enumerate(stats):
    x = 50 + i * 235
    draw.rectangle([x, y, x+210, y+100], fill='#f8f9fa', outline='#ddd', width=1)
    draw.text((x+105, y+20), num, fill='#1a73e8', font=title_font, anchor='mt')
    draw.text((x+105, y+60), label, fill='#666', font=small_font, anchor='mt')

# Services section
y = 820
draw.text((50, y), "Services Applied", fill='#1a73e8', font=header_font)
draw.line([50, y+30, width-50, y+30], fill='#1a73e8', width=2)

y = 880
services = ["Grammar & Punctuation", "Academic Tone", "APA Formatting", "Sentence Structure", "Clarity", "Hedging"]
for i, service in enumerate(services):
    row = i // 3
    col = i % 3
    x = 50 + col * 310
    sy = y + row * 50
    draw.rectangle([x, sy, x+290, sy+40], fill='#e3f2fd')
    draw.text((x+145, sy+12), service, fill='#1565c0', font=small_font, anchor='mt')

# Footer
draw.rectangle([0, height-80, width, height], fill='#f8f9fa')
draw.line([0, height-80, width, height-80], fill='#ddd', width=1)
draw.text((width//2, height-60), "Editor: MAHI Kamel Abdelghani | July 14, 2026 | 24hr Turnaround", fill='#333', font=small_font, anchor='mt')
draw.text((width//2, height-35), "Academic Editing & Proofreading | English (C1) | Arabic (Native)", fill='#666', font=small_font, anchor='mt')

# Save
output_path = r"C:\Users\Admin\Projects\active\portfolio\editing_portfolio_final.png"
img.save(output_path, 'PNG')
print(f"Saved: {output_path}")
print(f"Size: {os.path.getsize(output_path)} bytes")
print("\nDone! Upload this to Upwork.")