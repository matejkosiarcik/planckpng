#!/usr/bin/env bats
# shellcheck disable=SC2086

function setup() {
    cd "${BATS_TEST_DIRNAME}/.." || exit 1
    tmpdir="$(mktemp -d)"
    export tmpdir
}

function teardown() {
    rm -rf "${tmpdir}"
}

@test 'Help (long)' {
    run docker run matejkosiarcik/redopng:dev --help
    [ "${status}" -eq 0 ]
    [ "${output}" != '' ]
    grep -i 'usage:' <<<"${output}"
}

@test 'Help (short)' {
    run docker run matejkosiarcik/redopng:dev -h
    [ "${status}" -eq 0 ]
    [ "${output}" != '' ]
    grep -i 'usage:' <<<"${output}"
}

@test 'Optimizing file is smaller' {
    cp 'test/1x1.png' "${tmpdir}/1x1.png"
    run docker run --volume "${tmpdir}/1x1.png:/file.png" matejkosiarcik/redopng:dev --fast
    [ "${status}" -eq 0 ]
    printf 'Before %s\n' "$(wc -c <"${tmpdir}/1x1.png")" >>~/Desktop/log.txt
    printf 'After %s\n' "$(wc -c <'test/1x1.png')" >>~/Desktop/log.txt
}
