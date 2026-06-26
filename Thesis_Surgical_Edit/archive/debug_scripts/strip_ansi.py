import re
import os
import sys

def strip_ansi_codes(text):
    # ANSI escape code regex
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

def main():
    if len(sys.argv) < 2:
        print("Usage: python strip_ansi.py <input_md_path> [output_md_path]")
        return

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else input_path + ".clean.md"

    if not os.path.exists(input_path):
        print(f"Error: Input file {input_path} not found.")
        return

    print(f"Reading {input_path}...")
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Stripping ANSI escape codes...")
    clean_content = strip_ansi_codes(content)

    print(f"Writing to {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(clean_content)

    print("Done!")

if __name__ == "__main__":
    main()
