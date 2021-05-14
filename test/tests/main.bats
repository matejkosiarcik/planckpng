#!/usr/bin/env bats
# shellcheck disable=SC2086

function setup() {
    cd "${BATS_TEST_DIRNAME}/../.." || exit 1
    tmpdir="$(mktemp -d)"
    export tmpdir
}

function teardown() {
    rm -rf "${tmpdir}"
}

@test 'Optimize single file' {
    cp 'test/1x1.png' "${tmpdir}/"
    run docker run --volume "${tmpdir}/1x1.png:/img" matejkosiarcik/millipng:dev --level fast
    [ "${status}" -eq 0 ]

    # verify file is smaller than the original
    [ "$(wc -c <"${tmpdir}/1x1.png")" -lt "$(wc -c <'test/1x1.png')" ]
}

@test 'Dry run single file' {
    cp 'test/1x1.png' "${tmpdir}/"
    run docker run --volume "${tmpdir}/1x1.png:/img" matejkosiarcik/millipng:dev --level fast --dry-run
    [ "${status}" -eq 0 ]

    # verify the contents of the file did not change
    [ "$(wc -c <"${tmpdir}/1x1.png")" -eq "$(wc -c <'test/1x1.png')" ]
    [ "$(shasum -b <"${tmpdir}/1x1.png" | cut -d ' ' -f 1)" = "$(shasum -b <"test/1x1.png" | cut -d ' ' -f 1)" ]
}

@test 'Optimize multiple files' {
    cp 'test/1x1.png' 'test/2x2.png' "${tmpdir}/"
    run docker run --volume "${tmpdir}:/img" matejkosiarcik/millipng:dev --level fast
    [ "${status}" -eq 0 ]

    # verify files are smaller than the originals
    [ "$(wc -c <"${tmpdir}/1x1.png")" -lt "$(wc -c <'test/1x1.png')" ]
    [ "$(wc -c <"${tmpdir}/2x2.png")" -lt "$(wc -c <'test/2x2.png')" ]
}

@test 'Dry run multiple files' {
    cp 'test/1x1.png' 'test/2x2.png' "${tmpdir}/"
    run docker run --volume "${tmpdir}:/img" matejkosiarcik/millipng:dev --dry-run
    [ "${status}" -eq 0 ]

    # verify the contents of the files did not change
    [ "$(wc -c <"${tmpdir}/1x1.png")" -eq "$(wc -c <'test/1x1.png')" ]
    [ "$(shasum -b <"${tmpdir}/1x1.png" | cut -d ' ' -f 1)" = "$(shasum -b <"test/1x1.png" | cut -d ' ' -f 1)" ]
    [ "$(wc -c <"${tmpdir}/2x2.png")" -eq "$(wc -c <'test/2x2.png')" ]
    [ "$(shasum -b <"${tmpdir}/2x2.png" | cut -d ' ' -f 1)" = "$(shasum -b <"test/2x2.png" | cut -d ' ' -f 1)" ]
}
