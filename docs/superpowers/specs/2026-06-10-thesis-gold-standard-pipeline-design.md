# Design Spec: Thesis Gold-Standard Pipeline
**Date**: 2026-06-10
**Status**: Draft
**Version**: 1.0

## 1. Overview
The Thesis Gold-Standard Pipeline is a regulated build system designed to eliminate structural and visual bugs in the final thesis DOCX and PDF. It replaces the "patch-and-hope" method with a "verify-and-promote" workflow, ensuring that the final submission is perfect.

## 2. Architecture
The system follows a modular, gated architecture consisting of four primary components:

### 2.1 The Orchestrator (`Thesis_Orchestrator.ps1`)
The central controller that manages the lifecycle of the document.
- **Responsibility**: Sequence execution, quality gate enforcement, and state management.
- **Logic**: It will not allow a document to proceed to the next stage unless the current stage's "Quality Gate" is passed.

### 2.2 The Inspector (`Thesis_Inspector.py`)
A deep-scan tool that analyzes the document from two perspectives:
- **XML Perspective**: Scans `word/document.xml` and `word/footer*.xml` for cached `PAGE` field results, missing `w:bidi` tags in captions, and **stray "ghost" text at the bottom of pages**.
- **COM Perspective**: Interacts with the live Word instance to read the *rendered* text of footers and the bottom-most paragraphs of each page to verify what the user actually sees.
- **Output**: A `thesis_audit_report.json` containing all identified anomalies.

### 2.3 The Fixer (`Thesis_Fixer.py`)
A surgical repair tool that applies targeted fixes based on the Inspector's report.
- **Page 1 Fix**: Strips cached results from `PAGE` fields in XML to force a re-calculation.
- **RTL/LTR Fix**: Applies `w:bidi="1"` and `w:rtl="1"` to Arabic captions and `w:bidi="0"` to French captions.
- **Constraint**: Only modifies the specific XML nodes identified by the Inspector to avoid side effects.

### 2.4 The COM Control Layer (`Thesis_COM_Control.py`)
A specialized module for interacting with the Word Application object.
- **Field Force**: Programmatically executes `Ctrl+A` $\rightarrow$ `F9` to update all fields.
- **Visual Audit**: Reads the rendered text of the last page's footer to confirm the page number matches the total page count.

## 3. Data Flow & Quality Gates

### 3.1 The Pipeline Sequence
1. **Build**: `MD` $\rightarrow$ `Raw DOCX` (via `build-thesis.ps1`).
2. **Surgical Fix**: `Raw DOCX` $\rightarrow$ `Fixed DOCX` (via `Thesis_Fixer`).
3. **COM Update**: `Fixed DOCX` $\rightarrow$ `Updated DOCX` (via `Thesis_COM_Control`).
4. **Final Audit**: `Updated DOCX` $\rightarrow$ `Verified Golden DOCX` (via `Thesis_Inspector`).
5. **PDF Generation**: `Golden DOCX` $\rightarrow$ `Final PDF`.

### 3.2 The Quality Gates
| Gate | Tool | Requirement | Action on Failure |
|------|------|-------------|-------------------|
| **Structural** | Inspector | No cached PAGE results; all captions tagged | Halt $\rightarrow$ Retry Fixer |
| **Visual** | COM Control | Rendered footer $\neq$ "1" on all pages | Halt $\rightarrow$ Manual Review |
| **Integrity** | verify_docx_checks.py | 29/29 PASS | Halt $\rightarrow$ Fix Source |

## 4. Error Handling & Recovery
- **Atomic Updates**: The pipeline never overwrites the "Last Known Good" version until the final gate is passed.
- **Failure Artifacts**: On failure, the system saves the document as `Memoire_FAIL_<timestamp>.docx` and creates a `failure_report.txt`.
- **Surgical Retry**: The Fixer can be run in "Deep Mode" to attempt more aggressive XML repairs if the standard fix fails.

## 5. Success Criteria
- **Zero "Page 1" bugs**: Every page displays its correct number.
- **Perfect Alignment**: All Arabic captions are RTL; all French captions are LTR.
- **Verified Build**: 29/29 checks pass on the final Golden DOCX.
- **Automated PDF**: PDF is generated only from a Verified Golden DOCX.
