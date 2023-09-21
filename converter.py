import os

from PIL import Image
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

pdf_folder = os.environ.get("PDF_FOLDER", "pdf")
if not os.path.exists(pdf_folder):
    os.makedirs(pdf_folder)

jpg_files = [f for f in os.listdir() if f.lower().endswith((".jpg", ".jpeg"))]

for jpg_file in jpg_files:
    pdf_file = os.path.join(pdf_folder, os.path.splitext(jpg_file)[0] + ".pdf")

    img = Image.open(jpg_file)

    c = canvas.Canvas(pdf_file, pagesize=letter)
    width, height = letter
    c.drawImage(jpg_file, 0, 0, width, height)
    c.showPage()
    c.save()

    print(f"Converted {jpg_file} to {pdf_file}")

print("Conversion has completed.")
