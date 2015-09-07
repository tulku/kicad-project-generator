#!/bin/sh

set -x
set -e

DKICAD_FPTABLE=/home/kicad/.config/kicad/fp-lib-table
DKICAD_PRETTY=/home/kicad/kicad_libs/library-repos

mkdir -p ~/.config/kicad/
curl "https://raw.githubusercontent.com/KiCad/kicad-library/${LIB_COMMIT_SHA}/template/fp-lib-table.for-pretty" > $$DKICAD_FPTABLE
md5sum $$DKICAD_FPTABLE

mkdir -p $$DKICAD_PRETTY
wstool init -j 4 /home/kicad/kicad_libs/library-repos /usr/local/bin/kicad_libs.rosinstall
