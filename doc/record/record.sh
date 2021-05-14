#!/bin/sh
set -euf
cd "$(dirname "$0")"

castfile="$(mktemp)"
asciinema rec "$castfile" --title 'millipng' --command 'bash demo.sh'
GIFSICLE_OPTS='-k 16 -O3 --lossy=100' asciicast2gif -t monokai -w 80 -h 12 -s 6 "$castfile" '../terminal.gif'
rm -f "$castfile"
