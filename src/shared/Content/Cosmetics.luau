--[[
	Cosmetics: what a character can look like. The character creator shows each
	category in `order`; options are picked by id and saved with the life.

	Option fields:
		id, name                 required; ids are unique within a category
		color = { r, g, b }      skin and hair colors
		glow = 3                 locked until the player spends that much Glow
		record = "old_bones"     locked until the player has earned that Record
		store = "item_key"       sold in the store (Config.store.items); looks only
		daily = 7                unlocked by a 7-day login streak
	Skin tones are never locked.

	The shapes themselves (hair styles, outfit features, marks) are drawn by
	Engine/Avatar. A new option can reuse any existing `style`.
]]

return {
	order = { "skin", "hair", "hairColor", "outfit", "mark", "frame" },

	skin = {
		name = "Skin",
		options = {
			{ id = "porcelain", name = "Porcelain", color = { 247, 224, 205 } },
			{ id = "fair", name = "Fair", color = { 236, 204, 178 } },
			{ id = "sand", name = "Sand", color = { 222, 183, 150 } },
			{ id = "olive", name = "Olive", color = { 198, 158, 118 } },
			{ id = "amber", name = "Amber", color = { 176, 128, 88 } },
			{ id = "umber", name = "Umber", color = { 140, 96, 64 } },
			{ id = "deep", name = "Deep", color = { 106, 72, 50 } },
			{ id = "ebony", name = "Ebony", color = { 76, 52, 38 } },
		},
	},

	hair = {
		name = "Hair",
		options = {
			{ id = "crop", name = "Crop", style = "crop" },
			{ id = "shorn", name = "Shorn", style = "shorn" },
			{ id = "long", name = "Long", style = "long" },
			{ id = "bun", name = "Bun", style = "bun" },
			{ id = "braid", name = "Braid", style = "braid" },
			{ id = "curls", name = "Curls", style = "curls" },
			{ id = "ridge", name = "Ridge", style = "ridge", glow = 2 },
			{ id = "hood", name = "Wool Hood", style = "hood", glow = 3 },
			{ id = "captain", name = "Captain's Cap", style = "cap", record = "lantern_captain" },
			{ id = "veil", name = "Choir Veil", style = "veil", record = "still_voice" },
			{ id = "lamphat", name = "Lamplighter's Hat", style = "tophat", store = "hair_lamphat" },
		},
	},

	hairColor = {
		name = "Hair color",
		options = {
			{ id = "ink", name = "Ink", color = { 34, 30, 30 } },
			{ id = "umber", name = "Umber", color = { 72, 48, 34 } },
			{ id = "chestnut", name = "Chestnut", color = { 118, 70, 42 } },
			{ id = "rust", name = "Rust", color = { 156, 72, 40 } },
			{ id = "straw", name = "Straw", color = { 206, 170, 104 } },
			{ id = "ash", name = "Ash", color = { 150, 146, 140 } },
			{ id = "crimson", name = "Crimson", color = { 150, 34, 38 }, glow = 2 },
			{ id = "snow", name = "Snow", color = { 232, 230, 226 }, record = "old_bones" },
			{ id = "brine", name = "Brine", color = { 64, 150, 142 }, record = "gone_to_the_water" },
			{ id = "lantern", name = "Lantern Gold", color = { 214, 168, 72 }, store = "dye_lantern" },
			{ id = "tidesilver", name = "Tide Silver", color = { 188, 204, 212 }, store = "dye_tide" },
			{ id = "lamplit", name = "Lamplit", color = { 255, 196, 110 }, daily = 7 },
		},
	},

	outfit = {
		name = "Clothes",
		options = {
			{ id = "dockhand", name = "Dockhand", shirt = { 150, 62, 44 }, pants = { 92, 72, 54 }, shoes = { 40, 32, 28 }, belt = { 58, 42, 30 } },
			{ id = "slate", name = "Stairwell", shirt = { 92, 108, 126 }, pants = { 52, 56, 64 }, shoes = { 34, 32, 32 } },
			{ id = "market", name = "Market", shirt = { 176, 150, 98 }, pants = { 68, 78, 58 }, shoes = { 52, 40, 30 }, belt = { 90, 60, 36 } },
			{ id = "mender", name = "Mender", shirt = { 212, 206, 192 }, pants = { 66, 60, 54 }, shoes = { 44, 36, 30 }, apron = { 112, 78, 50 } },
			{ id = "clerk", name = "Clerk", shirt = { 226, 222, 214 }, pants = { 44, 46, 52 }, shoes = { 26, 24, 24 }, vest = { 58, 52, 50 }, tie = { 128, 36, 34 }, glow = 2 },
			{ id = "kin", name = "Kin Oilcloth", shirt = { 58, 96, 88 }, pants = { 46, 66, 62 }, shoes = { 30, 34, 32 }, belt = { 172, 150, 102 }, record = "elder_kin" },
			{ id = "choir", name = "Choir Robe", shirt = { 196, 208, 212 }, pants = { 196, 208, 212 }, shoes = { 120, 124, 128 }, robe = true, record = "still_voice" },
			{ id = "company", name = "Company Blues", shirt = { 36, 44, 70 }, pants = { 30, 34, 52 }, shoes = { 20, 20, 24 }, buttons = { 214, 172, 84 }, record = "director" },
			{ id = "diver", name = "Guild Diving Suit", shirt = { 70, 92, 96 }, pants = { 62, 80, 84 }, shoes = { 36, 40, 42 }, collar = { 196, 150, 70 }, record = "lantern_captain" },
			{ id = "midnight", name = "Midnight Diver", shirt = { 28, 34, 52 }, pants = { 22, 26, 40 }, shoes = { 16, 16, 20 }, collar = { 70, 160, 150 }, store = "outfit_midnight" },
			{ id = "rimward", name = "Rimward Finery", shirt = { 236, 226, 204 }, pants = { 70, 34, 40 }, shoes = { 40, 24, 24 }, vest = { 110, 32, 44 }, buttons = { 214, 172, 84 }, store = "outfit_rimward" },
			{ id = "gilded", name = "Gilded Coat", shirt = { 196, 152, 58 }, pants = { 58, 44, 30 }, shoes = { 30, 22, 16 }, buttons = { 255, 226, 140 }, collar = { 240, 200, 110 }, store = "pack_gilded" },
			{ id = "patron", name = "Patron's Purple", shirt = { 58, 34, 74 }, pants = { 34, 22, 44 }, shoes = { 20, 16, 24 }, collar = { 214, 172, 84 }, buttons = { 214, 172, 84 }, store = "pass_patron" },
		},
	},

	mark = {
		name = "Marks",
		options = {
			{ id = "none", name = "None" },
			{ id = "freckles", name = "Freckles" },
			{ id = "scar", name = "Old Scar" },
			{ id = "ink", name = "Ink Lines", glow = 1 },
			{ id = "patch", name = "Eye Patch", glow = 2 },
			{ id = "gilt", name = "Gilt Freckles", style = "freckles", color = { 214, 172, 84 }, store = "mark_gilt" },
		},
	},

	-- the color of your FILE card's corner brackets (not part of the figure)
	frame = {
		name = "File card",
		options = {
			{ id = "brass", name = "Brass", color = { 207, 163, 73 } },
			{ id = "crimson", name = "Crimson", color = { 196, 50, 42 }, store = "frame_crimson" },
			{ id = "brine", name = "Brine", color = { 96, 186, 178 }, store = "frame_brine" },
			{ id = "gold", name = "Gold", color = { 255, 214, 120 }, store = "pack_gilded" },
			{ id = "patron", name = "Patron", color = { 176, 128, 226 }, store = "pass_patron" },
		},
	},
}
