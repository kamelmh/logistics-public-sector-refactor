from PIL import Image, ImageDraw, ImageFont
import os

# Professional color scheme
COLORS = {
    'primary': '#1a73e8',
    'secondary': '#34a853',
    'accent': '#ea4335',
    'dark': '#202124',
    'light': '#f8f9fa',
    'white': '#ffffff',
    'gray': '#5f6368',
    'border': '#dadce0'
}

def get_font(size, bold=False):
    try:
        if bold:
            return ImageFont.truetype("arialbd.ttf", size)
        return ImageFont.truetype("arial.ttf", size)
    except:
        return ImageFont.load_default()

def create_modern_portfolio():
    width, height = 1280, 720
    img = Image.new('RGB', (width, height), color=COLORS['white'])
    draw = ImageDraw.Draw(img)
    
    # Header bar
    draw.rectangle([0, 0, width, 80], fill=COLORS['primary'])
    draw.text((width//2, 40), "Academic Editing Services", fill='white', font=get_font(28, bold=True), anchor='mm')
    
    # Left section - Before
    draw.rectangle([40, 120, 600, 680], fill=COLORS['light'], outline=COLORS['border'], width=2)
    draw.rectangle([40, 120, 600, 170], fill=COLORS['accent'])
    draw.text((320, 145), "BEFORE", fill='white', font=get_font(20, bold=True), anchor='mm')
    
    # Before content (errors)
    before_text = [
        "The student have been studying english",
        "for three years and they is very good",
        "at writing. However, there are some",
        "mistakes in there papers that needs",
        "to be corrected before submission.",
        "",
        "Their professor said that the quality",
        "of there work is good but need more",
        "attention to detail and grammer."
    ]
    
    y = 190
    for line in before_text:
        if line:
            # Highlight errors in red
            if any(word in line.lower() for word in ['have', 'english', 'they is', 'there', 'needs', 'grammer']):
                draw.text((60, y), line, fill=COLORS['accent'], font=get_font(16))
            else:
                draw.text((60, y), line, fill=COLORS['dark'], font=get_font(16))
        y += 30
    
    # Right section - After
    draw.rectangle([680, 120, 1240, 680], fill=COLORS['light'], outline=COLORS['border'], width=2)
    draw.rectangle([680, 120, 1240, 170], fill=COLORS['secondary'])
    draw.text((960, 145), "AFTER", fill='white', font=get_font(20, bold=True), anchor='mm')
    
    # After content (corrected)
    after_text = [
        "The student has been studying English",
        "for three years and is very good",
        "at writing. However, there are some",
        "errors in their papers that need",
        "to be corrected before submission.",
        "",
        "Their professor said that the quality",
        "of their work is good but needs more",
        "attention to detail and grammar."
    ]
    
    y = 190
    for line in after_text:
        if line:
            draw.text((700, y), line, fill=COLORS['dark'], font=get_font(16))
        y += 30
    
    # Arrow between sections
    draw.polygon([(610, 400), (670, 400), (670, 380), (700, 400), (670, 420), (670, 400), (610, 400)], fill=COLORS['primary'])
    
    # Bottom section - Stats
    draw.rectangle([40, 600, 1240, 680], fill=COLORS['primary'])
    
    stats = [
        ("50+", "Papers Edited"),
        ("100%", "Satisfaction"),
        ("24hr", "Fast Delivery"),
        ("5+", "Years Experience")
    ]
    
    x = 160
    for num, label in stats:
        draw.text((x, 620), num, fill='white', font=get_font(24, bold=True), anchor='mm')
        draw.text((x, 650), label, fill='white', font=get_font(14), anchor='mm')
        x += 280
    
    output_path = os.path.join(r"C:\Users\Admin\Projects\active\portfolio", "editing_before_after.png")
    img.save(output_path, 'PNG', quality=95)
    print(f"Created: {output_path}")
    return output_path

def create_services_overview():
    width, height = 1280, 720
    img = Image.new('RGB', (width, height), color=COLORS['white'])
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([0, 0, width, 80], fill=COLORS['primary'])
    draw.text((width//2, 40), "Services I Offer", fill='white', font=get_font(28, bold=True), anchor='mm')
    
    # Services grid
    services = [
        ("Academic Editing", "APA, MLA, Chicago\nThesis & Dissertation\nResearch Papers"),
        ("Proofreading", "Grammar & Spelling\nPunctuation Errors\nStyle Improvements"),
        ("Document Formatting", "Word & PDF\nProfessional Layout\nTable of Contents"),
        ("KDP Publishing", "Book Formatting\nCover Design\nAmazon Submission"),
        ("English Teaching", "Grammar Lessons\nESL Materials\nTest Preparation"),
        ("AI Automation", "Python Scripts\nAPI Integration\nWorkflow Tools")
    ]
    
    positions = [
        (80, 120), (480, 120), (880, 120),
        (80, 400), (480, 400), (880, 400)
    ]
    
    colors = [COLORS['primary'], COLORS['secondary'], COLORS['accent'], 
              COLORS['secondary'], COLORS['primary'], COLORS['accent']]
    
    for (title, desc), (x, y), color in zip(services, positions, colors):
        # Service box
        draw.rectangle([x, y, x+360, y+240], fill=COLORS['light'], outline=COLORS['border'], width=2)
        draw.rectangle([x, y, x+360, y+50], fill=color)
        draw.text((x+180, y+25), title, fill='white', font=get_font(18, bold=True), anchor='mm')
        
        # Description
        y_offset = y + 70
        for line in desc.split('\n'):
            draw.text((x+20, y_offset), f"• {line}", fill=COLORS['dark'], font=get_font(14))
            y_offset += 30
    
    # Footer
    draw.rectangle([0, 660, width, 720], fill=COLORS['dark'])
    draw.text((width//2, 690), "MAHI Kamel Abdelghani | Freelance Editor & Content Specialist", 
              fill='white', font=get_font(14), anchor='mm')
    
    output_path = os.path.join(r"C:\Users\Admin\Projects\active\portfolio", "services_overview.png")
    img.save(output_path, 'PNG', quality=95)
    print(f"Created: {output_path}")
    return output_path

def create_apa_format_sample():
    width, height = 1280, 720
    img = Image.new('RGB', (width, height), color=COLORS['white'])
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([0, 0, width, 80], fill=COLORS['primary'])
    draw.text((width//2, 40), "APA Formatting Expert", fill='white', font=get_font(28, bold=True), anchor='mm')
    
    # Document preview
    draw.rectangle([80, 120, 700, 650], fill='white', outline=COLORS['border'], width=2)
    
    # Title page
    draw.text((390, 160), "Title of Your Paper", fill=COLORS['dark'], font=get_font(20, bold=True), anchor='mm')
    draw.text((390, 200), "Your Name", fill=COLORS['dark'], font=get_font(16), anchor='mm')
    draw.text((390, 230), "University Name", fill=COLORS['dark'], font=get_font(16), anchor='mm')
    draw.text((390, 260), "Course Name", fill=COLORS['dark'], font=get_font(16), anchor='mm')
    draw.text((390, 290), "Instructor Name", fill=COLORS['dark'], font=get_font(16), anchor='mm')
    draw.text((390, 320), "Date", fill=COLORS['dark'], font=get_font(16), anchor='mm')
    
    # Abstract
    draw.text((120, 380), "Abstract", fill=COLORS['dark'], font=get_font(16, bold=True))
    draw.text((120, 410), "This is a sample APA formatted document...", fill=COLORS['gray'], font=get_font(12))
    
    # References
    draw.text((120, 480), "References", fill=COLORS['dark'], font=get_font(16, bold=True))
    refs = [
        "Author, A. A. (Year). Title of work. Publisher.",
        "Author, B. B. (Year). Title of article. Journal, volume(issue), pages.",
        "Author, C. C. (Year). Title of chapter. In Editor (Ed.), Book (pp. pages). Publisher."
    ]
    y = 510
    for ref in refs:
        draw.text((120, y), ref, fill=COLORS['dark'], font=get_font(10))
        y += 25
    
    # Right section - Features
    draw.rectangle([750, 120, 1200, 650], fill=COLORS['light'], outline=COLORS['border'], width=2)
    draw.text((975, 150), "APA Features", fill=COLORS['primary'], font=get_font(20, bold=True), anchor='mm')
    
    features = [
        "✓ Title Page",
        "✓ Running Head",
        "✓ Page Numbers",
        "✓ In-Text Citations",
        "✓ Reference List",
        "✓ Hanging Indents",
        "✓ Double Spacing",
        "✓ 12pt Times New Roman",
        "✓ 1-inch Margins",
        "✓ Abstract"
    ]
    
    y = 190
    for feature in features:
        draw.text((780, y), feature, fill=COLORS['secondary'], font=get_font(14))
        y += 35
    
    # Footer
    draw.rectangle([0, 660, width, 720], fill=COLORS['dark'])
    draw.text((width//2, 690), "APA • MLA • Chicago • All Academic Formats", 
              fill='white', font=get_font(14), anchor='mm')
    
    output_path = os.path.join(r"C:\Users\Admin\Projects\active\portfolio", "apa_format_sample.png")
    img.save(output_path, 'PNG', quality=95)
    print(f"Created: {output_path}")
    return output_path

# Create all professional assets
print("Creating professional portfolio assets...")
create_modern_portfolio()
create_services_overview()
create_apa_format_sample()
print("\nAll professional assets created!")
