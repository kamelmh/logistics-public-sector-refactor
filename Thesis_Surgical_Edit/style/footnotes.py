"""footnotes.py — Academix v13.2 (Titan)
Phase 2: Convert inline (Author, Year) citations to Word footnotes (CNEPD format).
Creates the footnotes XML part if it doesn't exist.
"""
import sys, re, os
import json
from lxml import etree
from docx import Document
from docx.opc.part import Part
from docx.opc.constants import RELATIONSHIP_TYPE as RT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement


W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
R = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
CT_FOOTNOTES = 'application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml'
FOOTNOTES_URI = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes'

CNEPD_PREFIX = "راجع: "
CITATION_RE = re.compile(r'\(([A-Z][A-Za-z\s&,\.\-;]+),\s*(\d{4})\)')


def clean_markdown(text):
    """Strip markdown syntax from text for Word output."""
    # Remove markdown italic/bold markers
    text = re.sub(r'\*+', '', text)
    # Convert pandoc en-dash/em-dash
    text = text.replace('---', '\u2014')  # em-dash
    text = text.replace('--', '\u2013')   # en-dash
    # Clean trailing comma before year (e.g. "journal, 1997" -> "journal 1997")
    text = re.sub(r',\s+(\d{4})$', r' \1', text)
    # Clean '.,' pattern (e.g. "D.," -> "D.")
    text = re.sub(r'\.\s*,\s*', '. ', text)
    return text.strip()


def extract_surnames(author_str):
    """Extract last names from an author string like 'Cooper, M. C., Lambert, D. M., & Pagh, J. D'"""
    surnames = []
    for part in author_str.split('&'):
        part = part.strip()
        # Get text before first comma (the surname)
        surname = part.split(',')[0].strip()
        if surname:
            surnames.append(surname)
    return surnames


def match_citation_to_ref(citation_text, year, ref):
    """Match citation text like 'Cooper, Lambert & Pagh, 1997' to a reference entry."""
    ref_year = str(ref.get('year', ''))
    if year != ref_year:
        return False

    ref_author = ref.get('authors', '')
    ref_surnames = extract_surnames(ref_author)

    # Check each surname against the citation text
    citation_lower = citation_text.lower()
    for sname in ref_surnames:
        if sname.lower() in citation_lower:
            return True

    return False


def ensure_footnotes_part(doc):
    """Create footnotes.xml part if it doesn't exist in the DOCX."""
    package = doc.part.package

    # Check if footnotes relationship already exists
    for rel in doc.part.rels.values():
        if 'footnotes' in rel.reltype:
            return rel.target_part

    # Create the footnotes XML
    FOOTNOTES_XML = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:footnotes xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
        ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<w:footnote w:type="separator" w:id="-1">'
        '<w:p><w:r><w:separator/></w:r></w:p>'
        '</w:footnote>'
        '<w:footnote w:type="continuationSeparator" w:id="0">'
        '<w:p><w:r><w:continuationSeparator/></w:r></w:p>'
        '</w:footnote>'
        '</w:footnotes>'
    )

    # Create footnotes part
    content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml'
    partname = '/word/footnotes.xml'
    footnotes_part = Part(
        partname, content_type, FOOTNOTES_XML.encode('utf-8'), package
    )

    # Add relationship from document to footnotes
    doc.part.relate_to(footnotes_part, FOOTNOTES_URI)

    return footnotes_part


def get_footnotes_xml(footnotes_part):
    """Get the lxml element for footnotes, or attach if it's bytes."""
    if isinstance(footnotes_part._blob, bytes):
        return etree.fromstring(footnotes_part._blob)
    return footnotes_part._element


