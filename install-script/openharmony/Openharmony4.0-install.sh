#!/usr/bin/env bash
set -Eeuo pipefail

DOWNLOAD_DIR="$HOME/download"
PROJECT_DIR="$HOME/project"
TARBALL="$DOWNLOAD_DIR/code-v4.0-Release.tar.gz"

# Check if tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "[ERROR] Tarball not found: $TARBALL"
    echo "Please download it first from:"
    echo "  https://repo.huaweicloud.com/openharmony/os/4.0-Release/code-v4.0-Release.tar.gz"
    exit 1
fi

# Extract
echo "Extracting OpenHarmony 4.0..."
cd "$DOWNLOAD_DIR"
tar -xzvf "$TARBALL"

# Get folder name after extract
folder_name=$(tar -tzf "$TARBALL" | head -1 | cut -f1 -d"/")

# Move to project directory
mkdir -p "$PROJECT_DIR"
if [ -d "$PROJECT_DIR/$folder_name" ]; then
    echo "[WARN] Directory already exists: $PROJECT_DIR/$folder_name"
    echo "Removing old directory..."
    rm -rf "$PROJECT_DIR/$folder_name"
fi
mv "$folder_name" "$PROJECT_DIR/"

# Clean up tarball
rm -f "$TARBALL"

# The 4.0 has fatal git error, we need to manually clone some repo
OH_DIR="$PROJECT_DIR/$folder_name/OpenHarmony"
SENSORS_DIR="$OH_DIR/base/sensors/miscdevice"

if [ -d "$SENSORS_DIR" ]; then
    echo "Fixing sensors_miscdevice repository..."
    cd "$SENSORS_DIR"
    wget -q https://gitee.com/openharmony/sensors_miscdevice/repository/archive/OpenHarmony-4.0-Release.zip
    unzip -q OpenHarmony-4.0-Release.zip 
    mv ./sensors_miscdevice-OpenHarmony-4.0-Release/* ./
    rm -rf OpenHarmony-4.0-Release.zip sensors_miscdevice-OpenHarmony-4.0-Release
fi

# Install build tools
cd "$OH_DIR"
echo "Installing build tools..."
python3 -m pip install --user build/hb
bash build/prebuilts_download.sh

echo ""
echo "OpenHarmony 4.0 installation completed!"
echo "Project location: $OH_DIR"
