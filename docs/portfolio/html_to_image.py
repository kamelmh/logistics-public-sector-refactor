from html2image import Html2Image
import os

html_path = r"C:\Users\Admin\Projects\active\portfolio\editing_sample_portfolio.html"
output_dir = r"C:\Users\Admin\Projects\active\portfolio"
edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

hti = Html2Image(output_path=output_dir, browser_executable=edge_path)

# Read the HTML file
with open(html_path, 'r', encoding='utf-8') as f:
    html_content = f.read()

# Convert HTML to PNG
output_file = hti.screenshot(html_str=html_content, save_as='editing_sample_portfolio.png', size=(900, 1200))
print(f"Saved: {output_file}")
print(f"Full path: {os.path.join(output_dir, 'editing_sample_portfolio.png')}")
print("\nDone! Upload this PNG to Upwork.")