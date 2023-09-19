#!/bin/bash

original_dir=$(pwd)
cd "$(dirname "$0")/$1"

msgfmt en.po -o en.mo
msgfmt zh.po -o zh.mo

cd "$original_dir"