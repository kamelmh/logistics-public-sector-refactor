import re
import os
import sys

def clean_thesis_md(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: Input file {input_path} not found.")
        return

    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Removing ANSI escape sequences...")
    # Matches \x1b[...m or literal [7m, [0m etc if they are present as text
    ansi_pattern = re.compile(r'\x1b\[[0-9;]*m|\[[0-7]m|\[0m')
    content = ansi_pattern.sub('', content)

    print("Cleaning footnote syntax (removing whitespace inside [^...])...")
    # Match [^ followed by any characters until ]
    # and replace it with [^label_without_spaces]
    def remove_spaces_in_footnote(match):
        label = match.group(1).replace(" ", "").replace("\t", "").replace("\n", "").replace("\r", "")
        return f"[^{label}]"

    footnote_pattern = re.compile(r'\[\^([^\]]+)\]')
    content = footnote_pattern.sub(remove_spaces_in_footnote, content)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Successfully cleaned {input_path} -> {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clean_thesis.py <input_md_path> [output_md_path]")
    else:
        in_p = sys.argv[1]
        out_p = sys.argv[2] if len(sys.argv) > 2 else in_p + ".clean.md"
        clean_thesis_md(in_p, out_p)
