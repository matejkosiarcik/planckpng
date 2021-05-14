#!/usr/bin/env bash
set -euf

cd "$(dirname "$0")"
. ./gitman/demo-magic/demo-magic.sh
TYPE_SPEED=6

cd .. # cd to project root
workdir="$(mktemp -d)"
cp -R test/ "$workdir/"
cd "$workdir"

clear
pei 'docker run -itv "$PWD:/img" matejkosiarcik/millipng:dev --level fast'
pei '' # basically prompt another line that keeps the results in view a bit longer
