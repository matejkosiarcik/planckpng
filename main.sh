#!/bin/sh
set -euf

formerdir="${PWD}"
workdir="$(mktemp -d)"
PATH="${PATH}:/src/node_modules/.bin"
cd "${workdir}"

cp '/file.png' '0.png'
printf 'Original: %s\n' "$(wc -c <'0.png')"

printf 'TruePNG...'
truepng '0.png' /o max /quiet /y /out '1.png' >/dev/null 2>&1 || true
printf '\rTruePNG: %s\n' "$(wc -c <'1.png')"

printf 'PNGOptimizer...'
pngoptimizer -AvoidGreyWithSimpleTransparency -IgnoreAnimatedGifs -KeepBackgroundColor -KeepTextualData:R -stdio <'1.png' >'2.png'
printf '\rPNGOptimizer: %s\n' "$(wc -c <'2.png')"

printf 'OptiPNG...'
optipng -quiet -strip all -o7 -zm1-9 '2.png' -out '3.png'
printf '\rOptiPNG: %s\n' "$(wc -c <'3.png')"

printf 'ZopfliPNG...'
zopflipng -y --iterations=1000 --filters=01234mepb --lossy_8bit --lossy_transparent '3.png' '4.png' >/dev/null 2>&1
printf '\rZopfliPNG: %s\n' "$(wc -c <'4.png')"

printf 'PNGOut...'
pngout -s0 -k1 -y '4.png' '5.png' >/dev/null || true
printf '\rPNGOut: %s\n' "$(wc -c <'5.png')"

printf 'Deflopt...'
cp '5.png' '6.png'
deflopt /s '6.png' >/dev/null
printf '\rDeflopt: %s\n' "$(wc -c <'6.png')"

# finish
cp '6.png' '/file.png'
cd "${formerdir}"
rm -rf "${workdir}"
