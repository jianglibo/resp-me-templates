#!/bin/bash

substitute_vars() {
	input_file="$1"
	shift
	if [ $# -lt 2 ] || [ $(($# % 2)) -eq 1 ]; then
		echo "Error: You must provide an even number of parameters (key-value pairs)." >&2
		return 1
	fi
	while [ $# -gt 0 ]; do
		# Extract the key and value from arguments
		key="$1"
		value="$2"
		# Set the environment variable using export
		export "$key=$value"
		# Shift the arguments to process the next pair
		shift 2
	done

	echo "$@"
	echo "$#"
	envsubst < "$input_file"
}

substitute_vars "$@"

