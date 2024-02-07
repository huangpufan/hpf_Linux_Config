#!/bin/bash

# Check if pysocks is already installed
if python -c "import pysocks" >/dev/null 2>&1; then
    echo "pysocks is already installed."
else
    # Install pysocks
    pip install pysocks
fi
