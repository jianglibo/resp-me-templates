# Function to replace special pattern with file content <<<filename>>> will be replaced by the content of the file filename
replace_pattern_with_content() {
    # local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local file="$1"
    local pattern="<<<([^>]+)>>>"
    local replacement=""

    while IFS= read -r line; do
        while [[ "$line" =~ $pattern ]]; do
            matched_text="${BASH_REMATCH[0]}"
            relative_filename="${BASH_REMATCH[1]}"
            content=$(cat "$relative_filename")
            line="${line//$matched_text/$content}"
        done
        echo "$line"
    done < "$file"
}