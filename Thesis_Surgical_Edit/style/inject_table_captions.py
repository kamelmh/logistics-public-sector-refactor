"""inject_table_captions.py — Inject Caption style + SEQ fields for body tables.

After pandoc generates the DOCX, this script:
1. Finds all <w:tbl> elements in the body
2. Identifies body tables (before annexes section)
3. Injects Caption paragraphs with SEQ جدول fields before each body table
4. Or applies Caption style to existing caption-like paragraphs

Usage: python inject_table_captions.py <path/to.docx> [--save]
"""
import sys, os, re, shutil, zipfile
from lxml import etree

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
W_NS = f'{{{W}}}'

# Body table patterns from MD (the 10 body tables)
BODY_TABLE_MARKERS = [
    'المؤشرات الكمية',      # tbl:01
    'مصفوفة تحليل الفجوات',  # tbl:02
    'مقارنة مؤشرات الأداء',  # tbl:03
    'التحقق من صحة الفرضيات', # tbl:04
    'التوصيات',              # tbl:06
    'BTS',                   # BTS table
    'XYZ',                   # XYZ table
    'ABC',                   # ABC table
    'BTS Competency',        # English BTS
    'Indicateurs',           # French indicators
]

# Table titles for TOF (maps table number to descriptive title)
TABLE_TITLES = {
    1: 'التحليل الكمي — نماذج ويلسون و ABC',
    2: 'مصفوفة تحليل الفجوات',
    3: 'مقارنة مؤشرات الأداء قبل وبعد التطبيق',
    4: 'التحقق من صحة الفرضيات',
    5: 'الإحصاء الوصفي للمؤشرات',
    6: 'التوصيات المقدمة لمصلحة المخازن',
    7: 'نتائج تحليل ABC',
    8: 'نتائج تحليل XYZ',
    9: 'التوافق مع منهاج BTS',
    10: 'المؤشرات التشغيلية',
    11: 'إحصائيات النظام',
}

ANNEX_MARKERS = [
    'الملاحق', 'Annexes', 'ملحق',
    'هيكل ملف النظام', 'وحدات VBA', 'بيانات المخزون',
    'نماذج الوثائق', 'نشر النماذج', 'نظام دعم القرار والمرجعيات',
]


def get_text(elem):
    """Get text content of an XML element."""
    texts = elem.findall(f'.//{W_NS}t')
    return ''.join(t.text or '' for t in texts)


def is_before_annexes(elem, all_children):
    """Check if an element comes before the annexes section."""
    elem_idx = None
    annex_idx = None
    for i, child in enumerate(all_children):
        if child is elem:
            elem_idx = i
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            pStyle = child.find(f'.//{W_NS}pStyle')
            if pStyle is not None:
                val = pStyle.get(f'{{{W}}}val', '')
                if 'Heading1' in val:
                    text = get_text(child)
                    for marker in ANNEX_MARKERS:
                        if marker in text:
                            annex_idx = i
                            break
    if elem_idx is not None and annex_idx is not None:
        return elem_idx < annex_idx
    if elem_idx is not None and annex_idx is None:
        return True  # No annexes found, assume body
    return False


def find_preceding_paragraph(tbl_elem, children):
    """Find the paragraph element immediately preceding a table."""
    tbl_idx = None
    for i, child in enumerate(children):
        if child is tbl_elem:
            tbl_idx = i
            break
    if tbl_idx is None:
        return None
    # Search backwards for the nearest paragraph
    for i in range(tbl_idx - 1, -1, -1):
        child = children[i]
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag == 'p':
            return child
    return None


