#!/usr/bin/env zsh

# Use zsh's built-in path array (lowercase)
echo "Your PATH directories:"
for dir in $path; do
    echo "  - $dir"
done
