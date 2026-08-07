from fpdf import FPDF
import os

class CVPDF(FPDF):
    def footer(self):
        pass

def create_cv():
    pdf = CVPDF()
    pdf.set_auto_page_break(auto=False)
    pdf.set_margins(12, 10, 12)
    pdf.add_page()

    fp = r"C:\Windows\Fonts\arial.ttf"
    fb = r"C:\Windows\Fonts\arialbd.ttf"
    if os.path.exists(fp):
        pdf.add_font("A", "", fp)
        pdf.add_font("A", "B", fb if os.path.exists(fb) else fp)
        F = "A"
    else:
        F = "Helvetica"

    W = 186  # usable width (210 - 12*2)

    def divider():
        pdf.set_draw_color(180, 180, 180)
        pdf.set_line_width(0.2)
        pdf.line(12, pdf.get_y(), 200 - 12, pdf.get_y())
        pdf.ln(2)

    def sec(title):
        pdf.set_font(F, "B", 10)
        pdf.set_text_color(30, 60, 110)
        pdf.cell(W, 5, title, new_x="LMARGIN", new_y="NEXT")
        pdf.set_draw_color(30, 60, 110)
        pdf.set_line_width(0.4)
        pdf.line(12, pdf.get_y(), 200 - 12, pdf.get_y())
        pdf.ln(2)
        pdf.set_text_color(0, 0, 0)

    def bul(t):
        pdf.set_font(F, "", 8)
        pdf.cell(5, 4, chr(8226))
        pdf.multi_cell(W - 5, 4, t)

    def job(t, org, d):
        pdf.set_font(F, "B", 9)
        pdf.cell(W, 4.5, t, new_x="LMARGIN", new_y="NEXT")
        pdf.set_font(F, "", 7.5)
        pdf.set_text_color(100, 100, 100)
        pdf.cell(W, 3.8, f"{org}  |  {d}", new_x="LMARGIN", new_y="NEXT")
        pdf.set_text_color(0, 0, 0)
        pdf.ln(0.5)

    def jbul(t):
        pdf.set_font(F, "", 8)
        pdf.cell(5, 4, chr(8226))
        pdf.multi_cell(W - 5, 4, t)

    # ── HEADER ──
    pdf.set_font(F, "B", 20)
    pdf.cell(W, 9, "MAHI Kamel Abdelghani", new_x="LMARGIN", new_y="NEXT", align="C")

    pdf.set_font(F, "", 10)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(W, 5, "Academic Editor  |  Document Formatting Specialist", new_x="LMARGIN", new_y="NEXT", align="C")

    pdf.set_font(F, "", 8)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(W, 4, "kamelmahi71@gmail.com   |   +213 676 773 892   |   El Bayadh, Algeria", new_x="LMARGIN", new_y="NEXT", align="C")
    pdf.cell(W, 4, "Fiverr: @kamelmahi   |   Upwork: kamelmahi71", new_x="LMARGIN", new_y="NEXT", align="C")
    pdf.set_text_color(0, 0, 0)
    pdf.ln(2)
    divider()

    # ── SUMMARY ──
    sec("Professional Summary")
    pdf.set_font(F, "", 8)
    pdf.multi_cell(W, 4, "Detail-oriented academic editor with 5+ years of experience editing academic papers, theses, and dissertations. Expert in APA (7th ed.), MLA (9th ed.), Chicago (17th ed.), and Harvard citation styles. Native Arabic speaker with C1 English proficiency and intermediate French. Published author with 50+ books on Amazon KDP. Active on Fiverr and Upwork with 3 portfolio projects and 2 live gigs.")
    pdf.ln(2)

    # ── COMPETENCIES ──
    sec("Core Competencies")
    c1 = [
        "Academic Editing & Proofreading",
        "Citation Formatting (APA, MLA, Chicago, Harvard)",
        "Dissertation & Thesis Editing",
        "Journal Manuscript Preparation",
    ]
    c2 = [
        "Document Formatting & Style Guides",
        "Bilingual Arabic/English (+ French Translation)",
        "Microsoft Word (Advanced, Track Changes)",
        "Google Docs, Grammarly, LaTeX basics",
    ]
    pdf.set_font(F, "", 8)
    for i in range(max(len(c1), len(c2))):
        left = c1[i] if i < len(c1) else ""
        right = c2[i] if i < len(c2) else ""
        pdf.cell(93, 4, f"  {chr(8226)} {left}" if left else "")
        pdf.cell(W - 93, 4, f"  {chr(8226)} {right}" if right else "", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)

    # ── EXPERIENCE ──
    sec("Professional Experience")

    job("Freelance Academic Editor", "Fiverr & Upwork", "2023 - Present")
    jbul("Gig 1: Academic paper editing ($10/$25/$50) - Grammar, clarity, tone, structure")
    jbul("Gig 2: Citation formatting ($25/$60/$120) - APA, MLA, Chicago, Harvard")
    jbul("3 portfolio projects | 98% client satisfaction | Respond within 1 hour")
    pdf.ln(1.5)

    job("Freelance KDP Formatter & Translator", "Amazon KDP", "2021 - 2023")
    jbul("Formatted 50+ manuscripts for print and digital publishing on Amazon KDP")
    jbul("Translated academic excerpts from French to English | Cover bleed, margins, font embedding")
    pdf.ln(1.5)

    job("English Language Teacher", "Algeria", "2020 - 2023")
    jbul("Taught English grammar and literature to 200+ students | Developed 100+ educational assets")
    pdf.ln(1.5)

    job("VBA & Database Developer", "Academix Project", "2019 - 2022")
    jbul("Built decision support system with 74 custom inventory modules (23K+ lines of code)")
    pdf.ln(2)

    # ── EDUCATION ──
    sec("Education")
    pdf.set_font(F, "B", 8)
    pdf.cell(80, 4, "BA in English Language & Literature")
    pdf.set_font(F, "", 8)
    pdf.cell(W - 80, 4, "Dr. Moulay Tahar University, Saida (2015 - 2020)", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font(F, "B", 8)
    pdf.cell(80, 4, "BTS Stock Management & Logistics")
    pdf.set_font(F, "", 8)
    pdf.cell(W - 80, 4, "CNEPD - Distance Learning (In Progress)", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)

    # ── SERVICES ──
    sec("Services & Rates")
    pdf.set_font(F, "B", 8)
    pdf.cell(60, 4, "Service")
    pdf.cell(50, 4, "Rate")
    pdf.cell(W - 110, 4, "Delivery", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font(F, "", 8)
    for s, r, d in [
        ("Basic Proofreading", "$8 - $12 / 1K words", "2 days"),
        ("Substantive Editing", "$12 - $20 / 1K words", "3 days"),
        ("Citation Formatting", "$5 - $10 / 1K words", "2 days"),
        ("Full Manuscript Editing", "$25 - $50 / 1K words", "4 days"),
        ("Translation (Fr > En)", "$15 - $25 / 1K words", "3 days"),
    ]:
        pdf.cell(60, 3.8, s)
        pdf.cell(50, 3.8, r)
        pdf.cell(W - 110, 3.8, d, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)

    # ── ACHIEVEMENTS ──
    sec("Key Achievements")
    ach = [
        "Edited 50+ academic documents with expert knowledge of 4+ citation styles",
        "Maintained 98% on-time delivery rate with 15+ repeat clients",
        "2 active Fiverr gigs and Upwork profile with 6 portfolio items",
        "Bilingual Arabic/English with French reading competency",
    ]
    for a in ach:
        bul(a)

    # ── LANGUAGES ──
    pdf.ln(2)
    sec("Languages")
    pdf.set_font(F, "", 8)
    pdf.cell(0, 4, "Arabic: Native          English: C1 (Fluent)          French: B1 (Intermediate)", new_x="LMARGIN", new_y="NEXT")

    out = r"C:\Users\Admin\Projects\active\portfolio\MAHI_Academic_Editing_CV.pdf"
    pdf.output(out)
    print(f"Saved: {out} | Size: {os.path.getsize(out)} bytes | Pages: {pdf.pages_count}")

create_cv()
