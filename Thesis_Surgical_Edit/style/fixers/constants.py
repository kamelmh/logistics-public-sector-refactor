"""Shared constants and helpers for thesis fixers."""

import os
import re
import time as _time
import zipfile

from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
from docx.shared import Pt

# ── Namespace constants ────────────────────────────────────────────────────────
W_URI  = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
MC_URI = 'http://schemas.openxmlformats.org/markup-compatibility/2006'
REL_URI = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'

EXTRA_NS = [
    ('mc',    MC_URI),
    ('w14',   'http://schemas.microsoft.com/office/word/2010/wordml'),
    ('w15',   'http://schemas.microsoft.com/office/word/2012/wordml'),
    ('w16se', 'http://schemas.microsoft.com/office/word/2015/wordml/symex'),
    ('w16cid','http://schemas.microsoft.com/office/word/2016/wordml/cid'),
    ('wp14',  'http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing'),
]

# ── Golden formatting values ───────────────────────────────────────────────────
GOLDEN = {
    'bodyFont'    : 'Traditional Arabic',
    'bodySize'    : 14,
    'h1Size'      : 22,
    'h2Size'      : 18,
    'h3Size'      : 16,
    'footnoteSize': 12,
    'marginsCm'   : 2.5,
    'pageWidthCm' : 21.0,
    'pageHeightCm': 29.7,
}

# Styles to receive full body treatment (font + size + spacing + RTL)
BODY_STYLES = [
    'Normal', 'Compact', 'Body Text', 'List Paragraph', 'No Spacing',
    'Caption', 'Annotation Text', 'Table Contents', 'Table Grid',
]
FOOTNOTE_STYLES = ['Footnote Text', 'footnote text', 'Footnote Reference']
HEADING_SIZES = {
    'Heading 1': GOLDEN['h1Size'], 'Titre 1': GOLDEN['h1Size'],
    'Heading 2': GOLDEN['h2Size'], 'Titre 2': GOLDEN['h2Size'],
    'Heading 3': GOLDEN['h3Size'], 'Titre 3': GOLDEN['h3Size'],
}


def _is_arabic_run(text):
    """Return True if text contains Arabic characters."""
    return any('\u0600' <= c <= '\u06ff' or '\ufe70' <= c <= '\ufeff' for c in text)


def _safe_replace(tmp_path, target_path, retries=4):
    """Replace target_path with tmp_path, retrying on Windows file-lock errors."""
    for attempt in range(retries):
        try:
            os.replace(tmp_path, target_path)
            return
        except PermissionError:
            _time.sleep(1.5)
    os.replace(tmp_path, target_path)


def _zip_replace(docx_path, replacements: dict):
    """Rewrite a DOCX zip replacing only the entries listed in replacements dict."""
    import tempfile
    fd, tmp = tempfile.mkstemp(suffix='.tmp', prefix='thesis_',
                               dir=os.path.dirname(docx_path))
    os.close(fd)
    try:
        with zipfile.ZipFile(docx_path, 'r') as zin:
            with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.namelist():
                    if item in replacements:
                        zout.writestr(item, replacements[item])
                    else:
                        zout.writestr(item, zin.read(item))
        existing = set()
        with zipfile.ZipFile(docx_path, 'r') as zin:
            existing = set(zin.namelist())
        new_entries = {k: v for k, v in replacements.items() if k not in existing}
        if new_entries:
            with zipfile.ZipFile(tmp, 'a', zipfile.ZIP_DEFLATED) as zout:
                for arc, data in new_entries.items():
                    zout.writestr(arc, data)
        _safe_replace(tmp, docx_path)
    except Exception:
        if os.path.exists(tmp):
            try:
                os.remove(tmp)
            except Exception:
                pass
        raise
