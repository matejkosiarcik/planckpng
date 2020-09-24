#!/bin/sh
set -euf

help() {
    printf 'Usage: matejkosiarcik/redopng [--fast|--default|--brute]\n'
    printf 'Modes:\n'
    printf ' --fast   \tFastest, least efficient optimizations\n'
    printf ' --default\tDefault optimizations\n'
    printf ' --brute\tSlowest, most efficient optimizations\n'
}

mode='default'
if [ "${#}" -ge 1 ]; then
    case "${1}" in
    '--fast') mode='fast';;
    '--default') mode='default';;
    '--brute') mode='brute';;
    '--help') help && exit 0;;
    '-h') help && exit 0;;
    *) printf 'Unrecognized option %s' "${1}\n" && help && exit 1;;
    esac
fi

formerdir="${PWD}"
workdir="$(mktemp -d)"
PATH="${PATH}:/src/node_modules/.bin"
cd "${workdir}"

cp '/file.png' '0.png'
printf 'Original: %s\n' "$(wc -c <'0.png')"

printf 'TruePNG...'
case "${mode}" in
'fast') truepng '0.png' /o 2 /quiet /y /out '1.png' >/dev/null 2>&1 || true;;
'default') truepng '0.png' /o 4 /quiet /y /out '1.png' >/dev/null 2>&1 || true;;
'brute') truepng '0.png' /o max /quiet /y /out '1.png' >/dev/null 2>&1 || true;;
esac
printf '\rTruePNG: %s\n' "$(wc -c <'1.png')"

printf 'PNGOptimizer...'
pngoptimizer -AvoidGreyWithSimpleTransparency -IgnoreAnimatedGifs -KeepBackgroundColor:R -KeepTextualData:R -stdio <'1.png' >'2.png'
printf '\rPNGOptimizer: %s\n' "$(wc -c <'2.png')"

printf 'OptiPNG...'
case "${mode}" in
'brute') optipng -quiet -strip all -o7 -zm1-9 '2.png' -out '3.png';;
*) optipng -quiet -strip all -o7 '2.png' -out '3.png';;
esac
printf '\rOptiPNG: %s\n' "$(wc -c <'3.png')"

printf 'ZopfliPNG...'
case "${mode}" in
'fast') zopflipng -y --iterations=100 --filters=01234mepb --lossy_8bit --lossy_transparent '3.png' '4.png' >/dev/null 2>&1;;
'default') zopflipng -y --iterations=250 --filters=01234mepb --lossy_8bit --lossy_transparent '3.png' '4.png' >/dev/null 2>&1;;
'brute') zopflipng -y --iterations=1000 --filters=01234mepb --lossy_8bit --lossy_transparent '3.png' '4.png' >/dev/null 2>&1;;
esac
printf '\rZopfliPNG: %s\n' "$(wc -c <'4.png')"

if [ "${mode}" = 'fast' ]; then
    cp '4.png' '5.png'
else
    printf 'PNGOut...'
    pngout -s0 -k1 -y '4.png' '5.png' >/dev/null || true
    printf '\rPNGOut: %s\n' "$(wc -c <'5.png')"
fi

printf 'Deflopt...'
cp '5.png' '6.png'
deflopt /s '6.png' >/dev/null
printf '\rDeflopt: %s\n' "$(wc -c <'6.png')"

# finish
cp '6.png' '/file.png'
cd "${formerdir}"
rm -rf "${workdir}"
