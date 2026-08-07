import os
from pdf2image import convert_from_path

pdf_path = r"C:\Users\Admin\Downloads\Academic Editing Sample - MAHI Kamel Abdelghani.pdf"
output_dir = r"C:\Users\Admin\Projects\active\portfolio"

print("Converting PDF to PNG...")
images = convert_from_path(pdf_path, dpi=200)
for i, img in enumerate(images):
    img_path = os.path.join(output_dir, f"editing_sample_page_{i+1}.png")
    img.save(img_path, "PNG")
    print(f"Saved: {img_path}")

print("\nDone! PDF converted to PNG images.")
print(f"Files saved to: {output_dir}")