def make_caption_paragraph(text, seq_num, title=''):
    """Create a Caption paragraph with SEQ field and optional title."""
    # Build the paragraph XML
    p = etree.Element(f'{W_NS}p')
    pPr = etree.SubElement(p, f'{W_NS}pPr')
    pStyle = etree.SubElement(pPr, f'{W_NS}pStyle')
    pStyle.set(f'{W_NS}val', 'Caption')

    # RTL
    rPr = etree.SubElement(pPr, f'{W_NS}rPr')
    rtl = etree.SubElement(rPr, f'{W_NS}rtl')

    # Text run: "الجدول رقم "
    r1 = etree.SubElement(p, f'{W_NS}r')
    rPr1 = etree.SubElement(r1, f'{W_NS}rPr')
    rtl1 = etree.SubElement(rPr1, f'{W_NS}rtl')
    t1 = etree.SubElement(r1, f'{W_NS}t')
    t1.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t1.text = text

    # SEQ field run
    r_begin = etree.SubElement(p, f'{W_NS}r')
    fldChar_begin = etree.SubElement(r_begin, f'{W_NS}fldChar')
    fldChar_begin.set(f'{W_NS}fldCharType', 'begin')

    r_instr = etree.SubElement(p, f'{W_NS}r')
    instrText = etree.SubElement(r_instr, f'{W_NS}instrText')
    instrText.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    instrText.text = ' SEQ جدول \\* ARABIC'

    r_separate = etree.SubElement(p, f'{W_NS}r')
    fldChar_separate = etree.SubElement(r_separate, f'{W_NS}fldChar')
    fldChar_separate.set(f'{W_NS}fldCharType', 'separate')

    r_num = etree.SubElement(p, f'{W_NS}r')
    t_num = etree.SubElement(r_num, f'{W_NS}t')
    t_num.text = str(seq_num)

    r_end = etree.SubElement(p, f'{W_NS}r')
    fldChar_end = etree.SubElement(r_end, f'{W_NS}fldChar')
    fldChar_end.set(f'{W_NS}fldCharType', 'end')

    # Add title if provided (after the SEQ field)
    if title:
        r_title = etree.SubElement(p, f'{W_NS}r')
        rPr_title = etree.SubElement(r_title, f'{W_NS}rPr')
        rtl_title = etree.SubElement(rPr_title, f'{W_NS}rtl')
        t_title = etree.SubElement(r_title, f'{W_NS}t')
        t_title.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        t_title.text = f': {title}'

    return p


def inject_captions(docx_path, save=False):
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc_xml = z.read('word/document.xml')

    root = etree.fromstring(doc_xml)
    body = root.find(f'.//{W_NS}body')
    children = list(body)

    # Find all tables
    tables = [c for c in children if c.tag.endswith('}tbl')]
    print(f'[CAPTION] Found {len(tables)} tables total')

    # Identify body tables
    body_tables = []
    for tbl in tables:
        if is_before_annexes(tbl, children):
            body_tables.append(tbl)

    print(f'[CAPTION] Body tables: {len(body_tables)}')

    # Count injected
    injected = 0
    for seq, tbl in enumerate(body_tables, 1):
        prev_p = find_preceding_paragraph(tbl, children)
        if prev_p is not None:
            prev_text = get_text(prev_p)
            # Check if this paragraph already looks like a caption
            pStyle = prev_p.find(f'.//{W_NS}pStyle')
            if pStyle is not None and pStyle.get(f'{W_NS}val', '') == 'Caption':
                print(f'  Table {seq}: Already has Caption style, skipping')
                continue
            # Check if it contains table number text
            if 'جدول' in prev_text or 'table' in prev_text.lower() or 'الجدول' in prev_text:
                # Apply Caption style to existing paragraph
                if pStyle is None:
                    pPr = prev_p.find(f'{W_NS}pPr')
                    if pPr is None:
                        pPr = etree.SubElement(prev_p, f'{W_NS}pPr')
                    pStyle = etree.SubElement(pPr, f'{W_NS}pStyle')
                pStyle.set(f'{W_NS}val', 'Caption')
                print(f'  Table {seq}: Applied Caption style to existing paragraph')
                injected += 1
                continue

        # Inject new caption paragraph before the table
        tbl_idx = children.index(tbl)
        title = TABLE_TITLES.get(seq, '')
        caption_p = make_caption_paragraph(f'الجدول رقم ', seq, title)
        body.insert(tbl_idx, caption_p)
        injected += 1
        print(f'  Table {seq}: Injected caption with title: {title[:50]}')

    print(f'[CAPTION] Total captions handled: {injected}')

    if save:
        new_xml = etree.tostring(root, xml_declaration=True, encoding='UTF-8', standalone=True)
        temp = docx_path + '.tmp'
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(temp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    if item.filename == 'word/document.xml':
                        zout.writestr(item, new_xml)
                    else:
                        zout.writestr(item, zin.read(item.filename))
        shutil.move(temp, docx_path)
        print(f'[CAPTION] Saved: {docx_path}')

    return injected


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python inject_table_captions.py <path/to.docx> [--save]')
        sys.exit(1)
    path = sys.argv[1]
    save = '--save' in sys.argv
    inject_captions(path, save)
