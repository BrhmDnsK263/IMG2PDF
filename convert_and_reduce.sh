#!/bin/bash
venv_name="pdf_env"
current_date=$(date +%Y_%m_%d)

# create output folder with current date
output_folder="$current_date"
mkdir -p "$output_folder"
# create pdf, reduced and original folders inside output folder
pdf_folder="$output_folder/pdf"
reduced_folder="$output_folder/reduced"
original_folder="$output_folder/original"
mkdir -p "$pdf_folder"
mkdir -p "$reduced_folder"
mkdir -p "$original_folder"
# export variable to be used in python script
export PDF_FOLDER="$pdf_folder"

# create virtual environment for python if it doesn't exist
if [ ! -d "$venv_name" ]; then
    echo "creating python virtual environment..."
    python3.9 -m venv "$venv_name"
    echo "python virtual environment created."
else
    echo "python virtual environment already exists."
fi

# activate virtual environment and install dependencies
source "$venv_name/bin/activate"
pip install Pillow reportlab
# ejecute python script to convert images to pdf
echo "converting images to pdf..."
python converter.py
echo "pdf files have been created in $pdf_folder"
# deactivate virtual environment
deactivate

# install ghostscript if it doesn't exist
if ! command -v gs &> /dev/null; then
    sudo apt-get install ghostscript
else
    echo "Ghostscript already installed."
fi

# reduce pdf files and move them to reduced folder
echo "reducing pdf files..."
for pdf_file in "$pdf_folder"/*.pdf; do
    if [ -f "$pdf_file" ]; then
        reduced_file="$reduced_folder/$(basename "$pdf_file")"
        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$reduced_file" "$pdf_file"
        echo "Reduced $pdf_file and saved to $reduced_file"
    fi
done
echo "PDF files have been reduced and saved in $reduced_folder"

echo "copying original files to $original_folder"
# copy original files to original folder, with jpg extension if they exist
if [ -e *.jpg ]; then
    cp *.jpg "./$original_folder"
fi
# copy original files to original folder, with jpeg extension if they exist
if [ -e *.jpeg ]; then
    cp *.jpeg "./$original_folder"
fi

echo "pdf convertion and reduction finished. can be found in $output_folder"
