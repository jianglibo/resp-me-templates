#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <template-folder-name>"
    exit 1
fi

# Store the original working directory
original_dir=$(pwd)

# Get the directory path of the executing script
cd "$(dirname "$0")/$1"

zipfile="${1%/}.zip"
rm $zipfile
zip $zipfile ./*.*

cd "$original_dir"