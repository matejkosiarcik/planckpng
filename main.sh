#!/bin/sh
set -euf

if [ "$(head -c4 <'/file.png')" != '?PNG' ]; then
    printf 'File is not valid png\n'
    exit 1
fi

formerdir="${PWD}"
workdir="$(mktemp -d)"
PATH="${PATH}:/src/node_modules/.bin"
cd "${workdir}"

printf 'Original\n'
cp '/file.png' '0.png'
wc -c <'0.png'

printf 'TruePNG\n'
truepng '0.png' /o max /quiet /y /out '1.png'
wc -c <'1.png'

printf 'PNGOptimizer\n'
pngoptimizer -AvoidGreyWithSimpleTransparency -IgnoreAnimatedGifs -KeepBackgroundColor -KeepTextualData:R -stdio <'1.png' >'2.png'
wc -c <'2.png'

printf 'ZopfliPNG\n'
zopflipng -y --iterations=1000 --filters=01234mepb --splitting=3 --lossy_8bit --lossy_transparent '2.png' '3.png'
wc -c <'3.png'

printf 'PNGOut\n'
pngout -s0 -k1 -y '3.png' '4.png' || true
wc -c <'4.png'

printf 'OptiPNG\n'
optipng -quiet -strip all -o7 -zm1-9 '4.png' -out '5.png'
wc -c <'5.png'

# TODO: can't seem to make this work
# printf 'Defluff\n'
# defluff '5.png' '6.png'
# wc -c <'6.png'

printf 'Deflopt\n'
cp '5.png' '7.png'
deflopt /s '7.png'
wc -c <'7.png'

# finish
cp '7.png' '/file.png'
cd "${formerdir}"
rm -rf "${workdir}"
