#!/usr/bin/env bats
# shellcheck disable=SC2086

load './helpers'

function setup() {
    cd "${BATS_TEST_DIRNAME}/.." || exit 1
    if [ -z "${TEST_COMMAND+x}" ] || [ "${TEST_COMMAND}" = '' ]; then
        printf 'TEST_COMMAND not specified\n' >&3
        exit 2
    fi
    tmpdir="$(mktemp -d)"
    export tmpdir
}

function teardown() {
    rm -rf "${tmpdir}"
}

@test 'Optimized file is smaller' {
    cp 'test/1x1.png' "${tmpdir}/1x1.png"
    docker run "${tmpdir}/1x1.png:/file.png"
}
