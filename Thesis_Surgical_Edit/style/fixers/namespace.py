"""fixers.namespace — Fix python-docx ns0/ns1 namespace pollution."""

import re
import zipfile
from .constants import EXTRA_NS, _zip_replace


def fix_word_compat(docx_path, changes):
    """Fix python-docx ns0/ns1 namespace prefix pollution in footnotes/endnotes."""
    targets = ['word/footnotes.xml', 'word/endnotes.xml']
    replacements = {}
    with zipfile.ZipFile(docx_path, 'r') as z:
        names = z.namelist()
        for tgt in targets:
            if tgt not in names:
                continue
            raw = z.read(tgt).decode('utf-8')
            orig = raw
            raw = raw.replace('ns1:Ignorable', 'mc:Ignorable')
            raw = re.sub(r'xmlns:ns0="([^"]+)"', r'xmlns:w="\1"', raw)
            raw = re.sub(r'xmlns:ns1="([^"]+)"', r'xmlns:mc="\1"', raw)
            raw = re.sub(r'\bns0:', 'w:', raw)
            raw = re.sub(r'\bns1:', 'mc:', raw)
            for prefix, uri in EXTRA_NS:
                if ('xmlns:%s=' % prefix) not in raw:
                    m = re.search(r'<w?:footnotes[\s>]', raw)
                    if m:
                        gt = raw.find('>', m.start())
                        if gt > 0:
                            raw = raw[:gt] + ' xmlns:%s="%s"' % (prefix, uri) + raw[gt:]
            if raw != orig:
                replacements[tgt] = raw.encode('utf-8')
    if replacements:
        _zip_replace(docx_path, replacements)
    changes['compat_fixes'] = len(replacements)
    return changes
