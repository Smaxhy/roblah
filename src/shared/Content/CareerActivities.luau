--[[
	Activities for specific careers (gated with when = { career = "..." }).
	Same format as pack.activities. Ids are prefixed act_tw_ / act_cond_.
		warden     act_tw_extra_shift (a clash), act_tw_keepers_book, act_tw_sit_umber
		           (needs tw_umber_bond from Events/Tidewell.luau). Between them, the extra
		           shift's win line and the keepers' book name the right way to tend all
		           eight Remnants.
		conductor  act_cond_night_run (a clash), act_cond_lost_property
]]

return {
	-- ── Tidewell Institute (warden) ─────────────────────────────────────────
	{
		id = "act_tw_extra_shift",
		category = "money",
		name = "Work an extra vault shift",
		desc = "Another eight hours on the night roster in the vaults under Glasswall. Double pay, if you come back up with your nerves.",
		minAge = 18,
		cooldown = 1,
		when = { career = "warden" },
		clash = { stat = "prudence", foe = "A long night in the vaults", coins = 1, base = 4, coinPower = 3 },
		win = {
			paycheck = 0.3,
			prudence = { 1, 2 },
			log = "You worked the extra night: a song for Lullay, old voices for Magpie, the cold sluice for Kettle and a kind word for Glim. You came up at dawn with double pay and your nerves where you left them.",
		},
		lose = {
			paycheck = 0.1,
			fortitude = { -3, 0 },
			sanity = { -6, -3 },
			condition = "night_terrors",
			log = "Around the fourth hour every vault went quiet at once and stayed quiet, and you spent the rest of the night with your back against a wall, listening. They paid you for the hours. You haven't slept right since.",
			cause = "Lost on a night shift in the vaults",
		},
	},
	{
		id = "act_tw_keepers_book",
		category = "self",
		name = "Read the keepers' book",
		desc = "Fifty years of notes on every Remnant in the vaults, in a dozen different hands, half of it underlined.",
		minAge = 18,
		cooldown = 1,
		when = { career = "warden" },
		result = {
			prudence = { 1, 3 },
			temperance = { 0, 1 },
			sanity = -1,
			log = "You read the keepers' book by a shaded lamp. The same rules are underlined in every hand: never a lamp for Umber, copy the Surveyor's maps, write down whatever the Tallyman counts, and never lift Thimble's jar. Some of the hands stop halfway down a page.",
		},
	},
	{
		id = "act_tw_sit_umber",
		category = "self",
		name = "Sit with Umber in the dark",
		desc = "Lamps out, back against the glass of the Dark Tank. It knows your footsteps now.",
		minAge = 18,
		cooldown = 1,
		when = { career = "warden", flags = { "tw_umber_bond" } },
		result = {
			prudence = 1,
			sanity = { 3, 5 },
			log = "You sat with your back to the Dark Tank's glass and every lamp out. Umber came up out of the black and leaned against the other side, and hummed until your bones buzzed and your head went quiet.",
		},
	},

	-- ── Undertow Line (conductor) ───────────────────────────────────────────
	{
		id = "act_cond_night_run",
		category = "money",
		name = "Take the night run",
		desc = "The last Undertow car through the drowned aqueducts, after midnight, when the strange passengers ride. Night pay is double.",
		minAge = 16,
		cooldown = 1,
		when = { career = "conductor" },
		clash = { stat = "justice", foe = "The night run", coins = 1, base = 5, coinPower = 3 },
		win = {
			paycheck = 0.3,
			justice = { 1, 2 },
			log = "You worked the night run end to end and punched every ticket, even the one printed in a year that hasn't happened yet. Night pay is double, and you earned it.",
		},
		lose = {
			fortitude = { -6, -2 },
			sanity = { -4, -2 },
			log = "The car lost its cable in the Long Tunnel, and you spent the small hours walking passengers along a flooded ledge by lamplight, one at a time.",
			cause = "Lost on the Undertow night run",
		},
	},
	{
		id = "act_cond_lost_property",
		category = "self",
		name = "Sort the lost property office",
		desc = "Three rooms under Platform Nine, forty years deep. Wet umbrellas, odd shoes, and things that tick. The Authority pays by the shelf.",
		minAge = 16,
		cooldown = 1,
		when = { career = "conductor" },
		result = {
			temperance = { 1, 2 },
			sanity = { 1, 2 },
			wage = { 4, 12 },
			log = "You sorted another shelf of lost property: nine umbrellas, all still wet, a hatbox that hummed, and a pair of spectacles that showed tomorrow's weather. The Authority paid by the shelf.",
		},
	},
}
