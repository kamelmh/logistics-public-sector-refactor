"""fixers.footer — Footer injection with PAGE field for single-section layout."""

import re
import zipfile
from .constants import REL_URI, _zip_replace


_FOOTER_XML = b'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
       xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex"
       xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
       xmlns:o="urn:schemas-microsoft-com:office:office"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
       xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
       xmlns:v="urn:schemas-microsoft-com:vml"
       xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
       xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
       xmlns:w10="urn:schemas-microsoft-com:office:word"
       xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
       xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
       xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
       xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex"
       xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
       xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
       xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
       xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
       mc:Ignorable="w14 w15 w16se wp14">
  <w:p>
    <w:pPr>
      <w:jc w:val="center"/>
      <w:bidi w:val="1"/>
      <w:rPr>
        <w:rFonts w:ascii="Traditional Arabic" w:hAnsi="Traditional Arabic"
                  w:cs="Traditional Arabic"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
    </w:pPr>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Traditional Arabic" w:hAnsi="Traditional Arabic"
                  w:cs="Traditional Arabic"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
      <w:fldChar w:fldCharType="begin"/>
    </w:r>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Traditional Arabic" w:hAnsi="Traditional Arabic"
                  w:cs="Traditional Arabic"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
      <w:instrText xml:space="preserve"> PAGE </w:instrText>
    </w:r>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Traditional Arabic" w:hAnsi="Traditional Arabic"
                  w:cs="Traditional Arabic"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
      <w:fldChar w:fldCharType="separate"/>
    </w:r>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Traditional Arabic" w:hAnsi="Traditional Arabic"
                  w:cs="Traditional Arabic"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
      <w:fldChar w:fldCharType="end"/>
    </w:r>
  </w:p>
</w:ftr>
'''

_FOOTER_BLANK_XML = b'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:p><w:pPr><w:jc w:val="center"/></w:pPr></w:p>
</w:ftr>
'''


def inject_footer(docx_path, changes):
    """Inject footer for SINGLE-SECTION document with 'different first page'.

    - footer1.xml = blank (cover/first page)
    - footer2.xml = PAGE field (all other pages)
    - Page numbering: decimal, start=1 (cover counts as page 1, no display)
    """
    with zipfile.ZipFile(docx_path, 'r') as z:
        names = z.namelist()
        rels_raw = z.read('word/_rels/document.xml.rels').decode('utf-8')
        doc_raw  = z.read('word/document.xml').decode('utf-8')
        ct_raw   = z.read('[Content_Types].xml').decode('utf-8')

    # Add content type entries for footer1.xml and footer2.xml
    ft_ct = 'application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml'
    new_ct = ct_raw
    for part in ['/word/footer1.xml', '/word/footer2.xml']:
        if part not in new_ct:
            new_ct = new_ct.replace(
                '</Types>',
                f'<Override PartName="{part}" ContentType="{ft_ct}"/></Types>'
            )

    # Add relationship entries
    new_rels = rels_raw
    new_rels = re.sub(r'<Relationship[^>]*Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer"[^/>]*/>', '', new_rels)
    new_rels = re.sub(r'<Relationship[^>]*Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer">.*?</Relationship>', '', new_rels)

    footer_rel = '<Relationship Id="{rid}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="{target}"/>'

    if 'rIdFooter1' not in new_rels:
        new_rels = new_rels.replace(
            '</Relationships>',
            footer_rel.format(rid='rIdFooter1', target='footer1.xml') + '</Relationships>'
        )
    if 'rIdFooter2' not in new_rels:
        new_rels = new_rels.replace(
            '</Relationships>',
            footer_rel.format(rid='rIdFooter2', target='footer2.xml') + '</Relationships>'
        )

    # Wire sectPr footerReference in document.xml
    new_doc = re.sub(r'<w:footerReference[^/]*/>', '', doc_raw)
    new_doc = re.sub(r'<w:footerReference[^>]*></w:footerReference>', '', new_doc)

    def _wire_section(m):
        s = m.group(0)
        if 'w:footerReference' in s:
            return s
        ref_default = f'<w:footerReference w:type="default" r:id="rIdFooter2" xmlns:r="{REL_URI}"/>'
        ref_first = f'<w:footerReference w:type="first" r:id="rIdFooter1" xmlns:r="{REL_URI}"/>'
        return s.replace('</w:sectPr>', ref_default + ref_first + '</w:sectPr>')

    new_doc = re.sub(
        r'<w:sectPr\b[^>]*>.*?</w:sectPr>',
        _wire_section,
        new_doc,
        flags=re.DOTALL
    )

    replacements = {
        'word/footer1.xml': _FOOTER_BLANK_XML,
        'word/footer2.xml': _FOOTER_XML,
        'word/_rels/document.xml.rels': new_rels.encode('utf-8'),
        'word/document.xml':       new_doc.encode('utf-8'),
        '[Content_Types].xml':     new_ct.encode('utf-8'),
    }
    _zip_replace(docx_path, replacements)
    changes['footer_injected'] = True
    return changes
