#!/usr/bin/env bash
set -euf

cd "$(dirname "$0")"
. ./gitman/demo-magic/demo-magic.sh # shellcheck ignore=SC1091
TYPE_SPEED=6 # shellcheck ignore=SC2034

# TODO: add more images for recording
cd ../.. # cd to project root
workdir="$(mktemp -d)"
cp -R test/ "$workdir/"
cd "$workdir"

clear
pei 'docker run -itv "$PWD:/img" matejkosiarcik/millipng:dev --level fast' # shellcheck ignore=SC2016
pei '' # basically prompt another line that keeps the results in view a bit longer
