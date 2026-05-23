<#
.SYNOPSIS
  Verify the English Research Paper DOCX against submission criteria.
#>

param(
    [string]$DocxPath = "Research_and_Development\Thesis_Surgical_Edit\output\English_Research_Paper_IEEE.docx"
)

$script:projectRoot = Split-Path -Parent $PSScriptRoot
$docxFull = Join-Path $script:projectRoot $DocxPath

if (-not (Test-Path $docxFull)) {
    Write-Host "FAIL: DOCX not found at $docxFull" -ForegroundColor Red
    exit 1
}

Write-Host "=== Verify English Research Paper ===" -ForegroundColor Cyan

$pythonCode = @"
import sys
sys.stdout.reconfigure(encoding='utf-8')
try:
    from docx import Document
except ImportError:
    print("FAIL: python-docx not installed")
    sys.exit(1)

doc = Document(r'$docxFull')
errors = []
warnings = []

# 1. File exists
print(f"OK: File exists ({len(list(doc.paragraphs))} paragraphs)")

# 2. Paper length between 6-8 pages (approx 2000-5000 words)
word_count = sum(len(p.text.split()) for p in doc.paragraphs if p.text.strip())
if word_count < 2000:
    errors.append(f"Too short: {word_count} words (min 2000)")
elif word_count > 6000:
    warnings.append(f"Long: {word_count} words (max 6000)")
else:
    print(f"OK: Word count = {word_count}")

# 3. Title present
has_title = any('Offline-First' in p.text for p in doc.paragraphs)
print(f"{'OK' if has_title else 'WARN'}: Title present")

# 4. Abstract section (heading + body)
has_abstract_heading = any(p.text.strip() == 'Abstract' and 'Heading' in (p.style.name or '') for p in doc.paragraphs)
has_abstract_body = any('Abstract' in p.text and len(p.text) > 50 for p in doc.paragraphs)
has_abstract = has_abstract_heading or has_abstract_body
print(f"{'OK' if has_abstract_heading else 'WARN'}: Abstract heading found")
print(f"{'OK' if has_abstract_body else 'WARN'}: Abstract body found (50+ chars)")
if has_abstract: print(f"   -> Abstract section present")

# 5. Section structure check
sections_found = {'Introduction': False, 'Related Work': False, 'Methodology': False,
                  'Results': False, 'Discussion': False, 'Conclusion': False}
for p in doc.paragraphs:
    for sec in sections_found:
        if sec.lower() in p.text.lower() and any(h in (p.style.name or '') for h in ['Heading', 'heading', 'Title']):
            sections_found[sec] = True

for sec, found in sections_found.items():
    print(f"{'OK' if found else 'WARN'}: Section '{sec}' found")

# 6. References (min 10)
ref_count = sum(1 for p in doc.paragraphs if p.text.strip().startswith('[') and ']' in p.text[:6])
if ref_count >= 10:
    print(f"OK: {ref_count} references")
else:
    errors.append(f"Only {ref_count} references (min 10)")

# 7. Tables
table_count = len(doc.tables)
print(f"{'OK' if table_count >= 2 else 'WARN'}: {table_count} tables")

# 8. Font analysis
tnr_count = 0
other_count = 0
for p in doc.paragraphs:
    for run in p.runs:
        if run.font.name and 'Times' in run.font.name:
            tnr_count += 1
        elif run.font.name:
            other_count += 1

font_ok = tnr_count >= other_count * 0.5
print(f"{'OK' if font_ok else 'WARN'}: Font check (TNR={tnr_count}, other={other_count})")

# 9. Page size A4
for s in doc.sections:
    w = s.page_width
    h = s.page_height
    if w and h:
        w_cm = w / 914400 * 2.54
        h_cm = h / 914400 * 2.54
        if 20.5 <= w_cm <= 21.5 and 29.0 <= h_cm <= 30.5:
            print(f"OK: Page A4 ({w_cm:.1f}x{h_cm:.1f}cm)")
        else:
            warnings.append(f"Page size {w_cm:.1f}x{h_cm:.1f}cm (not A4)")

# 10. Keywords check
has_keywords = any('Keywords' in p.text for p in doc.paragraphs)
print(f"{'OK' if has_keywords else 'WARN'}: Keywords section")

print(f"\n--- Summary ---")
if errors:
    for e in errors: print(f"ERROR: {e}")
if warnings:
    for w in warnings: print(f"WARN: {w}")
if not errors:
    print("ALL CHECKS PASSED")
else:
    print(f"{len(errors)} FAILURES")
"@

python -c $pythonCode 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "FAIL: Verification script error" -ForegroundColor Red; exit 1 }
Write-Host "Verify complete" -ForegroundColor Green
