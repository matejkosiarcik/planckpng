#!/usr/bin/env bash
set -euf

cd "$(dirname "$0")"
# shellcheck disable=SC1091
. ./gitman/demo-magic/demo-magic.sh
# shellcheck disable=SC2034
TYPE_SPEED=8

# TODO: add more images for recording
cd ../.. # cd to project root
workdir="$(mktemp -d)"
cp -R test/ "$workdir/"
cd "$workdir"

clear
# shellcheck disable=SC2016
pei 'docker run -itv "$PWD:/img" matejkosiarcik/planckpng:dev --level fast'
pei '' # basically prompt another line that keeps the results in view a bit longer
