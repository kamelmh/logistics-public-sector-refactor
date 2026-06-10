import win32com.client
import os

def force_field_update(doc_path):
    """
    Opens a Word document, updates all fields in body, headers, and footers, saves and closes it.
    """
    if not os.path.isabs(doc_path):
        doc_path = os.path.abspath(doc_path)

    word = win32com.client.Dispatch("Word.Application")
    word.Visible = False
    try:
        doc = word.Documents.Open(doc_path)
        print(f"DEBUG: Type of doc: {type(doc)}")

        
        # 1. Update body fields
        # Ensure we are working with the active document, not the Word application object
        active_doc = word.ActiveDocument
        active_doc.Content.Fields.Update()

        # 2. Update all headers and footers in all sections
        for section in active_doc.Sections:
            for header in section.Headers:
                header.Range.Fields.Update()
            for footer in section.Footers:
                footer.Range.Fields.Update()
                
        doc.Save()
        doc.Close()
    finally:
        word.DisplayAlerts = False # Suppress any prompts
        word.Quit()

def verify_footer_text(doc_path, page_num):
    """
    Opens a Word document, navigates to a specific page, and returns the footer text.
    """
    if not os.path.isabs(doc_path):
        doc_path = os.path.abspath(doc_path)

    word = win32com.client.Dispatch("Word.Application")
    word.Visible = False
    try:
        doc = word.Documents.Open(doc_path)
        # 1 = wdGoToPage, 1 = wdGoToAbsolute
        word.Selection.GoTo(1, 1, page_num)
        
        section = word.Selection.Sections(1)
        # Try Primary, FirstPage, and EvenPages
        for footer_type in [1, 2, 3]: # 1: Primary, 2: FirstPage, 3: EvenPages
            footer = section.Footers(footer_type)
            text = footer.Range.Text.strip()
            if text:
                return text
        
        return ""
    finally:
        word.Quit()

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python Thesis_COM_Control.py <update|verify> <doc_path> [page_num]")
    else:
        mode = sys.argv[1]
        path = sys.argv[2]
        if mode == "update":
            force_field_update(path)
            print(f"Updated fields in {path}")
        elif mode == "verify" and len(sys.argv) == 4:
            page = int(sys.argv[3])
            print(f"Footer text on page {page}: {verify_footer_text(path, page)}")
        else:
            print("Invalid arguments")
