#!/bin/bash

set -e
set -x

d="$(mktemp -d)"
touch "$d/.grassrc"
mkdir -p "$d/grassdata/tmploc/PERMANENT"
touch "$d/grassdata/tmploc/PERMANENT/"{DEFAULT_WIND,WIND}
export GISDBASE="$d/grassdata"
export GRASS_BATCH_JOB="$1"
grass -c "$d/grassdata/tmploc/tmpmapset"
rm -rf "$d"
