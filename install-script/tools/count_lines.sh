#!/usr/bin/env bash
set -Eeuo pipefail

# Recursive function to print line counts for all files in a directory
# $1: current directory path
# $2: indent string
print_tree() {
    local directory=$1
    local indent=$2
    local is_first=1

    # Iterate over all files and folders in the current directory
    for file in "$directory"/*; do
        [ -e "$file" ] || continue  # Skip if no matches
        
        # If it's a directory, recurse
        if [ -d "$file" ]; then
            if [ "$is_first" -eq 1 ]; then
                is_first=0
                echo "${indent}$(basename "$file")/"
            else
                echo "${indent}│"
                echo "${indent}├── $(basename "$file")/"
            fi
            # Recursive call with increased indent
            print_tree "$file" "$indent│   "
        elif [ -f "$file" ]; then
            # Check if it's a text file
            if file "$file" | grep -q text; then
                # Count lines
                local lines
                lines=$(wc -l < "$file")
                echo "${indent}│"
                echo "${indent}├── $(basename "$file") - $lines lines"
            else
                echo "${indent}│"
                echo "${indent}├── $(basename "$file") - Binary file"
            fi
        fi
    done
    # Adjust trailing branch display
    if [ "$is_first" -ne 1 ]; then
        echo "${indent}│"
    fi
}

# Start script from current directory without indent
print_tree "." ""
