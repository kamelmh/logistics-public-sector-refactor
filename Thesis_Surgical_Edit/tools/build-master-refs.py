"""build-master-refs.py — Academix v13.2
Phase 1: Extract all 56 bibliography entries from thesis .md,
build master-references.json, pdf-mapping.json, clean Old_Naming.
"""
import re, json, os, shutil
from pathlib import Path

THESIS_MD = Path("Memoire_DSS_Logistique_ElBayadh.md")
REFS_DIR = Path("refs")
MASTER_JSON = REFS_DIR / "master-references.json"
PDF_MAPPING = REFS_DIR / "pdf-mapping.json"
OLD_NAMING = REFS_DIR / "Archive" / "Old_Naming"

SEMESTER_PDF_MAP = {
    "Semester_1": {
        "18": "1.IDENTIFICATION ET COLLECTE DES INFORMATIONS INTERNES ET EXTERNES.pdf",
        "19": "2.ETUDES DES PRIX ET LES CONDITIONS DE NEGOCIATION..pdf",
        "20": "3.DROIT SOCIAL.pdf",
        "21": "4. INFORMATIQUE.pdf",
        "22": "5.MATHEMATIQUES GENERALES.pdf",
    },
    "Semester_2": {
        "23": "1.RECHERCHE ET SELECTION DES FOURNISSEURS.pdf",
        "24": "2.ETABLISSEMENT-ET-CONTROLE-DE-LA-COMMANDE DACHAT.pdf",
        "25": "3.ARHITMETIQUE COMMERCIALE.pdf",
        "26": "4.APPLICATION DES REGLES DHYGIENE SECURITE ET ENVIRONNEMENT.pdf",
        "27": "5.DROIT COMMERCIAL.pdf",
        "28": "6.DOCUMENTS COMMERCIAUX.pdf",
    },
    "Semester_3": {
        "29": "1. Enregistrement comptable et controle des approvisionnements.pdf",
        "30": "2. Réalisation de linventaire physique.pdf",
        "31": "3. Réalisation de linventaire comptable.pdf",
        "32": "4. Réalistion dune étude des myens de transport.pdf",
        "33": "5.DETERMINATION DES BESOINS ET LES ELEMENTS CONSTITUTIFS DU PROGRAMME DAPPROVISIONNEMENT.pdf",
        "34": "6.Gestion efficace des approvisionnements.pdf",
        "35": "7. Techniques dexpression et de communication.pdf",
        "36": "8.ECONOMIE DE L ENTREPRISE.pdf",
        "37": "9.STATISTIQUES DESCRIPTIVES.pdf",
    },
    "Semester_4": {
        "38": "1. PLANIFICATION STRATEGIQUE DE LA LOGISTIQUE.pdf",
        "39": "2. PLANIFICATION STRATEGIQUE.pdf",
        "40": "3. RENOUVELLEMENT DE LA COMMANDE.pdf",
        "41": "4. SUIVI ET CONTROLE DES  ARTICLES LIVRES.pdf",
        "42": "5. ORGANISATION DES MOYENS LOGISTIQUE.pdf",
        "43": "6. GESTION BUDGETAIRE.pdf",
        "44": "7. ANGLAIS COMMERCIAL .pdf",
        "45": "8. ORGANISATION DU MATERIEL.pdf",
        "46": "9. METHODOLOGIE.pdf",
        "47": "GLOSSAIRE.pdf",
    }
}

INLINE_CITED = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
INLINE_CITED_BODY = {1, 2, 3, 6, 7, 8, 9}

SECTION_LABELS = {
    "أولاً": "الكتب والمراجع العلمية",
    "ثانياً": "الإطار القانوني والتنظيمي الجزائري",
    "ثالثاً": "المنهاج الدراسي BTS GSL",
    "رابعاً": "المراجع التقنية",
    "خامساً": "مشاريع وأطروحات موازية",
    "سادساً": "مصادر البيانات الميدانية",
    "سابعاً": "المراجع البرمجية",
}

SECTION_EN = {
    "أولاً": "academic_books",
    "ثانياً": "legal_framework",
    "ثالثاً": "bts_curriculum",
    "رابعاً": "technical_refs",
    "خامساً": "parallel_theses",
    "سادساً": "field_data",
    "سابعاً": "software_ref",
}


