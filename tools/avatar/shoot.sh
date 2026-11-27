#!/bin/bash
# Contact sheets of the avatar figures: builds the dumps with Lune, draws them with gui_render.
#   bash tools/avatar/shoot.sh [sheet ...]      (no names: every sheet; see sheet.luau)
#   LIFESIM_PACK=Undermere bash tools/avatar/shoot.sh    the other pack (<sheet>_undermere.png)
#   SCALE=2 bash tools/avatar/shoot.sh hair     sharper PNGs
cd "$(dirname "$0")/../.." || exit 1
suffix=""
if [ "$LIFESIM_PACK" = "Undermere" ]; then suffix="_undermere"; fi
names="$*"
if [ -z "$names" ]; then names="weapons hair hairbig outfits poses ages identities npcs extras mesh"; fi
lune run tools/avatar/sheet.luau $names || exit 1
for name in $names; do
	dump="tools/avatar/shots/$name$suffix.json"
	if [ -f "$dump" ]; then
		node tools/gui_render/shoot.js --dump "$dump" --png "tools/avatar/shots/$name$suffix.png" --bg none --no-topbar --scale "${SCALE:-1}" || exit 1
		rm -f "$dump"
	fi
done
