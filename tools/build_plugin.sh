#!/usr/bin/env bash
# Build the BitLeveling Studio plugin (build/BitLevelingStudio.rbxmx). Needs rojo and lune.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
rojo build games/BitLeveling.kit.project.json -o build/BitLevelingKit.rbxmx
rojo build games/BitLevelingStudio.project.json -o build/BitLevelingStudioCode.rbxmx
lune run tools/plugin/build_plugin.luau
