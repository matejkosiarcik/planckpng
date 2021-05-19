#!/bin/sh
set -euf
cd "$(dirname "$0")"

castfile="$(mktemp)"
asciinema rec "$castfile" --title 'millipng' --command 'bash demo.sh'
GIFSICLE_OPTS='-k 8 -O3 --lossy=80 --resize-width 800 --no-comments --no-names --no-extensions' asciicast2gif -t monokai -w 80 -h 12 -s 7 "$castfile" '../demo.gif'
rm -rf "$castfile"
