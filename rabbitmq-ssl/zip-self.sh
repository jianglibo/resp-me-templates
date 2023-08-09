#!/bin/bash

# Store the original working directory
original_dir=$(pwd)

# Get the directory path of the executing script
cd "$(dirname "$0")"

zip rabbitmq-ssl.zip ./*.*

cd "$original_dir"