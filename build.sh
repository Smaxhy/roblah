#!/usr/bin/env bash
# Runs the tests, then builds the place file and the importable kit into build/.
#   ./build.sh            -> tests + build
#   ./build.sh --no-test  -> build only
# The game runs the pack named in src/shared/Config.luau (`pack = "City"` by default);
# the tests check both packs.
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" != "--no-test" ]]; then
	echo "== City pack: content + simulation =="
	lune run tests/run 2000
	echo "== City pack: careers, eras, chronicle =="
	lune run tests/city_check
	echo "== City pack: Roblox content scan =="
	python3 tests/safety_scan.py
	echo "== engine checks (v0.5 systems) =="
	lune run tests/v5_check
	echo "== UI smoke + integration (City, then the original Undermere pack) =="
	LIFESIM_PACK=City lune run tests/ui_smoke
	LIFESIM_PACK=Undermere lune run tests/ui_smoke
	echo "== Undermere pack: content + simulation =="
	LIFESIM_PACK=Undermere lune run tests/run 500
fi

mkdir -p build
rojo build default.project.json -o build/LifeInTheCity.rbxlx
rojo build model.project.json -o build/LifeSimKit.rbxmx
echo "Built build/LifeInTheCity.rbxlx and build/LifeSimKit.rbxmx"
