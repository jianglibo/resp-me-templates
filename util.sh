#!/bin/bash

# Define the function to zip a directory with exclusions
zip_with_exclusions() {
  local source_dir="$1"
  local output_zip="$2"
  local current_dir

  # Get the current directory
  current_dir=$(pwd)

  # Change to the source directory
  cd "$source_dir" || exit 1

  if [[ -f "$current_dir/$output_zip" ]];then
    rm "$current_dir/$output_zip"
  fi

  # Check if __excludes.txt exists and is not empty
  if [ -f "___excludes.txt" ] && [ -s "___excludes.txt" ]; then
    # Use zip with exclude list file
    zip -r "$current_dir/$output_zip" . -x@"$source_dir/___excludes.txt"
  else
    # Use zip without exclusions
    zip -r "$current_dir/$output_zip" .
  fi

  # Return to the original directory
  cd "$current_dir" || exit 1

  echo "Zip operation complete. Output file: $output_zip"
}
