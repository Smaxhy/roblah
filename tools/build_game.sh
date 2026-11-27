#!/usr/bin/env bash
# BUILD ONE GAME made with the blueprint.
#   bash tools/build_game.sh <Id>              checks, then build
#   bash tools/build_game.sh <Id> --no-test    build only
#   bash tools/build_game.sh <Id> --shots      checks, screenshots (PC and phone), then build
# Checks: tools/checkgame (validate, lint, 60 headless lives) and the Roblox content scan on
# the game's folder. Screenshots: the generic UI states (tests/game_steps.luau) rendered to
# shots/<Id>/{pc,phone}/*.png (needs Node + the Chromium the renderer uses).
# Out: build/<Id>.rbxlx   a place: open it in Studio, then File > Publish to Roblox
#      build/<Id>Kit.rbxmx the kit alone: drag it into a place you already have
set -euo pipefail
cd "$(dirname "$0")/.."
ID="${1:?usage: bash tools/build_game.sh <Id> [--no-test] [--shots]}"
[[ -d "src/shared/Games/$ID" ]] || { echo "no game called $ID in src/shared/Games"; exit 1; }

# the build bakes Config.luau in: point it at this game (and rewrite the project files)
lune run tools/newgame --use "$ID"

if [[ " $* " != *" --no-test "* ]]; then
	echo "== $ID: validate, lint, headless lives =="
	lune run tools/checkgame "$ID" --lives 60
	echo "== $ID: Roblox content scan =="
	python3 tests/safety_scan.py "src/shared/Games/$ID"
fi

if [[ " $* " == *" --shots "* ]]; then
	for dev in pc phone; do
		echo "== $ID: screenshots ($dev) =="
		LIFESIM_PACK="$ID" SNAP_STEPS=game node tools/gui_render/shoot.js --device "$dev"
		mkdir -p "shots/$ID"
		rm -rf "shots/$ID/$dev"
		cp -r "tools/gui_render/out/$dev" "shots/$ID/$dev"
	done
fi

mkdir -p build
ROJO="$(command -v rojo || echo "$HOME/.cargo/bin/rojo")"
"$ROJO" build "games/$ID.project.json" -o "build/$ID.rbxlx"
"$ROJO" build "games/$ID.kit.project.json" -o "build/${ID}Kit.rbxmx"
echo "Built build/$ID.rbxlx and build/${ID}Kit.rbxmx"
