#!/usr/bin/env python3
"""Get body statistics from a DOCX file."""
import zipfile
import sys
from xml.etree import ElementTree as ET

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'

def get_stats(docx_path):
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc = ET.fromstring(z.read('word/document.xml'))
        fn = ET.fromstring(z.read('word/footnotes.xml'))
        body = doc.find('.//' + W + 'body')
        paras = len([c for c in body if c.tag.endswith('}p')])
        tables = len([c for c in body if c.tag.endswith('}tbl')])
        fn_real = len([f for f in fn.findall('.//' + W + 'footnote') if f.get(W+'id','0') not in ('0','-1')])
        return paras, tables, fn_real

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: get_body_stats.py <docx_path>")
        sys.exit(1)
    paras, tables, fn_real = get_stats(sys.argv[1])
    print(f'paras={paras} tables={tables} footnotes={fn_real}')
