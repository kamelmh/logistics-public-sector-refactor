import re
import os
import sys

def strip_ansi_codes(text):
    # ANSI escape code regex
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

def fix_footnotes(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: Input file {input_path} not found.")
        return

    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Step 1: Strip ANSI escape codes
    print("Stripping ANSI escape codes...")
    content = strip_ansi_codes(content)

    # Step 2: Convert the footnotes
    # The user's original format was [^label]
    # After stripping ANSI, it should be exactly [^label]
    # We want to convert [^label] to [^fnN] and add [^fnN]: content at the end.
    
    print("Converting footnotes...")
    footnote_map = []
    counter = 1

    # Regex for [^label]
    # We look for [^ followed by any non-bracket characters, then ]
    pattern = re.compile(r'\[\^([^\]]+)\]')

    def replace_func(match):
        nonlocal counter
        # label = match.group(1) # We don't actually need the old label if we want to re-index
        fn_id = f"fn{counter}"
        footnote_map.append(f"[^{fn_id}]: ") # We'll fill the content later? 
        # Wait, the original format was [^label] where label IS the content? 
        # No, usually [^label] is the reference, and [^label]: content is the definition.
        # But in the user's file, it seems they used [^content] as the reference.
        # Let's check the original file again.
        # Line 124: ... الزبائن"  [7m[^ [0mfn1]. وقد تفرعت ...
        # It seems the label IS "fn1".
        # And the definition is somewhere else? 
        # Let's check the end of the file.
        counter += 1
        return f"[^{fn_id}]"

    # Actually, looking at the original file, it seems they used [^fn1] as the reference.
    # And the definitions are at the end of the file.
    # Let's see the end of the file.
    
    # Let's re-read the original file to see how they defined them.
    # I'll use a regex to find all [^...] and see if they look like labels or content.
    
    # Let's try a different approach.
    # 1. Find all [^label] in the text.
    # 2. Find all [^label]: content at the end.
    # 3. Re-map them to standard Pandoc [^label] and [^label]: content.
    
    # But if the user's [^label] is already standard, why did it fail?
    # Because of the ANSI codes! [7m[^ [0mfn1] is NOT [^fn1] to Pandoc.
    
    # So, if I strip ANSI, it becomes [^fn1].
    # If the definitions are also [^fn1]: content, then it's already standard!
    
    # Let's check the definitions in the original file.
    # I'll read the last 100 lines.
    
    return content, footnote_map # Placeholder

# Let's refine the script.
