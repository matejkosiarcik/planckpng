#!/bin/sh
set -euf

if [ "${#}" -lt 2 ]; then
    printf 'Not enough arguments. Expecting `./main.sh <path> <level>`\n' >&2
    exit 1
fi

image_path="$1"
mode="$2"
PATH="$PATH:/src/node_modules/.bin"
. ./utils.sh

if [ ! -e "$image_path" ]; then
    printf 'File %s does not exist' "$image_path" >&2
    exit 1
fi

run_truepng "$image_path" "$mode"
run_pngoptimizer "$image_path" "$mode"
run_optipng "$image_path" "$mode"
run_zopflipng "$image_path" "$mode"
run_pngout "$image_path" "$mode"
run_deflopt "$image_path" "$mode"

# TODO: defluff
