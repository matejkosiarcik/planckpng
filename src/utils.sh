#!/bin/sh
# Contains helper functions for individual tools

statistics() {
    input_size="$(wc -c <"$1")"
    output_size="$(wc -c <"$2")"
    optimization_ratio="$(printf 'scale=2; %s / %s * 100\n' "$output_size" "$input_size" | bc)"
    printf '%s -> %s [%s%%]\n' "$input_size" "$output_size" "$optimization_ratio"
}

run_truepng() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"

    # run
    # printf 'TruePNG...'
    case "$mode" in
    'fast') truepng 'input.png' /o 2 /quiet /y /out 'output.png' >/dev/null 2>&1 || true ;;
    'default') truepng 'input.png' /o 3 /quiet /y /out 'output.png' >/dev/null 2>&1 || true ;;
    'brute') truepng 'input.png' /o 4 /quiet /y /out 'output.png' >/dev/null 2>&1 || true ;;
    'ultra-brute') truepng 'input.png' /o max /quiet /y /out 'output.png' >/dev/null 2>&1 || true ;;
    *)
        printf 'Unrecognised mode %s\n' "$mode" >&2
        exit 1
        ;;
    esac
    # printf '\rTruePNG: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}

run_pngoptimizer() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"

    # run
    # printf 'PNG Optimizer...'
    pngoptimizer -AvoidGreyWithSimpleTransparency -IgnoreAnimatedGifs -KeepBackgroundColor:R -KeepTextualData:R -stdio <'input.png' >'output.png'
    # printf '\rPNG Optimizer: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}

run_optipng() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"

    # run
    # printf 'OptiPNG...'
    case "$mode" in
    'fast') optipng -quiet -strip all -o3 'input.png' -out 'output.png' ;;
    'default') optipng -quiet -strip all -o5 'input.png' -out 'output.png' ;;
    'brute') optipng -quiet -strip all -o7 'input.png' -out 'output.png' ;;
    'ultra-brute') optipng -quiet -strip all -o7 -zm1-9 'input.png' -out 'output.png' ;;
    *)
        printf 'Unrecognised mode %s\n' "$mode" >&2
        exit 1
        ;;
    esac
    # printf '\rOptiPNG: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}

run_zopflipng() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"

    # run
    # printf 'ZopfliPNG...'
    case "$mode" in
    'fast') zopflipng -y --iterations=100 --filters=01234mepb --lossy_8bit --lossy_transparent 'input.png' 'output.png' >/dev/null 2>&1 ;;
    'default') zopflipng -y --iterations=250 --filters=01234mepb --lossy_8bit --lossy_transparent 'input.png' 'output.png' >/dev/null 2>&1 ;;
    'brute') zopflipng -y --iterations=500 --filters=01234mepb --lossy_8bit --lossy_transparent 'input.png' 'output.png' >/dev/null 2>&1 ;;
    'ultra-brute') zopflipng -y --iterations=1000 --filters=01234mepb --lossy_8bit --lossy_transparent 'input.png' 'output.png' >/dev/null 2>&1 ;;
    *)
        printf 'Unrecognised mode %s\n' "$mode" >&2
        exit 1
        ;;
    esac
    # printf '\rZopfliPNG: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}

run_pngout() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"

    # run
    # printf 'PNGOut...'
    pngout -s0 -k1 -y 'input.png' 'output.png' >/dev/null || true
    # printf '\rPNGOut: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}

run_deflopt() {
    # prepare
    image="$1"
    mode="$2"
    workdir="$(mktemp -d)"
    cp "$image" "$workdir/input.png"
    cd "$workdir"
    cp 'input.png' 'output.png'

    # run
    # printf 'Deflopt...'
    deflopt /s 'output.png' >/dev/null
    # printf '\rDeflopt: '
    # statistics 'input.png' 'output.png'

    # cleanup
    cd - >/dev/null
    cp "$workdir/output.png" "$image"
    rm -rf "$workdir"
}