def parse_entry(line):
    m = re.match(r'^(\d+)\.\s+\*\*(.+?)\*\*\s*\((\d{4}|سنوي)\)[\.]?\s*(.*)', line)
    if not m:
        return None
    num = int(m.group(1))
    author = m.group(2).strip().rstrip(".")
    year_raw = m.group(3)
    year = year_raw if year_raw == "سنوي" else int(year_raw)
    rest = m.group(4).strip().rstrip(".")
    return num, author, year, rest


def classify_entry(num, author, year):
    has_arabic = bool(re.search(r'[\u0600-\u06FF]', author))
    return "arabic_regulatory" if has_arabic else "academic"


def make_key(author, year, title_full="", number=0):
    is_arabic = bool(re.search(r'[\u0600-\u06FF]', author))

    if is_arabic:
        fr_match = re.search(r'\(([A-Za-z\u00C0-\u024F][-\',A-Za-z\u00C0-\u024F\s]+)\)', author)
        if fr_match:
            fr_part = fr_match.group(1).lower().strip()
            fr_part = re.sub(r'[^a-z\-\s]', '', fr_part)[:30].replace(" ", "-")
            yr = str(year)
            return f"ar-{fr_part}-{yr}"

        title_short = re.sub(r'[^\w\s]', '', title_full)[:40]
        title_words = title_short.split()[:3]
        slug = "-".join(w for w in title_words if w)
        if not slug:
            slug = f"ref-{number}"
        yr = str(year)
        return f"ar-{slug}-{yr}"
    else:
        parts = [p.strip() for p in author.split(",") if p.strip()]
        name_part = parts[0].lower() if parts else "ref"
        name_part = re.sub(r'[^a-z0-9\s]', '', name_part).strip()
        name_part = name_part.replace(" ", "-")
        if len(parts) > 1:
            second = parts[1].strip().lower()
            second = re.sub(r'[^a-z0-9\s]', '', second).strip()
            if second and len(second) > 1:
                name_part += f"-{second.split()[0]}"
        if not name_part:
            name_part = "ref"
        yr = str(year)
        return f"{name_part}-{yr}"


def detect_type(rest, author):
    is_arabic = bool(re.search(r'[\u0600-\u06FF]', author))
    if is_arabic:
        if "الجريدة الرسمية" in rest:
            return "legal_decree"
        if "مقياس" in rest:
            return "course_module"
        if "وثيقة داخلية" in rest:
            return "internal_doc"
        return "arabic_regulatory"
    if rest.startswith("*") and "*" in rest[1:]:
        return "book"
    if rest.startswith("*") and "(" in rest:
        return "thesis"
    if rest.startswith("*"):
        return "book"
    if "*The International Journal" in rest or "*Factory" in rest or "*Harvard Business Review" in rest or "*The International" in rest:
        return "journal_article"
    if "Microsoft" in author:
        return "tech_doc"
    if "Github" in rest or "GitHub" in rest:
        return "software"
    if "Mémoire" in rest:
        return "thesis"
    return "other"


def extract_all_entries(md_path):
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    entries = []
    seen_keys = set()
    current_section_ar = ""
    current_section_en = ""
    in_bib = False

    for line in lines:
        if line.startswith("# قائمة المصادر والمراجع"):
            in_bib = True
            continue
        if not in_bib:
            continue
        if line.startswith("# ") and "قائمة المصادر" not in line and "قائمة المصطلحات" in line:
            break
        if line.startswith("# ") and "قائمة" in line:
            break

        section_m = re.match(r'^## (.+?):', line)
        if section_m:
            label = section_m.group(1)
            current_section_ar = SECTION_LABELS.get(label, label)
            current_section_en = SECTION_EN.get(label, f"section_{label}")
            continue

        parsed = parse_entry(line)
        if parsed:
            num, author, year, rest = parsed
            entry_type = detect_type(rest, author)
            key = make_key(author, year, rest, num)
            while key in seen_keys:
                key = f"{key}-{num}"
            seen_keys.add(key)
            inline = num in INLINE_CITED_BODY

            entries.append({
                "number": num,
                "key": key,
                "type": entry_type,
                "authors": author,
                "year": year,
                "title_full": rest,
                "section_ar": current_section_ar,
                "section_en": current_section_en,
                "inline_cited": inline,
                "linked_pdf": None,
            })

    return entries


