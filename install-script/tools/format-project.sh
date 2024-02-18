#!/bin/bash

# Find all .c and .h files in the current directory and its subdirectories
# and format them in-place.
find . -iname '*.c' -o -iname '*.h' | xargs clang-format -i -style=file
