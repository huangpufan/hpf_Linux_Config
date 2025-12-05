#!/usr/bin/env bash
set -Eeuo pipefail

# Generate compile_commands.json for a CMake project
# Usage: ./gen_compile_commands.sh [project_dir]

PROJECT_DIR="${1:-$(pwd)}"
TARGET_FILE="compile_commands.json"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "[ERROR] Project directory not found: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Check if build.sh exists (for OceanBase-like projects)
if [ -f "./build.sh" ]; then
    echo "Building with build.sh..."
    ./build.sh debug --init -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    
    # Move compile_commands.json to project root if it exists in build dir
    if [ -f "build_debug/$TARGET_FILE" ]; then
        cp "build_debug/$TARGET_FILE" "./$TARGET_FILE"
        echo "compile_commands.json copied to project root."
    fi
else
    # Standard CMake project
    echo "Building with CMake..."
    mkdir -p build
    cd build
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
    
    if [ -f "$TARGET_FILE" ]; then
        cp "$TARGET_FILE" "../$TARGET_FILE"
        echo "compile_commands.json copied to project root."
    fi
fi

echo "Done!"