def build_pdf_mapping(entries):
    pdf_map = {}
    for semester, sem_map in SEMESTER_PDF_MAP.items():
        for num_str, pdf_name in sem_map.items():
            pdf_path = str(REFS_DIR / semester / pdf_name)
            pdf_map[num_str] = {
                "bib_number": int(num_str),
                "semester": semester,
                "pdf_name": pdf_name,
                "pdf_path": pdf_path,
                "exists": os.path.exists(pdf_path),
            }

    linked = 0
    for entry in entries:
        num = entry["number"]
        if str(num) in pdf_map:
            pdf_info = pdf_map[str(num)]
            entry["linked_pdf"] = pdf_info["pdf_path"]
            if pdf_info["exists"]:
                linked += 1

    return pdf_map, linked


def clean_old_naming():
    if not OLD_NAMING.exists():
        print("No Old_Naming directory found, skipping.")
        return 0

    moved = 0
    for old_file in OLD_NAMING.iterdir():
        if not old_file.is_file() or old_file.suffix.lower() != '.pdf':
            continue
        name = old_file.name
        found = False
        for _, sem_map in SEMESTER_PDF_MAP.items():
            for _, pdf_name in sem_map.items():
                if pdf_name.lower() == name.lower() or name.lower().endswith(pdf_name.lower()):
                    found = True
                    break
            if found:
                break
        if not found:
            dest = REFS_DIR / "Archive" / name
            shutil.move(str(old_file), str(dest))
            moved += 1
            print(f"  Moved {name} \u2192 Archive/")

    if moved == 0 and any(OLD_NAMING.iterdir()):
        remaining = list(OLD_NAMING.iterdir())
        for f in remaining:
            if f.is_file():
                dest = REFS_DIR / "Archive" / f.name
                shutil.move(str(f), str(dest))
                moved += 1
                print(f"  Moved (fallback) {f.name} \u2192 Archive/")

    if OLD_NAMING.exists():
        try:
            OLD_NAMING.rmdir()
            print(f"  Removed empty Old_Naming directory")
        except OSError:
            print(f"  Old_Naming not empty, skipping removal")

    return moved


def main():
    print("=" * 50)
    print("Academix v13.2 \u2014 Master Reference Builder")
    print("=" * 50)

    print(f"\n[1/5] Extracting entries from {THESIS_MD}...")
    entries = extract_all_entries(THESIS_MD)
    print(f"  Found {len(entries)} bibliography entries")

    sections = {}
    for e in entries:
        s = e["section_ar"]
        sections.setdefault(s, 0)
        sections[s] += 1
    for s, c in sections.items():
        print(f"    {s}: {c} entries")

    print(f"\n[2/5] Building pdf-mapping.json...")
    pdf_map, linked = build_pdf_mapping(entries)
    with open(PDF_MAPPING, 'w', encoding='utf-8') as f:
        json.dump(pdf_map, f, ensure_ascii=False, indent=2)
    print(f"  Written: {PDF_MAPPING}")
    print(f"  Linked PDFs found: {linked}/{len(pdf_map)}")

    print(f"\n[3/5] Building master-references.json (with PDF links)...")
    os.makedirs(REFS_DIR, exist_ok=True)
    with open(MASTER_JSON, 'w', encoding='utf-8') as f:
        json.dump(entries, f, ensure_ascii=False, indent=2)
    print(f"  Written: {MASTER_JSON} ({os.path.getsize(MASTER_JSON)} bytes)")

    print(f"\n[4/5] Counting inline citations in body...")
    with open(THESIS_MD, 'r', encoding='utf-8') as f:
        body = f.read()
    bib_start = body.find("# قائمة المصادر والمراجع")
    body_only = body[:bib_start] if bib_start > 0 else body
    inline_pattern = re.findall(r'\([A-Z][A-Za-z\s&,\.\-;]+,\s*\d{4}\)', body_only)
    unique_cites = set(inline_pattern)
    print(f"  Inline (Author, Year) citations found in body: {len(unique_cites)}")

    print(f"\n[5/5] Cleaning Old_Naming directory...")
    moved = clean_old_naming()
    print(f"  Files handled: {moved}")

    print(f"\n{'=' * 50}")
    print(f"SUMMARY:")
    print(f"  Bibliography entries: {len(entries)}")
    print(f"  Inline citations in body: {len(unique_cites)}")
    print(f"  PDFs linked to bib entries: {linked}")
    print(f"  Old_Naming files handled: {moved}")
    print(f"{'=' * 50}")


if __name__ == "__main__":
    main()