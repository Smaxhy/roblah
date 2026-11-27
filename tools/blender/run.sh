#!/usr/bin/env bash
# THE BLENDER PIPELINE (BitLeveling), headless: Blender as a Python module (pip "bpy"), no GUI.
#
#   tools/blender/run.sh                  # dump the game's part layouts, model the kit, render previews
#   tools/blender/run.sh kit.py           # just one script
#   tools/blender/run.sh preview.py monsters
#
# First run makes a virtualenv with bpy and Pillow (BLENDER_VENV, default tools/blender/.venv).
# Needs Python 3.11+ (bpy 5.x wheels; 3.13 works) and lune on PATH for the layout dump.
# Outputs go to tools/blender/out/ (kit.fbx, kit.blend, layout.json, *.png).
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
venv="${BLENDER_VENV:-$here/.venv}"
if [ ! -x "$venv/bin/python" ]; then
	echo "setting up Blender (bpy) in $venv ..."
	python3 -m venv "$venv"
	"$venv/bin/pip" install --quiet --upgrade pip
	"$venv/bin/pip" install --quiet bpy pillow
fi
cd "$root"
if [ $# -gt 0 ]; then
	script="$1"
	shift
	exec "$venv/bin/python" "$here/$script" "$@"
fi
lune run tools/blender/dump_layout.luau
"$venv/bin/python" "$here/kit.py"
"$venv/bin/python" "$here/preview.py" all
echo "done: tools/blender/out/kit.fbx and the previews in tools/blender/out/"
