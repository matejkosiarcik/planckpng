#!/bin/sh
set -euf
cd "$(dirname "$0")/.."

PATH="$PATH:$PWD/record/node_modules/.bin"
castfile="$(mktemp)"
asciinema rec "$castfile" --title 'millipng' --command "set -x && python3 src/main.py --jobs 3 --dry-run"
asciicast2gif -t monokai -w 60 -h 15 "$castfile" 'doc/terminal.gif'
