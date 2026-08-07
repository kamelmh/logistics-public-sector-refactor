import subprocess
import os

pdf_path = r"C:\Users\Admin\Downloads\Academic Editing Sample - MAHI Kamel Abdelghani.pdf"
output_dir = r"C:\Users\Admin\Projects\active\portfolio"

# Use Edge to convert PDF to PNG via headless screenshot
edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Open PDF in Edge and take screenshot
cmd = [
    edge_path,
    "--headless",
    "--disable-gpu",
    "--screenshot=" + os.path.join(output_dir, "pdf_screenshot.png"),
    "--window-size=900,1200",
    "file:///" + pdf_path.replace("\\", "/")
]

print("Converting PDF to PNG via Edge...")
subprocess.run(cmd, capture_output=True)

# Check if file exists
output_file = os.path.join(output_dir, "pdf_screenshot.png")
if os.path.exists(output_file):
    print(f"Saved: {output_file}")
    print("Done!")
else:
    print("PDF screenshot failed. Use the HTML version instead.")