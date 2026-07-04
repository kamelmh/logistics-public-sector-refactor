"""fixers.empty_paras — Remove consecutive empty paragraphs."""


def clean_empty_paragraphs(doc, changes):
    """Remove consecutive empty paragraphs (keep one of each pair for spacing)."""
    empty = [i for i, p in enumerate(doc.paragraphs) if not p.text.strip()]
    to_rm = [i for i in empty if (i + 1) in set(empty)]
    for idx in reversed(to_rm):
        doc.paragraphs[idx]._element.getparent().remove(doc.paragraphs[idx]._element)
        changes['empty_paras_removed'] += 1
    return changes
