#!/usr/bin/env bash
set -Eeuo pipefail

# Install ranger and related preview tools
sudo apt-get install -y ranger           # ranger main program
sudo apt-get install -y caca-utils       # img2txt for images
sudo apt-get install -y highlight        # code highlighting
sudo apt-get install -y atool            # archive preview
sudo apt-get install -y w3m              # html page preview
sudo apt-get install -y poppler-utils    # pdf preview
sudo apt-get install -y mediainfo        # multimedia file preview
sudo apt-get install -y catdoc           # doc preview
sudo apt-get install -y docx2txt         # docx preview
sudo apt-get install -y xlsx2csv         # xlsx preview

echo "Ranger and preview tools installed successfully!"
