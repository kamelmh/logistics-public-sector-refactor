"""
inject_cover_com.py — Inject cover page from golden source into pandoc output using Word COM.

This avoids the corruption caused by raw XML injection by using Word itself
to copy/paste the cover page paragraphs.
"""
import os
import sys
import win32com.client


def log(msg):
    print("[COVER-COM] %s" % msg, flush=True)


def inject_cover_via_com(pandoc_docx, golden_docx, output_docx):
    """Use Word COM to prepend cover page from golden source into pandoc output."""
    word = None
    pandoc_doc = None
    golden_doc = None

    try:
        log("Starting Word...")
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        word.DisplayAlerts = 0

        # Open the pandoc output (target)
        log("Opening pandoc output: %s" % pandoc_docx)
        pandoc_doc = word.Documents.Open(os.path.abspath(pandoc_docx), ReadOnly=False)
        pandoc_paras = pandoc_doc.Paragraphs.Count
        log("  Pandoc doc: %d paragraphs" % pandoc_paras)

        # Open the golden source (source of cover page)
        log("Opening golden source: %s" % golden_docx)
        golden_doc = word.Documents.Open(os.path.abspath(golden_docx), ReadOnly=True)
        golden_paras = golden_doc.Paragraphs.Count
        log("  Golden doc: %d paragraphs" % golden_paras)

        # Find where cover page ends in golden source
        # Cover page = everything before first Heading 2 (إهداء)
        cover_end = 0
        for i in range(1, golden_paras + 1):
            p = golden_doc.Paragraphs(i)
            style_name = p.Style.NameLocal if hasattr(p.Style, 'NameLocal') else str(p.Style)
            if 'Heading' in style_name and ('إهداء' in p.Range.Text or 'F Heading' in style_name):
                cover_end = i - 1
                break

        if cover_end == 0:
            # Fallback: find first content paragraph (after date/year)
            for i in range(1, golden_paras + 1):
                p = golden_doc.Paragraphs(i)
                if 'فهرس المحتويات' in p.Range.Text or 'TOC' in p.Style.NameLocal:
                    cover_end = i - 1
                    break

        if cover_end == 0:
            cover_end = 15  # Default: first 15 paragraphs

        log("  Cover page: paragraphs 1-%d" % cover_end)

        # Select the cover page in golden source
        golden_doc.Range(
            golden_doc.Paragraphs(1).Range.Start,
            golden_doc.Paragraphs(cover_end).Range.End
        ).Copy()

        # Paste at the beginning of pandoc output
        pandoc_doc.Range(0, 0).Paste()

        log("  Injected %d cover paragraphs" % cover_end)

        # Save the result
        pandoc_doc.SaveAs(os.path.abspath(output_docx))
        log("  Saved: %s" % output_docx)

        return cover_end

    except Exception as e:
        log("ERROR: %s" % e)
        import traceback
        traceback.print_exc()
        return 0
    finally:
        try:
            if golden_doc:
                golden_doc.Close(SaveChanges=False)
        except:
            pass
        try:
            if pandoc_doc:
                pandoc_doc.Close(SaveChanges=False)
        except:
            pass
        try:
            if word:
                word.Quit()
        except:
            pass


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python inject_cover_com.py <pandoc.docx> <golden.docx> <output.docx>")
        sys.exit(1)

    pandoc_docx = sys.argv[1]
    golden_docx = sys.argv[2]
    output_docx = sys.argv[3]

    count = inject_cover_via_com(pandoc_docx, golden_docx, output_docx)
    sys.exit(0 if count > 0 else 1)
