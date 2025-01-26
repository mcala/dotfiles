#!/usr/bin/env bash

# Use ':' as the delimiter for splitting PATH
IFS=':' read -r -a path_array <<< "$PATH"

echo "Your PATH directories:"
for dir in "${path_array[@]}"; do
  echo "  - $dir"
done
