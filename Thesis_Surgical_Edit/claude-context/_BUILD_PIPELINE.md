# Build Pipeline Guide — for Claude Code

## Pipeline Steps
```
Markdown source → pandoc (DOCX) → Python post-process → PDF via Word
```

## Step-by-step

### Step 1: Reference DOCX
```bash
pandoc -o style/reference-in.docx --print-default-data-file reference.docx
python style/customize-reference.py
```
Generates `style/reference.docx` with user's original formatting.

### Step 2: Generate DOCX from Markdown
```bash
pandoc Memoire_DSS_Logistique_ElBayadh.md \
  --from markdown+grid_tables-yaml_metadata_block \
  --to docx \
  --reference-doc style/reference.docx \
  --metadata-file style/thesis-metadata.yaml \
  --resource-path "images;." \
  --output output/Memoire_Academix_v13_2_Final.docx
```

### Step 3: Post-process tables
```bash
python style/format-tables.py output/Memoire_Academix_v13_2_Final.docx
```

### Step 4: Format cover
```bash
python style/format-cover.py output/Memoire_Academix_v13_2_Final.docx
```

### Step 5: PDF via Word COM
```powershell
$word = New-Object -ComObject Word.Application
$doc = $word.Documents.Open("output/Memoire_Academix_v13_2_Final.docx")
$doc.SaveAs2("output/Memoire_Academix_v13_2_Final.pdf", 17)
$doc.Close(); $word.Quit()
```

### Step 6: Verify
Check both DOCX and PDF exist and have reasonable sizes.

## For Claude's DOCX Generation
If generating directly via python-docx (recommended for precision):
1. Clone `cover-page.docx` using python-docx
2. Insert body content paragraph by paragraph with proper formatting
3. Apply table styles
4. Save as `Memoire_Academix_v13_2_POLISHED.docx`
5. Then convert to PDF via Word COM (Step 5)

## File Locations
| Path | Purpose |
|------|---------|
| `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` | Source markdown |
| `Thesis_Surgical_Edit/style/reference.docx` | Style template |
| `Thesis_Surgical_Edit/style/thesis-metadata.yaml` | Metadata |
| `Thesis_Surgical_Edit/cover-page.docx` | Cover page (user's design) |
| `Thesis_Surgical_Edit/output/` | Output directory |
| `Thesis_Surgical_Edit/style/customize-reference.py` | Reference builder |
| `Thesis_Surgical_Edit/style/format-tables.py` | Table formatter |
| `Thesis_Surgical_Edit/style/format-cover.py` | Cover formatter |
