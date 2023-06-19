#!/usr/bin/env bats
# shellcheck disable=SC2086

function setup() {
    cd "$BATS_TEST_DIRNAME/../.." || exit 1
    tmpdir="$(mktemp -d)"
    export tmpdir
}

function teardown() {
    rm -rf "$tmpdir"
}

@test 'Get help (long)' {
    run docker run matejkosiarcik/planckpng:dev --help
    [ "$status" -eq 0 ]
    [ "$output" != '' ]
    grep -i 'usage:' <<<"$output"
}

@test 'Get help (short)' {
    run docker run matejkosiarcik/planckpng:dev -h
    [ "$status" -eq 0 ]
    [ "$output" != '' ]
    grep -i 'usage:' <<<"$output"
}

@test 'Get version (long)' {
    run docker run matejkosiarcik/planckpng:dev --version
    [ "$status" -eq 0 ]
    [ "$output" != '' ]
    grep -E 'planckpng [0-9]+\.[0-9]+\.[0-9]+' <<<"$output"
}

@test 'Get version (short)' {
    run docker run matejkosiarcik/planckpng:dev -V
    [ "$status" -eq 0 ]
    [ "$output" != '' ]
    grep -E 'planckpng [0-9]+\.[0-9]+\.[0-9]+' <<<"$output"
}