def create_footnote(footnotes_part, citation_text, ref_map, cited_sources, year_str):
    """Create a professional CNEPD footnote. Returns the footnote ID."""
    root = get_footnotes_xml(footnotes_part)
    
    # Identify the source key from the citation text (e.g., "Cooper, Lambert & Pagh, 1997")
    source_key = None
    for ref in ref_map:
        if isinstance(ref, dict) and match_citation_to_ref(citation_text, year_str, ref):
            source_key = ref.get('key')
            break
    
    # Determine footnote content based on CNEPD rules
    if source_key:
        ref_data = next((r for r in ref_map if r.get('key') == source_key), {})
        if source_key not in cited_sources:
            # FIRST MENTION: Full CNEPD Bibliographic Entry
            full_ref = clean_markdown(f"{ref_data.get('authors', '')}, {ref_data.get('title_full', '')}, {ref_data.get('year', '')}")
            footnote_content = full_ref
            cited_sources.add(source_key)
        else:
            # SUBSEQUENT MENTION: op. cit.
            author_last = ref_data.get('authors', '').split(',')[0].strip()
            footnote_content = f"{author_last}, op. cit."
    else:
        footnote_content = citation_text

    max_id = 0
    for fn in root.findall(qn('w:footnote')):
        fid = int(fn.get(qn('w:id'), '0'))
        if fid > max_id:
            max_id = fid
    new_id = max_id + 1

    footnote = etree.SubElement(root, qn('w:footnote'))
    footnote.set(qn('w:id'), str(new_id))

    p = etree.SubElement(footnote, qn('w:p'))
    pPr = etree.SubElement(p, qn('w:pPr'))
    pStyle = etree.SubElement(pPr, qn('w:pStyle'))
    pStyle.set(qn('w:val'), 'FootnoteText')
    bidi = etree.SubElement(pPr, qn('w:bidi'))
    jc = etree.SubElement(pPr, qn('w:jc'))
    jc.set(qn('w:val'), 'right')

    r1 = etree.SubElement(p, qn('w:r'))
    rPr1 = etree.SubElement(r1, qn('w:rPr'))
    rStyle1 = etree.SubElement(rPr1, qn('w:rStyle'))
    rStyle1.set(qn('w:val'), 'FootnoteReference')
    fnRef = etree.SubElement(r1, qn('w:footnoteRef'))

    r2 = etree.SubElement(p, qn('w:r'))
    t2 = etree.SubElement(r2, qn('w:t'))
    t2.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t2.text = ' '

    r3 = etree.SubElement(p, qn('w:r'))
    t3 = etree.SubElement(r3, qn('w:t'))
    t3.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t3.text = f"{CNEPD_PREFIX}{footnote_content}"

    footnotes_part._blob = etree.tostring(root, xml_declaration=True, encoding='UTF-8', standalone=True)
    footnotes_part._element = root

    return new_id


def insert_footnote_reference(paragraph, fn_id):
    """Insert a footnote reference run at the end of the paragraph."""
    r = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    rStyle = OxmlElement('w:rStyle')
    rStyle.set(qn('w:val'), 'FootnoteReference')
    rPr.append(rStyle)
    r.append(rPr)

    fnRef = OxmlElement('w:footnoteReference')
    fnRef.set(qn('w:id'), str(fn_id))
    r.append(fnRef)

    last_runs = paragraph._element.findall(qn('w:r'))
    if last_runs:
        last_runs[-1].addnext(r)
    else:
        paragraph._element.append(r)


def process_docx(docx_path):
    doc = Document(docx_path)
    footnotes_part = ensure_footnotes_part(doc)
    
    # Load reference map for CNEPD full-cite logic
    ref_map_path = os.path.join(os.path.dirname(os.path.dirname(docx_path)), 'refs', 'master-references.json')
    try:
        with open(ref_map_path, 'r', encoding='utf-8') as f:
            ref_map = json.load(f)
    except Exception:
        ref_map = {}

    cited_sources = set()
    changes = 0

    for para in doc.paragraphs:
        text = para.text
        matches = list(CITATION_RE.finditer(text))
        if not matches:
            continue

        for m in reversed(matches):
            citation_text = f"{m.group(1)}, {m.group(2)}"
            full_citation = m.group(0)

            fn_id = create_footnote(footnotes_part, citation_text, ref_map, cited_sources, m.group(2))

            # Remove citation from paragraph XML runs
            char_offset = m.start()
            citation_len = len(full_citation)
            runs = list(para._element.findall(qn('w:r')))
            current_pos = 0

            for run in runs:
                t = run.find(qn('w:t'))
                if t is None or t.text is None:
                    current_pos += 1
                    continue

                run_text = t.text
                run_end = current_pos + len(run_text)

                if run_end > char_offset and current_pos < char_offset + citation_len:
                    overlap_start = max(char_offset - current_pos, 0)
                    overlap_end = min(char_offset + citation_len - current_pos, len(run_text))

                    if overlap_start == 0 and overlap_end == len(run_text):
                        run.getparent().remove(run)
                    elif overlap_start == 0:
                        t.text = run_text[overlap_end:]
                    elif overlap_end == len(run_text):
                        t.text = run_text[:overlap_start]
                    else:
                        t.text = run_text[:overlap_start]

                current_pos = run_end

            insert_footnote_reference(para, fn_id)
            changes += 1

    doc.save(docx_path)
    print(f"Footnotes added: {changes} citation{'s' if changes != 1 else ''} converted")
    return changes


def main():
    if len(sys.argv) < 2:
        print("Usage: python footnotes.py <docx_path>")
        sys.exit(1)
    process_docx(sys.argv[1])


if __name__ == '__main__':
    main()
