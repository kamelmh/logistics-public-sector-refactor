# Thesis Gold-Standard Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal**: Implement a regulated build pipeline that eliminates the "Page 1" bug and ensures perfect RTL/LTR alignment for all captions in the thesis DOCX.

**Architecture**: A gated pipeline: `Build` $\rightarrow$ `Surgical Fix` $\rightarrow$ `COM Update` $\rightarrow$ `Final Audit` $\rightarrow$ `PDF`.

**Tech Stack**: Python (lxml, pywin32), PowerShell, Word COM.

---

### Task 1: The COM Control Layer (`Thesis_COM_Control.py`)
This module provides the low-level interface to Word for field updates and visual verification.

**Files**:
- Create: `Thesis_Surgical_Edit/Thesis_COM_Control.py`

- [ ] **Step 1: Implement `force_field_update()`**
  This function will open the document, select all content, and execute the `F9` command.
  ```python
  import win32com.client
  def force_field_update(doc_path):
      word = win32com.client.Dispatch("Word.Application")
      word.Visible = False
      doc = word.Documents.Open(doc_path)
      word.Selection.WholeStory()
      word.Selection.Fields.Update()
      doc.Save()
      doc.Close()
      word.Quit()
  ```
- [ ] **Step 2: Implement `verify_footer_text(page_num)`**
  This function will navigate to a specific page and read the rendered text of the footer.
  ```python
  def verify_footer_text(doc_path, page_num):
      word = win32com.client.Dispatch("Word.Application")
      doc = word.Documents.Open(doc_path)
      # Navigate to page
      word.Selection.GoTo(1, 1, page_num) # 1 = wdGoToPage
      # Access footer of current section
      footer = doc.Sections(doc.Selection.Sections(1).Index).Footers(1).Range.Text
      doc.Close()
      word.Quit()
      return footer.strip()
  ```
- [ ] **Step 3: Test COM Control**
  Run a test script that opens the DOCX, updates fields, and prints the footer of page 2.
  Expected: Footer text should be "2" (or the correct page number), not "1".
- [ ] **Step 4: Commit**
  `git add Thesis_Surgical_Edit/Thesis_COM_Control.py`
  `git commit -m "feat(thesis): add COM control layer for field updates and verification"`

---

### Task 2: The Inspector (`Thesis_Inspector.py`)
The "Eye" of the system. It identifies structural and visual anomalies.

**Files**:
- Create: `Thesis_Surgical_Edit/Thesis_Inspector.py`
- Dependency: `Thesis_COM_Control.py`

- [ ] **Step 1: Implement `scan_xml_for_page1_bug()`**
  Scan `word/footer*.xml` for `w:fldSimple` or `w:instrText` containing `PAGE` that has cached text results.
- [ ] **Step 1b: Implement `scan_for_ghost_text()`**
  Scan `word/document.xml` for stray paragraphs or text boxes positioned at the bottom of pages that do not belong to the official footer/footnote structure.
- [ ] **Step 2: Implement `scan_captions_alignment()`**
  Scan `word/document.xml` for all captions. Detect language (Arabic/French) and check for `w:bidi` and `w:rtl` tags.
- [ ] **Step 3: Implement `perform_visual_audit()`**
  Use `Thesis_COM_Control.verify_footer_text()` to check a sample of pages (e.g., 2, 10, 20, last page).
- [ ] **Step 4: Implement `generate_audit_report()`**
  Combine XML and COM results into a `thesis_audit_report.json`.
- [ ] **Step 5: Test Inspector**
  Run against the current `v7c` DOCX.
  Expected: Report should identify the "Page 1" bug and any misaligned captions.
- [ ] **Step 6: Commit**
  `git add Thesis_Surgical_Edit/Thesis_Inspector.py`
  `git commit -m "feat(thesis): add deep inspector for XML and COM audit"`

---

### Task 3: The Fixer (`Thesis_Fixer.py`)
The "Surgeon." It applies targeted XML patches based on the Inspector's report.

**Files**:
- Create: `Thesis_Surgical_Edit/Thesis_Fixer.py`
- Dependency: `lxml`

- [ ] **Step 1: Implement `clear_page_field_cache()`**
  Open the DOCX as a ZIP, find `footer*.xml`, and remove the cached text results from `PAGE` fields.
- [ ] **Step 1b: Implement `remove_ghost_text()`**
  Surgically remove the stray paragraphs/text boxes identified by the Inspector from `word/document.xml`.
- [ ] **Step 2: Implement `fix_caption_alignment()`**
  Apply `w:bidi="1"` and `w:rtl="1"` to Arabic captions and `w:bidi="0"` to French captions in `document.xml`.
- [ ] **Step 3: Implement `apply_fixes_from_report(report_json)`**
  Read the `thesis_audit_report.json` and apply only the necessary fixes.
- [ ] **Step 4: Test Fixer**
  Run Fixer on a buggy DOCX $\rightarrow$ Run Inspector.
  Expected: Inspector should now report "No structural issues found."
- [ ] **Step 5: Commit**
  `git add Thesis_Surgical_Edit/Thesis_Fixer.py`
  `git commit -m "feat(thesis): add surgical fixer for XML layout bugs"`

---

### Task 4: The Orchestrator (`Thesis_Orchestrator.ps1`)
The "Brain" that regulates the pipeline and enforces quality gates.

**Files**:
- Create: `Thesis_Surgical_Edit/Thesis_Orchestrator.ps1`

- [ ] **Step 1: Implement Pipeline Sequence**
  Write the logic to call: `Build` $\rightarrow$ `Fixer` $\rightarrow$ `COM Update` $\rightarrow$ `Inspector`.
- [ ] **Step 2: Implement Quality Gates**
  Add logic: `if ($Inspector.Result -ne "PASS") { throw "Quality Gate Failed: $Reason" }`.
- [ ] **Step 3: Implement PDF Promotion**
  Only call `build-thesis.ps1`'s PDF generation if the final audit is "PASS".
- [ ] **Step 4: Implement Failure Artifacts**
  Save failed documents as `Memoire_FAIL_<timestamp>.docx`.
- [ ] **Step 5: Test Orchestrator**
  Run the full pipeline.
  Expected: A "Verified Golden DOCX" and a corresponding PDF.
- [ ] **Step 6: Commit**
  `git add Thesis_Surgical_Edit/Thesis_Orchestrator.ps1`
  `git commit -m "feat(thesis): add regulated orchestrator with quality gates"`

---

### Task 5: Integration & Regulation (`build-thesis.ps1`)
Integrating the orchestrator into the main build script.

**Files**:
- Modify: `Thesis_Surgical_Edit/build-thesis.ps1`

- [ ] **Step 1: Add `-Regulated` parameter**
  Update the param block to include `[switch]$Regulated`.
- [ ] **Step 2: Implement Orchestrator Delegation**
  If `$Regulated` is true, call `Thesis_Orchestrator.ps1` instead of the standard PDF build.
- [ ] **Step 3: Final End-to-End Test**
  Run `& "Thesis_Surgical_Edit/build-thesis.ps1" -Regulated`.
  Expected: Full pipeline execution $\rightarrow$ Golden DOCX $\rightarrow$ Golden PDF.
- [ ] **Step 4: Commit**
  `git add Thesis_Surgical_Edit/build-thesis.ps1`
  `git commit -m "feat(thesis): integrate regulated pipeline into build script"`
