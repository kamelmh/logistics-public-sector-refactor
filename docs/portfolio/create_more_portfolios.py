from PIL import Image, ImageDraw, ImageFont
import os

def create_portfolio_image(title, subtitle, content_items, stats, services, filename):
    width, height = 1000, 1200
    img = Image.new('RGB', (width, height), color='white')
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 32)
        header_font = ImageFont.truetype("arial.ttf", 24)
        body_font = ImageFont.truetype("arial.ttf", 16)
        small_font = ImageFont.truetype("arial.ttf", 14)
    except:
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, width, 100], fill='#1a73e8')
    draw.text((width//2, 25), title, fill='white', font=title_font, anchor='mt')
    draw.text((width//2, 65), subtitle, fill='white', font=small_font, anchor='mt')
    
    # Content items
    y = 130
    for i, (label, text) in enumerate(content_items):
        color = '#e53935' if i % 2 == 0 else '#43a047'
        bg_color = '#fff3f3' if i % 2 == 0 else '#f1f8e9'
        draw.rectangle([50, y, width-50, y+120], fill=bg_color, outline=color, width=2)
        draw.text((60, y+10), label, fill=color, font=small_font)
        draw.text((60, y+30), text[:80], fill='#333', font=small_font)
        if len(text) > 80:
            draw.text((60, y+50), text[80:160], fill='#333', font=small_font)
        y += 140
    
    # Stats
    y += 20
    draw.text((50, y), "Statistics", fill='#1a73e8', font=header_font)
    draw.line([50, y+30, width-50, y+30], fill='#1a73e8', width=2)
    y += 50
    
    for i, (num, label) in enumerate(stats):
        x = 50 + i * 235
        draw.rectangle([x, y, x+210, y+80], fill='#f8f9fa', outline='#ddd')
        draw.text((x+105, y+15), num, fill='#1a73e8', font=header_font, anchor='mt')
        draw.text((x+105, y+50), label, fill='#666', font=small_font, anchor='mt')
    
    # Services
    y += 110
    draw.text((50, y), "Services", fill='#1a73e8', font=header_font)
    draw.line([50, y+30, width-50, y+30], fill='#1a73e8', width=2)
    y += 50
    
    for i, service in enumerate(services):
        row = i // 3
        col = i % 3
        x = 50 + col * 310
        sy = y + row * 45
        draw.rectangle([x, sy, x+290, sy+35], fill='#e3f2fd')
        draw.text((x+145, sy+10), service, fill='#1565c0', font=small_font, anchor='mt')
    
    # Footer
    draw.rectangle([0, height-60, width, height], fill='#f8f9fa')
    draw.text((width//2, height-40), "MAHI Kamel Abdelghani | Freelance Editor & Content Specialist", fill='#333', font=small_font, anchor='mt')
    
    output_path = os.path.join(r"C:\Users\Admin\Projects\active\portfolio", filename)
    img.save(output_path, 'PNG')
    print(f"Created: {output_path}")
    return output_path

# Portfolio 5: KDP Book Publishing
create_portfolio_image(
    title="KDP Book Publishing Sample",
    subtitle="Amazon Kindle Direct Publishing Expert",
    content_items=[
        ("PUBLISHING SERVICES", "Book formatting, cover design, interior layout, and Amazon submission"),
        ("BOOK CATEGORIES", "Non-fiction, self-help, planners, journals, and educational content"),
    ],
    stats=[("22", "Books Published"), ("100%", "Acceptance Rate"), ("5", "Book Categories"), ("24hr", "Turnaround")],
    services=["Book Formatting", "Cover Design", "Interior Layout", "Amazon SEO", "KDP Submission", "Kindle Publishing"],
    filename="portfolio_kdp.png"
)

# Portfolio 6: AI Automation Tools
create_portfolio_image(
    title="AI Automation Tools",
    subtitle="Custom AI Solutions for Business",
    content_items=[
        ("AI TOOLS BUILT", "Exercise generators, grammar engines, content management systems"),
        ("AUTOMATION", "Python scripts, API integration, workflow automation"),
    ],
    stats=[("17", "Components Built"), ("34", "Grammar Topics"), ("100+", "Exercises"), ("100%", "Automation")],
    services=["Python Development", "API Integration", "AI Prompt Engineering", "Workflow Automation", "Content Management", "Data Processing"],
    filename="portfolio_ai_tools.png"
)

print("\nAll portfolio images created!")